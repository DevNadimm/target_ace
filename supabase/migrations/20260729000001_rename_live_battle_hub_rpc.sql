-- Rename get_live_battle_hub_data to get_battle_arena_data RPC

CREATE OR REPLACE FUNCTION public.get_battle_arena_data(
    p_user_id UUID,
    p_group_id TEXT
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    v_active_exam JSONB := NULL;
    v_has_submitted_active BOOLEAN := FALSE;
    v_active_exam_id UUID := NULL;
    
    v_upcoming_exams JSONB := '[]'::jsonb;
    v_recent_history JSONB := '[]'::jsonb;
    
    rec_active RECORD;
BEGIN
    -- 1. Resolve Active Exam (Next unended exam)
    SELECT * INTO rec_active
    FROM public.exams
    WHERE group_id = p_group_id
      AND (start_time + (COALESCE(duration_minutes, 30) || ' minutes')::interval) > NOW()
    ORDER BY start_time ASC
    LIMIT 1;

    -- Fallback to the most recent completed exam if no unended exams exist
    IF rec_active.id IS NULL THEN
        SELECT * INTO rec_active
        FROM public.exams
        WHERE group_id = p_group_id
        ORDER BY start_time DESC
        LIMIT 1;
    END IF;

    IF rec_active.id IS NOT NULL THEN
        v_active_exam_id := rec_active.id;
        v_active_exam := jsonb_build_object(
            'id', rec_active.id,
            'title', rec_active.title,
            'goal_id', rec_active.goal_id,
            'group_id', rec_active.group_id,
            'start_time', rec_active.start_time,
            'duration_minutes', rec_active.duration_minutes,
            'total_questions', rec_active.total_questions,
            'status', rec_active.status,
            'per_question_mark', rec_active.per_question_mark,
            'negative_mark', rec_active.negative_mark,
            'exam_date', rec_active.exam_date,
            'exam_type', rec_active.exam_type
        );

        IF p_user_id IS NOT NULL THEN
            SELECT EXISTS(
                SELECT 1 FROM public.exam_submissions
                WHERE exam_id = rec_active.id AND user_id = p_user_id
            ) INTO v_has_submitted_active;
        END IF;
    END IF;

    -- 2. Resolve Upcoming Scheduled Battles (Excluding the Active Exam)
    SELECT COALESCE(jsonb_agg(to_jsonb(e.*)), '[]'::jsonb) INTO v_upcoming_exams
    FROM (
        SELECT 
            id, title, goal_id, group_id, start_time, duration_minutes,
            total_questions, status, per_question_mark, negative_mark,
            exam_date, exam_type, created_at, reminder_sent
        FROM public.exams
        WHERE group_id = p_group_id
          AND (v_active_exam_id IS NULL OR id != v_active_exam_id)
          AND start_time > NOW()
        ORDER BY start_time ASC
        LIMIT 10
    ) e;

    -- 3. Resolve Recent 5 Exam History
    IF p_user_id IS NOT NULL THEN
        SELECT COALESCE(jsonb_agg(to_jsonb(h.*)), '[]'::jsonb) INTO v_recent_history
        FROM (
            SELECT 
                es.id,
                es.exam_id,
                e.title AS exam_title,
                COALESCE(es.completed_at, es.submitted_at) AS completed_at,
                ROUND(es.score, 2) AS score,
                es.unanswered_count,
                COALESCE(es.time_taken_seconds, 0) AS time_taken_seconds,
                COALESCE(
                    (
                        SELECT rank FROM public.leaderboards 
                        WHERE exam_id = es.exam_id AND user_id = p_user_id AND rank > 0
                    ),
                    (
                        SELECT (COUNT(*) + 1)::INT 
                        FROM public.exam_submissions es2 
                        WHERE es2.exam_id = es.exam_id AND es2.score > es.score
                    ),
                    1
                ) AS rank,
                (
                    SELECT COUNT(*)::INT 
                    FROM public.exam_submissions es3 
                    WHERE es3.exam_id = es.exam_id
                ) AS total_participants
            FROM public.exam_submissions es
            JOIN public.exams e ON e.id = es.exam_id
            WHERE es.user_id = p_user_id
            ORDER BY COALESCE(es.completed_at, es.submitted_at) DESC
            LIMIT 5
        ) h;
    END IF;

    -- Build Final Combined Payload
    result := jsonb_build_object(
        'active_exam', v_active_exam,
        'has_submitted_active', v_has_submitted_active,
        'upcoming_exams', v_upcoming_exams,
        'recent_history', v_recent_history
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the old function
DROP FUNCTION IF EXISTS public.get_live_battle_hub_data(UUID, TEXT);
