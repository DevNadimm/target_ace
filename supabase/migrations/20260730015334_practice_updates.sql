-- Create question_reports table
CREATE TABLE IF NOT EXISTS public.question_reports (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  report_text text NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'ignored')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.question_reports ENABLE ROW LEVEL SECURITY;

-- Create Policies
CREATE POLICY "Users can insert their own reports" 
ON public.question_reports 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own reports" 
ON public.question_reports 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all reports" 
ON public.question_reports 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true
  )
);

-- Update start_practice_session
CREATE OR REPLACE FUNCTION start_practice_session(
  p_user_id uuid,
  p_subject_id uuid,
  p_topic_id uuid DEFAULT NULL,
  p_limit int DEFAULT 20
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_topics json;
  v_bookmarks json;
  v_attempts json;
  v_questions json;
BEGIN
  -- Get topics
  SELECT coalesce(json_agg(t), '[]'::json) INTO v_topics
  FROM (
    SELECT * FROM topics 
    WHERE subject_id = p_subject_id 
    ORDER BY display_order ASC NULLS LAST
  ) t;

  -- Get bookmarked question IDs
  SELECT coalesce(json_agg(bq.question_id), '[]'::json) INTO v_bookmarks
  FROM bookmarked_questions bq
  WHERE bq.user_id = p_user_id;

  -- Get latest attempt for each question
  SELECT coalesce(json_agg(json_build_object(
    'question_id', sub.question_id,
    'is_correct', sub.is_correct
  )), '[]'::json) INTO v_attempts
  FROM (
    SELECT DISTINCT ON (question_id) question_id, is_correct
    FROM practice_attempts
    WHERE user_id = p_user_id AND subject_id = p_subject_id
    ORDER BY question_id, attempted_at DESC
  ) sub;

  -- Get questions
  SELECT coalesce(json_agg(q), '[]'::json) INTO v_questions
  FROM (
    SELECT * FROM questions 
    WHERE subject_id = p_subject_id 
      AND (p_topic_id IS NULL OR topic_id = p_topic_id)
    LIMIT p_limit
  ) q;

  RETURN json_build_object(
    'topics', v_topics,
    'bookmarked_ids', v_bookmarks,
    'previous_attempts', v_attempts,
    'attempted_ids', (SELECT coalesce(json_agg(question_id), '[]'::json) FROM (SELECT DISTINCT question_id FROM practice_attempts WHERE user_id = p_user_id AND subject_id = p_subject_id) a),
    'questions', v_questions
  );
END;
$$;
