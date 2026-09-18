# PICO V1 - FUNCTIONAL SPECIFICATION

**Version:** 0.1 - Build Blueprint
**Status:** Ready for product/technical review
**Platform:** iOS + Android
**Framework:** Flutter
**Backend:** Supabase
**Football data:** BeSoccer API
**Monetization:** RevenueCat + In app ads
**Primary objective:** Ship a real, playable football prediction game and generate measurable social/referral growth within the 14-day Shipaton window.

---

## 1. PRODUCT NORTH STAR

### Core promise
Predict real football matches, compete in tournaments, and beat your friends without betting money.

### Core loop
`DISCOVER MATCH` ↓
`MAKE PREDICTION` ↓
`PREDICTION LOCKS` ↓
`WATCH REAL MATCH` ↓
`RESULT ARRIVES` ↓
`EARN PICO POINTS + XP` ↓
`LEADERBOARD CHANGES` ↓
`COMPETE/ SHARE` ↓
`RETURN FOR NEXT MATCH`

Everything in V1 should support this loop.

---

## 2. APP INFORMATION ARCHITECTURE

**Recommended bottom navigation:**
```text
|         CONTENT         |
|-------------------------|
| Home | Matches | Tournaments | Profile |
```

### Primary sections

*   **Home**
    *   Personalized match feed
    *   Match of the Day
    *   Current streak
    *   Level/XP
    *   Active tournaments
*   **Matches**
    *   Search
    *   Teams
    *   Leagues
    *   Upcoming matches
    *   Prediction access
*   **Tournaments**
    *   Events
    *   Leagues
    *   Private Leagues
    *   Leaderboards
*   **Profile**
    *   Mascot
    *   Level
    *   XP
    *   Streak
    *   Trophies
    *   Teams
    *   Tournaments
    *   Prediction history

*Note: Private League creation/joining can be accessible from Tournaments and relevant contextual CTAs.*

---

## 3. FIRST-TIME USER JOURNEY

The first session is extremely important. We want the user to reach their first prediction quickly.

**Flow:**
`OPEN PICO` ↓ `WELCOME` ↓ `MASCOT` ↓ `WHAT IS PICO?` ↓ `CHOOSE TEAM/INTERESTS` ↓ `CREATE ACCOUNT/LOGIN` ↓ `FIRST MATCH` ↓ `MAKE FIRST PREDICTION` ↓ `PREDICTION CONFIRMED` ↓ `"YOU'RE IN!"` ↓ `JOIN/CREATE PRIVATE LEAGUE` ↓ `INVITE FRIENDS`

---

## 4. ONBOARDING SCREEN 1: WELCOME

**Purpose:** Establish Pico's identity.

**Content:**
*   Pico mascot
*   Pico logo
*   Short headline
*   Primary CTA

**Suggested copy:**
> Think you know football?
> Predict real matches.
> Climb the leaderboard.
> Beat your friends.

**CTA:** Let's Play

---

## 5. ONBOARDING SCREEN 2: HOW PICO WORKS

Three simple concepts:
1.  **Predict:** Pick the winner and exact score.
2.  **Compete:** Earn Pico Points and climb tournaments.
3.  **Win:** Beat your friends and collect trophies.

**CTA:** Start Predicting
*No long tutorial.*

---

## 6. TEAM/INTEREST SELECTION

User can choose:
*   Favorite team
*   Favorite leagues
*   Potentially favorite events

This personalizes Home and Matches.

**Important:** Selection should not prevent the user from exploring the rest of Pico.

---

## 7. ACCOUNT

We need persistent accounts because progression, predictions, leagues and referrals need to survive across devices.

**Account options (TBD during technical implementation):**
*   Apple
*   Google
*   Email
*   Guest → upgrade to account

*For V1, we should minimize authentication friction.*

---

## 8. FIRST PREDICTION

This is the activation moment. The user sees a real upcoming match.

**Example:**
```text
REAL MADRID VS BARCELONA

Who wins?
[Real Madrid]  [Draw]  [Barcelona]

Exact score
[ 2 ] - [ 1 ]

[ PREDICT ]
```

**Important:** The prediction UI should feel like a game, not a betting slip.
**Avoid:** Odds, Betting terminology, Money symbols, "Stake", "Bet", Gambling visual language.

---

## 9. PREDICTION CONFIRMATION

After submitting:
> Prediction locked in!

**Display:**
*   Real Madrid 2-1 Barcelona
*   Winner: Real Madrid
*   Potential Pico Points: TBD

The user should immediately understand: *I have participated.*

---

## 10. PREDICTION STATES

Every prediction needs explicit states:

`UPCOMING` ↓ `OPEN` ↓ `SUBMITTED` ↓ `LOCKED` ↓ `MATCH LIVE` ↓ `FINISHED` ↓ `SETTLED`

**Potential exceptional states:**
*   Cancelled
*   Postponed
*   Suspended
*   Data unavailable
*(These need backend handling.)*

---

## 11. PREDICTION LOCK

**Current rule:** Predictions lock before kickoff.
**Our working implementation:** 10 minutes before scheduled kickoff.

**At lock:**
*   Prediction becomes immutable.
*   UI changes to "Locked".
*   Backend rejects edits.
*   User cannot submit another prediction.

**Security principle:** Locking must be enforced server-side, not only by Flutter.

---

## 12. MATCH RESULT

When the football match finishes:

`BeSoccer` ↓ `Result received` ↓ `Backend validates` ↓ `Prediction settlement` ↓ `Pico Points calculated` ↓ `XP calculated` ↓ `Leaderboard updated` ↓ `Streak updated`

**The user then sees:**
> **Your prediction:** Real Madrid 2-1 Barcelona
> **Final result:** Real Madrid 2-1 Barcelona
> **Exact score!**
> +5 Pico Points
> +25 XP

---

## 13. SCORING SYSTEM - LOCKED

**Pico Points Outcome:**
*   Wrong prediction: 0
*   Correct winner: +3
*   Correct exact score: +5 total

*Exact score does not add another +3. Therefore: Exact score = 5 total Pico Points. No negative points.*

---

## 14. XP SYSTEM - LOCKED

| Action | XP |
| :--- | :--- |
| Submit prediction | +10 |
| Match completed | +5 |
| Correct winner | +5 |
| Exact score | +10 |

**So an exact-score prediction can generate:**
*   Prediction submitted: +10 XP
*   Correct winner: +5 XP
*   Exact score: +10 XP
*   Match completed: +5 XP
*   **TOTAL: +30 XP**

*XP is not used to determine tournament ranking.*

---

## 15. XP LEVELS

XP should generate user levels.

**Example:**
*   LEVEL 1: 0 XP
*   LEVEL 2: 100 XP
*   LEVEL 3: 250 XP

**Still to design:** The exact level progression curve.
We don't need this to block the core prediction architecture, so the Coding agent can initially implement a configurable level table.

---

## 16. HOME SCREEN

Home is not a dashboard full of information. Its job is: *Get the user to their next prediction.*

**Recommended hierarchy:**
```text
[LEVEL 12] [Streak: 7]
GOOD MORNING, JOÃO

UPCOMING PREDICTIONS
Real Madrid
vs
Barcelona

Predict by 19:50
[ PREDICT ]

YOUR TOURNAMENTS
[Premier League] [World Cup] [Friends League]

MATCH OF THE DAY
```

---

## 17. MATCHES

**Main functions:**
*   Search
*   Browse leagues
*   Browse teams
*   View matches
*   Predict

**Match card must clearly communicate:**
*   Teams
*   Competition
*   Kickoff
*   States: Prediction status, Lock countdown, User prediction if submitted. (Predict, Predicted, Locked, Live, Finished)

---

## 18. TOURNAMENTS

This is one of Pico's central screens.

**Top-level tabs/categories:**
`TOURNAMENTS` | `[ALL]` | `EVENTS` | `LEAGUES` | `PRIVATE`

**Each tournament card displays:** Name, Type, Status, Participants where relevant, User position, Current points, CTA.

---

## 19. TOURNAMENT DETAIL

**Example (Public):**
```text
WORLD CUP
Your position: #128 | Your points: 184
[MATCHES] [LEADERBOARD]

Upcoming matches...
Leaderboard...
1. João
2. Maria
3. Pedro
```

**Private League version:**
```text
JOÃO'S LEAGUE
12 PLAYERS
[MATCHES] [LEADERBOARD]
Your position: #3

[INVITE FRIENDS]
```

---

## 20. JOIN TOURNAMENT

*   **For public Events/Leagues:** Participate
*   **For Private Leagues:** Join Private League (User can enter Code or Link).

*Deep links should ideally open Pico directly into the relevant league.*

---

## 21. CREATE PRIVATE LEAGUE

**Flow:**
`Tournaments` ↓ `Create Private League` ↓ `Name League` ↓ `Confirm` ↓ `League created` ↓ `Invitation screen`

**V1 fields:** League name.
*(Potential future fields: Tournament scope, Start/end, Entry requirements, Custom rules, Coin cost)*

---

## 22. PRIVATE LEAGUE LIMIT

**Locked V1 rule:** First 10 Private Leagues are free. Additional leagues may require Coins in the future.

For V1, we should track: `user.private_leagues_created` and enforce the limit server-side.

---

## 23. INVITATION SYSTEM

Every Private League gets:
*   **Unique code:** Example: `PICO-JOAO92`
*   **Deep link:** Example concept: `pico://league/PICO-JOAO92` (exact domain TBD)

**Share options:**
Use the native mobile share sheet for V1. (WhatsApp, Instagram, Messenger, SMS, Copy link, Other installed apps).

---

## 24. REFERRAL SYSTEM

This is a core V1 growth system.

**Referral definition:**
A referred user becomes an Activated Referral only when:
1. They join/signup through the referral mechanism.
2. They make their first prediction.

Only then does the referrer receive referral credit.

---

## 25. REFERRAL TRACKING

**Conceptually:**
*   `Referral`
    *   `referrer_user_id`
    *   `referred_user_id`
    *   `source`
    *   `created_at`
    *   `activated_at`
    *   `status`
    *   `reward_status`

**Statuses:** CLICKED, JOINED, ACTIVATED, REWARDED.
*(Exact implementation depends on the auth/deep-link architecture.)*

---

## 26. REFERRAL REWARD ENGINE

We will make rewards configurable.

**Example proposed rewards:**
*   2 activated users → 2 months Premium
*   5 activated users → 6 months Premium
*   10-20 activated users → 1 year Premium

*These remain configurable until growth testing tells us what works.*

---

## 27. WHY THIS MATTERS FOR SHIPATON

This gives Pico a measurable acquisition loop. We can demonstrate:
`User A joins Pico` ↓ `User A creates Private League` ↓ `User A shares it` ↓ `5 friends join` ↓ `Friends make predictions` ↓ `Competition begins` ↓ `User A earns Premium` ↓ `Those users create/share their own leagues`.

That's much stronger than simply showing a prediction UI.

---

## 28. LEADERBOARD

**Ranking:**
*   Primary sorting: Pico Points descending.
*   Potential secondary tie handling: Same points = same rank/reward. (Original brief establishes equal-score users sharing podium).

**Display Example:**
1. João (580)
2. Maria (560)
3. Pedro (560)
4. Ana (545)
5. Lucas (530)

*(Need to decide between competition ranking [1,2,2,4] or dense ranking [1,2,2,3]).*

---

## 29. TOURNAMENT FINISH

When a Tournament ends:
`Tournament` ↓ `Final results` ↓ `Leaderboard frozen` ↓ `Winner determined` ↓ `Rewards distributed` ↓ `Trophy awarded` ↓ `Victory screen` ↓ `Share banner`

---

## 30. TROPHY CABINET

Profile includes: Trophy Cabinet.

**Trophy objects should contain:**
`trophy_id`, `tournament_id`, `name`, `image`, `awarded_at`, `rank`.

**Example:**
> World Cup Champion
> #1 - 2026

---

## 31. PROFILE

**Minimum:**
Mascot, Level, XP, Streak, Trophies, Teams, Tournaments, Last 10 predictions.

**Potential:** Total Pico Points, Career stats, Win rate, Exact-score rate.

*Don't let profile become a social network in V1.*

---

## 32. FRIEND PREDICTIONS

Private League participants can see each other's predictions **after** the match.

*   **Before the match:** `João Prediction: Hidden`
*   **After the match:** `João predicted Real Madrid 2-1 Barcelona`

This protects the competitive integrity of the prediction.

---

## 33. VICTORY BANNER

Triggered by important achievements (Winning League, Tournament, Major leaderboard stat, Streak).

**Example:**
> I WON MY PICO LEAGUE
> João finished #1
> Can you beat me?
> [Share]

This should produce an image/card suitable for social sharing.

---

## 34. ADS

Ads are part of the business model. However: **Ads must not interfere with the core prediction flow.**

**Potential placements:**
*   Between content
*   Post-match
*   Optional reward/ad experiences
*   Other non-disruptive areas

---

## 35. PREMIUM

V1 architecture supports Premium (Additional prediction types, Reduced/removed ads). The exact commercial package remains configurable.

**RevenueCat manages:**
Product, Subscription, Entitlement, Purchase, Restore, Subscription status.

*The backend should not invent its own independent subscription truth.*

---

## 36. COINS

Coins exist in the architecture but should not dominate V1.

**Potential uses:** Additional Private Leagues, Mascot customization, Future features, Potential reward mechanics.
*Do not make Coins necessary to enjoy the core game.*

---

## 37. SUPABASE ARCHITECTURE

**Recommended high-level structure:**
*   **Flutter** -> **Supabase** (Auth, PostgreSQL, Storage, Realtime, Edge Functions) <- **BeSoccer API**
*   **Flutter** -> **RevenueCat**

---

## 38. INITIAL DATABASE ENTITIES

At minimum:
*   `profiles`: User-facing profile.
*   `teams`: Football teams.
*   `competitions`: Football competitions from data provider.
*   `tournaments`: Pico tournaments.
*   `tournament_participants`: Users participating in tournaments.
*   `matches`: Football matches.
*   `predictions`: User predictions.
*   `prediction_results`: Settlement/calculation data.
*   `private_leagues`: Private tournament metadata.
*   `private_league_members`: Membership.
*   `referrals`: Referral relationships.
*   `referral_rewards`: Rewards issued.
*   `xp_transactions`: Every XP change.
*   `pico_point_transactions`: Every competitive score change.
*   `coin_transactions`: Future economy ledger.
*   `trophies`: Available trophies.
*   `user_trophies`: Awarded trophies.
*   `streaks`: Current/historical streak data.
*   `subscriptions/entitlements`: Only if needed for cached state (RevenueCat is authority).

---

## 39. IMPORTANT DATABASE PRINCIPLE

Do not store only: `user.pico_points = 583` without an audit trail.
**Prefer transaction records.**

Example `pico_point_transactions`:
*   +5 exact score
*   +3 winner
*   +0 incorrect

This allows debugging, recalculation, cheat investigation, error correction, and analytics. Same for XP and Coins.

---

## 40. SERVER-SIDE SECURITY

**Critical operations must happen server-side.** Never trust the Flutter client for:
*   Pico Points / XP / Coin balances
*   Referral activation / Premium status
*   Prediction locking / Prediction settlement
*   Tournament ranking / Trophy awarding

*The client requests an action. The backend verifies and performs it.*

---

## 41. BE SOCCER SYNC

We need a backend synchronization process.

**Conceptually:**
`Scheduled job` ↓ `BeSoccer API` ↓ `Fetch competitions` ↓ `Fetch matches` ↓ `Normalize` ↓ `Supabase`

**Result Sync:**
`Finished matches` ↓ `Fetch final result` ↓ `Validate` ↓ `Settle predictions`

---

## 42. DATA NORMALIZATION

Create Pico's own normalized model rather than depending directly on BeSoccer's structure.

**Example `Pico Match`:**
`pico_match_id`, `provider_match_id`, `home_team_id`, `away_team_id`, `competition_id`, `kickoff_at`, `status`, `home_score`, `away_score`.

*This gives us the ability to change football-data providers later.*

---

## 43. ADMIN

V1 Admin should prioritize operations.

*   **Dashboard:** Active users, Predictions, Matches, Tournaments, Private leagues, Users, Referrals, Errors.
*   **Matches:** Upcoming, Live, Finished, Sync status.
*   **Tournaments:** Manage, Inspect, Leaderboards.
*   **Private Leagues:** Search, Inspect, Moderate.
*   **Referral:** View referral funnel, Activated users, Rewards.

---

## 44. ANALYTICS EVENTS

Implement analytics as part of the feature rather than after launch.

**Important events:**
`app_opened`, `onboarding_started`, `onboarding_completed`, `account_created`, `team_selected`, `match_viewed`, `prediction_started`, `prediction_submitted`, `prediction_locked`, `prediction_result_viewed`, `tournament_viewed`, `tournament_joined`, `private_league_created`, `private_league_joined`, `private_league_invite_shared`, `referral_link_opened`, `referral_signup`, `referral_first_prediction`, `referral_activated`, `referral_reward_granted`, `tournament_won`, `trophy_awarded`, `victory_shared`, `premium_viewed`, `purchase_started`, `purchase_completed`.

---

## 45. THE CORE GROWTH FUNNEL

Analytics should let us calculate:
`INSTALLS` ↓ `ONBOARDING` ↓ `ACCOUNT` ↓ `FIRST PREDICTION` ↓ `PRIVATE LEAGUE` ↓ `INVITE` ↓ `REFERRED USER` ↓ `FIRST PREDICTION` ↓ `ACTIVATED REFERRAL`

*This becomes one of our main Shipaton metrics.*

---

## 46. QA PRINCIPLES

QA AI should test the rules, not just whether screens render.

**Critical tests:**
*   **Prediction:** Can predict? Cannot predict/edit after lock? Correct score/winner/incorrect settlement? Postponed/Cancelled matches?
*   **Competition:** Join tournament, Leave where allowed, Multiple tournaments, Leaderboard ranking & Ties, Tournament completion.
*   **Private League:** Create, Join, Invalid code, Duplicate membership, 10-league limit, Invitation attribution.
*   **Referral:** Link tracking, Signup, First prediction, Activation, Reward, Duplicate referral abuse.
*   **Economy:** XP, Pico Points, Coins, Premium.

---

## 47. ANTI-CHEAT/INTEGRITY

Because Pico is competitive, assume users will try to exploit it.

**V1 basics:**
*   Server-side prediction locking & scoring.
*   Immutable prediction after lock.
*   Server-side XP, referral activation, and leaderboard calculation.
*   Audit logs.

---

## 48. DESIGN DIRECTION

**Pico should feel:** Football + game + competition
**Not:** sportsbook + gambling

**Design principles:**
Bold, Playful, Fast, Mobile-first, Mascot-driven, Strong hierarchy, Clear calls to action, Visually rewarding, Minimal friction.

*The UI itself should be one of the things judges remember.*

---

## 49. WHAT THE UI/UX AGENT SHOULD NOW DO

Produce the following sequentially:
1. Information architecture
2. User flows
3. Low-fidelity wireframes
4. Design system
5. High-fidelity screens
6. Interactive prototype
7. Developer-ready specifications

*(Do not invent game rules. Escalate product decisions to Product/Manager AI).*

---

## 50. WHAT THE CODING AGENT SHOULD NOW DO

**Order of operations:**
*   **Sprint 0 - Foundation:** Flutter, Supabase, Environments, GitHub, CI, Secrets, Architecture.
*   **Sprint 1 - Data:** BeSoccer integration, Normalized match model, Sync jobs.
*   **Sprint 2 - User:** Auth, Profile, Teams.
*   **Sprint 3 - Core game:** Match, Prediction, Lock, Settlement, XP, Pico Points.
*   **Sprint 4 - Competition:** Tournaments, Leaderboards, Private Leagues.
*   **Sprint 5 - Growth:** Referral, Sharing, Victory banners.
*   **Sprint 6 - Monetization:** RevenueCat, Premium, Ads architecture.
*   **Sprint 7 - QA:** Automated/Integration/Production testing.

---

## 51. WHAT THE QA AGENT SHOULD DO

QA starts before Sprint 7.
**For every feature:**
`Requirement` ↓ `Acceptance criteria` ↓ `Test cases` ↓ `Implementation` ↓ `Automated test` ↓ `Manual validation` ↓ `Human approval`

*No "we'll test everything at the end."*

---

## 52. WHAT THE BUSINESS/GROWTH AGENT SHOULD DO

While Coding is happening, prepare:
Landing page, Social accounts/content, Build-in-public strategy, Referral/Launch messaging, Influencer/community outreach, KPI dashboard, User feedback collection, Growth experiments.

*Promotion should start before launch.*

---

## 53. THE 14-DAY TEAM OPERATING MODEL

We run the project as parallel workstreams coordinated by the Manager AI:

```text
       PRODUCT / MANAGER
               |
  +------------+-------------+
  ▼            ▼             ▼
UI/UX        CODING        GROWTH
  |            |             |
  +------------+-------------+
               |
               QA
         HUMAN APPROVAL
             RELEASE
            REAL USERS
            ANALYTICS
               |
           ITERATION
```

*Humans remain the final decision-makers.*

---

## 54. IMMEDIATE NEXT ACTIONS

**Sequence:**
1.  **NOW:** Finalize this Functional Specification
2.  Create the screen-by-screen UX specification
3.  Create the Supabase database schema
4.  Create the API/football-data specification
5.  Create the AI-agent operating specification
6.  Create the development backlog
7.  Start parallel UI + backend/core development

---

## 55. CURRENT BLOCKERS

**Product:** Exact XP level progression, Tie ranking display, Exact trophy distribution, Streak definition.
**Technical:** Supabase project configuration, BeSoccer API access/limitations, Authentication provider, Analytics provider, RevenueCat products/entitlements.
**Business:** Exact Premium package, Referral reward values, Ad strategy.

*Everything else can be iterated.*

---

## 56. THE RULE FOR THE REST OF THE PROJECT

If a decision isn't necessary to build V1, we don't spend hours deciding it. We make the simplest reasonable implementation, keep it configurable where possible, ship, and learn.

**Next: UX + screen specification.**
Go one level deeper and define every single V1 screen and flow, including what the user sees in every state. Hand the result directly to the UI/UX agent.