// ignore_for_file: experimental_member_use
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/services/ad_consent_service.dart';

/// Singleton service managing Google Mobile Ads and RevenueCat ILRD (Impression-Level Revenue Data).
///
/// Features:
/// - Initializes Google Mobile Ads SDK and RevenueCat SDK.
/// - Syncs authenticated Supabase user ID with RevenueCat via [Purchases.logIn].
/// - Wraps Banner, Native, and Interstitial ads with AdMob listeners.
/// - Manually routes all ad lifecycle events to RevenueCat AdTracker:
///   - `onAdLoaded` -> [Purchases.adTracker.trackAdLoaded]
///   - `onAdFailedToLoad` -> [Purchases.adTracker.trackAdFailedToLoad]
///   - `onAdImpression` / `onAdShowedFullScreenContent` -> [Purchases.adTracker.trackAdDisplayed]
///   - `onAdClicked` -> [Purchases.adTracker.trackAdOpened]
///   - `onPaidEvent` -> [Purchases.adTracker.trackAdRevenue]
/// - Preloads and safely presents Interstitial ads with graceful degradation.
class RevenueCatAdService {
  RevenueCatAdService._();

  static final RevenueCatAdService _instance = RevenueCatAdService._();
  static RevenueCatAdService get instance => _instance;

  static const _uuid = Uuid();
  bool _initialized = false;
  bool _isPurchasesConfigured = false;
  InterstitialAd? _preloadedInterstitialAd;
  bool _isPreloadingInterstitial = false;
  String? _interstitialImpressionId;

  bool get isInitialized => _initialized;
  bool get isPurchasesConfigured => _isPurchasesConfigured;
  bool get hasPreloadedInterstitial => _preloadedInterstitialAd != null;

  /// Returns true when running inside Flutter test runner.
  bool get isTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Initializes Google Mobile Ads and RevenueCat SDKs.
  Future<void> initialize({String? revenueCatApiKey, String? initialUserId}) async {
    if (_initialized) return;

    if (isTestEnvironment) {
      _initialized = true;
      AppLogger.info('RevenueCatAdService initialized in test environment');
      return;
    }

    // 1. Initialize Google Mobile Ads safely after consent verification
    try {
      await AdConsentService.instance.initializeMobileAdsIfAllowed();
    } catch (e) {
      AppLogger.warning('Failed to initialize Google Mobile Ads via AdConsentService: $e');
    }

    // 2. Initialize RevenueCat
    final rcKey = revenueCatApiKey ?? dotenv.env['REVENUECAT_API_KEY'];
    if (rcKey != null && rcKey.trim().isNotEmpty && !rcKey.contains('placeholder')) {
      try {
        final isAlreadyConfigured = await Purchases.isConfigured;
        if (!isAlreadyConfigured) {
          final config = PurchasesConfiguration(rcKey);
          if (initialUserId != null && initialUserId.isNotEmpty) {
            config.appUserID = initialUserId;
          }
          await Purchases.configure(config);
        } else if (initialUserId != null && initialUserId.isNotEmpty) {
          await Purchases.logIn(initialUserId);
        }
        _isPurchasesConfigured = true;
        AppLogger.info('RevenueCat initialized successfully with AdTracker support');
      } catch (e) {
        _isPurchasesConfigured = false;
        AppLogger.warning('Failed to configure RevenueCat: $e');
      }
    } else {
      _isPurchasesConfigured = false;
      AppLogger.info('RevenueCat API key not provided; AdTracker will log events safely');
    }

    _initialized = true;
  }

  /// Syncs user identity with RevenueCat when authentication state changes.
  Future<void> syncUser(String? userId) async {
    if (!_isPurchasesConfigured) return;
    try {
      if (userId != null && userId.isNotEmpty) {
        await Purchases.logIn(userId);
        AppLogger.info('RevenueCat user synced: $userId');
      } else {
        await Purchases.logOut();
        AppLogger.info('RevenueCat user logged out');
      }
    } catch (e) {
      AppLogger.warning('Failed to sync user with RevenueCat: $e');
    }
  }

  // ==========================================
  // BANNER AD CREATION & TRACKING
  // ==========================================

  /// Creates and loads a [BannerAd] with automatic RevenueCat AdTracker routing.
  BannerAd createBannerAd({
    required String adUnitId,
    required String placement,
    required AdSize size,
    required void Function(Ad ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    void Function(Ad ad)? onAdImpression,
    void Function(Ad ad)? onAdClicked,
    void Function(Ad ad)? onAdOpened,
    void Function(Ad ad)? onAdClosed,
  }) {
    final impressionId = _uuid.v4();

    return BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _trackAdLoaded(
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _trackAdFailedToLoad(
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
          );
          onAdFailedToLoad(ad, error);
        },
        onAdImpression: (ad) {
          _trackAdDisplayed(
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdImpression?.call(ad);
        },
        onAdClicked: (ad) {
          _trackAdOpened(
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdClicked?.call(ad);
        },
        onAdOpened: onAdOpened,
        onAdClosed: onAdClosed,
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          _trackAdRevenue(
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
            revenueMicros: valueMicros.toInt(),
            currency: currencyCode,
            precision: _mapPrecision(precision),
          );
        },
      ),
    );
  }

  // ==========================================
  // NATIVE AD CREATION & TRACKING
  // ==========================================

  /// Creates and loads a [NativeAd] with automatic RevenueCat AdTracker routing.
  NativeAd createNativeAd({
    required String adUnitId,
    required String placement,
    required void Function(Ad ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    void Function(Ad ad)? onAdImpression,
    void Function(Ad ad)? onAdClicked,
    void Function(Ad ad)? onAdOpened,
    void Function(Ad ad)? onAdClosed,
    NativeTemplateStyle? nativeTemplateStyle,
  }) {
    final impressionId = _uuid.v4();

    return NativeAd(
      adUnitId: adUnitId,
      factoryId: null,
      request: const AdRequest(),
      nativeTemplateStyle: nativeTemplateStyle,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _trackAdLoaded(
            adFormat: const AdFormat('native'),
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _trackAdFailedToLoad(
            adFormat: const AdFormat('native'),
            placement: placement,
            adUnitId: adUnitId,
          );
          onAdFailedToLoad(ad, error);
        },
        onAdImpression: (ad) {
          _trackAdDisplayed(
            adFormat: const AdFormat('native'),
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdImpression?.call(ad);
        },
        onAdClicked: (ad) {
          _trackAdOpened(
            adFormat: const AdFormat('native'),
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
          );
          onAdClicked?.call(ad);
        },
        onAdOpened: onAdOpened,
        onAdClosed: onAdClosed,
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          _trackAdRevenue(
            adFormat: const AdFormat('native'),
            placement: placement,
            adUnitId: adUnitId,
            impressionId: impressionId,
            revenueMicros: valueMicros.toInt(),
            currency: currencyCode,
            precision: _mapPrecision(precision),
          );
        },
      ),
    );
  }

  // ==========================================
  // INTERSTITIAL AD PRELOADING & PRESENTATION
  // ==========================================

  /// Preloads an InterstitialAd for subsequent instant presentation.
  Future<void> preloadInterstitialAd({
    String? adUnitId,
    String placement = 'private_league_creation',
  }) async {
    if (isTestEnvironment) return;
    if (_isPreloadingInterstitial || _preloadedInterstitialAd != null) return;
    _isPreloadingInterstitial = true;

    final unitId = adUnitId ??
        dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'] ??
        'ca-app-pub-3940256099942544/1033173712';

    final impressionId = _uuid.v4();
    _interstitialImpressionId = impressionId;

    try {
      await InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _preloadedInterstitialAd = ad;
            _isPreloadingInterstitial = false;

            // Track loaded
            _trackAdLoaded(
              adFormat: AdFormat.interstitial,
              placement: placement,
              adUnitId: unitId,
              impressionId: impressionId,
            );

            // Setup paid event
            ad.onPaidEvent = (paidAd, valueMicros, precision, currencyCode) {
              _trackAdRevenue(
                adFormat: AdFormat.interstitial,
                placement: placement,
                adUnitId: unitId,
                impressionId: impressionId,
                revenueMicros: valueMicros.toInt(),
                currency: currencyCode,
                precision: _mapPrecision(precision),
              );
            };

            AppLogger.info('Interstitial ad preloaded successfully');
          },
          onAdFailedToLoad: (error) {
            _preloadedInterstitialAd = null;
            _isPreloadingInterstitial = false;

            _trackAdFailedToLoad(
              adFormat: AdFormat.interstitial,
              placement: placement,
              adUnitId: unitId,
            );

            AppLogger.warning('Failed to preload Interstitial ad: ${error.message}');
          },
        ),
      ).catchError((e) {
        _isPreloadingInterstitial = false;
        AppLogger.warning('Failed to invoke InterstitialAd.load: $e');
      });
    } catch (e) {
      _isPreloadingInterstitial = false;
      AppLogger.warning('Failed to invoke InterstitialAd.load: $e');
    }
  }

  /// Shows the preloaded InterstitialAd.
  /// Gracefully degrades and invokes [onDismissed] if the ad fails to show or is not ready.
  Future<void> showInterstitialAd({
    String placement = 'private_league_creation',
    VoidCallback? onDismissed,
  }) async {
    if (isTestEnvironment) {
      onDismissed?.call();
      return;
    }

    final ad = _preloadedInterstitialAd;
    final impressionId = _interstitialImpressionId ?? _uuid.v4();
    final unitId = dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'] ??
        'ca-app-pub-3940256099942544/1033173712';

    if (ad == null) {
      AppLogger.info('Interstitial ad not ready; proceeding gracefully');
      onDismissed?.call();
      // Trigger preload for future actions
      preloadInterstitialAd(placement: placement);
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _trackAdDisplayed(
          adFormat: AdFormat.interstitial,
          placement: placement,
          adUnitId: unitId,
          impressionId: impressionId,
        );
        AppLogger.info('Interstitial ad displayed on screen');
      },
      onAdClicked: (ad) {
        _trackAdOpened(
          adFormat: AdFormat.interstitial,
          placement: placement,
          adUnitId: unitId,
          impressionId: impressionId,
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.info('Interstitial ad dismissed; cleaning up');
        ad.dispose();
        _preloadedInterstitialAd = null;
        onDismissed?.call();
        // Preload next interstitial
        preloadInterstitialAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Interstitial ad failed to show: ${error.message}; degrading gracefully');
        ad.dispose();
        _preloadedInterstitialAd = null;
        onDismissed?.call();
        // Preload next interstitial
        preloadInterstitialAd(placement: placement);
      },
    );

    try {
      await ad.show();
    } catch (e) {
      AppLogger.warning('Exception showing interstitial ad; proceeding gracefully: $e');
      ad.dispose();
      _preloadedInterstitialAd = null;
      onDismissed?.call();
      preloadInterstitialAd(placement: placement);
    }
  }

  // ==========================================
  // REVENUECAT ADTRACKER ROUTING (PRIVATE HELPERS)
  // ==========================================

  void _trackAdLoaded({
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
    required String impressionId,
  }) {
    if (!_isPurchasesConfigured) return;
    try {
      Purchases.adTracker.trackAdLoaded(
        AdLoadedData(
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
        ),
      ).catchError((e) {
        AppLogger.debug('AdTracker.trackAdLoaded error: $e');
      });
    } catch (e) {
      AppLogger.debug('AdTracker.trackAdLoaded note: $e');
    }
  }

  void _trackAdFailedToLoad({
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
  }) {
    if (!_isPurchasesConfigured) return;
    try {
      Purchases.adTracker.trackAdFailedToLoad(
        AdFailedToLoadData(
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
        ),
      ).catchError((e) {
        AppLogger.debug('AdTracker.trackAdFailedToLoad error: $e');
      });
    } catch (e) {
      AppLogger.debug('AdTracker.trackAdFailedToLoad note: $e');
    }
  }

  void _trackAdDisplayed({
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
    required String impressionId,
  }) {
    if (!_isPurchasesConfigured) return;
    try {
      Purchases.adTracker.trackAdDisplayed(
        AdDisplayedData(
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
        ),
      ).catchError((e) {
        AppLogger.debug('AdTracker.trackAdDisplayed error: $e');
      });
    } catch (e) {
      AppLogger.debug('AdTracker.trackAdDisplayed note: $e');
    }
  }

  void _trackAdOpened({
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
    required String impressionId,
  }) {
    if (!_isPurchasesConfigured) return;
    try {
      Purchases.adTracker.trackAdOpened(
        AdOpenedData(
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
        ),
      ).catchError((e) {
        AppLogger.debug('AdTracker.trackAdOpened error: $e');
      });
    } catch (e) {
      AppLogger.debug('AdTracker.trackAdOpened note: $e');
    }
  }

  void _trackAdRevenue({
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
    required String impressionId,
    required int revenueMicros,
    required String currency,
    required AdRevenuePrecision precision,
  }) {
    if (!_isPurchasesConfigured) return;
    try {
      Purchases.adTracker.trackAdRevenue(
        AdRevenueData(
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
          revenueMicros: revenueMicros,
          currency: currency.isNotEmpty ? currency : 'USD',
          precision: precision,
        ),
      ).catchError((e) {
        AppLogger.debug('AdTracker.trackAdRevenue error: $e');
      });
    } catch (e) {
      AppLogger.debug('AdTracker.trackAdRevenue note: $e');
    }
  }

  AdRevenuePrecision _mapPrecision(PrecisionType precision) {
    switch (precision) {
      case PrecisionType.precise:
        return const AdRevenuePrecision('exact');
      case PrecisionType.estimated:
        return const AdRevenuePrecision('estimated');
      case PrecisionType.publisherProvided:
        return const AdRevenuePrecision('publisher_provided');
      case PrecisionType.unknown:
        return const AdRevenuePrecision('unknown');
    }
  }
}
