# TargetAce DB Architecture Specification — Phase 3: AI-Ready Engine & Adaptive Learning

**Document Version:** 1.0  
**Phase:** 3 (Scale & AI Priority)  
**Module:** Database Architecture  
**Status:** Proposed  

---

## 1. Executive Summary

Phase 3 introduces **AI-ready Question Metadata**, **Topic Mastery Tracking**, and **Smart Adaptive Exam Generation**. This phase transforms TargetAce into an intelligent competitive exam platform capable of auto-generating exams and personalizing recommendations based on weak topics.

---

## 2. Target Schema Changes

### 2.1 `questions` Table AI Extensions
Extends the questions table with rich metadata for AI validation, quality scoring, and attribution.

```sql
ALTER TABLE public.questions
ADD COLUMN IF NOT EXISTS ai_generated BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS source TEXT, -- e.g. '38th BCS', 'DU 2023'
ADD COLUMN IF NOT EXISTS reference TEXT, -- Textbook or citation
ADD COLUMN IF NOT EXISTS estimated_time_seconds INT DEFAULT 45,
ADD COLUMN IF NOT EXISTS quality_score NUMERIC(3,2) DEFAULT 5.00 CHECK (quality_score BETWEEN 0.00 AND 5.00),
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;
```

---

### 2.2 New Table: `user_topic_mastery`
Tracks individual user proficiency per topic to power weak-topic detection and personalized AI recommendations.

```sql
CREATE TABLE IF NOT EXISTS public.user_topic_mastery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    total_attempted INT NOT NULL DEFAULT 0,
    correct_count INT NOT NULL DEFAULT 0,
    mastery_percentage NUMERIC(5,2) GENERATED ALWAYS AS (
        CASE WHEN total_attempted > 0 THEN (correct_count::numeric / total_attempted::numeric) * 100.0 ELSE 0.0 END
    ) STORED,
    last_practiced_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_topic_mastery UNIQUE (user_id, topic_id)
);

-- RLS
ALTER TABLE public.user_topic_mastery ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow user read own topic mastery" ON public.user_topic_mastery FOR SELECT TO authenticated USING (user_id = auth.uid() OR public.is_admin());

CREATE INDEX IF NOT EXISTS idx_user_topic_mastery_weak ON public.user_topic_mastery(user_id, mastery_percentage ASC);
```

---

### 2.3 Postgres RPC Function: AI Smart Exam Generator
Custom Postgres function to pick questions dynamically based on specified subject distribution and difficulty balance.

```sql
CREATE OR REPLACE FUNCTION public.generate_ai_custom_exam(
    p_subject_id UUID,
    p_question_count INT DEFAULT 20,
    p_min_difficulty INT DEFAULT 1,
    p_max_difficulty INT DEFAULT 5
)
RETURNS TABLE (
    question_id UUID,
    question_text TEXT,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    difficulty_level INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id,
        q.question_text,
        q.option_a,
        q.option_b,
        q.option_c,
        q.option_d,
        q.difficulty_level
    FROM public.questions q
    WHERE q.subject_id = p_subject_id
      AND q.difficulty_level BETWEEN p_min_difficulty AND p_max_difficulty
    ORDER BY RANDOM()
    LIMIT p_question_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 3. Expected Benefits

- **Automated AI Question Generation**: Store and audit AI-generated questions safely.
- **Weak Topic Detection**: Identify exact chapters where a student struggles and serve tailored practice tests.
- **Adaptive Difficulty Engine**: Dynamically pick questions suited to the student's mastery level.
