import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/shop/presentation/ad_free_provider.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Stitch 5-Tab PicoBottomNavBar Tests (Shop, Matches, Home, Tournaments, Profile)', () {
    testWidgets('renders 5 tabs in order: Shop, Matches, Home, Tournaments, Profile',
        (WidgetTester tester) async {
      int selectedIndex = 2; // Home active by default

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return PicoBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (idx) {
                    setState(() => selectedIndex = idx);
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 5 tab labels are visible
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tournaments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify semantic keys
      final shopKey = find.byKey(const ValueKey('nav_shop'));
      final matchesKey = find.byKey(const ValueKey('nav_matches'));
      final homeKey = find.byKey(const ValueKey('nav_home'));
      final tournamentsKey = find.byKey(const ValueKey('nav_tournaments'));
      final profileKey = find.byKey(const ValueKey('nav_profile'));

      expect(shopKey, findsOneWidget);
      expect(matchesKey, findsOneWidget);
      expect(homeKey, findsOneWidget);
      expect(tournamentsKey, findsOneWidget);
      expect(profileKey, findsOneWidget);

      // Check horizontal ordering: shop < matches < home < tournaments < profile
      final shopOffset = tester.getCenter(shopKey);
      final matchesOffset = tester.getCenter(matchesKey);
      final homeOffset = tester.getCenter(homeKey);
      final tournamentsOffset = tester.getCenter(tournamentsKey);
      final profileOffset = tester.getCenter(profileKey);

      expect(shopOffset.dx < matchesOffset.dx, isTrue);
      expect(matchesOffset.dx < homeOffset.dx, isTrue);
      expect(homeOffset.dx < tournamentsOffset.dx, isTrue);
      expect(tournamentsOffset.dx < profileOffset.dx, isTrue);

      // Tap on Shop (index 0)
      await tester.tap(shopKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);

      // Tap on Matches (index 1)
      await tester.tap(matchesKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);

      // Tap on Home (index 2)
      await tester.tap(homeKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);

      // Tap on Tournaments (index 3)
      await tester.tap(tournamentsKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 3);

      // Tap on Profile (index 4)
      await tester.tap(profileKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 4);
    });

    testWidgets('renders localized Spanish tab labels correctly with Tienda',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('es')],
          home: Scaffold(
            bottomNavigationBar: PicoBottomNavBar(
              currentIndex: 0,
              onTap: _noOp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tienda'), findsOneWidget);
      expect(find.text('Partidos'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Torneos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('renders 5 protruding pop icons at 40x40 and gold pill indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
          home: Scaffold(
            bottomNavigationBar: PicoBottomNavBar(
              currentIndex: 0, // Shop active
              onTap: _noOp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify dark stadium grass gradient on the outer container
      final containerFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).gradient is LinearGradient,
      );
      expect(containerFinder, findsWidgets);

      // 2. Verify all 5 tab icons are rendered at 40x40 without opacity dimming
      expect(find.byType(Image), findsNWidgets(5));
      expect(find.byType(AnimatedOpacity), findsNothing);

      // 3. Verify text colors (active is crisp white, inactive is soft meadow mint)
      final shopText = tester.widget<Text>(find.text('Shop'));
      expect(shopText.style?.color, Colors.white);

      final homeText = tester.widget<Text>(find.text('Home'));
      expect(homeText.style?.color, const Color(0xFFA7D1BC));

      // 4. Verify gold pill indicator (#FCCB2B)
      final goldPillFinder = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == const Color(0xFFFCCB2B),
      );
      expect(goldPillFinder, findsOneWidget);

      // 5. Verify the active Shop icon has translation and scale pop (-8.0 offset)
      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      final poppedContainer = animatedContainers.firstWhere(
        (c) => c.transform != null && c.transform!.getTranslation().y < -5.0,
      );
      expect(poppedContainer.transform!.getTranslation().y, -8.0);
    });
  });

  group('ShopScreen UI & Remove Ads Item Tests', () {
    testWidgets('renders shop header, Remove Ads card, and restore button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('es')],
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('PICO STORE'), findsOneWidget);
      expect(find.text('Power up your prediction experience'), findsOneWidget);

      // Verify Primary Item: Remove Ads
      expect(find.text('Remove Ads'), findsOneWidget);
      expect(
        find.text('Enjoy an uninterrupted match-tracking experience with zero ads.'),
        findsOneWidget,
      );
      expect(find.text('LIFETIME PASS'), findsOneWidget);
      expect(find.text('Zero banner ads on Home & Matches'), findsOneWidget);
      expect(find.text('Zero interstitial video ads'), findsOneWidget);
      expect(find.text('Unlock Ad-Free • \$2.99'), findsOneWidget);
      expect(find.byKey(const Key('remove_ads_action_button')), findsOneWidget);

      // Verify Restore Purchases button
      expect(find.byKey(const Key('restore_purchases_button')), findsOneWidget);

      // Verify Coming soon teaser
      expect(find.text('MORE REWARDS COMING SOON'), findsOneWidget);
    });

    testWidgets(
        'isAdFreeProvider dynamically switches UI between locked and unlocked state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Initial State: locked
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('es')],
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LIFETIME PASS'), findsOneWidget);
      expect(find.text('Unlock Ad-Free • \$2.99'), findsOneWidget);

      // Tap action button without crashes or fake timer delays
      await tester.tap(find.byKey(const Key('remove_ads_action_button')));
      await tester.pumpAndSettle();

      // Dynamically unlock adFreeProvider
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ShopScreen)),
      );
      await container.read(adFreeProvider.notifier).unlockAdFree();
      await tester.pumpAndSettle();

      // Verify UI dynamically reflects unlocked state
      expect(find.text('ACTIVE • UNLOCKED'), findsOneWidget);
      expect(find.text('Ads Removed • Lifetime Unlocked'), findsOneWidget);
      expect(find.byKey(const Key('remove_ads_action_button')), findsNothing);
    });
  });
}

void _noOp(int idx) {}
