import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/profile/presentation/widgets/division_ladder_sheet.dart';
import 'package:pico/shared/components/division_badge.dart';

/// Reusable global top bar implementing [PreferredSizeWidget],
/// updated for the Sprint 7 Division System.
///
/// Features:
/// - Dark teal rounded capsule pill floating over the background.
/// - Tactile Division badge (`DIV 8`, `ELITE`, etc.) with tier-specific metallic colors.
/// - Candy-striped tier progress bar + `${totalPoints} / ${nextThreshold} PP`.
/// - Subtle vertical divider.
/// - Polished Prediction Points (PP) pill (`${totalPoints} PP`).
/// - Tapping opens the interactive [DivisionLadderSheet].
/// - Automatic tactile back button when [showBackButton] is true or [Navigator.canPop] is true.
class PicoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PicoAppBar({
    super.key,
    this.showBackButton,
    this.onBackPressed,
    this.onProfileTap,
    this.onPointsTap,
    this.onCoinsTap,
    this.onStreakTap,
    this.backgroundColor,
  });

  /// Explicit flag to control back button visibility.
  final bool? showBackButton;

  /// Callback executed when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Callback when user taps the Division badge / XP area.
  final VoidCallback? onProfileTap;

  /// Callback when user taps the Prediction Points area.
  final VoidCallback? onPointsTap;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onCoinsTap;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onStreakTap;

  /// Optional background color (defaults to transparent so sky/pitch shows through).
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final profile = profileAsync.value ??
        const UserProfile(
          id: 'preview',
          username: 'Alex',
          totalPoints: 140,
          currentDivisionKey: 'div_8',
        );

    final bool canPop = showBackButton ?? false;

    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440.0),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: canPop ? 6.0 : 10.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  // 1. Tactile Back Button (Rendered on inner screens)
                  if (canPop) ...[
                    _buildBackButton(context),
                    const SizedBox(width: 6.0),
                  ],

                  // 2. Stitch Unified Division Capsule Pill
                  Expanded(
                    child: _buildCapsuleBar(context, profile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tactile 3D Back button matching the Stitch dark teal pitch aesthetic.
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      key: const Key('pico_app_bar_back_button'),
      onTap: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          color: const Color(0xCC072522),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color(0xFF14736E).withValues(alpha: 0.85),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Unified Stitch dark teal capsule housing Division Badge, Progress Bar, and Prediction Points.
  Widget _buildCapsuleBar(BuildContext context, UserProfile profile) {
    final tier = profile.division;
    final points = profile.totalPoints;
    final progress = profile.divisionProgressRatio;
    final nextTier = tier.nextTier;

    return Container(
      height: 46.0,
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 4.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC082E2B), // ~80% opacity dark cyan-teal
            Color(0xCC052220),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF14736E).withValues(alpha: 0.85),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Division Badge
          GestureDetector(
            key: const Key('pico_app_bar_division_section'),
            onTap: () {
              if (onProfileTap != null) {
                onProfileTap!();
              } else {
                DivisionLadderSheet.show(context, profile);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: DivisionBadge(
              tier: tier,
              size: DivisionBadgeSize.medium,
            ),
          ),
          const SizedBox(width: 6.0),

          // 2. Division Progress Section (Striped Progress Bar + Tabular "140 / 220 PP")
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (onProfileTap != null) {
                  onProfileTap!();
                } else {
                  DivisionLadderSheet.show(context, profile);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Striped Progress Bar
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 15.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07292D),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFF0F474A),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: _StripedProgressBar(
                          ratio: progress,
                          primaryColor: tier.primaryColor,
                          accentColor: tier.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),

                  // Progress Text Label
                  Expanded(
                    flex: 4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        nextTier != null
                            ? '${UserProfileXpX.formatNumberWithCommas(points)} / ${UserProfileXpX.formatNumberWithCommas(nextTier.minPoints)} PP'
                            : '${UserProfileXpX.formatNumberWithCommas(points)} PP',
                        style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4.0),

          // 3. Subtle Vertical Divider
          Container(
            width: 1.0,
            height: 20.0,
            color: const Color(0x384DFFA0),
          ),
          const SizedBox(width: 4.0),

          // 4. Prediction Points Pill (Gold/Neon PP Counter)
          GestureDetector(
            key: const Key('pico_app_bar_points_section'),
            onTap: () {
              if (onPointsTap != null) {
                onPointsTap!();
              } else if (onCoinsTap != null) {
                onCoinsTap!();
              } else {
                DivisionLadderSheet.show(context, profile);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0x80041814),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_soccer_rounded,
                    size: 14.0,
                    color: Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${profile.formattedTotalPoints} PP',
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Candy-striped progress bar with tier-tailored gradient and diagonal translucent stripes.
class _StripedProgressBar extends StatelessWidget {
  const _StripedProgressBar({
    required this.ratio,
    this.primaryColor = const Color(0xFF22C55E),
    this.accentColor = const Color(0xFF4ADE80),
  });

  final double ratio;
  final Color primaryColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filledWidth = (totalWidth * ratio.clamp(0.0, 1.0));
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: filledWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accentColor,
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: CustomPaint(
              painter: _DiagonalStripesPainter(),
            ),
          ),
        );
      },
    );
  }
}

/// Draws 45-degree diagonal candy stripes across the progress bar.
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;

    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    const spacing = 9.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
