---
trigger: always_on
---

# SPRINT 6: MONETIZATION

## 1. RevenueCat Integration
*   Integrate the RevenueCat SDK (`purchases_flutter`) to manage the Premium product and entitlements[cite: 6].
*   Create a `revenueCatProvider` to expose subscription status to the Flutter UI. Ensure the Supabase backend defers entirely to RevenueCat as the source of truth for subscription status[cite: 6].

## 2. Google AdMob Integration
*   Integrate `google_mobile_ads`.
*   Implement non-disruptive ad placements (e.g., standard bottom banners on leaderboards, or interstitial ads *only* after a match settlement is viewed)[cite: 6]. Do not interfere with the core prediction flow[cite: 6].