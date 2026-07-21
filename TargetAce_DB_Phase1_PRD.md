# TargetAce DB Architecture Specification — Phase 1: Core Hierarchy & Plans

**Document Version:** 1.0  
**Phase:** 1 (Immediate / Pre-Launch Priority)  
**Module:** Database Architecture  
**Status:** Ready for Implementation  

---

## 1. Executive Summary

Phase 1 focuses on introducing essential **educational hierarchy** (`Subject ➔ Topic ➔ Question`) and **subscription plan normalization**. These changes are critical for subject-wise practice, chapter-wise practice, and flexible pricing before the public launch.

---

## 2. Target Schema Changes

### 2.1 New Table: `subjects`
Represents core subjects under an onboarding goal (e.g. BCS ➔ Bangla, English, Math, ICT).

```sql
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id TEXT NOT NULL REFERENCES public.onboarding_goals(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT DEFAULT 'book',
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read subjects" ON public.subjects FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Allow admin manage subjects" ON public.subjects FOR ALL TO authenticated USING (public.is_admin());
```

---

### 2.2 New Table: `topics`
Represents chapters/topics under a specific subject (e.g. BCS English ➔ Parts of Speech, Tense).

```sql
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read topics" ON public.topics FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Allow admin manage topics" ON public.topics FOR ALL TO authenticated USING (public.is_admin());
```

---

### 2.3 `questions` Table Expansion
Adds direct links to `subject_id` and `topic_id`, and standardizes `difficulty_level`.

```sql
ALTER TABLE public.questions 
ADD COLUMN IF NOT EXISTS subject_id UUID REFERENCES public.subjects(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS difficulty_level INT DEFAULT 2 CHECK (difficulty_level BETWEEN 1 AND 5);

CREATE INDEX IF NOT EXISTS idx_questions_subject ON public.questions(subject_id);
CREATE INDEX IF NOT EXISTS idx_questions_topic ON public.questions(topic_id);
```

---

### 2.4 `exams` Table Expansion
Adds `exam_type` classification for filtering exam categories.

```sql
ALTER TABLE public.exams 
ADD COLUMN IF NOT EXISTS exam_type TEXT DEFAULT 'live' CHECK (exam_type IN ('live', 'daily', 'practice', 'mock', 'premium', 'custom'));

CREATE INDEX IF NOT EXISTS idx_exams_type ON public.exams(exam_type);
```

---

### 2.5 New Table: `plans`
Normalizes subscription pricing and feature definitions.

```sql
CREATE TABLE IF NOT EXISTS public.plans (
    id TEXT PRIMARY KEY, -- 'starter', 'pro', 'yearly'
    name TEXT NOT NULL,
    duration_days INT NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read active plans" ON public.plans FOR SELECT TO authenticated USING (is_active = TRUE OR public.is_admin());
CREATE POLICY "Allow admin manage plans" ON public.plans FOR ALL TO authenticated USING (public.is_admin());
```

---

## 3. Migration & Backfill Strategy

To prevent breaking existing DB records (142 questions and 5 exams):
1. All foreign keys (`subject_id`, `topic_id`) are initialized as `NULLABLE`.
2. A default set of `subjects` and `topics` will be inserted for existing goals.
3. Existing `questions` will be backfilled with appropriate `subject_id`s based on their `group_id`.

---

## 4. Flutter App Impact

- **Models**: Update `Question` model to include `subjectId`, `topicId`, and `difficultyLevel`. Update `Exam` model to include `examType`.
- **Repositories**: Update `BattleRepository` and question fetching queries to support filtering by `subject_id` and `topic_id`.
- **UI**: Enables Subject-wise and Chapter-wise practice screens.
