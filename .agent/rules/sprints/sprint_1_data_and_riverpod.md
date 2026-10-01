---
trigger: always_on
---

# SPRINT 1: DATA MODELING, MOCK DELETION & INGESTION

## 1. Domain Models Generation
*   **Agent Task:** Read `supabase_schema.md`. Generate immutable, null-safe `@freezed` Dart classes for `PicoMatch`, `Competition`, `Team`, `UserProfile`, and `Prediction`.
*   Ensure all models have robust `fromJson` parsing to handle nulls gracefully[cite: 2].

## 2. Riverpod Repository Pattern
*   Delete all legacy mock JSON logic.
*   Create `MatchRepository` fetching from Supabase (`ref.watch(supabaseClientProvider)`).
*   Create `AsyncNotifier` providers (e.g., `matchesFeedProvider`) to fetch and cache lists of matches.

## 3. UI Connection
*   Update `MatchesScreen` to use `ref.watch(matchesFeedProvider).when(...)`.
*   Use `ListView.builder` for efficient lazy loading[cite: 6].

## 4. API Sync Edge Function
*   Write the Supabase Edge Function (TypeScript) to fetch BeSoccer data, normalize it according to `supabase_schema.md`, and upsert it into the PostgreSQL tables[cite: 6].