ALTER TABLE public.questions 
  DROP COLUMN IF EXISTS difficulty,
  ADD COLUMN IF NOT EXISTS image_url text NULL;
