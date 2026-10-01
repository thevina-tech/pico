CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Unschedules old jobs if they exist to prevent duplicates
DO $$
BEGIN
  PERFORM cron.unschedule('sync-live-matches') 
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-live-matches');
  
  PERFORM cron.unschedule('sync-upcoming-matches') 
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-upcoming-matches');

  PERFORM cron.unschedule('sync-weekly-metadata') 
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-weekly-metadata');
END $$;

-- 1. Polling Live Scores (Every 5 minutes)
SELECT cron.schedule(
  'sync-live-matches',
  '*/5 * * * *',
  $$
    SELECT net.http_post(
      url := 'https://klvommgxwjallydbpksk.supabase.co/functions/v1/sync-matches?action=sync-live',
      headers := '{"x-pico-cron-secret": "YOUR_SECRET_HERE", "Content-Type": "application/json"}'::jsonb,
      body := '{}'::jsonb
    );
  $$
);

-- 2. Daily Upcoming Fixtures (Every day at 2:00 AM UTC)
SELECT cron.schedule(
  'sync-upcoming-matches',
  '0 2 * * *',
  $$
    SELECT net.http_post(
      url := 'https://klvommgxwjallydbpksk.supabase.co/functions/v1/sync-matches?action=sync-upcoming',
      headers := '{"x-pico-cron-secret": "YOUR_SECRET_HERE", "Content-Type": "application/json"}'::jsonb,
      body := '{}'::jsonb
    );
  $$
);

-- 3. Weekly Competitions & Teams Metadata (Every Monday at 3:00 AM UTC)
SELECT cron.schedule(
  'sync-weekly-metadata',
  '0 3 * * 1',
  $$
    SELECT net.http_post(
      url := 'https://klvommgxwjallydbpksk.supabase.co/functions/v1/sync-matches?action=sync-metadata',
      headers := '{"x-pico-cron-secret": "YOUR_SECRET_HERE", "Content-Type": "application/json"}'::jsonb,
      body := '{}'::jsonb
    );
  $$
);