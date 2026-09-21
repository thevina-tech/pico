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
```
(`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically by Supabase Edge Runtime).

## Invocation Examples
Deploy:
```bash
supabase functions deploy sync-matches
```

Trigger sync:
```bash
# Sync competitions
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-competitions' \
  --header 'Authorization: Bearer <service_role_key>'

# Sync teams for Premier League (league=1)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-teams&league=1' \
  --header 'Authorization: Bearer <service_role_key>'

# Sync matches for Premier League (league=1)
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-matches&league=1' \
  --header 'Authorization: Bearer <service_role_key>'

# Sync live scores / matchday settlement
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-live' \
  --header 'Authorization: Bearer <service_role_key>'

# Sync all
curl -i --location --request POST 'https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-all&league=1' \
  --header 'Authorization: Bearer <service_role_key>'
```

## Scheduling (pg_cron)
In Supabase SQL Editor:
```sql
-- Sync live matches every 2 minutes
select
  cron.schedule(
    'sync-live-matches',
    '*/2 * * * *',
    $$
    select
      net.http_post(
          url:='https://<project-ref>.supabase.co/functions/v1/sync-matches?action=sync-live',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer <service_role_key>"}'::jsonb
      ) as request_id;
    $$
  );
```
