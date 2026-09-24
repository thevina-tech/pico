import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Pico Shop screen.
///
/// Features a streamlined, uncluttered experience:
/// 1. Top bar with Level/XP, Coins, and Streak.
/// 2. Header banner showing current club coin balance.
/// 3. Free Reward Video Ad card allowing users to earn coins (+50 coins per watch).
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({
    super.key,
    this.showBottomNavBar = false,
    this.currentNavIndex = 0,
    this.onNavTap,
  });

  final bool showBottomNavBar;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late int _currentNavIndex;
  bool _isWatchingAd = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final userCoins = profileAsync.value?.coins ?? 1450;

    return PicoGameExitScope(
      child: PicoPitchBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PicoAppBar(
            onProfileTap: () => context.go('/profile'),
          ),
          bottomNavigationBar: widget.showBottomNavBar
              ? Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440.0),
                    child: PicoBottomNavBar(
                      currentIndex: _currentNavIndex,
                      onTap: (idx) {
                        setState(() => _currentNavIndex = idx);
                        widget.onNavTap?.call(idx);
                        switch (idx) {
                          case 0:
                            break;
                          case 1:
                            context.go('/matches');
                            break;
                          case 2:
                            context.go('/home');
                            break;
                          case 3:
                            context.go('/tournaments');
                            break;
                          case 4:
                            context.go('/profile');
                            break;
                        }
                      },
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 32.0),
                  children: [
                    // 1. Header Banner
                    _buildHeader(l10n, userCoins),
                    const SizedBox(height: 20.0),

                    // 2. Reward Ad Section (Earn Free Coins)
                    _buildSectionTitle(
                      title: 'REWARD ADS',
                      subtitle: 'Watch short sponsor videos to earn free coins',
                      icon: Icons.play_circle_fill_rounded,
                      color: PicoColors.gold,
                    ),
                    const SizedBox(height: 12.0),
                    _buildRewardAdCard(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n, int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x24FFFFFF), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: PicoColors.primaryDark,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: PicoColors.primaryFixed, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/nav_shop.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.storefront_rounded,
                  color: PicoColors.primaryFixed,
                  size: 24.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLUB SHOP',
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Watch ads to earn free coins',
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                  ),
                ),
              ],
            ),
          ),
          // Coin balance pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1607),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: PicoColors.gold, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  size: 14.0,
                  color: PicoColors.gold,
                ),
                const SizedBox(width: 5.0),
                Text(
                  '$coins',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.0, color: color),
            const SizedBox(width: 6.0),
            Text(
              title,
              style: PicoTypography.labelPill.copyWith(
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          subtitle,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textWhiteMuted,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardAdCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A2A20),
            Color(0xFF0F1A14),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: PicoColors.gold.withValues(alpha: 0.6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle coin glow watermark
          Positioned(
            right: -15,
            top: -15,
            child: Icon(
              Icons.monetization_on_rounded,
              size: 130,
              color: PicoColors.gold.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Value Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: PicoColors.gold,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: PicoColors.goldBevel,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.smart_display_rounded,
                            size: 13.0,
                            color: Color(0xFF1B1607),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'REWARD VIDEO',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: const Color(0xFF1B1607),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF263B2E),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: PicoColors.electricMint, width: 1.0),
                      ),
                      child: Text(
                        '+50 COINS',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.electricMint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),

                // Main Content with 3D Coin and Description
                Row(
                  children: [
                    Container(
                      width: 58.0,
                      height: 58.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16251C),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: PicoColors.gold.withValues(alpha: 0.3), width: 1.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/images/coin_3d.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.monetization_on_rounded,
                            color: PicoColors.gold,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Coins Refill',
                            style: PicoTypography.headlineMd.copyWith(
                              color: PicoColors.textWhite,
                              fontWeight: FontWeight.w800,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            'Watch a quick video sponsor to receive 50 free Pico Coins in your club wallet.',
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.textWhiteMuted,
                              fontSize: 12.0,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Watch Video Button
                SizedBox(
                  width: double.infinity,
                  height: 48.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PicoColors.gold,
                      foregroundColor: const Color(0xFF1B1607),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _isWatchingAd ? null : _handleWatchAd,
                    child: _isWatchingAd
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.smart_display_rounded, size: 20.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'WATCHING AD...',
                                style: PicoTypography.labelPill.copyWith(
                                  color: const Color(0xFF1B1607),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 22.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'WATCH VIDEO (+50 COINS)',
                                style: PicoTypography.labelPill.copyWith(
                                  color: const Color(0xFF1B1607),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
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

  Future<void> _handleWatchAd() async {
    setState(() => _isWatchingAd = true);

    final rewarded = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => const _SimulatedRewardAdDialog(),
    );

    if (mounted) {
      setState(() => _isWatchingAd = false);
      if (rewarded == true) {
        ref.read(currentUserProfileProvider.notifier).addCoins(50);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: PicoColors.pitchSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: PicoColors.gold, width: 1.2),
            ),
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: PicoColors.gold, size: 24.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    '🎉 Reward granted! +50 Pico Coins added to your club wallet.',
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// Simulated ad dialog shown when the user taps "Watch Video".
class _SimulatedRewardAdDialog extends StatelessWidget {
  const _SimulatedRewardAdDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A14),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: PicoColors.gold, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              offset: Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: PicoColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: PicoColors.gold, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_display_rounded, size: 12.0, color: PicoColors.gold),
                      const SizedBox(width: 4.0),
                      Text(
                        'SPONSOR PREVIEW',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.gold,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: PicoColors.textWhiteMuted, size: 20.0),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Simulated video player canvas
            Container(
              width: double.infinity,
              height: 140.0,
              decoration: BoxDecoration(
                color: const Color(0xFF070C09),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: PicoColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: PicoColors.gold,
                      size: 36.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Sponsor Video Demonstration',
                    style: PicoTypography.labelPill.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Ready to claim reward',
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.electricMint,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              'Video Ad Completed!',
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Claim your +50 Pico Coins bonus to use in your club wallet.',
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 44.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PicoColors.gold,
                  foregroundColor: const Color(0xFF1B1607),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'CLAIM +50 COINS',
                  style: PicoTypography.labelPill.copyWith(
                    color: const Color(0xFF1B1607),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
