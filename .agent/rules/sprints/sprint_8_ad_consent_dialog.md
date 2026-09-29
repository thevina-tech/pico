---
trigger: always_on
---

# TASK: Implement GDPR/CPRA Ad Consent Dialog (Google UMP via Google Mobile Ads)

## Overview
To comply with GDPR and CPRA for our ad monetization, we need to implement Google's User Messaging Platform (UMP) SDK. We must request user consent *before* initializing the Google Mobile Ads SDK. 

**Important:** Do NOT use the deprecated `user_messaging_platform` package. UMP is now fully integrated directly into the `google_mobile_ads` Flutter package.

## Instructions

### 1. Consent Initialization Service
Create a service (e.g., `AdConsentService`) to handle the UMP flow on app launch. 

### 2. Request Consent Info
On app startup, configure `ConsentRequestParameters` and request the latest consent info:
*   Call `ConsentInformation.instance.requestConsentInfoUpdate()`.
*   **Testing Mode:** Include `ConsentDebugSettings` with `debugGeography: DebugGeography.debugGeographyEea` and your device's hashed test identifier so the GDPR popup forces itself to appear during local testing.

### 3. Show the Consent Form
Inside the success callback of `requestConsentInfoUpdate`:
*   Call `ConsentForm.loadAndShowConsentFormIfRequired()`.
*   Handle the completion callback (whether consent was gathered or an error occurred).

### 4. Initialize Google Mobile Ads safely
*   Check if ads can be requested using `await ConsentInformation.instance.canRequestAds()`.
*   **ONLY** initialize the AdMob SDK (`MobileAds.instance.initialize()`) if `canRequestAds()` returns `true`.
*   Ensure your logic prevents redundant AdMob initialization calls (e.g., using a boolean flag `_isMobileAdsInitializeCalled`).

### 5. Privacy Options Entry Point (Settings/Help Hub)
Google requires users to be able to revoke or change consent at any time.
*   After calling `requestConsentInfoUpdate()`, check `ConsentInformation.instance.getPrivacyOptionsRequirementStatus()`.
*   If the status is `required`, add a "Privacy Settings" or "Ad Choices" button to our new `HelpSupportScreen` (the one we just built).
*   When that button is tapped, call `ConsentForm.showPrivacyOptionsForm()` to let users modify their ad preferences.