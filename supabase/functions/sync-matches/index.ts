import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const BEROCCER_BASE_URL = "https://apiclient.besoccerapps.com/scripts/api/api.php";

// Initialize Supabase admin client using environment secrets
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const besoccerApiKey = Deno.env.get("BESOCCER_API_KEY") ?? "";

const supabase = createClient(supabaseUrl, supabaseServiceKey);

/**
 * Strictly limited top-tier competitions (Sprint 4 requirement):
 * 1. Primera División (La Liga) - BeSoccer ID: 1
 * 2. Premier League - BeSoccer ID: 10
 * 3. Serie A - BeSoccer ID: 7
 * 4. Bundesliga - BeSoccer ID: 8
 * 5. Ligue 1 - BeSoccer ID: 16
 * 6. Champions League - BeSoccer ID: 107
 * 7. Europa League - BeSoccer ID: 117
 * 8. Conference League - BeSoccer ID: 2492
 */
const CORE_COMPETITIONS: Array<{ id: string; name: string; emblem_url?: string | null }> = [
  { id: "1", name: "Primera División (La Liga)", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/1.png?size=120x&lossy=1" },
  { id: "10", name: "Premier League", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/10.png?size=120x&lossy=1" },
  { id: "7", name: "Serie A", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/7.png?size=120x&lossy=1" },
  { id: "8", name: "Bundesliga", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/8.png?size=120x&lossy=1" },
  { id: "16", name: "Ligue 1", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/16.png?size=120x&lossy=1" },
  { id: "107", name: "Champions League", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/107.png?size=120x&lossy=1" },
  { id: "117", name: "Europa League", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/117.png?size=120x&lossy=1" },
  { id: "2492", name: "Conference League", emblem_url: "https://t.resfu.com/img_data/competiciones/logo/2492.png?size=120x&lossy=1" },
];

const ALLOWED_COMPETITION_IDS = new Set(CORE_COMPETITIONS.map((c) => c.id));

/**
 * Strips query parameters like '&v=...' or '?v=...' from BeSoccer image URLs.
 */
function cleanImageUrl(url?: string | null): string | null {
  if (!url) return null;
  try {
    const parsed = new URL(url);
    parsed.searchParams.delete("v");
    return parsed.toString();
  } catch {
    return url.replace(/([?&])v=[^&#]*/g, "").replace(/[?&]$/, "");
  }
}

/**
 * Safely parses score values from BeSoccer response fields (e.g., result1, local_goals, or "2-1").
 */
function parseScore(val: any, fallbackStr?: any, resultStr?: string, partIndex = 0): number | null {
  if (val !== undefined && val !== null && val !== "" && val !== "x") {
    const num = Number(val);
    if (!isNaN(num)) return num;
  }
  if (fallbackStr !== undefined && fallbackStr !== null && fallbackStr !== "" && fallbackStr !== "x") {
    const num = Number(fallbackStr);
    if (!isNaN(num)) return num;
  }
  if (resultStr && typeof resultStr === "string" && resultStr.includes("-")) {
    const parts = resultStr.split("-");
    if (parts.length === 2) {
      const num = Number(parts[partIndex].trim());
      if (!isNaN(num)) return num;
    }
  }
  return null;
}

/**
 * Maps BeSoccer status strings or status codes to our Postgres match_status enum:
 * 'upcoming' | 'live' | 'finished' | 'postponed' | 'cancelled'
 */
function mapMatchStatus(rawStatus?: string | number | null): "upcoming" | "live" | "finished" | "postponed" | "cancelled" {
  if (rawStatus === null || rawStatus === undefined) return "upcoming";

  const statusStr = String(rawStatus).toLowerCase().trim();

  // Numeric BeSoccer status codes
  if (statusStr === "-1") return "upcoming";
  if (statusStr === "0") return "live";
  if (statusStr === "1") return "finished";
  if (statusStr === "2") return "postponed";
  if (statusStr === "3") return "cancelled";

  // Textual representations
  if (["upcoming", "not_started", "scheduled", "sched"].includes(statusStr)) return "upcoming";
  if (["live", "playing", "in_play", "1t", "2t", "ht", "et", "pen"].includes(statusStr)) return "live";
  if (["finished", "ft", "final", "ended"].includes(statusStr)) return "finished";
  if (["postponed", "post"].includes(statusStr)) return "postponed";
  if (["cancelled", "canceled", "suspended", "abd"].includes(statusStr)) return "cancelled";

  return "upcoming";
}

/**
 * Parses kickoff timestamp from BeSoccer date/hour/schedule fields.
 */
function parseKickoffAt(match: any): string {
  if (match.schedule && typeof match.schedule === "string") {
    const parsed = new Date(match.schedule);
    if (!isNaN(parsed.getTime())) return parsed.toISOString();
  }

  const dateStr = match.date || "";
  const hourStr = match.hour || match.time || "00:00:00";

  if (dateStr) {
    const combined = new Date(`${dateStr}T${hourStr}Z`);
    if (!isNaN(combined.getTime())) return combined.toISOString();

    const fallback = new Date(`${dateStr} ${hourStr}`);
    if (!isNaN(fallback.getTime())) return fallback.toISOString();
  }

  return new Date().toISOString();
}

/**
 * Helper to fetch from BeSoccer Level 1 API.
 */
async function callBeSoccer(params: Record<string, string>): Promise<any> {
  const query = new URLSearchParams({
    key: besoccerApiKey,
    format: "json",
    tz: "Europe/Madrid",
    ...params,
  });

  const url = `${BEROCCER_BASE_URL}?${query.toString()}`;
  console.log(`Calling BeSoccer API: req=${params.req}`);

  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`BeSoccer API error [req=${params.req}]: ${res.status} ${res.statusText}`);
  }

  return await res.json();
}

/**
 * 1. Sync Top Competitions (Sprint 4: strictly limited to the curated 8 top-tier competitions)
 * Only processes and upserts these specific 8 competitions and ignores all other API data.
 */
async function syncCompetitions(): Promise<number> {
  // First, guarantee core competitions exist with curated names and emblems
  const { error: upsertErr } = await supabase
    .from("competitions")
    .upsert(CORE_COMPETITIONS, { onConflict: "id" });

  if (upsertErr) {
    console.error("Supabase upsert core competitions error:", upsertErr.message);
    throw upsertErr;
  }

  try {
    const data = await callBeSoccer({ req: "categories", filter: "competitions" });
    const allComps: any[] = [];
    if (data?.category?.competitions) {
      for (const list of Object.values(data.category.competitions)) {
        if (Array.isArray(list)) allComps.push(...list);
      }
    }

    // STRICT: Only process and upsert the 8 permitted competitions, ignore all other API data
    const permittedOnly = allComps.filter((c: any) => 
      ALLOWED_COMPETITION_IDS.has(String(c.id || c.category_id))
    );

    if (permittedOnly.length > 0) {
      const records = permittedOnly.map((c: any) => {
        const id = String(c.id || c.category_id);
        const core = CORE_COMPETITIONS.find((item) => item.id === id);
        return {
          id,
          name: core?.name || c.name || "Unknown Competition",
          emblem_url: cleanImageUrl(c.logo || c.logo_png || c.shield) || core?.emblem_url,
        };
      });

      const { error } = await supabase
        .from("competitions")
        .upsert(records, { onConflict: "id" });

      if (error) console.warn("Supabase upsert competitions warning:", error.message);
    }
  } catch (err: any) {
    console.warn("BeSoccer fetch competitions error:", err.message);
  }

  return CORE_COMPETITIONS.length;
}

/**
 * 2. Sync Teams for a Competition (Endpoint 10: req=teams)
 */
async function syncTeams(leagueId: string): Promise<number> {
  if (!ALLOWED_COMPETITION_IDS.has(leagueId)) {
    console.warn(`Skipping syncTeams for disallowed competition: ${leagueId}`);
    return 0;
  }

  const data = await callBeSoccer({ req: "teams", league: leagueId });
  const rawList: any[] = Array.isArray(data)
    ? data
    : data.team || data.teams || data.data || [];

  if (!rawList.length) return 0;

  const records = rawList.map((t: any) => ({
    id: String(t.dteam || t.id || t.team_id),
    name: t.name || t.fullName || "Unknown Team",
    short_name: t.short_name || t.name_short || t.shortName || t.abbr || null,
    crest_url: cleanImageUrl(t.shield || t.logo || t.image || t.badge),
  }));

  const { error } = await supabase
    .from("teams")
    .upsert(records, { onConflict: "id" });

  if (error) throw new Error(`Supabase upsert teams error: ${error.message}`);
  return records.length;
}

/**
 * 3. Sync Matches for a Competition (Endpoint 13: req=matchs)
 * Strictly restricted to the 8 top-tier competitions.
 * Automatically ensures referenced competition and teams exist to avoid foreign key violations.
 */
async function syncMatches(leagueId: string): Promise<number> {
  if (!ALLOWED_COMPETITION_IDS.has(leagueId)) {
    console.warn(`Skipping syncMatches for disallowed competition: ${leagueId}`);
    return 0;
  }

  const data = await callBeSoccer({ req: "matchs", league: leagueId });
  const rawList: any[] = Array.isArray(data)
    ? data
    : data.match || data.matches || data.data || [];

  if (!rawList.length) return 0;

  // 1. Relational Integrity: Ensure parent competition exists in public.competitions
  const coreComp = CORE_COMPETITIONS.find((c) => c.id === leagueId);
  const compName = coreComp?.name || rawList[0]?.competition_name || rawList[0]?.category_name || `Competition ${leagueId}`;
  const compEmblem = coreComp?.emblem_url || cleanImageUrl(rawList[0]?.cflag_local || rawList[0]?.logo || rawList[0]?.shield);

  await supabase
    .from("competitions")
    .upsert([{ id: leagueId, name: compName, emblem_url: compEmblem }], { onConflict: "id" });

  // 2. Relational Integrity: Extract and upsert all teams from the match payload
  const teamsMap = new Map<string, { id: string; name: string; short_name: string | null; crest_url: string | null }>();

  for (const m of rawList) {
    // Home Team: prefer persistent direct team id (dteam1), fallback to id_local, id_home, team1
    const homeTeamId = String(m.dteam1 || m.id_local || m.id_home || m.local_id || m.team1?.id || m.team1 || "");
    if (homeTeamId && !teamsMap.has(homeTeamId)) {
      teamsMap.set(homeTeamId, {
        id: homeTeamId,
        name: m.local || m.name_home || m.team1?.name || `Team ${homeTeamId}`,
        short_name: m.local_abbr || m.team1?.short_name || null,
        crest_url: cleanImageUrl(m.local_shield || m.local_shield_png || m.shield1 || m.team1?.shield || m.team1?.logo),
      });
    }

    // Away Team: prefer persistent direct team id (dteam2), fallback to id_visitor, id_away, team2
    const awayTeamId = String(m.dteam2 || m.id_visitor || m.id_away || m.visitor_id || m.team2?.id || m.team2 || "");
    if (awayTeamId && !teamsMap.has(awayTeamId)) {
      teamsMap.set(awayTeamId, {
        id: awayTeamId,
        name: m.visitor || m.name_away || m.team2?.name || `Team ${awayTeamId}`,
        short_name: m.visitor_abbr || m.team2?.short_name || null,
        crest_url: cleanImageUrl(m.visitor_shield || m.visitor_shield_png || m.shield2 || m.team2?.shield || m.team2?.logo),
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

  // 3. Map and upsert matches with proper persistent team IDs
  const records = rawList
    .filter((m: any) => m.id && (m.dteam1 || m.team1 || m.id_local || m.id_home) && (m.dteam2 || m.team2 || m.id_visitor || m.id_away))
    .map((m: any) => {
      const homeTeamId = String(m.dteam1 || m.id_local || m.id_home || m.local_id || m.team1?.id || m.team1);
      const awayTeamId = String(m.dteam2 || m.id_visitor || m.id_away || m.visitor_id || m.team2?.id || m.team2);
      const homeScore = parseScore(m.result1, m.local_goals, m.result, 0);
      const awayScore = parseScore(m.result2, m.visitor_goals, m.result, 1);
      const status = mapMatchStatus(m.status);

      return {
        provider_match_id: String(m.id),
        competition_id: leagueId,
        home_team_id: homeTeamId,
        away_team_id: awayTeamId,
        kickoff_at: parseKickoffAt(m),
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
 * 4. Sync Matches of the Day / Live Settlement (Endpoint 12: req=matchsday)
 */
async function syncMatchesDay(targetDate?: string): Promise<number> {
  const params: Record<string, string> = { req: "matchsday" };
  if (targetDate) params.date = targetDate;

  const data = await callBeSoccer(params);
  const rawList: any[] = Array.isArray(data)
    ? data
    : data.match || data.matches || data.data || [];

  if (!rawList.length) return 0;

  let updatedCount = 0;

  for (const m of rawList) {
    if (!m.id) continue;
    const providerMatchId = String(m.id);
    const status = mapMatchStatus(m.status);
    const homeScore = parseScore(m.result1, m.local_goals, m.result, 0);
    const awayScore = parseScore(m.result2, m.visitor_goals, m.result, 1);

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
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") || "sync-live";
    const league = url.searchParams.get("league") || "1"; // Default to La Liga / Top League
    const date = url.searchParams.get("date") || undefined;

    const results: Record<string, any> = { action, timestamp: new Date().toISOString() };

    switch (action) {
      case "sync-competitions": {
        results.competitionsSynced = await syncCompetitions();
        break;
      }
      case "sync-teams": {
        results.teamsSynced = await syncTeams(league);
        break;
      }
      case "sync-matches": {
        if (league === "all") {
          let total = 0;
          for (const compId of ALLOWED_COMPETITION_IDS) {
            try {
              total += await syncMatches(compId);
            } catch (e: any) {
              console.warn(`Sync error for comp ${compId}:`, e.message);
            }
          }
          results.matchesSynced = total;
        } else {
          results.matchesSynced = await syncMatches(league);
        }
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
            totalMatches += await syncMatches(compId);
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
