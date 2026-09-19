---
trigger: always_on
---

# SPRINT 4: COMPETITION & TOURNAMENTS

## 1. Leaderboard Logic (Tournament-Scoped)
*   Write SQL views/RPCs to calculate leaderboards based on the `pico_points` column located inside `tournament_participants` (for public events) and `private_league_members` (for private leagues)[cite: 6].
*   Implement dense ranking (1, 2, 2, 3) directly in the SQL query[cite: 6]. Do not calculate rankings on the Flutter client.

## 2. Riverpod Caching & Performant UI
*   Create `leaderboardProvider(String tournamentId)` as an `AsyncNotifier` to fetch the ranked entries.
*   Build the tournament leaderboards using `ListView.builder` for efficient lazy loading[cite: 6]. Ensure the UI clearly shows the user's specific rank and points for *that* specific tournament.