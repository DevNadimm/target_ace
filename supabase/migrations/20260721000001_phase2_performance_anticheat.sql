-- Phase 2 Migration: Performance Scaling & Anti-Cheat Metadata

-- 1. Create Leaderboards Cache Table
CREATE TABLE IF NOT EXISTS public.leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    score NUMERIC(5,2) NOT NULL DEFAULT 0.0,
    time_taken_seconds INT NOT NULL DEFAULT 0,
    rank INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_exam_user_leaderboard UNIQUE (exam_id, user_id)
);

-- RLS for Leaderboards Cache
ALTER TABLE public.leaderboards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read leaderboards for authenticated" ON public.leaderboards FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Allow system/admin manage leaderboards" ON public.leaderboards FOR ALL TO authenticated USING (TRUE);

CREATE INDEX IF NOT EXISTS idx_leaderboards_rank ON public.leaderboards(exam_id, rank ASC);
CREATE INDEX IF NOT EXISTS idx_leaderboards_user ON public.leaderboards(user_id);

-- 2. Expand exam_submissions Table for Anti-Cheat & Analytics
ALTER TABLE public.exam_submissions
ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS time_taken_seconds INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS device_info JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS app_version TEXT,
ADD COLUMN IF NOT EXISTS ip_address TEXT,
ADD COLUMN IF NOT EXISTS is_auto_submitted BOOLEAN DEFAULT FALSE;

-- 3. Automatic Leaderboard Cache Sync Trigger
CREATE OR REPLACE FUNCTION public.sync_exam_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.leaderboards (exam_id, user_id, score, time_taken_seconds, rank, updated_at)
    VALUES (
        NEW.exam_id,
        NEW.user_id,
        NEW.score,
        COALESCE(NEW.time_taken_seconds, 0),
        0,
        NOW()
    )
    ON CONFLICT (exam_id, user_id) DO UPDATE SET
        score = EXCLUDED.score,
        time_taken_seconds = EXCLUDED.time_taken_seconds,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_submission_leaderboard_sync ON public.exam_submissions;

CREATE TRIGGER on_submission_leaderboard_sync
    AFTER INSERT OR UPDATE OF score ON public.exam_submissions
    FOR EACH ROW EXECUTE FUNCTION public.sync_exam_leaderboard();

-- Backfill initial leaderboards cache from existing submissions
INSERT INTO public.leaderboards (exam_id, user_id, score, time_taken_seconds, rank, updated_at)
SELECT 
    exam_id,
    user_id,
    score,
    COALESCE(time_taken_seconds, 0),
    0,
    submitted_at
FROM public.exam_submissions
ON CONFLICT (exam_id, user_id) DO UPDATE SET
    score = EXCLUDED.score,
    time_taken_seconds = EXCLUDED.time_taken_seconds,
    updated_at = EXCLUDED.updated_at;
