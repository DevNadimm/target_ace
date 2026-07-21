-- Phase 1 Migration: Core Educational Hierarchy (Subjects & Topics) & Subscription Plans

-- 1. Create Subjects Table
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id TEXT NOT NULL REFERENCES public.onboarding_goals(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT DEFAULT 'book',
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Subjects
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read subjects for authenticated" ON public.subjects FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Allow admin manage subjects" ON public.subjects FOR ALL TO authenticated USING (public.is_admin());

-- 2. Create Topics Table
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Topics
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read topics for authenticated" ON public.topics FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Allow admin manage topics" ON public.topics FOR ALL TO authenticated USING (public.is_admin());

-- 3. Expand Questions Table
ALTER TABLE public.questions 
ADD COLUMN IF NOT EXISTS subject_id UUID REFERENCES public.subjects(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS difficulty_level INT DEFAULT 2 CHECK (difficulty_level BETWEEN 1 AND 5);

CREATE INDEX IF NOT EXISTS idx_questions_subject ON public.questions(subject_id);
CREATE INDEX IF NOT EXISTS idx_questions_topic ON public.questions(topic_id);

-- 4. Expand Exams Table
ALTER TABLE public.exams 
ADD COLUMN IF NOT EXISTS exam_type TEXT DEFAULT 'live' CHECK (exam_type IN ('live', 'daily', 'practice', 'mock', 'premium', 'custom'));

CREATE INDEX IF NOT EXISTS idx_exams_type ON public.exams(exam_type);

-- 5. Create Plans Table
CREATE TABLE IF NOT EXISTS public.plans (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    duration_days INT NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Plans
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read active plans for authenticated" ON public.plans FOR SELECT TO authenticated USING (is_active = TRUE OR public.is_admin());
CREATE POLICY "Allow admin manage plans" ON public.plans FOR ALL TO authenticated USING (public.is_admin());

-- 6. Seed Default Subjects for Existing Goals
INSERT INTO public.subjects (goal_id, name, description, icon_name, display_order)
VALUES 
    ('bcs', 'Bangla Language & Literature', 'Bangla Grammar, Literature and Vocabulary', 'menu_book', 1),
    ('bcs', 'English Language & Literature', 'English Grammar, Composition & Literature', 'translate', 2),
    ('bcs', 'Bangladesh Affairs', 'History, Constitution, Economy & Geography of BD', 'flag', 3),
    ('bcs', 'International Affairs', 'Global Relations, International Organizations', 'public', 4),
    ('bcs', 'Mathematical Reasoning & Mental Ability', 'General Math, Logic & Spatial Reasoning', 'calculate', 5),
    ('bcs', 'General Science & Computer/ICT', 'Basic Science, Information & Tech', 'memory', 6),

    ('admission', 'Bangla', 'HSC Bangla First & Second Paper', 'menu_book', 1),
    ('admission', 'English', 'HSC English Grammar & Vocabulary', 'translate', 2),
    ('admission', 'General Knowledge', 'Current Affairs & Basic GK', 'lightbulb', 3),
    ('admission', 'Physics & Chemistry', 'Science Unit Specialization', 'science', 4)
ON CONFLICT DO NOTHING;

-- 7. Seed Initial Plans
INSERT INTO public.plans (id, name, duration_days, price, features, is_active)
VALUES
    ('starter', 'Starter Plan', 30, 199.00, '["Access to Live Battle Exams", "Basic Performance Analytics"]'::jsonb, TRUE),
    ('pro', 'Pro Monthly', 30, 399.00, '["Access to Live Battle Exams", "Subject-wise Practice", "Detailed Performance Analytics", "Priority Support"]'::jsonb, TRUE),
    ('yearly', 'Yearly Pass', 365, 1999.00, '["All Pro Features", "Unlimited Subject Practice", "AI Exam Recommendations", "Exclusive Badges"]'::jsonb, TRUE)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    duration_days = EXCLUDED.duration_days,
    price = EXCLUDED.price,
    features = EXCLUDED.features;
