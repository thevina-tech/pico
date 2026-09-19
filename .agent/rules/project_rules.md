---
trigger: always_on
---

# PICO PRODUCT & SHIPATHON DIRECTIVES

## 1. Product North Star
- Pico is a gamified social football prediction game[cite: 4]. The core promise is to predict real matches, compete in tournaments, and beat friends without betting money[cite: 4].
- Everything in V1 must support the core loop: Discover Match -> Make Prediction -> Lock -> Result Arrives -> Earn Points/XP -> Leaderboard Changes -> Compete[cite: 4].

## 2. Anti-Gambling Lexicon
- The UI must feel like a game, not a sportsbook[cite: 4].
- STRICTLY FORBIDDEN: Betting slips, odds, stake amounts, money symbols, "bet", "wager"[cite: 4].
- MANDATORY TERMS: "Predict", "Pick winner", "Exact score", "Pico Points", "XP", "Tournaments", "Streaks"[cite: 4].

## 3. Shipathon Growth Funnel (Referrals)
- The primary acquisition loop is the referral system[cite: 4]. 
- A referred user only becomes an "Activated Referral" when they: 1) Join through the referral mechanism AND 2) Make their first prediction[cite: 4].
- All UI/UX decisions must minimize friction to get a new user to their first prediction[cite: 4].

## 4. Monetization Authority
- RevenueCat strictly manages the product, subscriptions, and entitlements[cite: 4].
- The Supabase backend MUST NOT invent its own independent subscription truth[cite: 4].
- In-app ads must exist for revenue but must not interfere with the core prediction flow[cite: 4].