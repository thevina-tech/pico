# PICO SENIOR FLUTTER ENGINEER CONSTRAINTS

## 1. Directory Layout & Routing
- Strict feature-first architecture: `lib/features/<feature_name>/{data,domain,presentation}`.
- Routing: Use `go_router` exclusively. The core shell (Home, Matches, Tournaments, Profile) must use `StatefulShellRoute` to preserve state across tabs.

## 2. State Management (Provider)
- Use `Provider` strictly with the Repository Pattern. UI widgets must NEVER talk to Supabase or HTTP clients directly.
- NEVER call `context.watch<T>()` at the top level of a screen or in build methods of large widgets.
- ALWAYS use `context.select<T, R>((state) => state.subField)` or wrap only the leaf widgets in granular `Consumer<T>` blocks.
- ViewModels/ChangeNotifiers must extend `SafeChangeNotifier` (which checks `hasListeners` and `!disposed` before `notifyListeners()`).
- Keep state variables private with public unmodifiable getters (e.g., `List<PicoMatch> get matches => List.unmodifiable(_matches)`).
- Never place UI business logic in screens. Screens are dumb display layers.

## 3. UI & Performance Directives
- Tone: Playful, bold, competitive, mobile-first.
- Lists: All feeds displaying matches or leaderboards must use `ListView.builder` with pagination/lazy loading to maintain 60fps.
- Assets: Always use `CachedNetworkImage` with fallback asset placeholders for badges and team logos. Strip query parameters (like `&v=`) from BeSoccer image URLs before passing them to the caching layer.