# PICO PRODUCT & SHIPATHON DIRECTIVES

## 1. Product North Star
- Pico is a gamified social football prediction game. The core promise is to predict real matches, compete in tournaments, and beat friends without betting money.
- Everything in V1 must support the core loop: Discover Match -> Make Prediction -> Lock -> Result Arrives -> Earn Points/XP -> Leaderboard Changes -> Compete.

## 2. Anti-Gambling Lexicon
- The UI must feel like a game, not a sportsbook.
- STRICTLY FORBIDDEN: Betting slips, odds, stake amounts, money symbols, "bet", "wager".
- MANDATORY TERMS: "Predict", "Pick winner", "Exact score", "Pico Points", "XP", "Tournaments", "Streaks".

## 3. Shipathon Growth Funnel (Referrals)
- The primary acquisition loop is the referral system. 
- A referred user only becomes an "Activated Referral" when they: 1) Join through the referral mechanism AND 2) Make their first prediction.
- All UI/UX decisions must minimize friction to get a new user to their first prediction.

## 4. Monetization Authority
- RevenueCat strictly manages the product, subscriptions, and entitlements.
- The Supabase backend MUST NOT invent its own independent subscription truth.
- In-app ads must exist for revenue but must not interfere with the core prediction flow.