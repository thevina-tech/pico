import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';

/// Reusable global top bar implementing [PreferredSizeWidget],
/// strictly adhering to Stitch "Direction A: Clash Royale Resource Bar".
///
/// Features:
/// - Beveled blue Level Shield with XP progress bar.
/// - 3D Gold Coin pill with coin balance and green '+' action button.
/// - Streak pill with tactile flame badge.
/// - Automatic native back button when [Navigator.canPop] is true on inner screens.
class PicoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PicoAppBar({
    super.key,
    this.showBackButton,
    this.onBackPressed,
    this.onProfileTap,
    this.onCoinsTap,
    this.onStreakTap,
  });

  /// Explicit flag to control back button visibility.
  /// When null, automatically detects if the active [Navigator] can pop.
  final bool? showBackButton;

  /// Callback executed when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Callback when user taps the Level / XP area.
  final VoidCallback? onProfileTap;

  /// Callback when user taps the Coins pill or plus button.
  final VoidCallback? onCoinsTap;

  /// Callback when user taps the Streak pill.
  final VoidCallback? onStreakTap;

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

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

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              children: [
                // 1. Tactile Back Button (Rendered on inner screens)
                if (canPop) ...[
                  _buildBackButton(context),
                  const SizedBox(width: 8.0),
                ],

                // 2. Clash Royale Style Resource Status Bar
                Expanded(
                  child: _buildResourceBar(context, profile, canPop: canPop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tactile 3D Back button matching the Stitch dark pitch style.
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
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          color: const Color(0xFF13281C),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFF224B33), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF08120B),
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15.0,
            color: PicoColors.textWhite,
          ),
        ),
      ),
    );
  }

  /// The tactile status container housing Level/XP, Coins, and Streak.
  Widget _buildResourceBar(
    BuildContext context,
    UserProfile profile, {
    required bool canPop,
  }) {
    return Container(
      height: 48.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xF20A1B12), // #0a1b12/95
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1A3826), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF050E09),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x80000000),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Level Shield & XP Progress Track (Compact, doesn't take too much space)
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: canPop ? 100.0 : 112.0,
              child: _buildLevelAndXpTrack(profile),
            ),
          ),
          const SizedBox(width: 8.0),

          // 2. Coins Resource Pill (Expanded with ample space for balance)
          Expanded(
            child: GestureDetector(
              onTap: onCoinsTap,
              behavior: HitTestBehavior.opaque,
              child: _buildCoinsPill(profile),
            ),
          ),
          const SizedBox(width: 8.0),

          // 3. Streak Resource Pill (Compact)
          GestureDetector(
            onTap: onStreakTap,
            behavior: HitTestBehavior.opaque,
            child: _buildStreakPill(profile),
          ),
        ],
      ),
    );
  }

  /// Beveled Level Shield + Overlapping Emerald XP Progress Track.
  Widget _buildLevelAndXpTrack(UserProfile profile) {
    final level = profile.level > 0 ? profile.level : 1;
    final progress = profile.xpProgressRatio;
    final xpLabel = profile.xpDisplayLabel;

    return SizedBox(
      height: 32.0,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // XP Progress Track
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Container(
              height: 22.0,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F16),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                  topLeft: Radius.circular(6.0),
                  bottomLeft: Radius.circular(6.0),
                ),
                border: Border.all(color: const Color(0xFF1E432F), width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                  topLeft: Radius.circular(4.0),
                  bottomLeft: Radius.circular(4.0),
                ),
                child: Stack(
                  children: [
                    // Emerald Gradient Fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF34D399),
                              Color(0xFF10B981),
                              Color(0xFF047857),
                            ],
                          ),
                          border: Border(
                            right: BorderSide(
                              color: Color(0xFF6EE7B7),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 3.0,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),

                    // XP Text Label
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 4.0),
                        child: Text(
                          xpLabel,
                          style: PicoTypography.labelPillSm.copyWith(
                            color: const Color(0xFFF0FDF4),
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            shadows: const [
                              Shadow(
                                color: Color(0xE6000000),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Beveled Blue Level Shield
          Container(
            width: 26.0,
            height: 30.0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                  Color(0xFF1E40AF),
                ],
              ),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF93C5FD), width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0F2B6B),
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top Bevel Highlight
                Positioned(
                  top: 1.5,
                  left: 2.0,
                  right: 2.0,
                  child: Container(
                    height: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
                ),
                // Level Number
                Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Color(0xCC000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tactile Gold Coin + Balance + Green Plus Action Button.
  Widget _buildCoinsPill(UserProfile profile) {
    return Container(
      height: 28.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13281C),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF224B33), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF08120B),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 3D Gold Coin
          Container(
            width: 18.0,
            height: 18.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFEF08A),
                  Color(0xFFEAB308),
                  Color(0xFFA16207),
                ],
              ),
              border: Border.all(color: const Color(0xFFFDE047), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF713F12),
                  offset: Offset(0, 1.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '¢',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF422006),
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6.0),

          // Formatted Coins (Expanded space for large coin amounts)
          Flexible(
            child: Text(
              profile.formattedCoins,
              style: const TextStyle(
                fontFamily: 'Rubik',
                color: Color(0xFFFEF08A),
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                shadows: [
                  Shadow(
                    color: Color(0xCC000000),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6.0),

          // Tactile Green Plus Button
          Container(
            width: 15.0,
            height: 15.0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF15803D),
                ],
              ),
              borderRadius: BorderRadius.circular(4.5),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF14532D),
                  offset: Offset(0, 1),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tactile Flame Badge + Streak Count.
  Widget _buildStreakPill(UserProfile profile) {
    return Container(
      height: 28.0,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13281C),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF224B33), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF08120B),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tactile Flame Circle
          Container(
            width: 17.0,
            height: 17.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDBA74),
                  Color(0xFFF97316),
                  Color(0xFFC2410C),
                ],
              ),
              border: Border.all(color: const Color(0xFFFED7AA), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7C2D12),
                  offset: Offset(0, 1),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(
                  fontSize: 9.0,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),

          // Streak Value
          Text(
            '${profile.streak}',
            style: const TextStyle(
              fontFamily: 'Rubik',
              color: Color(0xFFFED7AA),
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              shadows: [
                Shadow(
                  color: Color(0xCC000000),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
