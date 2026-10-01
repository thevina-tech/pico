import 'package:flutter/material.dart';
import 'pico_colors.dart';

/// Unified Pico typography tokens matching the Stitch design system.
///
/// Font hierarchy:
/// - **Rubik**: Chunky, friendly display headings and titles.
/// - **Plus Jakarta Sans**: Clear, readable body copy.
/// - **Space Grotesk**: Monospaced-feel stats, minute tickers, and pill tags.
abstract final class PicoTypography {
  // ---------------------------------------------------------------------------
  // Font Family Constants
  // ---------------------------------------------------------------------------
  static const String headlineFontFamily = 'Rubik';
  static const String bodyFontFamily = 'Plus Jakarta Sans';
  static const String labelFontFamily = 'Space Grotesk';

  // ---------------------------------------------------------------------------
  // 1. Display & Headlines (Rubik)
  // ---------------------------------------------------------------------------
  /// Display Hero: 40px / 46px, Weight 800, Letter spacing -0.02em
  static const TextStyle displayHero = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 40.0,
    fontWeight: FontWeight.w800,
    height: 46.0 / 40.0,
    letterSpacing: -0.8,
    color: PicoColors.textWhite,
  );

  /// Display Hero Mobile: 32px / 38px, Weight 800, Letter spacing -0.02em
  static const TextStyle displayHeroMobile = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    height: 38.0 / 32.0,
    letterSpacing: -0.64,
    color: PicoColors.textWhite,
  );

  /// Headline LG: 28px / 34px, Weight 700, Letter spacing -0.01em
  static const TextStyle headlineLg = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 34.0 / 28.0,
    letterSpacing: -0.28,
    color: PicoColors.textWhite,
  );

  /// Headline LG Mobile: 24px / 30px, Weight 700, Letter spacing -0.01em
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 30.0 / 24.0,
    letterSpacing: -0.24,
    color: PicoColors.textWhite,
  );

  /// Headline MD: 20px / 26px, Weight 700
  static const TextStyle headlineMd = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 26.0 / 20.0,
    color: PicoColors.textWhite,
  );

  /// Title Card: 17px / 22px, Weight 600
  static const TextStyle titleCard = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    height: 22.0 / 17.0,
    color: PicoColors.textPitchInk,
  );

  // ---------------------------------------------------------------------------
  // 2. Body Copy (Plus Jakarta Sans)
  // ---------------------------------------------------------------------------
  /// Body LG: 16px / 24px, Weight 500
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 24.0 / 16.0,
    color: PicoColors.textWhiteMuted,
  );

  /// Body MD: 14px / 20px, Weight 500
  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 14.0,
    color: PicoColors.textWhiteMuted,
  );

  /// Body MD Bold: 14px / 20px, Weight 600
  static const TextStyle bodyMdBold = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 20.0 / 14.0,
    color: PicoColors.textWhite,
  );

  /// Body SM: 12px / 16px, Weight 500
  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 16.0 / 12.0,
    color: PicoColors.textWhiteMuted,
  );

  // ---------------------------------------------------------------------------
  // 3. Stats, Counters & Pill Badges (Space Grotesk)
  // ---------------------------------------------------------------------------
  /// Stat Counter: 24px / 26px, Weight 700, Letter spacing -0.03em
  static const TextStyle statCounter = TextStyle(
    fontFamily: labelFontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 26.0 / 24.0,
    letterSpacing: -0.72,
    color: PicoColors.textWhite,
  );

  /// Stat Counter SM: 20px / 24px, Weight 700, Letter spacing -0.03em
  static const TextStyle statCounterSm = TextStyle(
    fontFamily: labelFontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 24.0 / 20.0,
    letterSpacing: -0.6,
    color: PicoColors.textWhite,
  );

  /// Label Pill: 11px / 14px, Weight 700, Letter spacing 0.04em
  static const TextStyle labelPill = TextStyle(
    fontFamily: labelFontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    height: 14.0 / 11.0,
    letterSpacing: 0.44,
    color: PicoColors.textPitchInk,
  );

  /// Label Pill SM: 10px / 12px, Weight 700, Letter spacing 0.04em
  static const TextStyle labelPillSm = TextStyle(
    fontFamily: labelFontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w700,
    height: 12.0 / 10.0,
    letterSpacing: 0.4,
    color: PicoColors.textPitchInk,
  );
}
