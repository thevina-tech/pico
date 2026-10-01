---
trigger: always_on
---

# TASK: Rewrite Edge Function for API-Football Integration

Our sports data provider has changed. Rewrite the current `sync-matches.ts` Edge Function to use the new API-Football provider while strictly maintaining our existing Supabase database schema (`matches`, `teams`, `competitions`).

## 1. API Configuration
*   **Base URL:** Change the base URL to `https://v3.football.api-sports.io`[cite: 1].
*   **Authentication:** Pass the API key in the headers using `x-apisports-key` via `Deno.env.get("FOOTBALL_API_KEY")`.

## 2. Core Mapping Rules (Adapter Pattern)
When fetching from the `/fixtures` endpoint (e.g., `/fixtures?league=X&season=2023`), map the JSON response to our exact tables[cite: 1]:

**Competitions Table:**
*   Map `league.id` to our `id`[cite: 1].
*   Map `league.name` to our `name`[cite: 1].
*   Map `league.logo` to our `emblem_url`[cite: 1].

**Teams Table:**
*   Map `teams.home.id` to our `id`[cite: 1].
*   Map `teams.home.name` to our `name`[cite: 1].
*   Map `teams.home.logo` to our `crest_url`[cite: 1].
*   Do the exact same for the away team using `teams.away`[cite: 1].

**Matches Table:**
*   Map the `fixture.id` to our `provider_match_id`[cite: 1].
*   Map `league.id` to our `competition_id`[cite: 1].
*   Map `teams.home.id` to our `home_team_id`[cite: 1].
*   Map `teams.away.id` to our `away_team_id`[cite: 1].
*   Map `fixture.date` to our `kickoff_at` column[cite: 1].
*   Map `goals.home` to `home_score` and `goals.away` to `away_score`[cite: 1].

## 3. Status String Translation
You must translate `fixture.status.short` into our strict status strings[cite: 1]:
*   Use 'NS' and 'TBD' for `"upcoming"`[cite: 1].
*   Use '1H', 'HT', '2H', 'ET', 'BT', 'P', 'SUSP', 'INT', and 'LIVE' for `"live"`[cite: 1].
*   Use 'FT', 'AET', and 'PEN' for `"finished"`[cite: 1].
*   Use 'PST' for `"postponed"`[cite: 1].
*   Use 'CANC', 'ABD', 'AWD', and 'WO' for `"cancelled"`[cite: 1].

## 4. Instructions
*   Keep the existing Edge Function HTTP routing (`sync-competitions`, `sync-matches`, `sync-live`).
*   Update the `fetch` logic to hit the new endpoints.
*   Ensure all upserts into Supabase retain their `onConflict` targets.

## 5. Update Core Competition IDs
Replace the old BeSoccer IDs in the `CORE_COMPETITIONS` array with the exact API-Football IDs below to ensure we only sync our targeted leagues:
*   `id: "140"` (La Liga)
*   `id: "39"` (Premier League)
*   `id: "135"` (Serie A)
*   `id: "78"` (Bundesliga)
*   `id: "61"` (Ligue 1)
*   `id: "2"` (Champions League)
*   `id: "3"` (Europa League)
*   `id: "848"` (Conference League)
*   `id: "5"` (UEFA Nations League)

For the new UEFA Nations League entry in the `CORE_COMPETITIONS` array, initialize it with this fallback data:
`name: "UEFA Nations League"`, `short_name: "Nations League"`, `flag: "🇪🇺"`, and `emblem_url: null`.

Ensure `ALLOWED_COMPETITION_IDS` correctly references these new string IDs so the script filters out and ignores all other global leagues returned by the API.

## 6. Strict Trademark & Logo Removal (Crucial)
To avoid copyright issues during app store review, we must NOT save the official team crests or league logos from the API.

Update the mapping rules for the Edge Function as follows:

**Competitions Table (Use Flags instead of Logos):**
*   Map `league.flag` to `emblem_url` instead of `league.logo`[cite: 1]. 
*   *Note:* For international competitions (like the Champions League), `league.flag` will be `null`[cite: 1]. Ensure the database safely accepts `null` for `emblem_url` so our Flutter app can fall back to the default emojis we already defined in `CORE_COMPETITIONS`.

**Teams Table (Nullify Crests):**
*   Do NOT map `teams.home.logo` or `teams.away.logo`[cite: 1]. 
*   Hardcode `crest_url` to `null` for all team upserts. We will populate these later using an internal tool.

## 7. Protect Custom Logos from Cron Overwrites
Because this Edge Function runs on a cron schedule using `upsert`, it must not overwrite the custom logos we manually add later.

*   **Teams Table:** Do NOT include the `crest_url` property at all in the mapped objects when upserting teams. By omitting it entirely, Supabase will default new teams to `null` and safely ignore the column for existing teams, protecting our manual updates.
*   **Competitions Table:** During regular match syncs, do NOT map or include `league.name` or `emblem_url` in the upsert payload. Only rely on the fallback names and emojis defined in `CORE_COMPETITIONS` for the initial creation, and omit them entirely from the periodic upserts so our manual database edits are never overwritten
*   **Competitions Table:** Do NOT include the `emblem_url` property in the mapped objects when upserting competitions during the regular match sync. Only rely on the fallback emojis defined in `CORE_COMPETITIONS`.

## 8. Frontend Fallback for Team Crests (Flutter)
* Locate the UI widgets responsible for rendering team logos (e.g., inside match cards, predictions, or leaderboards).
* Implement a null-check for the `crest_url`. If it is null or empty, display a generic local asset (e.g., `assets/images/default_shield.png`) or a clean placeholder icon (e.g., `Icons.shield`).