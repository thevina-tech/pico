---
trigger: always_on
---

# DART & PROJECT CONVENTIONS

## 1. Immutability & Domain Models
- All domain entities (e.g., `PicoMatch`, `UserProfile`, `Tournament`) must be strongly typed, null-safe, and immutable[cite: 2]. 
- Use the `@freezed` package for robust immutability and copy-with generation.
- Use factory constructors (e.g., `fromJson`) to parse data, handling all type casting and default fallbacks safely[cite: 2]. No untyped `dynamic` variables in business logic[cite: 2].

## 2. Global Error Handling & Logging
- Implement a centralized `AppLogger` (e.g., using `talker_flutter`). Never leave naked `print()` statements in production code[cite: 2].
- Wrap all network and Supabase calls in `try/catch` blocks[cite: 2].
- Return explicit `Result<T>` types or throw custom exceptions from Repositories[cite: 2]. The UI must catch these and display user-friendly error states (e.g., "Check your connection") rather than failing silently[cite: 2].

## 3. Analytics Instrumentation
- Analytics must be built into the features immediately, not bolted on post-launch[cite: 2].
- Core funnels must log events precisely: `app_opened`, `account_created`, `match_viewed`, `prediction_submitted`, `private_league_joined`, `referral_activated`[cite: 2].