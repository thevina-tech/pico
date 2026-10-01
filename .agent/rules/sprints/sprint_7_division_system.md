---
trigger: always_on
---

# TASK: Refactor Progression System to Division Ladder & Tiered Scoring

## Overview
Deprecate all legacy gamification elements (Coins, Streaks, Levels, and raw XP). Replace them with a unified **Prediction Points (PP)** system where a user's total points determine both their global leaderboard standing and their current **Division** (from Division 10 up to Elite Division).

---

## 1. Database Schema Refactor (Supabase)

### A. Profiles Table Cleanup
* Remove or deprecate columns related to legacy mechanics: `coins`, `streak_count`, `level`, and `xp`.
* Maintain a single source of truth for progression: `total_points` (integer, default `0`).

### B. Tier Mapping (Calculation / View)
Compute the user's division based on their cumulative `total_points` using standard threshold brackets:
* **`div_10`** (Division 10): 0 – 49 pts
* **`div_9`** (Division 9): 50 – 119 pts
* **`div_8`** (Division 8): 120 – 219 pts
* **`div_7`** (Division 7): 220 – 349 pts
* **`div_6`** (Division 6): 350 – 499 pts
* **`div_5`** (Division 5): 500 – 699 pts
* **`div_4`** (Division 4): 700 – 949 pts
* **`div_3`** (Division 3): 950 – 1249 pts
* **`div_2`** (Division 2): 1250 – 1599 pts
* **`div_1`** (Division 1): 1600 – 1999 pts
* **`elite`** (Elite Division): 2000+ pts

Expose this tier identifier as a computed field or database function (e.g., `current_division_key`) that returns the programmatic key string (e.g., `'div_4'`).

---

## 2. Match Scoring Engine

When evaluating finished fixtures, calculate awarded points without deductions for misses:

* **Exact Score (5 Points):**
  * Predicted Home == Actual Home AND Predicted Away == Actual Away.
* **Correct Outcome + Goal Difference (3 Points):**
  * Outcome matches (Home Win / Draw / Away Win) AND (Predicted Home - Predicted Away) == (Actual Home - Actual Away), but exact score did not match.
* **Correct Outcome Only (1 Point):**
  * Outcome matches (Home Win / Draw / Away Win), but goal difference and score line differ.
* **Incorrect Outcome (0 Points):**
  * Prediction missed the match result completely.

*Note: Design the calculation function to accept additional modular rules in future updates (e.g., first goalscorer, card tallies) without breaking the core outcome score.*

---

## 3. Localization & UI Integration (Flutter)

### A. Localization Keys (`.arb`)
Add translation entries for all division keys rather than returning translated strings from the backend:
* `div_10`: "Division 10" (EN) / "10ª División" (ES)
* ...
* `div_1`: "Division 1" (EN) / "1ª División" (ES)
* `elite`: "Elite Division" (EN) / "División Élite" (ES)

### B. UI Updates
* **Profile & Header Screens:** Remove coin counters and streak badges. Display the user's current Division badge, division title, and progress bar toward the next division threshold (e.g., "140 / 220 pts to Division 7").
* **Leaderboard Screen:** Ensure ranking order is sorted descending by `total_points`, rendering each player's respective division badge alongside their points.