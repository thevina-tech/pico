import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';

/// Reusable global top bar implementing [PreferredSizeWidget],
/// strictly adhering to Stitch "Top Bar" unified dark-teal capsule specification.
///
/// Features:
/// - Dark teal rounded capsule pill floating over the background.
/// - Tactile Level badge (`LVL ${profile.level}`).
/// - Candy-striped green XP progress bar + tabular `${profile.xp} / 1,000 XP`.
/// - Subtle vertical dividers.
/// - 3D Gold Soccer Coin with tabular balance (`${profile.formattedCoins}`).
/// - 3D Flame icon with current streak count (`${profile.streak}`).
/// - Automatic tactile back button when [showBackButton] is true or [Navigator.canPop] is true.
class PicoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PicoAppBar({
    super.key,
    this.showBackButton,
    this.onBackPressed,
    this.onProfileTap,
    this.onCoinsTap,
    this.onStreakTap,
    this.backgroundColor,
  });

  /// Explicit flag to control back button visibility.
  /// When null, defaults to false (or can be passed explicitly).
  final bool? showBackButton;

  /// Callback executed when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Callback when user taps the Level / XP area.
  final VoidCallback? onProfileTap;

  /// Callback when user taps the Coins area.
  final VoidCallback? onCoinsTap;

  /// Callback when user taps the Streak area.
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
          level: 7,
          xp: 720,
          streak: 4,
          coins: 1450,
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

                  // 2. Stitch Unified Capsule Pill
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

  /// Unified Stitch dark teal capsule housing Level, XP bar, Coins, and Streak.
  Widget _buildCapsuleBar(BuildContext context, UserProfile profile) {
    final xpInLevel = profile.xpInLevel;
    final targetXp = profile.targetXpForLevel;
    final progress = profile.xpProgressRatio;

    return Container(
      height: 46.0,
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 4.0),
      decoration: BoxDecoration(
        // Semi-transparent so the sky background softly peeks through
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC082E2B), // ~80% opacity dark cyan-teal
            Color(0xCC052220),
          ],
        ),
        // Rounded rectangle (not overly rounded/pill)
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF14736E).withValues(alpha: 0.85), // Bright cyan-teal border outline
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
          // 1. Level Badge (e.g. "LVL 7" with Stitch 3D bevel effect & green number)
          GestureDetector(
            key: const Key('pico_app_bar_level_section'),
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 32.0,
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D3230), // Beveled top highlight
                    Color(0xFF051C1B), // Dark sunken base
                  ],
                ),
                borderRadius: BorderRadius.circular(9.0),
                border: Border.all(
                  color: const Color(0xFF135E58),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x60000000),
                    offset: Offset(0, 2),
                    blurRadius: 1.5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top bevel glass reflection line
                  Positioned(
                    top: 1.0,
                    left: 1.0,
                    right: 1.0,
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'LVL ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: '${profile.level > 0 ? profile.level : 1}',
                            style: const TextStyle(
                              color: Color(0xFF4ADE80), // Vivid emerald green number from Stitch
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            offset: Offset(0, 1.5),
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5.0),

          // 2. XP Section (Striped Green Progress Bar + Tabular "720 / 1,000 XP")
          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
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
                        child: _StripedProgressBar(ratio: progress),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),

                  // XP Text Label (Tabular, scaling down gracefully without overflow)
                  Expanded(
                    flex: 4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${UserProfileXpX.formatNumberWithCommas(xpInLevel)} / ${UserProfileXpX.formatNumberWithCommas(targetXp)} XP',
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

          // 3. Subtle Vertical Divider 1
          Container(
            width: 1.0,
            height: 20.0,
            color: const Color(0x384DFFA0),
          ),
          const SizedBox(width: 4.0),

          // 4. Coins Section (3D Soccer Coin + Balance)
          GestureDetector(
            key: const Key('pico_app_bar_coins_section'),
            onTap: onCoinsTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/coin_3d.png',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFBBF24),
                    ),
                    child: const Center(
                      child: Text(
                        '¢',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3.5),
                Text(
                  profile.formattedCoins,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4.0),

          // 5. Subtle Vertical Divider 2
          Container(
            width: 1.0,
            height: 20.0,
            color: const Color(0x384DFFA0),
          ),
          const SizedBox(width: 4.0),

          // 6. Streak Section (3D Flame + Streak Count)
          GestureDetector(
            key: const Key('pico_app_bar_streak_section'),
            onTap: onStreakTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/streak_flame_3d.png',
                  width: 22.0,
                  height: 22.0,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    '🔥',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                const SizedBox(width: 3.5),
                Text(
                  '${profile.streak}',
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Candy-striped progress bar with lime-to-emerald gradient and diagonal translucent stripes.
class _StripedProgressBar extends StatelessWidget {
  const _StripedProgressBar({required this.ratio});
  final double ratio;

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4ADE80), // Lime green
                  Color(0xFF22C55E), // Vivid emerald
                  Color(0xFF16A34A),
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
