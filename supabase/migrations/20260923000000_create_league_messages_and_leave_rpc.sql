-- ==========================================
-- LEAGUE MESSAGES & REALTIME PRIVATE LEAGUE RPC
-- ==========================================

-- 1. Ensure admin_id column exists on private_leagues (matches owner_id)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'private_leagues' 
      AND column_name = 'admin_id'
  ) THEN
    ALTER TABLE public.private_leagues ADD COLUMN admin_id UUID REFERENCES public.profiles(id);
    UPDATE public.private_leagues SET admin_id = owner_id WHERE admin_id IS NULL;
  END IF;
END $$;

-- 2. Create league_messages table
CREATE TABLE IF NOT EXISTS public.league_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  league_id UUID NOT NULL REFERENCES public.private_leagues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for fast reverse-chronological chat query
CREATE INDEX IF NOT EXISTS idx_league_messages_league_created
  ON public.league_messages(league_id, created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.league_messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they already exist
DROP POLICY IF EXISTS "League members can read messages" ON public.league_messages;
DROP POLICY IF EXISTS "League members can insert messages" ON public.league_messages;

-- RLS: Members of the private league can read messages
CREATE POLICY "League members can read messages"
  ON public.league_messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.private_league_members
      WHERE private_league_members.private_league_id = league_messages.league_id
        AND private_league_members.user_id = auth.uid()
    )
  );

-- RLS: Members can send messages as themselves
CREATE POLICY "League members can insert messages"
  ON public.league_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM public.private_league_members
      WHERE private_league_members.private_league_id = league_messages.league_id
        AND private_league_members.user_id = auth.uid()
    )
  );

-- Enable Supabase Realtime for league_messages table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'league_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.league_messages;
  END IF;
END $$;

-- 3. RPC Function: leave_private_league(p_league_id UUID, p_user_id UUID)
-- Logic:
--   If the leaving user is admin_id (or owner_id), randomly select another active member
--   and promote them to admin_id/owner_id.
--   If no other members exist, delete the league.
--   Remove user from private_league_members and tournament_participants.
CREATE OR REPLACE FUNCTION public.leave_private_league(
  p_league_id UUID,
  p_user_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_admin_id uuid;
  v_new_admin_id uuid;
  v_remaining_members int;
BEGIN
  -- 1. Validate league exists and fetch current owner/admin
  SELECT COALESCE(admin_id, owner_id) INTO v_current_admin_id
  FROM public.private_leagues
  WHERE id = p_league_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'LEAGUE_NOT_FOUND';
  END IF;

  -- 2. If the user leaving is the current admin
  IF v_current_admin_id = p_user_id THEN
    -- Randomly select another user currently in the league
    SELECT user_id INTO v_new_admin_id
    FROM public.private_league_members
    WHERE private_league_id = p_league_id 
      AND user_id != p_user_id
    ORDER BY random()
    LIMIT 1;

    IF v_new_admin_id IS NOT NULL THEN
      -- Promote the randomly selected member to admin/owner
      UPDATE public.private_leagues
      SET owner_id = v_new_admin_id,
          admin_id = v_new_admin_id
      WHERE id = p_league_id;
    ELSE
      -- No other members remain, delete the league
      DELETE FROM public.private_leagues WHERE id = p_league_id;
    END IF;
  END IF;

  -- 3. Remove user from private_league_members
  DELETE FROM public.private_league_members
  WHERE private_league_id = p_league_id 
    AND user_id = p_user_id;

  -- 4. Remove user from tournament_participants for this league/tournament
  DELETE FROM public.tournament_participants
  WHERE tournament_id = p_league_id 
    AND user_id = p_user_id;

  -- 5. If the league has 0 members left and wasn't deleted yet, clean it up
  SELECT count(*) INTO v_remaining_members
  FROM public.private_league_members
  WHERE private_league_id = p_league_id;

  IF v_remaining_members = 0 THEN
    DELETE FROM public.private_leagues WHERE id = p_league_id;
  END IF;
END;
$$;

-- Overload for single-arg leave_private_league(p_league_id UUID) using auth.uid()
CREATE OR REPLACE FUNCTION public.leave_private_league(
  p_league_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM public.leave_private_league(p_league_id, auth.uid());
END;
$$;
