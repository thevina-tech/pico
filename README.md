# Pico

A gamified social football prediction game where players predict real match scores, earn Points & XP, compete on leaderboards, and challenge friends in private leagues—without betting money.

---

## How to Run Locally

Follow these quick steps to get the app running on an emulator or connected device in under a minute.

### 1. Prerequisites
- **Flutter SDK** (3.24+ recommended) installed and configured on your machine.
- An active Android emulator, iOS simulator, or connected physical device.
- Verify your environment setup:
  ```bash
  flutter doctor
  ```

### 2. Environment Variables
Create a `.env` file in the root directory (or use `.env.dev`) and supply your API keys for **Supabase**, **RevenueCat**, and **API-Football**:

```env
# Supabase Backend
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# In-App Purchases (RevenueCat)
REVENUECAT_API_KEY=your-revenuecat-public-key

# Football Data Provider (API-Football / BeSoccer)
FOOTBALL_API_KEY=your-football-api-key
```

### 3. Install Dependencies
Fetch the project packages and dependencies:

```bash
flutter pub get
```

### 4. Run the App
Launch the application on your target device:

```bash
flutter run
```

---

## Tech Stack & Architecture
- **Framework:** Flutter & Dart (Null-Safe, Feature-First Architecture)
- **State Management:** Riverpod (`@riverpod` code generation)
- **Navigation:** `go_router` with `StatefulShellRoute`
- **Backend & Database:** Supabase (Auth, PostgreSQL, Realtime)
- **Monetization:** RevenueCat (Subscriptions & Paywalls) + Google Mobile Ads
- **Localization:** Flutter `gen-l10n` (English & Spanish)
