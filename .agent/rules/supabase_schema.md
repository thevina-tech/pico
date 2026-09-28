---
trigger: always_on
---

-- ==========================================
-- 1. EXTENSIONS & ENUMS
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE match_status AS ENUM ('upcoming', 'live', 'finished', 'postponed', 'cancelled');

-- ==========================================
-- 2. PROFILES & AUTHENTICATION
-- ==========================================
CREATE TABLE public.profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email text,
  username text UNIQUE,
  avatar_url text,
  level int NOT NULL DEFAULT 1,
  xp int NOT NULL DEFAULT 0,
  streak int NOT NULL DEFAULT 0,
  coins int NOT NULL DEFAULT 0, 
  private_leagues_created int NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Trigger: Auto-create profile on ANY signup (including Anonymous)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NULL, -- Custom username must be explicitly chosen by the user during onboarding
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 3. FOOTBALL DATA ENTITIES (NORMALIZED)[cite: 5]
-- ==========================================
CREATE TABLE public.competitions (
  id text PRIMARY KEY,
  name text NOT NULL,
  emblem_url text
);

CREATE TABLE public.teams (
  id text PRIMARY KEY,
  name text NOT NULL,
  short_name text,
  crest_url text
);

CREATE TABLE public.matches (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_match_id text UNIQUE NOT NULL,
  competition_id text REFERENCES public.competitions(id) ON DELETE CASCADE,
  home_team_id text REFERENCES public.teams(id) ON DELETE CASCADE,
  away_team_id text REFERENCES public.teams(id) ON DELETE CASCADE,
  kickoff_at timestamptz NOT NULL,
  status match_status DEFAULT 'upcoming',
  home_score int DEFAULT null,
  away_score int DEFAULT null,
  settled boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- ==========================================
-- 4. TOURNAMENTS & PRIVATE LEAGUES (SCOPED POINTS)
-- ==========================================
-- Public Tournaments (e.g., Global Premier League)
CREATE TABLE public.tournaments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  competition_id text REFERENCES public.competitions(id) ON DELETE CASCADE,
  start_date timestamptz,
  end_date timestamptz
);

CREATE TABLE public.tournament_participants (
  tournament_id uuid REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  pico_points int NOT NULL DEFAULT 0, -- TOURNAMENT-SPECIFIC POINTS
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (tournament_id, user_id)
);

-- Private Leagues
CREATE TABLE public.private_leagues (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  invite_code text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.private_league_members (
  league_id uuid REFERENCES public.private_leagues(id) ON DELETE CASCADE,
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  pico_points int NOT NULL DEFAULT 0, -- LEAGUE-SPECIFIC POINTS
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (league_id, user_id)
);

-- ==========================================
-- 5. PREDICTIONS & SECURITY CONSTRAINTS
-- ==========================================
CREATE TABLE public.predictions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  match_id uuid REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
  home_score int NOT NULL,
  away_score int NOT NULL,
  predicted_winner text NOT NULL CHECK (predicted_winner IN ('home', 'away', 'draw')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, match_id)
);

-- Trigger: Enforce Zero-Client Trust Prediction Window (Locks 10 Mins Before Kickoff)[cite: 5]
CREATE OR REPLACE FUNCTION public.check_prediction_window()
RETURNS trigger AS $$
DECLARE
  v_kickoff timestamptz;
BEGIN
  SELECT kickoff_at INTO v_kickoff FROM public.matches WHERE id = NEW.match_id;
  
  IF v_kickoff IS NULL THEN
    RAISE EXCEPTION 'Target match does not exist.';
  END IF;

  IF now() >= (v_kickoff - interval '10 minutes') THEN
    RAISE EXCEPTION 'Predictions lock exactly 10 minutes before scheduled kickoff.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_prediction_window
  BEFORE INSERT OR UPDATE ON public.predictions
  FOR EACH ROW EXECUTE PROCEDURE public.check_prediction_window();

-- ==========================================
-- 6. AUDIT TRAIL / TRANSACTION LEDGERS[cite: 5]
-- ==========================================
CREATE TABLE public.pico_point_transactions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  match_id uuid REFERENCES public.matches(id),
  points int NOT NULL,
  reason text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.xp_transactions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  match_id uuid REFERENCES public.matches(id),
  xp_amount int NOT NULL,
  action text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.coin_transactions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  coin_amount int NOT NULL,
  reason text NOT NULL,
  created_at timestamptz DEFAULT now()
);