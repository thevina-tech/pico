---
trigger: always_on
---

# SPRINT 5: GROWTH & REFERRALS

## 1. Invite Codes
*   Implement simple 6-8 character alphanumeric invite codes for joining Private Leagues (e.g., `PICO-AB12`). Build a UI modal to enter these codes.

## 2. Referral Tracking
*   Create the `referrals` table[cite: 6].
*   Write a Supabase trigger that updates the referral status to "ACTIVATED" only when the referred user submits their first prediction[cite: 6].

## 3. Social Sharing
*   Build shareable victory banners and integrate native OS share sheets (using `share_plus`)[cite: 6].