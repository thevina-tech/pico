# Supabase Edge Function: `sync-matches`

This edge function is responsible for ingesting football data from **API-Football** (`https://v3.football.api-sports.io`) directly into Supabase PostgreSQL tables according to the normalized schema in `supabase_schema.md`.

## Zero Client Trust Architecture
- The Flutter client **NEVER** calls sports data APIs directly.
- The client reads exclusively from Supabase tables (`competitions`, `teams`, `matches`).
- Strict trademark protection: Team `crest_url` is omitted from automatic syncs to protect custom logos. Competitions use national flags or emojis (never official league logos).

## API-Football Endpoints Implemented
1. **`/leagues?id={id}`**: Syncs core competitions with country flags into `public.competitions`.
2. **`/teams?league={id}&season={season}`**: Syncs teams without crests into `public.teams`.
3. **`/fixtures?league={id}&season={season}`**: Syncs fixtures/matches into `public.matches`.
4. **`/fixtures?date={date}` & `/fixtures?live=all`**: Polls live scores and settles finished matches.

## Core Competitions Supported
- `140`: Primera División (La Liga)
- `39`: Premier League
- `135`: Serie A
- `78`: Bundesliga
- `61`: Ligue 1
- `2`: Champions League
- `3`: Europa League
- `848`: Conference League
- `5`: UEFA Nations League

## Environment Variables Required
In your Supabase project settings or via CLI secrets:
```bash
supabase secrets set FOOTBALL_API_KEY="your_api_sports_key"
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

# Tier 2: Sync upcoming matches across all 9 leagues (daily)
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

# Sync matches for a single league (e.g., La Liga league=140)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-matches&league=140' \
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

-- 2. Tier 2: Sync upcoming fixtures for all 9 leagues (daily at 03:00 UTC)
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
