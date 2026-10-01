---
trigger: always_on
---

# SPRINT 0: FOUNDATION, MIGRATION & i18n

## 1. Dependency Updates & Cleanup
*   **Remove:** `provider` from `pubspec.yaml`.
*   **Add/Update:** `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `build_runner`.
*   **Add:** `supabase_flutter`, `go_router`, `talker_flutter`.
*   **Add:** `flutter_localizations` and `intl`.

## 2. Localization Setup (ARB Files)
Configure `flutter_localizations` to support English and Spanish natively.
*   Update `pubspec.yaml` to include `generate: true`.
*   Create `l10n.yaml` with `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, and `output-localization-file: app_localizations.dart`.
*   Create `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`. Define keys like `"predictButton": "Predict"` (EN) and `"predictButton": "Predecir"` (ES).
*   Wrap `MaterialApp` with `localizationsDelegates` and `supportedLocales`.

## 3. Architecture & Routing
*   Enforce `lib/features/<name>/{data,domain,presentation}`[cite: 6].
*   Implement `go_router` using a `StatefulShellRoute` for the bottom navigation (Home, Matches, Tournaments, Profile)[cite: 6].

## 4. Supabase Initialization
*   Initialize the single Supabase environment and configure local secure secrets[cite: 6].
*   Create `supabaseClientProvider` in Riverpod.