-- ==============================================================================
-- Migration: Add Insert Policy on Profiles and Backfill Orphaned Auth Users
-- Allows authenticated users to insert/upsert their own profile row.
-- Backfills any auth.users that do not have a row in public.profiles.
-- ==============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' AND policyname = 'Users can insert own profile'
  ) THEN
    CREATE POLICY "Users can insert own profile" 
    ON public.profiles 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- Backfill any existing users in auth.users that lack a row in public.profiles
INSERT INTO public.profiles (id, email, avatar_url)
SELECT 
  id, 
  email, 
  COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'picture')
FROM auth.users
ON CONFLICT (id) DO NOTHING;
