import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const API_FOOTBALL_BASE_URL = "https://v3.football.api-sports.io";

// Initialize Supabase admin client using environment secrets
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const footballApiKey =
  Deno.env.get("FOOTBALL_API_KEY") ?? Deno.env.get("API_FOOTBALL_KEY") ?? "";

const supabase = createClient(supabaseUrl, supabaseServiceKey);

/**
 * Strictly targeted top-tier competitions (Sprint 9 API-Football IDs):
 * 1. Primera División (La Liga) - ID: 140
 * 2. Premier League - ID: 39
 * 3. Serie A - ID: 135
 * 4. Bundesliga - ID: 78
 * 5. Ligue 1 - ID: 61
 * 6. Champions League - ID: 2
 * 7. Europa League - ID: 3
 * 8. Conference League - ID: 848
 * 9. UEFA Nations League - ID: 5
 */
const CORE_COMPETITIONS: Array<{
  id: string;
  name: string;
  short_name: string;
  flag: string;
  emblem_url?: string | null;
}> = [
  {
    id: "140",
    name: "Primera División (La Liga)",
    short_name: "La Liga",
    flag: "🇪🇸",
    emblem_url: "https://media.api-sports.io/flags/es.svg",
  },
  {
    id: "39",
    name: "Premier League",
    short_name: "Premier League",
    flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿",
    emblem_url: "https://media.api-sports.io/flags/gb.svg",
  },
  {
    id: "135",
    name: "Serie A",
    short_name: "Serie A",
    flag: "🇮🇹",
    emblem_url: "https://media.api-sports.io/flags/it.svg",
  },
  {
    id: "78",
    name: "Bundesliga",
    short_name: "Bundesliga",
    flag: "🇩🇪",
    emblem_url: "https://media.api-sports.io/flags/de.svg",
  },
  {
    id: "61",
    name: "Ligue 1",
    short_name: "Ligue 1",
    flag: "🇫🇷",
    emblem_url: "https://media.api-sports.io/flags/fr.svg",
  },
  {
    id: "2",
    name: "Champions League",
    short_name: "UCL",
    flag: "⭐",
    emblem_url: null,
  },
  {
    id: "3",
    name: "Europa League",
    short_name: "UEL",
    flag: "🟠",
    emblem_url: null,
  },
  {
    id: "848",
    name: "Conference League",
    short_name: "UECL",
    flag: "🟢",
    emblem_url: null,
  },
  {
    id: "5",
    name: "UEFA Nations League",
    short_name: "Nations League",
    flag: "🇪🇺",
    emblem_url: null,
  },
];

const ALLOWED_COMPETITION_IDS = new Set(CORE_COMPETITIONS.map((c) => c.id));

/**
 * Safely parses numeric score values from API-Football fields (e.g., goals.home).
 */
function parseScore(val: any): number | null {
  if (val !== undefined && val !== null && val !== "") {
    const num = Number(val);
    if (!isNaN(num)) return num;
  }
  return null;
}

/**
 * Maps API-Football fixture.status.short to our Postgres match_status enum:
 * 'upcoming' | 'live' | 'finished' | 'postponed' | 'cancelled'
 *
 * Mapping rules:
 * - 'NS', 'TBD' -> "upcoming"
 * - '1H', 'HT', '2H', 'ET', 'BT', 'P', 'SUSP', 'INT', 'LIVE' -> "live"
 * - 'FT', 'AET', 'PEN' -> "finished"
 * - 'PST' -> "postponed"
 * - 'CANC', 'ABD', 'AWD', 'WO' -> "cancelled"
 */
function mapMatchStatus(
  rawStatus?: string | null
): "upcoming" | "live" | "finished" | "postponed" | "cancelled" {
  if (!rawStatus) return "upcoming";

  const s = String(rawStatus).trim().toUpperCase();

  // Upcoming
  if (s === "NS" || s === "TBD") return "upcoming";

  // Live
  if (
    s === "1H" ||
    s === "HT" ||
    s === "2H" ||
    s === "ET" ||
    s === "BT" ||
    s === "P" ||
    s === "SUSP" ||
    s === "INT" ||
    s === "LIVE"
  ) {
    return "live";
  }

  // Finished
  if (s === "FT" || s === "AET" || s === "PEN") return "finished";

  // Postponed
  if (s === "PST") return "postponed";

  // Cancelled
  if (s === "CANC" || s === "ABD" || s === "AWD" || s === "WO") return "cancelled";

  // Fallback checks for string representations
  const lower = s.toLowerCase();
  if (["upcoming", "not_started", "scheduled"].includes(lower)) return "upcoming";
  if (["live", "playing", "in_play"].includes(lower)) return "live";
  if (["finished", "final", "ended"].includes(lower)) return "finished";
  if (["postponed"].includes(lower)) return "postponed";
  if (["cancelled", "canceled", "abandoned"].includes(lower)) return "cancelled";

  return "upcoming";
}

/**
 * Parses kickoff timestamp from API-Football date/timestamp fields.
 */
function parseKickoffAt(fixture: any): string {
  if (fixture?.date) {
    const parsed = new Date(fixture.date);
    if (!isNaN(parsed.getTime())) return parsed.toISOString();
  }
  if (fixture?.timestamp) {
    const parsed = new Date(Number(fixture.timestamp) * 1000);
    if (!isNaN(parsed.getTime())) return parsed.toISOString();
  }
  return new Date().toISOString();
}

/**
 * Helper to call API-Football with authentication headers.
 */
async function callApiFootball(
  endpoint: string,
  params: Record<string, string | number> = {}
): Promise<any> {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== "") {
      query.set(key, String(value));
    }
  }

  const queryString = query.toString();
  const url = `${API_FOOTBALL_BASE_URL}${endpoint}${
    queryString ? `?${queryString}` : ""
  }`;
  console.log(`Calling API-Football: ${endpoint}?${queryString}`);

  const res = await fetch(url, {
    method: "GET",
    headers: {
      "x-apisports-key": footballApiKey,
    },
  });

  if (!res.ok) {
    throw new Error(
      `API-Football error [${endpoint}]: ${res.status} ${res.statusText}`
    );
  }

  const json = await res.json();
  if (
    json.errors &&
    typeof json.errors === "object" &&
    Object.keys(json.errors).length > 0 &&
    !Array.isArray(json.errors)
  ) {
    console.error("API-Football errors:", json.errors);
  }

  return json;
}

/**
 * Resolves the season year for querying API-Football.
 * Defaults to current European season year (e.g. 2024 for 2024-2025).
 */
function resolveSeason(customSeason?: string | null): number {
  if (customSeason) {
    const parsed = parseInt(customSeason, 10);
    if (!isNaN(parsed)) return parsed;
  }
  const now = new Date();
  return now.getMonth() >= 6 ? now.getFullYear() : now.getFullYear() - 1;
}

/**
 * 1. Sync Top Competitions (Sprint 9: strictly limited to the curated 9 API-Football competitions)
 * Uses flag emojis / country flags as emblem_url (never official league.logo).
 */
async function syncCompetitions(): Promise<number> {
  // First, guarantee core competitions exist with curated names and flag emblems
  const { error: upsertErr } = await supabase
    .from("competitions")
    .upsert(CORE_COMPETITIONS, { onConflict: "id" });

  if (upsertErr) {
    console.error("Supabase upsert core competitions error:", upsertErr.message);
    throw upsertErr;
  }

  try {
    for (const comp of CORE_COMPETITIONS) {
      const data = await callApiFootball("/leagues", { id: comp.id });
      const item = data?.response?.[0];
      if (item) {
        // Map league.flag or country.flag to emblem_url instead of league.logo
        // For international competitions (like Champions League), flag will be null
        const flagUrl = item.country?.flag || item.league?.flag || null;
        if (flagUrl) {
          const { error } = await supabase
            .from("competitions")
            .update({ emblem_url: flagUrl })
            .eq("id", comp.id);
          if (error) {
            console.warn(
              `Supabase update competition emblem warning (${comp.id}):`,
              error.message
            );
          }
        }
      }
    }
  } catch (err: any) {
    console.warn("API-Football fetch leagues error:", err.message);
  }

  return CORE_COMPETITIONS.length;
}

/**
 * 2. Sync Teams for a Competition (/teams?league={id}&season={season})
 * Strict Trademark Rule:
 * - Do NOT include the crest_url property at all when upserting teams.
 * - This defaults new teams to null and protects manually added logos.
 */
async function syncTeams(
  leagueId: string,
  customSeason?: string | null
): Promise<number> {
  if (!ALLOWED_COMPETITION_IDS.has(leagueId)) {
    console.warn(`Skipping syncTeams for disallowed competition: ${leagueId}`);
    return 0;
  }

  const season = resolveSeason(customSeason);
  const data = await callApiFootball("/teams", { league: leagueId, season });
  const rawList: any[] = Array.isArray(data?.response) ? data.response : [];

  if (!rawList.length) return 0;

  // Strict Rule 7: Do NOT include the crest_url property at all in the mapped objects
  const records = rawList
    .filter((item: any) => item?.team?.id)
    .map((item: any) => ({
      id: String(item.team.id),
      name: item.team.name || `Team ${item.team.id}`,
      short_name: item.team.code ?? null,
    }));

  const { error } = await supabase
    .from("teams")
    .upsert(records, { onConflict: "id" });

  if (error) throw new Error(`Supabase upsert teams error: ${error.message}`);
  return records.length;
}

/**
 * 3. Sync Matches for a Competition (/fixtures?league={id}&season={season})
 * Strict Rules:
 * - Relational integrity: ensure competition exists without overwriting name or emblem_url.
 * - Upsert teams without the crest_url property.
 * - Map fixtures to provider_match_id, competition_id, home_team_id, away_team_id,
 *   kickoff_at, status, home_score, away_score, and settled.
 */
async function syncMatches(
  leagueId: string,
  customSeason?: string | null
): Promise<number> {
  if (!ALLOWED_COMPETITION_IDS.has(leagueId)) {
    console.warn(`Skipping syncMatches for disallowed competition: ${leagueId}`);
    return 0;
  }

  const season = resolveSeason(customSeason);
  const data = await callApiFootball("/fixtures", { league: leagueId, season });
  const rawList: any[] = Array.isArray(data?.response) ? data.response : [];

  if (!rawList.length) return 0;

  // 1. Relational Integrity: Ensure parent competition exists in public.competitions
  // Rule 7: Do NOT include league.name or emblem_url in periodic upserts to protect manual edits!
  const coreComp = CORE_COMPETITIONS.find((c) => c.id === leagueId);
  const { data: existingComp } = await supabase
    .from("competitions")
    .select("id")
    .eq("id", leagueId)
    .maybeSingle();

  if (!existingComp) {
    await supabase.from("competitions").insert({
      id: leagueId,
      name: coreComp?.name || `Competition ${leagueId}`,
      short_name: coreComp?.short_name || coreComp?.name || `Comp ${leagueId}`,
      flag: coreComp?.flag || "🏆",
      emblem_url: coreComp?.emblem_url ?? null,
    });
  }

  // 2. Relational Integrity: Extract and upsert all teams from the fixture payload
  // Rule 7: Do NOT include the crest_url property at all when upserting teams
  const teamsMap = new Map<
    string,
    { id: string; name: string; short_name: string | null }
  >();

  for (const f of rawList) {
    const home = f.teams?.home;
    const away = f.teams?.away;

    if (home?.id && !teamsMap.has(String(home.id))) {
      teamsMap.set(String(home.id), {
        id: String(home.id),
        name: home.name || `Team ${home.id}`,
        short_name: home.code ?? null,
      });
    }

    if (away?.id && !teamsMap.has(String(away.id))) {
      teamsMap.set(String(away.id), {
        id: String(away.id),
        name: away.name || `Team ${away.id}`,
        short_name: away.code ?? null,
      });
    }
  }

  if (teamsMap.size > 0) {
    const { error: teamsError } = await supabase
      .from("teams")
      .upsert(Array.from(teamsMap.values()), { onConflict: "id" });
    if (teamsError) {
      console.warn("Auto-upsert teams warning in syncMatches:", teamsError.message);
    }
  }

  // 3. Map and upsert matches with proper status translation
  const records = rawList
    .filter(
      (f: any) =>
        f?.fixture?.id && f?.teams?.home?.id && f?.teams?.away?.id
    )
    .map((f: any) => {
      const status = mapMatchStatus(f.fixture?.status?.short);
      const homeScore = parseScore(f.goals?.home);
      const awayScore = parseScore(f.goals?.away);

      return {
        provider_match_id: String(f.fixture.id),
        competition_id: leagueId,
        home_team_id: String(f.teams.home.id),
        away_team_id: String(f.teams.away.id),
        kickoff_at: parseKickoffAt(f.fixture),
        status: status,
        home_score: homeScore,
        away_score: awayScore,
        settled: status === "finished",
      };
    });

  if (!records.length) return 0;

  const { error } = await supabase
    .from("matches")
    .upsert(records, { onConflict: "provider_match_id" });

  if (error) throw new Error(`Supabase upsert matches error: ${error.message}`);
  return records.length;
}

/**
 * 4. Sync Matches of the Day / Live Settlement (/fixtures?date={date} & /fixtures?live=all)
 * Updates match statuses, live/final scores, and sets settled = true for finished matches.
 */
async function syncMatchesDay(targetDate?: string): Promise<number> {
  const dateStr = targetDate || new Date().toISOString().split("T")[0];
  const allFixtures: any[] = [];

  try {
    const dateData = await callApiFootball("/fixtures", { date: dateStr });
    if (Array.isArray(dateData?.response)) {
      allFixtures.push(...dateData.response);
    }
  } catch (e: any) {
    console.warn(`Error fetching date fixtures (${dateStr}):`, e.message);
  }

  try {
    const liveData = await callApiFootball("/fixtures", { live: "all" });
    if (Array.isArray(liveData?.response)) {
      allFixtures.push(...liveData.response);
    }
  } catch (e: any) {
    console.warn("Error fetching live fixtures:", e.message);
  }

  // Filter to permitted core competitions only
  const fixturesMap = new Map<string, any>();
  for (const f of allFixtures) {
    if (!f?.fixture?.id) continue;
    const leagueId = String(f.league?.id || "");
    if (ALLOWED_COMPETITION_IDS.has(leagueId)) {
      fixturesMap.set(String(f.fixture.id), f);
    }
  }

  if (fixturesMap.size === 0) return 0;

  let updatedCount = 0;
  for (const f of fixturesMap.values()) {
    const providerMatchId = String(f.fixture.id);
    const status = mapMatchStatus(f.fixture?.status?.short);
    const homeScore = parseScore(f.goals?.home);
    const awayScore = parseScore(f.goals?.away);

    const { error } = await supabase
      .from("matches")
      .update({
        status: status,
        home_score: homeScore,
        away_score: awayScore,
        settled: status === "finished",
      })
      .eq("provider_match_id", providerMatchId);

    if (!error) updatedCount++;
  }

  return updatedCount;
}

// HTTP Server Handler for Edge Function
serve(async (req: Request) => {
  // CORS headers
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type, x-pico-cron-secret",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers });
  }

  // 1. Enforce secret key check before executing any logic
  const cronSecretHeader = req.headers.get("x-pico-cron-secret");
  const expectedCronSecret = Deno.env.get("CRON_SECRET");

  if (
    !cronSecretHeader ||
    !expectedCronSecret ||
    cronSecretHeader !== expectedCronSecret
  ) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers,
    });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") || "sync-live";
    const league = url.searchParams.get("league") || "140"; // Default to La Liga
    const date = url.searchParams.get("date") || undefined;
    const season = url.searchParams.get("season") || undefined;

    const results: Record<string, any> = {
      action,
      timestamp: new Date().toISOString(),
    };

    switch (action) {
      case "sync-competitions": {
        results.competitionsSynced = await syncCompetitions();
        break;
      }
      case "sync-teams": {
        if (league === "all") {
          let total = 0;
          for (const compId of ALLOWED_COMPETITION_IDS) {
            try {
              total += await syncTeams(compId, season);
            } catch (e: any) {
              console.warn(`Sync teams error for comp ${compId}:`, e.message);
            }
          }
          results.teamsSynced = total;
        } else {
          results.teamsSynced = await syncTeams(league, season);
        }
        break;
      }
      case "sync-matches": {
        if (league === "all") {
          let total = 0;
          for (const compId of ALLOWED_COMPETITION_IDS) {
            try {
              total += await syncMatches(compId, season);
            } catch (e: any) {
              console.warn(`Sync error for comp ${compId}:`, e.message);
            }
          }
          results.matchesSynced = total;
        } else {
          results.matchesSynced = await syncMatches(league, season);
        }
        break;
      }
      case "sync-upcoming": {
        let total = 0;
        for (const compId of ALLOWED_COMPETITION_IDS) {
          try {
            total += await syncMatches(compId, season);
          } catch (e: any) {
            console.warn(
              `Sync upcoming matches error for comp ${compId}:`,
              e.message
            );
          }
        }
        results.matchesSynced = total;
        break;
      }
      case "sync-metadata": {
        results.competitionsSynced = await syncCompetitions();
        let totalTeams = 0;
        for (const compId of ALLOWED_COMPETITION_IDS) {
          try {
            totalTeams += await syncTeams(compId, season);
          } catch (e: any) {
            console.warn(
              `Sync metadata teams error for comp ${compId}:`,
              e.message
            );
          }
        }
        results.teamsSynced = totalTeams;
        break;
      }
      case "sync-live":
      case "sync-matchsday": {
        results.matchesDayUpdated = await syncMatchesDay(date);
        break;
      }
      case "sync-all": {
        results.competitionsSynced = await syncCompetitions();
        let totalMatches = 0;
        for (const compId of ALLOWED_COMPETITION_IDS) {
          try {
            totalMatches += await syncMatches(compId, season);
          } catch (e: any) {
            console.warn(`Sync error for comp ${compId}:`, e.message);
          }
        }
        results.matchesSynced = totalMatches;
        results.matchesDayUpdated = await syncMatchesDay(date);
        break;
      }
      default:
        return new Response(
          JSON.stringify({ error: `Unknown action: ${action}` }),
          { status: 400, headers }
        );
    }

    return new Response(JSON.stringify({ success: true, data: results }), {
      status: 200,
      headers,
    });
  } catch (err: any) {
    console.error("sync-matches edge function error:", err);
    return new Response(
      JSON.stringify({ success: false, error: err.message || String(err) }),
      { status: 500, headers }
    );
  }
});
