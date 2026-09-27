---
trigger: always_on
---

# SPRINT 5: Monetization Integration via Google AdMob + RevenueCat ILRD

## Task Overview
Implement zero-friction AdMob monetization for our Flutter/Supabase prediction app. All core features remain 100% free. 

**Core Constraint:** We are using `google_mobile_ads` to render the ads, but **all ad lifecycle events and revenue data MUST be manually routed through the RevenueCat SDK (`purchases_flutter`)** to capture Impression-Level Revenue Data (ILRD). 

We are testing Android-first. Ensure `purchases_flutter` is version `^10.2.0` or higher to use the AdTracker APIs.

## 1. Global Setup & Security
1. **Manifest:** Inject the `<meta-data>` tag for `com.google.android.gms.ads.APPLICATION_ID` into `android/app/src/main/AndroidManifest.xml`.
2. **Environment Variables:** Load all Unit IDs from `.env`. Use `kDebugMode` to strictly enforce Google's public Test Ad Unit IDs during development to prevent account suspension.
   - `ADMOB_BANNER_DASHBOARD_ANDROID`
   - `ADMOB_NATIVE_MATCH_FEED_ANDROID`
   - `ADMOB_INTERSTITIAL_PRIVATE_LEAGUE_ANDROID`

## 2. Core Service: `lib/services/revenuecat_ad_service.dart`
Create a singleton service to manage SDK initialization and RC tracking.
* **Init & Sync:** Initialize Google Mobile Ads and RevenueCat. Call `Purchases.logIn(supabase.auth.currentUser!.id)` on login.
* **Manual Tracking:** Create wrapper methods to load Banner, Native, and Interstitial ads. Inside the AdMob `AdListener` callbacks, manually route events to RevenueCat (use `// ignore: experimental_member_use` if required by the analyzer):
  * `onAdLoaded` -> `Purchases.adTracker.trackAdLoaded()`
  * `onAdFailedToLoad` -> `Purchases.adTracker.trackAdFailedToLoad()`
  * `onAdImpression` / `onAdShowedFullScreenContent` -> `Purchases.adTracker.trackAdDisplayed()`
  * `onAdClicked` -> `Purchases.adTracker.trackAdOpened()`
* **CRITICAL - ILRD Capture:** Attach an `OnPaidEvent` listener to every ad object. When fired, call `Purchases.adTracker.trackAdRevenue()`. You MUST convert the double revenue into integer micros: `(revenue * 1_000_000).toInt()`.
* **Dimensions:** When calling the trackers, explicitly pass accurate dimensions for RevenueCat Charts v3:
  * `mediatorName`: AdMob
  * `placement`: e.g., `'dashboard_bottom'`, `'match_feed'`, `'private_league_creation'`
  * `adFormat`: e.g., `'banner'`, `'native'`, `'interstitial'`

## 3. Banner Widget: `lib/widgets/ads/banner_ad_widget.dart`
* Implement a sticky adaptive banner widget for the dashboard.
* **Layout:** Constrain the height (e.g., 50–60px) to prevent Cumulative Layout Shift (CLS). If `onAdFailedToLoad` triggers, collapse the height to 0.
* **Lifecycle:** Properly `.dispose()` the `BannerAd` when unmounted.

## 4. Native Feed Widget: `lib/widgets/ads/native_ad_card_widget.dart`
* Implement a `NativeAd` widget designed to match the UI of a standard `MatchCard` (same border-radius, shadows, padding). 
* Include standard compliance UI ("Ad" badge, CTA button). Do not spoof football data.
* **Integration:** In `lib/views/match_feed_view.dart`, modify the scrollable list to dynamically inject this widget at every 6th index using the `ADMOB_NATIVE_MATCH_FEED_ANDROID` key.

## 5. Interstitial Flow
* Add a method to the service to **preload** an `InterstitialAd` (e.g., `loadInterstitialAd()`). 
* Add a method to **show** the ad. Ensure the app degrades gracefully (proceeds silently) if the ad fails to load or show, so the user is never trapped.
* Dispose of the interstitial ad inside `onAdDismissedFullScreenContent`.