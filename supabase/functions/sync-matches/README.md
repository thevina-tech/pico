# Supabase Edge Function: `sync-matches`

This edge function is responsible for ingesting football data from the **BeSoccer API Level 1** directly into Supabase PostgreSQL tables according to the normalized schema in `supabase_schema.md`.

## Zero Client Trust Architecture
- The Flutter client **NEVER** calls BeSoccer directly.
- The client reads exclusively from Supabase tables (`competitions`, `teams`, `matches`).
- Image URLs are stripped of query parameters like `&v=` prior to storage.

## Level 1 Endpoints Implemented
1. **Endpoint 5 (`req=competitions`)**: Syncs top competitions into `public.competitions`.
2. **Endpoint 10 (`req=teams&league={league_id}`)**: Syncs teams into `public.teams`.
3. **Endpoint 13 (`req=matchs&league={league_id}`)**: Syncs fixtures/matches into `public.matches`.
4. **Endpoint 12 (`req=matchsday&date={date}`)**: Polls live scores and settles finished matches.

## Environment Variables Required
In your Supabase project settings or via CLI secrets:
```bash
supabase secrets set BESOCCER_API_KEY="your_api_key"
supabase secrets set CRON_SECRET="your_secure_cron_secret"
```
(`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically by Supabase Edge Runtime).

## Invocation Examples
Deploy:
```bash
supabase functions deploy sync-matches
```

Trigger sync (requires `x-pico-cron-secret` header matching `CRON_SECRET`):
```bash
# Tier 1: Sync live scores / matchday settlement (every 2 mins)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-live' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'

# Tier 2: Sync upcoming matches across all 8 leagues (daily)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-upcoming' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'

# Tier 3: Sync metadata (competitions & all teams, weekly)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-metadata' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'

# Individual helpers
# Sync competitions
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-competitions' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'

# Sync teams across all leagues (league=all)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-teams&league=all' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'

# Sync matches for a single league (e.g., La Liga league=1)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-matches&league=1' \
  --header 'Authorization: Bearer <service_role_key>' \
  --header 'x-pico-cron-secret: <cron_secret>'
```

## Scheduling (pg_cron Three-Tier Schedule)
In Supabase SQL Editor:
```sql
-- 1. Tier 1: Sync live scores and settle finished matches (every 2 minutes)
select
  cron.schedule(
    'sync-live-matches',
    '*/2 * * * *',
    $$
    select
      net.http_post(
          url:='https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-live',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer <service_role_key>", "x-pico-cron-secret": "<cron_secret>"}'::jsonb
      ) as request_id;
    $$
  );

-- 2. Tier 2: Sync upcoming 14-day fixtures for all 8 leagues (daily at 03:00 UTC)
select
  cron.schedule(
    'sync-upcoming-matches-daily',
    '0 3 * * *',
    $$
    select
      net.http_post(
          url:='https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-upcoming',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer <service_role_key>", "x-pico-cron-secret": "<cron_secret>"}'::jsonb
      ) as request_id;
    $$
  );

-- 3. Tier 3: Sync metadata (competitions & all teams, weekly on Monday at 02:00 UTC)
select
  cron.schedule(
    'sync-metadata-weekly',
    '0 2 * * 1',
    $$
    select
      net.http_post(
          url:='https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-metadata',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer <service_role_key>", "x-pico-cron-secret": "<cron_secret>"}'::jsonb
      ) as request_id;
    $$
  );
```
