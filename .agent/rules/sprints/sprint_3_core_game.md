---
trigger: always_on
---

# SPRINT 3: CORE GAME & SERVER-SIDE SECURITY

## 1. Prediction UI
*   Build the prediction bottom sheet using "Predict" and "Exact score," strictly avoiding all gambling terminology (e.g., "bet", "odds")[cite: 6]. All text must use `AppLocalizations.of(context)`.

## 2. Zero-Client Trust Locking
*   Write the Supabase RPC or Postgres Trigger to enforce the prediction lock exactly 10 minutes before kickoff. The backend MUST reject any insert/update if `now() >= kickoff_at - 10 minutes`.

## 3. Settlement & Ledgers (Tournament-Scoped Points)
*   Implement match settlement logic writing to transaction ledgers (`pico_point_transactions` and `xp_transactions`)[cite: 6].
*   **Crucial Architectural Rule:** Pico Points are NOT global. When a match settles, the backend must update the `pico_points` balance in `tournament_participants` and `private_league_members` for the specific tournaments that include this match.
*   XP remains global and is updated on the `profiles` table to manage user level progression.