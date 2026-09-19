import 'package:flutter/material.dart';

/// Unified Pico color tokens calibrated from the Stitch "Friendly Football World"
/// designs and actual dark pitch screen environments.
abstract final class PicoColors {
  // ---------------------------------------------------------------------------
  // 1. Dark Pitch Environment & Canvas
  // ---------------------------------------------------------------------------
  /// Base dark pitch background canvas (#08140E).
  static const Color pitchBackground = Color(0xFF08140E);

  /// Deepest pitch shadow for gradients and inset wells (#060F0B).
  static const Color pitchBackgroundDeep = Color(0xFF060F0B);

  /// Top gradient pitch tone (#0C1E15).
  static const Color pitchGradientTop = Color(0xFF0C1E15);

  /// Base gradient pitch tone (#08140E).
  static const Color pitchGradientBottom = Color(0xFF08140E);

  /// Slightly elevated dark pitch surface used in prediction sheets (#091610).
  static const Color pitchSurface = Color(0xFF091610);

  /// Elevated dark pitch panel (#11231A).
  static const Color pitchSurfaceElevated = Color(0xFF11231A);

  // ---------------------------------------------------------------------------
  // 2. Primary Meadow Turf Greens
  // ---------------------------------------------------------------------------
  /// Primary Meadow Pitch Green for main actions and brand identity (#2D8B55).
  static const Color primary = Color(0xFF2D8B55);

  /// Darker underside shelf for 3D tactile button depression (#236B42).
  static const Color primaryBevel = Color(0xFF236B42);

  /// Deep forest brand green (#006A3A).
  static const Color primaryDark = Color(0xFF006A3A);

  /// Container fill green (#25844F).
  static const Color primaryContainer = Color(0xFF25844F);

  /// Light green subtle tint container (#E8F5EE).
  static const Color primaryTintContainer = Color(0xFFE8F5EE);

  /// Vibrant pitch line and contour green (#99F6B6).
  static const Color primaryFixed = Color(0xFF99F6B6);

  /// Subtle avatar border and badge accent (#7ED99C).
  static const Color primaryFixedDim = Color(0xFF7ED99C);

  // ---------------------------------------------------------------------------
  // 3. Tactile Cream Cards (Chunky Physical Board)
  // ---------------------------------------------------------------------------
  /// Pure white face of elevated prediction cards (#FFFFFF).
  static const Color cardFace = Color(0xFFFFFFFF);

  /// Default 4px/8px 3D bottom bevel extrusion shelf (#EDE8DD).
  static const Color cardBevel = Color(0xFFEDE8DD);

  /// Darker sand bevel for pressed cards and active borders (#D8D1C3).
  static const Color cardBevelDark = Color(0xFFD8D1C3);

  /// Recessed well background for unselected prediction slots (#F3EFE6).
  static const Color cardTray = Color(0xFFF3EFE6);

  /// Card outline and hairline dividers (#EDE8DD).
  static const Color cardBorder = Color(0xFFEDE8DD);

  // ---------------------------------------------------------------------------
  // 4. Secondary Champagne Trophy Gold
  // ---------------------------------------------------------------------------
  /// Champagne trophy gold for streaks, multipliers, and crowns (#E6C687).
  static const Color gold = Color(0xFFE6C687);

  /// 3D bottom bevel shelf for gold buttons and tokens (#A8883B).
  static const Color goldBevel = Color(0xFFA8883B);

  /// Softer champagne container fill (#FDDC9B).
  static const Color goldContainer = Color(0xFFFDDC9B);

  // ---------------------------------------------------------------------------
  // 5. Competitive Electric Mint (Live & Multiplier Accents)
  // ---------------------------------------------------------------------------
  /// Electric mint for live match chips, multipliers, and success ticks (#00E599).
  static const Color electricMint = Color(0xFF00E599);

  /// Glowing pitch geometry curves and neon indicators (#4DFFB2).
  static const Color mintGlow = Color(0xFF4DFFB2);

  // ---------------------------------------------------------------------------
  // 6. Typography & Ink (High-Contrast Readability)
  // ---------------------------------------------------------------------------
  /// Pure white text for headings and primary content over dark pitch (#FFFFFF).
  static const Color textWhite = Color(0xFFFFFFFF);

  /// Warm chalk muted text (75% opacity) over dark pitch (#FAF9F4 with alpha).
  static const Color textWhiteMuted = Color(0xBFFAF9F4);

  /// High-contrast pitch ink for text inside white/cream cards (#13211B).
  static const Color textPitchInk = Color(0xFF13211B);

  /// Muted tactical stats text inside white/cream cards (#5C6B64).
  static const Color textTactileMuted = Color(0xFF5C6B64);

  /// Secondary descriptive ink inside cards (#3F4940).
  static const Color textTactileSecondary = Color(0xFF3F4940);

  // ---------------------------------------------------------------------------
  // 7. Translucent Glass & Overlay Surfaces
  // ---------------------------------------------------------------------------
  /// 10% white fill for translucent top bars and dark chips.
  static const Color glassSurface = Color(0x1AFFFFFF);

  /// 5% white stroke for translucent borders.
  static const Color glassBorder = Color(0x0DFFFFFF);

  /// Dark sunken track fill for progress bars and badges.
  static const Color darkTray = Color(0x40000000);

  // ---------------------------------------------------------------------------
  // 8. Alerts & Feedback
  // ---------------------------------------------------------------------------
  /// Error red (#BA1A1A).
  static const Color error = Color(0xFFBA1A1A);

  /// Error container (#FFDAD6).
  static const Color errorContainer = Color(0xFFFFDAD6);
}
