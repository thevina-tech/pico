import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/shop/presentation/ad_free_provider.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/widgets/ads/banner_ad_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RevenueCat Remove Ads Integration Tests', () {
    test('1. Environment contains REVENUECAT_API_KEY in .env.dev and .env.prod', () {
      final envDevFile = File('.env.dev');
      expect(envDevFile.existsSync(), isTrue);
      final devContent = envDevFile.readAsStringSync();
      expect(devContent.contains('REVENUECAT_API_KEY='), isTrue);

      final envProdFile = File('.env.prod');
      expect(envProdFile.existsSync(), isTrue);
      final prodContent = envProdFile.readAsStringSync();
      expect(prodContent.contains('REVENUECAT_API_KEY='), isTrue);
    });

    test('2. isAdFreeProvider is a NotifierProvider defaulting to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isAdFree = container.read(isAdFreeProvider);
      expect(isAdFree, isFalse);
    });

    test('3. isAdFreeProvider can update state to true and false', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isAdFreeProvider), isFalse);

      await container.read(isAdFreeProvider.notifier).unlockAdFree();
      expect(container.read(isAdFreeProvider), isTrue);

      await container.read(isAdFreeProvider.notifier).resetAdFree();
      expect(container.read(isAdFreeProvider), isFalse);
    });

    testWidgets('4. BannerAdWidget renders when isAdFree is false and hides when isAdFree is true',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: BannerAdWidget(placement: 'dashboard_bottom'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When false, banner widget is present
      expect(find.byType(BannerAdWidget), findsOneWidget);

      // Now set isAdFree to true
      await container.read(isAdFreeProvider.notifier).unlockAdFree();
      await tester.pumpAndSettle();

      // BannerAdWidget renders SizedBox.shrink() when isAdFree is true
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(
        sizedBoxes.any((box) => box.width == 0.0 && box.height == 0.0),
        isTrue,
      );
    });

    testWidgets('5. Consumer wrapping BannerAdWidget returns SizedBox.shrink() when isAdFree is true',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final isAdFree = ref.watch(isAdFreeProvider);
                  if (isAdFree) return const SizedBox.shrink();
                  return const BannerAdWidget(placement: 'dashboard_bottom');
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BannerAdWidget), findsOneWidget);

      // Unlock ad-free
      await container.read(isAdFreeProvider.notifier).unlockAdFree();
      await tester.pumpAndSettle();

      // Now BannerAdWidget should be completely gone
      expect(find.byType(BannerAdWidget), findsNothing);
    });

    testWidgets('6. ShopScreen renders Unlock Ad-Free button and triggers paywall handler',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check button existence
      final buttonFinder = find.byKey(const Key('remove_ads_action_button'));
      expect(buttonFinder, findsOneWidget);

      // Tap button to verify handler execution does not crash
      await tester.tap(buttonFinder);
      await tester.pump();
    });
  });
}
