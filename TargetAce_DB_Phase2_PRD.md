# TargetAce DB Architecture Specification — Phase 2: Performance Scaling, Anti-Cheat & Notifications

**Document Version:** 1.0  
**Phase:** 2 (Growth Priority)  
**Module:** Database Architecture  
**Status:** Proposed  

---

## 1. Executive Summary

Phase 2 introduces **real-time scalability, performance optimization, user engagement notifications**, and **anti-cheat submission metadata**. This phase ensures sub-100ms response times for concurrent exam leaderboards and robust user activity tracking as traffic grows.

---

## 2. Target Schema Changes

### 2.1 New Table: `notifications`
Supports targeted announcements, exam battle alerts, and streak reminders.

```sql
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'general' CHECK (type IN ('general', 'exam_reminder', 'battle_invite', 'streak_alert', 'subscription')),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow user read own notifications" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Allow user update read status" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "Allow admin create notifications" ON public.notifications FOR INSERT TO authenticated WITH CHECK (public.is_admin());

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read);
```

---

### 2.2 New Table: `leaderboards` (Leaderboard Cache)
Pre-calculated cache table for high-concurrency exam rankings, eliminating dynamic full-table aggregation on live submissions.

```sql
CREATE TABLE IF NOT EXISTS public.leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    score NUMERIC(5,2) NOT NULL DEFAULT 0.0,
    time_taken_seconds INT NOT NULL DEFAULT 0,
    rank INT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_exam_user_leaderboard UNIQUE (exam_id, user_id)
);

-- RLS
ALTER TABLE public.leaderboards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read leaderboards for authenticated" ON public.leaderboards FOR SELECT TO authenticated USING (TRUE);

CREATE INDEX IF NOT EXISTS idx_leaderboards_rank ON public.leaderboards(exam_id, rank ASC);
```

---

### 2.3 `exam_submissions` Metadata Expansion
Enhanced fields for anti-cheat verification, crash recovery, and detailed exam analytics.

```sql
ALTER TABLE public.exam_submissions
ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS time_taken_seconds INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS device_info JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS app_version TEXT,
ADD COLUMN IF NOT EXISTS ip_address TEXT,
ADD COLUMN IF NOT EXISTS is_auto_submitted BOOLEAN DEFAULT FALSE;
```

---

### 2.4 Automatic Leaderboard Update Trigger
Database function to recalculate ranks asynchronously or upon submission insertion.

```sql
CREATE OR REPLACE FUNCTION public.sync_exam_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.leaderboards (exam_id, user_id, score, time_taken_seconds, rank, updated_at)
    VALUES (
        NEW.exam_id,
        NEW.user_id,
        NEW.score,
        COALESCE(NEW.time_taken_seconds, 0),
        0, -- Rank can be updated via background worker or cron
        NOW()
    )
    ON CONFLICT (exam_id, user_id) DO UPDATE SET
        score = EXCLUDED.score,
        time_taken_seconds = EXCLUDED.time_taken_seconds,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_submission_leaderboard_sync
    AFTER INSERT OR UPDATE OF score ON public.exam_submissions
    FOR EACH ROW EXECUTE FUNCTION public.sync_exam_leaderboard();
```

---

## 3. Expected Benefits

- **Leaderboard Performance**: Sub-100ms load time for tens of thousands of simultaneous users.
- **Anti-Cheat & Security**: IP and device tracking detects multi-device submission attempts.
- **Engagement**: In-app notifications drive daily battle retention.
