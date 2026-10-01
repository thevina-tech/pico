-- ==============================================================================
-- Migration: Sprint 7 - Division Ladder & Tiered Scoring Engine
-- 1. Adds total_points (Prediction Points) to public.profiles.
-- 2. Creates immutable get_division_key function with threshold brackets.
-- 3. Adds current_division_key generated stored column.
-- 4. Updates settle_match() with Sprint 7 Tiered Scoring (5, 3, 1, 0) & total_points.
-- ==============================================================================

-- 1. Add total_points column to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS total_points int NOT NULL DEFAULT 0;

-- 2. Create immutable division calculation function
CREATE OR REPLACE FUNCTION public.get_division_key(p_points int)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_points >= 2000 THEN 'elite'
    WHEN p_points >= 1600 THEN 'div_1'
    WHEN p_points >= 1250 THEN 'div_2'
    WHEN p_points >= 950 THEN 'div_3'
    WHEN p_points >= 700 THEN 'div_4'
    WHEN p_points >= 500 THEN 'div_5'
    WHEN p_points >= 350 THEN 'div_6'
    WHEN p_points >= 220 THEN 'div_7'
    WHEN p_points >= 120 THEN 'div_8'
    WHEN p_points >= 50 THEN 'div_9'
    ELSE 'div_10'
  END;
$$;

-- 3. Add generated column for current_division_key
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'profiles' 
      AND column_name = 'current_division_key'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN current_division_key text 
    GENERATED ALWAYS AS (public.get_division_key(total_points)) STORED;
  END IF;
END $$;

-- 4. Set-based atomic settlement function (High-Volume Scaling via CTEs)
CREATE OR REPLACE FUNCTION public.settle_match(p_match_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_match record;
  v_actual_winner text;
  v_actual_gd int;
  v_settled_count int := 0;
BEGIN
  -- 1. Fetch target match and perform validation checks
  SELECT * INTO v_match FROM public.matches WHERE id = p_match_id;

  IF v_match IS NULL THEN
    RAISE EXCEPTION 'Target match % does not exist.', p_match_id;
  END IF;

  IF v_match.settled = true THEN
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Match already settled.',
      'settled_count', 0
    );
  END IF;

  IF v_match.home_score IS NULL OR v_match.away_score IS NULL THEN
    RAISE EXCEPTION 'Match % has not recorded final scores.', p_match_id;
  END IF;

  -- 2. Determine actual winner & goal difference
  IF v_match.home_score > v_match.away_score THEN
    v_actual_winner := 'home';
  ELSIF v_match.away_score > v_match.home_score THEN
    v_actual_winner := 'away';
  ELSE
    v_actual_winner := 'draw';
  END IF;

  v_actual_gd := v_match.home_score - v_match.away_score;

  -- 3. Pure Set-Based Atomic Settlement via Chained Common Table Expressions (CTEs)
  WITH calculated_scores AS (
    SELECT
      p.user_id,
      p.match_id,
      -- Sprint 7 Tiered Scoring Engine:
      -- 1) Exact score match: 5 PP
      -- 2) Correct outcome + Goal difference: 3 PP
      -- 3) Correct outcome only: 1 PP
      -- 4) Miss / Incorrect: 0 PP
      CASE
        WHEN p.home_score = m.home_score AND p.away_score = m.away_score THEN 5
        WHEN p.predicted_winner = v_actual_winner AND (p.home_score - p.away_score) = v_actual_gd THEN 3
        WHEN p.predicted_winner = v_actual_winner THEN 1
        ELSE 0
      END AS points,
      CASE
        WHEN p.home_score = m.home_score AND p.away_score = m.away_score THEN 'exact_score'
        WHEN p.predicted_winner = v_actual_winner AND (p.home_score - p.away_score) = v_actual_gd THEN 'outcome_and_goal_difference'
        WHEN p.predicted_winner = v_actual_winner THEN 'correct_outcome'
        ELSE 'wrong_prediction'
      END AS point_reason
    FROM public.predictions p
    JOIN public.matches m ON m.id = p.match_id
    WHERE p.match_id = p_match_id
  ),
  -- 4. Bulk insert the audit trail into pico_point_transactions
  ins_audit AS (
    INSERT INTO public.pico_point_transactions (user_id, match_id, points, reason)
    SELECT cs.user_id, p_match_id, cs.points, cs.point_reason
    FROM calculated_scores cs
    WHERE cs.points >= 0
    RETURNING 1
  ),
  -- 5. Bulk update profiles (Global Prediction Points / Division Progression)
  upd_profiles AS (
    UPDATE public.profiles pr
    SET total_points = pr.total_points + cs.points
    FROM calculated_scores cs
    WHERE pr.id = cs.user_id
      AND cs.points > 0
    RETURNING 1
  ),
  -- 6. Bulk update tournament participants (Public Tournament Scoped Points)
  upd_tournaments AS (
    UPDATE public.tournament_participants tp
    SET pico_points = tp.pico_points + cs.points
    FROM calculated_scores cs, public.tournaments t
    WHERE tp.tournament_id = t.id
      AND tp.user_id = cs.user_id
      AND t.competition_id = v_match.competition_id
      AND cs.points > 0
    RETURNING 1
  ),
  -- 7. Bulk update private league members (Private League Scoped Points)
  upd_private_leagues AS (
    UPDATE public.private_league_members plm
    SET pico_points = plm.pico_points + cs.points
    FROM calculated_scores cs
    WHERE plm.user_id = cs.user_id
      AND cs.points > 0
    RETURNING 1
  )
  SELECT count(*) INTO v_settled_count
  FROM calculated_scores;

  -- 8. Mark match settled and status as finished
  UPDATE public.matches
  SET settled = true,
      status = 'finished'
  WHERE id = p_match_id;

  RETURN jsonb_build_object(
    'success', true,
    'match_id', p_match_id,
    'settled_count', v_settled_count,
    'actual_winner', v_actual_winner,
    'final_score', v_match.home_score || '-' || v_match.away_score
  );
END;
$function$;
