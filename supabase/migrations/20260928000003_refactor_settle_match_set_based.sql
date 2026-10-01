-- ==============================================================================
-- Migration: Refactor settle_match for High-Volume Scaling (Set-Based SQL)
-- 1. Eliminates row-by-row procedural FOR loop to prevent row-lock contention.
-- 2. Uses Common Table Expressions (CTEs) to join predictions with match result.
-- 3. Performs bulk INSERT into pico_point_transactions audit ledger.
-- 4. Performs atomic set-based bulk UPDATE on profiles.total_points,
--    tournament_participants.pico_points, and private_league_members.pico_points.
-- ==============================================================================

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
