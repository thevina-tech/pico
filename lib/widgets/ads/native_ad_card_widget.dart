import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/services/revenuecat_ad_service.dart';

/// Native Ad Card designed to seamlessly blend with Pico's [MatchCard] design language.
///
/// Features:
/// - Exact MatchCard geometry: tactile cream card face (`#F7F4EC`), 3D bottom bevel, 22px border radius.
/// - AdMob compliance: Clear "AD" badge and prominent Call-To-Action button.
/// - Ethical standard: Does not spoof football data or fake match scores.
/// - Automatic lifecycle disposal on widget unmount.
/// - Routed through [RevenueCatAdService] to capture Impression-Level Revenue Data (ILRD).
class NativeAdCardWidget extends StatefulWidget {
  const NativeAdCardWidget({
    super.key,
    this.placement = 'match_feed',
    this.adUnitId,
  });

  final String placement;
  final String? adUnitId;

  @override
  State<NativeAdCardWidget> createState() => _NativeAdCardWidgetState();
}

class _NativeAdCardWidgetState extends State<NativeAdCardWidget> {
  NativeAd? _nativeAd;
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
        dotenv.env['ADMOB_NATIVE_MATCH_FEED_ID_ANDROID'] ??
        'ca-app-pub-3940256099942544/2247696110';

    try {
      _nativeAd = RevenueCatAdService.instance.createNativeAd(
        adUnitId: unitId,
        placement: widget.placement,
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: PicoColors.cardFace,
          cornerRadius: 18.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: PicoColors.primary,
            style: NativeTemplateFontStyle.bold,
            size: 13.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF1B231D),
            style: NativeTemplateFontStyle.bold,
            size: 14.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF5A665D),
            style: NativeTemplateFontStyle.normal,
            size: 12.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF7A887E),
            style: NativeTemplateFontStyle.normal,
            size: 11.0,
          ),
        ),
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
          _nativeAd = null;
        },
      );

      _nativeAd?.load().catchError((_) {
        if (mounted) {
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFailed) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded) {
      return const SizedBox.shrink();
    }

    if (!RevenueCatAdService.instance.isTestEnvironment && _nativeAd == null) {
      return const SizedBox.shrink();
    }

    const bevelHeight = 4.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3D Bottom Bevel Layer matching MatchCard
          Positioned(
            left: 0,
            right: 0,
            top: bevelHeight,
            bottom: -bevelHeight,
            child: Container(
              decoration: BoxDecoration(
                color: PicoColors.cardBevel,
                borderRadius: BorderRadius.circular(22.0),
              ),
            ),
          ),

          // Main Card Face matching MatchCard styling
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
            decoration: BoxDecoration(
              color: PicoColors.cardFace,
              borderRadius: BorderRadius.circular(22.0),
              border: Border.all(color: PicoColors.cardBorder, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compliance Header: Prominent "Ad" Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'SPONSORED PARTNER',
                          style: PicoTypography.labelPillSm.copyWith(
                            color: PicoColors.textTactileMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.0,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 15.0,
                      color: PicoColors.textTactileMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Native Ad Content Widget
                RevenueCatAdService.instance.isTestEnvironment
                    ? Container(
                        height: 90.0,
                        alignment: Alignment.center,
                        child: Text(
                          'Featured Football Partner',
                          style: PicoTypography.bodySm.copyWith(
                            color: PicoColors.textTactileMuted,
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 320,
                          minHeight: 90,
                          maxHeight: 120,
                        ),
                        child: AdWidget(ad: _nativeAd!),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
