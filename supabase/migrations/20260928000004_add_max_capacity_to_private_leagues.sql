-- Migration: Add max_capacity to private_leagues and update join_private_league RPC
-- Task: 25-Member Cap for Private Leagues

-- 1. Add max_capacity column to private_leagues
ALTER TABLE public.private_leagues
ADD COLUMN IF NOT EXISTS max_capacity int NOT NULL DEFAULT 25;

-- 2. Drop existing join_private_league to ensure clean signature replacement
DROP FUNCTION IF EXISTS public.join_private_league(text, uuid);
DROP FUNCTION IF EXISTS public.join_private_league(text, uuid, uuid);

-- 3. Create or replace join_private_league RPC with capacity check
CREATE OR REPLACE FUNCTION public.join_private_league(
  p_invite_code text DEFAULT NULL,
  p_user_id uuid DEFAULT auth.uid(),
  p_league_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_league public.private_leagues%ROWTYPE;
  v_clean_code text;
  v_member_count int;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required to join a private league.';
  END IF;

  IF p_league_id IS NOT NULL THEN
    SELECT * INTO v_league
    FROM public.private_leagues
    WHERE id = p_league_id;
  ELSIF p_invite_code IS NOT NULL THEN
    v_clean_code := upper(trim(p_invite_code));
    SELECT * INTO v_league
    FROM public.private_leagues
    WHERE invite_code = v_clean_code;
  ELSE
    RAISE EXCEPTION 'Either invite code or league ID must be provided.';
  END IF;

  IF NOT FOUND OR v_league.id IS NULL THEN
    RAISE EXCEPTION 'LEAGUE_NOT_FOUND';
  END IF;

  -- 1. If user is the creator/owner
  IF v_league.owner_id = p_user_id THEN
    RAISE EXCEPTION 'CREATOR_CANNOT_REJOIN';
  END IF;

  -- 2. If user is already a member
  IF EXISTS (
    SELECT 1 FROM public.private_league_members
    WHERE private_league_id = v_league.id AND user_id = p_user_id
  ) THEN
    RAISE EXCEPTION 'ALREADY_MEMBER';
  END IF;

  -- 3. Check 25-member capacity
  SELECT COUNT(*) INTO v_member_count
  FROM public.private_league_members
  WHERE private_league_id = v_league.id;

  IF v_member_count >= v_league.max_capacity THEN
    RAISE EXCEPTION 'This league has reached its maximum capacity.';
  END IF;

  -- 4. Insert member
  INSERT INTO public.private_league_members (private_league_id, user_id, pico_points, joined_at)
  VALUES (v_league.id, p_user_id, 0, now());

  RETURN jsonb_build_object(
    'id', v_league.id,
    'name', v_league.name,
    'owner_id', v_league.owner_id,
    'competition_id', v_league.competition_id,
    'invite_code', v_league.invite_code,
    'created_at', v_league.created_at,
    'max_capacity', v_league.max_capacity
  );
END;
$function$;
