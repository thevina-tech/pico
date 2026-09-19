---
trigger: always_on
---

# PICO SERVER-SIDE SECURITY & DATA ARCHITECTURE

## 1. Zero Client Trust
- Critical operations must happen server-side[cite: 5]. NEVER trust the Flutter client for: Pico Points, XP, Coin balances, Referral activation, Premium status, Prediction locking, or Settlement[cite: 5].
- Predictions lock exactly 10 minutes before scheduled kickoff[cite: 5]. This lock must be enforced by the backend rejecting edits, not just the UI hiding a button[cite: 5].

## 2. Transaction Ledgers
- Do not store flat values without an audit trail (e.g., do not just update `user.pico_points = 583`)[cite: 5].
- Use transaction records: `pico_point_transactions` (+5 exact score, +3 winner) and `xp_transactions` (+10 submit, +5 complete)[cite: 5]. This allows debugging, recalculating, and investigating cheating[cite: 5].

## 3. Data Normalization & Sync
- Do not couple the database directly to BeSoccer's raw object structure[cite: 5]. Use a normalized Pico model (`matches` table with `pico_match_id` and `provider_match_id`)[cite: 5].
- Data is ingested via a scheduled backend job syncing the BeSoccer API into Supabase, followed by a settlement process when matches finish[cite: 5]. Flutter reads ONLY from Supabase[cite: 5].