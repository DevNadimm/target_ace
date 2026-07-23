-- Phase 2.5 Migration: User Device Tokens Storage & Old Token Pruning

-- 1. Create User Device Tokens Table
CREATE TABLE IF NOT EXISTS public.user_device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_device_token UNIQUE (user_id, device_token)
);

-- 2. Index for fast search by user
CREATE INDEX IF NOT EXISTS idx_user_device_tokens_user ON public.user_device_tokens(user_id);

-- 3. Row Level Security Policies
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read own tokens" ON public.user_device_tokens 
    FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "Allow insert own tokens" ON public.user_device_tokens 
    FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Allow update own tokens" ON public.user_device_tokens 
    FOR UPDATE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "Allow delete own tokens" ON public.user_device_tokens 
    FOR DELETE TO authenticated USING (user_id = auth.uid());

-- 4. Trigger Function to Enforce Max 2 Tokens per User (pruning oldest)
CREATE OR REPLACE FUNCTION public.clean_old_device_tokens()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.user_device_tokens
    WHERE user_id = NEW.user_id
      AND id NOT IN (
          SELECT id 
          FROM public.user_device_tokens 
          WHERE user_id = NEW.user_id 
          ORDER BY last_seen_at DESC 
          LIMIT 2
      );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Trigger Bind
DROP TRIGGER IF EXISTS on_device_token_inserted ON public.user_device_tokens;

CREATE TRIGGER on_device_token_inserted
    AFTER INSERT OR UPDATE OF last_seen_at ON public.user_device_tokens
    FOR EACH ROW EXECUTE FUNCTION public.clean_old_device_tokens();
