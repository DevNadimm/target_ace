-- Add missing DELETE policy for notifications so users can delete their own notifications

DROP POLICY IF EXISTS "Allow user delete own notifications" ON public.notifications;
CREATE POLICY "Allow user delete own notifications" ON public.notifications 
    FOR DELETE TO authenticated USING (user_id = auth.uid());
