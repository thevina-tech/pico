-- ==========================================
-- COMPOSITE INDEXES FOR MATCHES FEED OPTIMIZATION
-- ==========================================
-- Ensures lightning-fast time-bounded filtering by competition, status, and kickoff date
CREATE INDEX IF NOT EXISTS idx_matches_comp_status ON public.matches(competition_id, status);
CREATE INDEX IF NOT EXISTS idx_matches_comp_kickoff ON public.matches(competition_id, kickoff_at);
CREATE INDEX IF NOT EXISTS idx_matches_status_kickoff ON public.matches(status, kickoff_at);
