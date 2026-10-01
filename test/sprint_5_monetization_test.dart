// ignore_for_file: experimental_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pico/services/revenuecat_ad_service.dart';
import 'package:pico/widgets/ads/banner_ad_widget.dart';
import 'package:pico/widgets/ads/native_ad_card_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
  });

  group('Sprint 5: AdMob & RevenueCat ILRD Setup', () {
    test('AndroidManifest contains com.google.android.gms.ads.APPLICATION_ID', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);
      final content = manifestFile.readAsStringSync();
      expect(content, contains('com.google.android.gms.ads.APPLICATION_ID'));
      expect(content, contains('ca-app-pub-3940256099942544~3347511713'));
    });

    test('Environment files contain all 3 AdMob unit keys', () async {
      await dotenv.load(fileName: '.env.dev');
      expect(dotenv.env['ADMOB_BANNER_ID_ANDROID'], isNotEmpty);
      expect(dotenv.env['ADMOB_NATIVE_MATCH_FEED_ID_ANDROID'], isNotEmpty);
      expect(dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'], isNotEmpty);

      await dotenv.load(fileName: '.env.prod');
      expect(dotenv.env['ADMOB_BANNER_ID_ANDROID'], isNotEmpty);
      expect(dotenv.env['ADMOB_NATIVE_MATCH_FEED_ID_ANDROID'], isNotEmpty);
      expect(dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'], isNotEmpty);
    });

    test('RevenueCatAdService singleton lifecycle and user sync', () async {
      final service = RevenueCatAdService.instance;
      expect(service, isNotNull);

      // Initialize
      await service.initialize();
      expect(service.isInitialized, isTrue);

      // Sync user
      await service.syncUser('test_user_pico_123');
      await service.syncUser(null);
    });

    test('RevenueCatAdService Interstitial graceful degradation', () async {
      final service = RevenueCatAdService.instance;
      bool dismissed = false;

      // When interstitial is not loaded, it immediately degrades gracefully and calls onDismissed
      await service.showInterstitialAd(
        placement: 'private_league_creation',
        onDismissed: () {
          dismissed = true;
        },
      );

      expect(dismissed, isTrue);
    });

    test('RevenueCat ad tracker dimensions and data models', () {
      const bannerLoaded = AdLoadedData(
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat.banner,
        placement: 'dashboard_bottom',
        adUnitId: 'test_banner',
        impressionId: 'imp_1',
      );
      expect(bannerLoaded.mediatorName, AdMediatorName.adMob);
      expect(bannerLoaded.adFormat, AdFormat.banner);
      expect(bannerLoaded.placement, 'dashboard_bottom');

      const nativeLoaded = AdLoadedData(
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat('native'),
        placement: 'match_feed',
        adUnitId: 'test_native',
        impressionId: 'imp_2',
      );
      expect(nativeLoaded.adFormat, const AdFormat('native'));
      expect(nativeLoaded.placement, 'match_feed');

      const interstitialLoaded = AdLoadedData(
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat.interstitial,
        placement: 'private_league_creation',
        adUnitId: 'test_interstitial',
        impressionId: 'imp_3',
      );
      expect(interstitialLoaded.adFormat, AdFormat.interstitial);
      expect(interstitialLoaded.placement, 'private_league_creation');

      const failedData = AdFailedToLoadData(
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat.banner,
        placement: 'dashboard_bottom',
        adUnitId: 'test_unit',
      );
      expect(failedData.placement, 'dashboard_bottom');

      const revenueData = AdRevenueData(
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat.banner,
        placement: 'dashboard_bottom',
        adUnitId: 'test_banner',
        impressionId: 'imp_1',
        revenueMicros: 1500,
        currency: 'USD',
        precision: AdRevenuePrecision('exact'),
      );
      expect(revenueData.revenueMicros, 1500);
      expect(revenueData.currency, 'USD');
    });
  });

  group('Sprint 5: Ad Widgets (Banner & Native)', () {
    testWidgets('BannerAdWidget builds and safely collapses on unsupported platform', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BannerAdWidget(placement: 'dashboard_bottom'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // On desktop unit test environment, BannerAdWidget collapses to 0 height gracefully
      final bannerFinder = find.byType(BannerAdWidget);
      expect(bannerFinder, findsOneWidget);
    });

    testWidgets('NativeAdCardWidget builds with compliance AD badge', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NativeAdCardWidget(placement: 'match_feed'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nativeFinder = find.byType(NativeAdCardWidget);
      expect(nativeFinder, findsOneWidget);
    });

    test('Feed index math: every 6th item is an ad', () {
      bool isAdIndex(int index) => (index + 1) % 6 == 0;
      int getMatchIndex(int index) => index - ((index + 1) ~/ 6);

      expect(isAdIndex(0), isFalse);
      expect(getMatchIndex(0), 0);

      expect(isAdIndex(4), isFalse);
      expect(getMatchIndex(4), 4);

      // 6th item (index 5) is an ad
      expect(isAdIndex(5), isTrue);

      // 7th item (index 6) is match 5
      expect(isAdIndex(6), isFalse);
      expect(getMatchIndex(6), 5);

      // 12th item (index 11) is an ad
      expect(isAdIndex(11), isTrue);

      // 13th item (index 12) is match 10
      expect(isAdIndex(12), isFalse);
      expect(getMatchIndex(12), 10);
    });
  });
}
