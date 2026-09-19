---
trigger: always_on
---

# SPRINT 2: USER & AUTHENTICATION

## 1. Anonymous Authentication (Guest Mode) & Env Setup
*   Ensure environment variables are loaded securely using the `flutter_dotenv` package.
*   Implement Supabase Anonymous Auth (`supabase.auth.signInAnonymously()`) on the onboarding screen to minimize friction[cite: 6]. 
*   Create an `authProvider` (Riverpod) that listens to `supabase.auth.onAuthStateChange` to handle route redirects (unauthenticated -> Onboarding, authenticated -> Home).

## 2. Profile Generation (Server-Side)
*   *Note:* The Supabase Postgres trigger for profile generation is **already deployed** on the database. 
*   **Do not write SQL for this.** Simply rely on the fact that when `supabase.auth.signInAnonymously()` completes, a `profiles` row will automatically exist for you to read.

## 3. Personalization & Username Setup
*   Since users are anonymous initially, prompt them to choose a custom Username and select their favorite team/leagues[cite: 6] immediately after clicking "Play".
*   Save the custom username, favorite team, and league IDs to their `profiles` row using a Supabase `update` call.