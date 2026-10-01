import 'package:flutter/material.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Programmatic division tiers in the Pico Prediction Points ladder.
enum DivisionTier {
  div10(
    key: 'div_10',
    tierNumber: 10,
    minPoints: 0,
    maxPoints: 49,
    badgeLabel: 'DIV 10',
    defaultTitle: 'Division 10',
    primaryColor: Color(0xFF94A3B8), // Slate Bronze
    accentColor: Color(0xFFCBD5E1),
    gradientColors: [Color(0xFF334155), Color(0xFF1E293B)],
    borderColor: Color(0xFF64748B),
  ),
  div9(
    key: 'div_9',
    tierNumber: 9,
    minPoints: 50,
    maxPoints: 119,
    badgeLabel: 'DIV 9',
    defaultTitle: 'Division 9',
    primaryColor: Color(0xFFB45309), // Bronze
    accentColor: Color(0xFFD97706),
    gradientColors: [Color(0xFF451A03), Color(0xFF291004)],
    borderColor: Color(0xFF92400E),
  ),
  div8(
    key: 'div_8',
    tierNumber: 8,
    minPoints: 120,
    maxPoints: 219,
    badgeLabel: 'DIV 8',
    defaultTitle: 'Division 8',
    primaryColor: Color(0xFFCD7F32), // Warm Bronze
    accentColor: Color(0xFFF59E0B),
    gradientColors: [Color(0xFF592708), Color(0xFF361403)],
    borderColor: Color(0xFFB45309),
  ),
  div7(
    key: 'div_7',
    tierNumber: 7,
    minPoints: 220,
    maxPoints: 349,
    badgeLabel: 'DIV 7',
    defaultTitle: 'Division 7',
    primaryColor: Color(0xFF94A3B8), // Silver
    accentColor: Color(0xFFE2E8F0),
    gradientColors: [Color(0xFF334155), Color(0xFF1E293B)],
    borderColor: Color(0xFF94A3B8),
  ),
  div6(
    key: 'div_6',
    tierNumber: 6,
    minPoints: 350,
    maxPoints: 499,
    badgeLabel: 'DIV 6',
    defaultTitle: 'Division 6',
    primaryColor: Color(0xFFC0C0C0), // Polished Silver
    accentColor: Color(0xFFF8FAFC),
    gradientColors: [Color(0xFF475569), Color(0xFF1E293B)],
    borderColor: Color(0xFFCBD5E1),
  ),
  div5(
    key: 'div_5',
    tierNumber: 5,
    minPoints: 500,
    maxPoints: 699,
    badgeLabel: 'DIV 5',
    defaultTitle: 'Division 5',
    primaryColor: Color(0xFFEAB308), // Gold
    accentColor: Color(0xFFFDE047),
    gradientColors: [Color(0xFF713F12), Color(0xFF422006)],
    borderColor: Color(0xFFCA8A04),
  ),
  div4(
    key: 'div_4',
    tierNumber: 4,
    minPoints: 700,
    maxPoints: 949,
    badgeLabel: 'DIV 4',
    defaultTitle: 'Division 4',
    primaryColor: Color(0xFFF59E0B), // Radiant Gold
    accentColor: Color(0xFFFEF08A),
    gradientColors: [Color(0xFF854D0E), Color(0xFF451A03)],
    borderColor: Color(0xFFEAB308),
  ),
  div3(
    key: 'div_3',
    tierNumber: 3,
    minPoints: 950,
    maxPoints: 1249,
    badgeLabel: 'DIV 3',
    defaultTitle: 'Division 3',
    primaryColor: Color(0xFF10B981), // Emerald
    accentColor: Color(0xFF6EE7B7),
    gradientColors: [Color(0xFF064E3B), Color(0xFF022C22)],
    borderColor: Color(0xFF059669),
  ),
  div2(
    key: 'div_2',
    tierNumber: 2,
    minPoints: 1250,
    maxPoints: 1599,
    badgeLabel: 'DIV 2',
    defaultTitle: 'Division 2',
    primaryColor: Color(0xFF06B6D4), // Cyan Platinum
    accentColor: Color(0xFF67E8F9),
    gradientColors: [Color(0xFF164E63), Color(0xFF083344)],
    borderColor: Color(0xFF0891B2),
  ),
  div1(
    key: 'div_1',
    tierNumber: 1,
    minPoints: 1600,
    maxPoints: 1999,
    badgeLabel: 'DIV 1',
    defaultTitle: 'Division 1',
    primaryColor: Color(0xFF38BDF8), // Diamond
    accentColor: Color(0xFFBAE6FD),
    gradientColors: [Color(0xFF0C4A6E), Color(0xFF082F49)],
    borderColor: Color(0xFF0284C7),
  ),
  elite(
    key: 'elite',
    tierNumber: 0,
    minPoints: 2000,
    maxPoints: null,
    badgeLabel: 'ELITE',
    defaultTitle: 'Elite Division',
    primaryColor: Color(0xFFA855F7), // Regal Purple & Gold
    accentColor: Color(0xFFFDE047),
    gradientColors: [Color(0xFF581C87), Color(0xFF2E1065)],
    borderColor: Color(0xFFC084FC),
  );

  const DivisionTier({
    required this.key,
    required this.tierNumber,
    required this.minPoints,
    required this.maxPoints,
    required this.badgeLabel,
    required this.defaultTitle,
    required this.primaryColor,
    required this.accentColor,
    required this.gradientColors,
    required this.borderColor,
  });

  final String key;
  final int tierNumber;
  final int minPoints;
  final int? maxPoints;
  final String badgeLabel;
  final String defaultTitle;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final Color borderColor;

  /// Returns the next tier in the ladder, or `null` if already at Elite Division.
  DivisionTier? get nextTier {
    final idx = index + 1;
    if (idx < DivisionTier.values.length) {
      return DivisionTier.values[idx];
    }
    return null;
  }

  /// Calculates the [DivisionTier] corresponding to a given [points] total.
  static DivisionTier fromPoints(int points) {
    if (points >= 2000) return DivisionTier.elite;
    if (points >= 1600) return DivisionTier.div1;
    if (points >= 1250) return DivisionTier.div2;
    if (points >= 950) return DivisionTier.div3;
    if (points >= 700) return DivisionTier.div4;
    if (points >= 500) return DivisionTier.div5;
    if (points >= 350) return DivisionTier.div6;
    if (points >= 220) return DivisionTier.div7;
    if (points >= 120) return DivisionTier.div8;
    if (points >= 50) return DivisionTier.div9;
    return DivisionTier.div10;
  }

  /// Resolves the [DivisionTier] from a string key (e.g. `'div_4'`).
  static DivisionTier fromKey(String? key) {
    if (key == null) return DivisionTier.div10;
    for (final tier in DivisionTier.values) {
      if (tier.key == key) return tier;
    }
    return DivisionTier.div10;
  }

  /// Normalized progress ratio (0.0 to 1.0) towards the next division.
  /// For Elite Division (no ceiling), returns 1.0.
  double progressRatio(int points) {
    if (maxPoints == null) return 1.0;
    final next = nextTier;
    if (next == null) return 1.0;
    final currentInBracket = (points - minPoints).clamp(0, double.infinity).toInt();
    final bracketSpan = next.minPoints - minPoints;
    if (bracketSpan <= 0) return 1.0;
    return (currentInBracket / bracketSpan).clamp(0.0, 1.0);
  }

  /// Points needed to reach the next division tier (0 if already Elite).
  int pointsToNext(int points) {
    final next = nextTier;
    if (next == null) return 0;
    final remaining = next.minPoints - points;
    return remaining > 0 ? remaining : 0;
  }

  /// Formatted progress string, e.g. "140 / 220 pts to Division 7" or "2,150 pts (Elite Division)".
  String progressLabel(int points, {String? localizedNextTitle, String? localizedCurrentTitle}) {
    final next = nextTier;
    if (next == null) {
      final currentTitle = localizedCurrentTitle ?? defaultTitle;
      return '$points pts ($currentTitle)';
    }
    final nextTitle = localizedNextTitle ?? next.defaultTitle;
    return '$points / ${next.minPoints} pts to $nextTitle';
  }

  /// Returns localized division name using [AppLocalizations].
  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case DivisionTier.div10:
        return l10n.division10Title;
      case DivisionTier.div9:
        return l10n.division9Title;
      case DivisionTier.div8:
        return l10n.division8Title;
      case DivisionTier.div7:
        return l10n.division7Title;
      case DivisionTier.div6:
        return l10n.division6Title;
      case DivisionTier.div5:
        return l10n.division5Title;
      case DivisionTier.div4:
        return l10n.division4Title;
      case DivisionTier.div3:
        return l10n.division3Title;
      case DivisionTier.div2:
        return l10n.division2Title;
      case DivisionTier.div1:
        return l10n.division1Title;
      case DivisionTier.elite:
        return l10n.divisionEliteTitle;
    }
  }
}

