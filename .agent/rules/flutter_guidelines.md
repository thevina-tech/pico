---
trigger: always_on
---

# PICO SENIOR FLUTTER ENGINEER CONSTRAINTS

## 1. Directory Layout & Routing
- Strict feature-first architecture: `lib/features/<feature_name>/{data,domain,presentation}`[cite: 3].
- Routing: Use `go_router` exclusively[cite: 3]. The core shell (Home, Matches, Tournaments, Profile) must use `StatefulShellRoute` to preserve state across tabs[cite: 3].

## 2. State Management (Riverpod)
- Use Riverpod strictly with the Repository Pattern. UI widgets must NEVER talk to Supabase or HTTP clients directly.
- Use code generation (`@riverpod`) exclusively for providers to ensure predictable scoping and auto-disposal.
- ViewModels/Controllers must extend `_$YourController` and return `AsyncValue<T>`.
- UI must elegantly handle all `AsyncValue` states (`.when(data: ..., loading: ..., error: ...)`).
- Never place UI business logic in screens. Screens are dumb display layers.

## 3. UI & Performance Directives
- Tone: Playful, bold, competitive, mobile-first[cite: 3].
- Lists: All feeds displaying matches or leaderboards must use `ListView.builder` with pagination/lazy loading to maintain 60fps[cite: 3].
- Assets: Always use `CachedNetworkImage` with fallback asset placeholders for badges and team logos[cite: 3]. Strip query parameters (like `&v=`) from BeSoccer image URLs before passing them to the caching layer[cite: 3].

## 4. Code Simplicity & Readability (No Flashy Syntactic Sugar)
- Prioritize clear, simple, and readable programming syntax over clever, cryptic, or over-engineered syntactic sugar[cite: 3].
- Prefer explicit, standard control flow (clear `if/else`, standard loops, clean method bodies) over dense nested ternaries, convoluted pattern matching, or hard-to-read functional one-liners[cite: 3].
- Write clean, straightforward constructors, models, and methods that any developer can read and understand at a glance[cite: 3].
- Avoid unnecessary "flashy" syntax or language tricks when standard, direct Dart gets the job done cleanly and maintainably[cite: 3].