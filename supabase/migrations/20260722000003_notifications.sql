-- Phase 2.6 Migration: Notifications Table, Indexes & RLS Policies

-- 1. Create Notifications Table
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

-- 2. Index for fast lookup of unread notifications by user
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read);

-- 3. Row Level Security Configuration
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
DROP POLICY IF EXISTS "Allow user read own notifications" ON public.notifications;
CREATE POLICY "Allow user read own notifications" ON public.notifications 
    FOR SELECT TO authenticated USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "Allow user update read status" ON public.notifications;
CREATE POLICY "Allow user update read status" ON public.notifications 
    FOR UPDATE TO authenticated USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Allow admin create notifications" ON public.notifications;
CREATE POLICY "Allow admin create notifications" ON public.notifications 
    FOR INSERT TO authenticated WITH CHECK (public.is_admin());
