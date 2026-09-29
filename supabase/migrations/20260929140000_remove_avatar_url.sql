-- ==============================================================================
-- Migration: Remove Avatar URL from Profiles & Handle New User Trigger
-- Users' avatars from Google are not collected or stored.
-- ==============================================================================

-- 1. Update handle_new_user() trigger function to omit avatar_url
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username)
  VALUES (
    NEW.id,
    NEW.email,
    NULL
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 2. Drop avatar_url column from public.profiles
ALTER TABLE public.profiles DROP COLUMN IF EXISTS avatar_url;
