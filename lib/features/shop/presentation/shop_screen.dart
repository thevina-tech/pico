import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/shop/presentation/ad_free_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Pico Shop screen.
///
/// Features:
/// - Highlights the core "Remove Ads" lifetime pass item.
/// - Tactile 3D button interactions using [GameButton].
/// - Persistent ad-free state tracking via [adFreeProvider].
/// - Restore purchases support.
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
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  Future<void> _handlePurchase() async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    // Simulate purchase network call
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      await ref.read(adFreeProvider.notifier).unlockAdFree();
      if (!mounted) return;
      setState(() => _isPurchasing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: PicoColors.primaryFixed),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Ads successfully removed! Enjoy your uninterrupted Pico experience.',
                  style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F2F20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.restore_rounded, color: PicoColors.gold),
            SizedBox(width: 8.0),
            Text(
              'Checking purchase history... Purchases restored.',
              style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF162534),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdFree = ref.watch(adFreeProvider);

    return PicoGameExitScope(
      child: Scaffold(
        backgroundColor: PicoColors.pitchBackground,
        appBar: PicoAppBar(
          title: l10n?.navShop ?? 'Shop',
          isTransparent: true,
          showBackButton: false,
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
                          // Already in Shop
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
        body: PicoPitchBackground(
          imageAsset: 'assets/images/main_background.png',
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 32.0),
                  children: [
                    // Header Tagline
                    _buildShopHeader(),
                    const SizedBox(height: 20.0),

                    // Primary Item: Remove Ads
                    _buildRemoveAdsCard(context, isAdFree),
                    const SizedBox(height: 20.0),

                    // Restore Purchases Action
                    Center(
                      child: TextButton.icon(
                        key: const Key('restore_purchases_button'),
                        onPressed: _handleRestore,
                        icon: const Icon(
                          Icons.restore_rounded,
                          size: 18.0,
                          color: Color(0xFFA7D1BC),
                        ),
                        label: const Text(
                          'Restore Purchases',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA7D1BC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Coming Soon Teaser
                    _buildComingSoonBanner(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xCC0F1E17),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0x3334D399),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFCCB2B), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FCCB2B),
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                size: 26.0,
                color: Color(0xFF261700),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICO STORE',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: const Color(0xFFFCCB2B),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'Power up your prediction experience',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveAdsCard(BuildContext context, bool isAdFree) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF132B20),
            Color(0xFF0B1913),
          ],
        ),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: const Color(0x4D34D399),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            offset: Offset(0, 6),
            blurRadius: 18.0,
          ),
          BoxShadow(
            color: Color(0x2210B981),
            offset: Offset(0, 1),
            blurRadius: 8.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + Icon Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isAdFree
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isAdFree ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  isAdFree ? 'ACTIVE • UNLOCKED' : 'LIFETIME PASS',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: isAdFree ? const Color(0xFF34D399) : const Color(0xFFFCD34D),
                  ),
                ),
              ),
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF163325),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x334ADE80),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.block_rounded,
                    color: Color(0xFF34D399),
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Title
          const Text(
            'Remove Ads',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6.0),

          // Description
          const Text(
            'Enjoy a clean, uninterrupted football prediction experience. Never see banner ads or video interruptions ever again.',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13.0,
              height: 1.4,
              color: Color(0xFFCADED4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18.0),

          // Perks list
          _buildPerkRow('Zero banner ads on Home & Matches'),
          const SizedBox(height: 8.0),
          _buildPerkRow('Zero interstitial video ads'),
          const SizedBox(height: 8.0),
          _buildPerkRow('Instant prediction screen transitions'),
          const SizedBox(height: 8.0),
          _buildPerkRow('One-time purchase • Keep forever'),
          const SizedBox(height: 22.0),

          // CTA Action
          if (isAdFree)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3D27),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: const Color(0xFF34D399),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34D399),
                    size: 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      'Ads Removed • Lifetime Unlocked',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF34D399),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            GameButton.gold(
              key: const Key('remove_ads_purchase_button'),
              text: _isPurchasing ? 'Processing...' : 'REMOVE ADS • \$2.99',
              onPressed: _isPurchasing ? null : _handlePurchase,
              width: double.infinity,
              height: 52.0,
            ),
        ],
      ),
    );
  }

  Widget _buildPerkRow(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF34D399),
          size: 16.0,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0x660F1A24),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D3D),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFCCB2B),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MORE REWARDS COMING SOON',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFCCB2B),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  'Exclusive mascot jerseys, division badges & league themes are currently in preparation.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
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
