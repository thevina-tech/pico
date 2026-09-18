# DART & PROJECT CONVENTIONS

## 1. Immutability & Domain Models
- All domain entities (e.g., `PicoMatch`, `UserProfile`, `Tournament`) must be strongly typed, null-safe, and immutable. 
- Use factory constructors (e.g., `fromJson`) to parse data, handling all type casting and default fallbacks safely. No untyped `dynamic` variables in business logic.

## 2. Global Error Handling & Logging
- Implement a centralized `AppLogger`. Never leave naked `print()` statements in production code.
- Wrap all network and Supabase calls in `try/catch` blocks.
- Return explicit `Result<T>` types or throw custom exceptions from Repositories. The UI must catch these and display user-friendly error states (e.g., "Check your connection") rather than failing silently.

## 3. Analytics Instrumentation
- Analytics must be built into the features immediately, not bolted on post-launch.
- Core funnels must log events precisely: `app_opened`, `account_created`, `match_viewed`, `prediction_submitted`, `private_league_joined`, `referral_activated`.