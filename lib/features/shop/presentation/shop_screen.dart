import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
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
/// - Prominently highlights the core "Remove Ads" lifetime pass item.
/// - Polished UI layout consistent with Pico's tactile game design system.
/// - Strict reliance on [isAdFreeProvider] for ad-free state.
/// - Clean action handlers ready for real RevenueCat in-app purchase and restore flows.
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

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  /// Triggers the RevenueCat paywall for the "remove_ads" entitlement if needed.
  Future<void> _onRemoveAdsPressed() async {
    final l10n = AppLocalizations.of(context);
    try {
      await RevenueCatUI.presentPaywallIfNeeded("remove_ads");
    } catch (e) {
      AppLogger.warning('RevenueCat paywall presentation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.shopPaywallLoadError ?? 'Could not load store offerings. Please check your connection and try again.',
            ),
          ),
        );
      }
    }
  }

  /// Clean handler triggering real RevenueCat purchase restoration.
  Future<void> _onRestorePurchasesPressed() async {
    final l10n = AppLocalizations.of(context);
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isUnlocked =
          customerInfo.entitlements.all['remove_ads']?.isActive == true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUnlocked
                  ? (l10n?.shopRestoreSuccess ?? 'Purchases restored successfully!')
                  : (l10n?.shopRestoreNothingFound ?? 'No active purchases found to restore.'),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.warning('Failed to restore purchases: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.shopRestoreFailed(e.toString()) ?? 'Failed to restore purchases: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdFree = ref.watch(isAdFreeProvider);

    return PicoGameExitScope(
      child: PicoPitchBackground(
        imageAsset: 'assets/images/main_background.png',
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
          body: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 32.0),
                  children: [
                    // Header Tagline
                    _buildShopHeader(l10n),
                    const SizedBox(height: 20.0),

                    // Dedicated "Remove Ads" / Ad-Free Experience Card
                    _buildRemoveAdsCard(context, isAdFree, l10n),
                    const SizedBox(height: 18.0),

                    // Restore Purchases Action Link
                    Center(
                      child: TextButton.icon(
                        key: const Key('restore_purchases_button'),
                        onPressed: _onRestorePurchasesPressed,
                        icon: const Icon(
                          Icons.restore_rounded,
                          size: 18.0,
                          color: Color(0xFFA7D1BC),
                        ),
                        label: Text(
                          l10n?.shopRestorePurchases ?? 'Restore Purchases',
                          style: const TextStyle(
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
                    _buildComingSoonBanner(l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xCC0F1E17),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: const Color(0x3334D399), width: 1.2),
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
                  l10n?.shopHeaderBadge ?? 'CLASH ELEVEN STORE',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: const Color(0xFFFCCB2B),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.shopHeaderTagline ?? 'Power up your prediction experience',
                  style: const TextStyle(
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

  Widget _buildRemoveAdsCard(BuildContext context, bool isAdFree, AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132B20), Color(0xFF0B1913)],
        ),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0x4D34D399), width: 1.5),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: isAdFree
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isAdFree
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  isAdFree
                      ? (l10n?.shopAdFreeActiveBadge ?? 'ACTIVE • UNLOCKED')
                      : (l10n?.shopAdFreeLockedBadge ?? 'LIFETIME PASS'),
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: isAdFree
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFCD34D),
                  ),
                ),
              ),
              // Dedicated Ad-Off / Shield Icon
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
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        isAdFree
                            ? Icons.verified_user_rounded
                            : Icons.shield_rounded,
                        color: const Color(0xFF34D399),
                        size: 24.0,
                      ),
                      Positioned(
                        right: 2.0,
                        top: 2.0,
                        child: Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFFFCCB2B),
                          size: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Title
          Text(
            l10n?.shopRemoveAdsTitle ?? 'Remove Ads',
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6.0),

          // Description
          Text(
            l10n?.shopRemoveAdsDescription ?? 'Enjoy an uninterrupted match-tracking experience with zero ads.',
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13.5,
              height: 1.4,
              color: Color(0xFFCADED4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18.0),

          // Perks list
          _buildPerkRow(l10n?.shopPerkNoBannerAds ?? 'Zero banner ads on Home & Matches'),
          const SizedBox(height: 8.0),
          _buildPerkRow(l10n?.shopPerkNoVideoAds ?? 'Zero interstitial video ads'),
          const SizedBox(height: 8.0),
          _buildPerkRow(l10n?.shopPerkFastTransitions ?? 'Instant prediction screen transitions'),
          const SizedBox(height: 8.0),
          _buildPerkRow(l10n?.shopPerkLifetime ?? 'One-time unlock • Keep forever'),
          const SizedBox(height: 22.0),

          // Action Button
          if (isAdFree)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3D27),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFF34D399), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34D399),
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      l10n?.shopAdsRemovedConfirm ?? 'Ads Removed • Lifetime Unlocked',
                      style: const TextStyle(
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
              key: const Key('remove_ads_action_button'),
              text: l10n?.shopUnlockAdFreeButton ?? 'Unlock Ad-Free • \$5.99',
              textColor: const Color(0xFF3D1800),
              textShadowColor: Colors.transparent,
              onPressed: _onRemoveAdsPressed,
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

  Widget _buildComingSoonBanner(AppLocalizations? l10n) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.shopComingSoonBadge ?? 'MORE REWARDS COMING SOON',
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFCCB2B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.shopComingSoonBody ?? 'Exclusive mascot jerseys, division badges & league themes are currently in preparation.',
                  style: const TextStyle(
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
