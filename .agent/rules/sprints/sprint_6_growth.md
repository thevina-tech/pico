---
trigger: always_on
---

# SPRINT 6: Google Authentication & Sequential Onboarding Flow

## Task Overview
Refactor the onboarding experience to integrate Google Sign-In at the "How it works" screen, followed by a stateful multi-step profile creation flow (Username -> Favorite Team -> Leagues). 

## 1. Dependencies & Configuration
* Ensure `google_sign_in` is added to `pubspec.yaml`.
* In your Auth Service, read `GOOGLE_WEB_CLIENT_ID` from `dotenv.env`.

## 2. Authentication Logic (Supabase + Google)
* Implement a `signInWithGoogle()` method.
* Initialize the `GoogleSignIn` object passing the `GOOGLE_WEB_CLIENT_ID` to the `serverClientId` parameter.
* Execute the sign-in, extract the `idToken` and `accessToken`, and pass them to `supabase.auth.signInWithIdToken(provider: OAuthProvider.google, ...)`.

## 3. UI Sequence & State Management
Implement this strict navigation and state flow:

**Step A: "How it works" Screen (Auth Trigger)**
* Replace the generic "Next" button with a standard "Continue with Google" button (incorporate the Google logo icon).
* On tap, show a loading state and trigger the Google auth flow.
* **Routing Check:** Immediately after auth success, query the user's database profile. If they already have a `username` saved (i.e., returning user), bypass onboarding and route directly to the Main Dashboard. If not, proceed to Step B.

**Step B: Unique Username Selection**
* Create a simple, focused screen for username input.
* Implement a `TextFormField` with local validation (e.g., alphanumeric, no spaces, 3+ characters).
* Retain the inputted username in state/memory (do not save to Supabase yet).

**Step C: Favorite Team Selection**
* Present a searchable list or visual grid of football teams.
* User selects one team. Retain this selection in state/memory.

**Step D: League Selection (Existing UI)**
* Present the existing league selection UI.
* **Final Submission:** When the user clicks "Finish" on this final screen, execute a single Supabase update to the user's profile record, saving the `username`, `favorite_team`, and `selected_leagues` all at once.

## 4. Error Handling & Edge Cases
* **Unique Username Collision:** Ensure the database table has a unique constraint on the username column. If the final profile save fails due to a uniqueness violation, catch the error, alert the user ("Username already taken"), and route them back to Step B to pick a new one.
* **Cancellation:** If the user closes the Google login modal before finishing, gracefully dismiss the loading state without throwing a red screen error.