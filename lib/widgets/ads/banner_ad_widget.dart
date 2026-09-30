import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pico/features/shop/presentation/ad_free_provider.dart';
import 'package:pico/services/revenuecat_ad_service.dart';

/// Sticky adaptive Banner Ad widget for dashboard/home.
///
/// Features:
/// - Fixed height constraint (50-60px) to eliminate Cumulative Layout Shift (CLS).
/// - Seamlessly collapses to 0 height if loading fails, ad is unavailable, or user is ad-free.
/// - Automatically disposes [BannerAd] on unmount to prevent memory leaks.
/// - Routed through [RevenueCatAdService] to capture Impression-Level Revenue Data (ILRD).
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({
    super.key,
    this.placement = 'dashboard_bottom',
    this.adUnitId,
  });

  final String placement;
  final String? adUnitId;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (RevenueCatAdService.instance.isTestEnvironment) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
          _isFailed = false;
        });
      }
      return;
    }

    final unitId = widget.adUnitId ??
        dotenv.env['ADMOB_BANNER_ID_ANDROID'] ??
        'ca-app-pub-3940256099942544/9214589741';

    try {
      _bannerAd = RevenueCatAdService.instance.createBannerAd(
        adUnitId: unitId,
        placement: widget.placement,
        size: AdSize.banner,
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
          ad.dispose();
          _bannerAd = null;
        },
      );

      _bannerAd?.load().catchError((_) {
        if (mounted) {
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
        }
      });
    } catch (_) {
      // In non-supported platforms (e.g. desktop/unit test runner), collapse gracefully
      if (mounted) {
        setState(() {
          _isFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdFree = ref.watch(adFreeProvider);
    if (isAdFree || _isFailed) {
      return const SizedBox.shrink();
    }

    if (RevenueCatAdService.instance.isTestEnvironment) {
      return const SizedBox(
        height: 54.0,
        width: double.infinity,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isLoaded ? 54.0 : 0.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: _isLoaded && _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
