-- Migration: Remove unused color_hex and icon_name columns from onboarding_goals and battle_groups
-- Created At: 2026-07-31

ALTER TABLE public.onboarding_goals DROP COLUMN IF EXISTS color_hex;
ALTER TABLE public.onboarding_goals DROP COLUMN IF EXISTS icon_name;
ALTER TABLE public.battle_groups DROP COLUMN IF EXISTS icon_name;
