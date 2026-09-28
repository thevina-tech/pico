import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/domain/division.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/division_badge.dart';

/// Interactive modal sheet displaying the full 11-tier Division Ladder and user progression.
class DivisionLadderSheet extends StatelessWidget {
  const DivisionLadderSheet({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  static Future<void> show(BuildContext context, UserProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DivisionLadderSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userTier = profile.division;
    final totalPoints = profile.totalPoints;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF071D15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border(
          top: BorderSide(color: Color(0xFF14736E), width: 1.5),
          left: BorderSide(color: Color(0xFF14736E), width: 1.5),
          right: BorderSide(color: Color(0xFF14736E), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 44.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.divisionLadderTitle ?? 'Division Ladder',
                        style: PicoTypography.headlineLgMobile.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        l10n?.divisionLadderSubtitle ??
                            'Climb tiers with accurate match predictions',
                        style: PicoTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Current User Status Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: userTier.gradientColors,
                ),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: userTier.borderColor, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x60000000),
                    offset: Offset(0, 3),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DivisionBadge(tier: userTier, size: DivisionBadgeSize.large),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userTier.localizedTitle(l10n!),
                              style: PicoTypography.headlineMd.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '${profile.formattedTotalPoints} ${l10n.predictionPointsAbbr}',
                              style: PicoTypography.statCounterSm.copyWith(
                                color: userTier.accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      height: 8.0,
                      color: const Color(0xFF02100A),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: userTier.progressRatio(totalPoints),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                userTier.primaryColor,
                                userTier.accentColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    userTier.nextTier != null
                        ? l10n.pointsToNextDivision(
                            userTier.pointsToNext(totalPoints).toString(),
                            userTier.nextTier!.localizedTitle(l10n),
                          )
                        : l10n.eliteDivisionStatus(profile.formattedTotalPoints),
                    style: PicoTypography.bodySm.copyWith(
                      color: const Color(0xFFE2E8F0),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Scoring Guide Pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF04140D),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoringPill('Exact Score', '+5 PP', const Color(0xFFFBBF24)),
                  _buildScoringPill('Outcome + Diff', '+3 PP', const Color(0xFF34D399)),
                  _buildScoringPill('Outcome Only', '+1 PP', const Color(0xFF67E8F9)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // Ladder List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
              itemCount: DivisionTier.values.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                // Reverse so Elite is at the top of the ladder
                final tier = DivisionTier.values[DivisionTier.values.length - 1 - index];
                final isCurrent = tier == userTier;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? tier.borderColor.withValues(alpha: 0.15)
                        : const Color(0xFF0A2218),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isCurrent ? tier.borderColor : const Color(0xFF133628),
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      DivisionBadge(tier: tier, size: DivisionBadgeSize.small),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier.localizedTitle(l10n),
                              style: PicoTypography.headlineMd.copyWith(
                                color: isCurrent ? Colors.white : const Color(0xFFE2E8F0),
                                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 1.0),
                            Text(
                              tier.maxPoints != null
                                  ? '${tier.minPoints} - ${tier.maxPoints} PP'
                                  : '2,000+ PP',
                              style: PicoTypography.bodySm.copyWith(
                                color: isCurrent ? tier.accentColor : const Color(0xFF94A3B8),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: tier.accentColor,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF05130D),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringPill(String title, String pts, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pts,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.w900,
            fontSize: 12.0,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
