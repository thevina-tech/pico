import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

void main() {
  group('Stitch 4-Tab PicoBottomNavBar Tests', () {
    testWidgets('renders 4 tabs with Matches far-left, Home, Tournaments, and Profile far-right',
        (WidgetTester tester) async {
      int selectedIndex = 1; // Home active by default

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

      // Verify Shop is completely scrapped
      expect(find.text('Shop'), findsNothing);
      expect(find.byKey(const ValueKey('nav_shop')), findsNothing);

      // Verify all 4 tab labels are visible
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tournaments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify semantic keys and ordering
      final matchesKey = find.byKey(const ValueKey('nav_matches'));
      final homeKey = find.byKey(const ValueKey('nav_home'));
      final tournamentsKey = find.byKey(const ValueKey('nav_tournaments'));
      final profileKey = find.byKey(const ValueKey('nav_profile'));

      expect(matchesKey, findsOneWidget);
      expect(homeKey, findsOneWidget);
      expect(tournamentsKey, findsOneWidget);
      expect(profileKey, findsOneWidget);

      // Check horizontal ordering: matches < home < tournaments < profile
      final matchesOffset = tester.getCenter(matchesKey);
      final homeOffset = tester.getCenter(homeKey);
      final tournamentsOffset = tester.getCenter(tournamentsKey);
      final profileOffset = tester.getCenter(profileKey);

      expect(matchesOffset.dx < homeOffset.dx, isTrue);
      expect(homeOffset.dx < tournamentsOffset.dx, isTrue);
      expect(tournamentsOffset.dx < profileOffset.dx, isTrue);

      // Tap on Matches (index 0)
      await tester.tap(matchesKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);

      // Tap on Home (index 1)
      await tester.tap(homeKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);

      // Tap on Tournaments (index 2)
      await tester.tap(tournamentsKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);

      // Tap on Profile (index 3)
      await tester.tap(profileKey);
      await tester.pumpAndSettle();
      expect(selectedIndex, 3);
    });

    testWidgets('renders localized Spanish tab labels correctly',
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
              currentIndex: 1,
              onTap: _noOp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tienda'), findsNothing);
      expect(find.text('Partidos'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Torneos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('renders grass-blending dark emerald gradient, meadow text, and protruding pop icons',
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
              currentIndex: 1, // Home active
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

      // 2. Verify all 4 tab icons are rendered at 40x40 without opacity dimming
      expect(find.byType(Image), findsNWidgets(4));
      expect(find.byType(AnimatedOpacity), findsNothing);

      // 3. Verify text colors (active is crisp white, inactive is soft meadow mint)
      final homeText = tester.widget<Text>(find.text('Home'));
      expect(homeText.style?.color, Colors.white);

      final matchesText = tester.widget<Text>(find.text('Matches'));
      expect(matchesText.style?.color, const Color(0xFFA7D1BC));

      // 4. Verify gold pill indicator (#FCCB2B)
      final goldPillFinder = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == const Color(0xFFFCCB2B),
      );
      expect(goldPillFinder, findsOneWidget);

      // 5. Verify the active Home icon has translation and scale pop (protruding out of navbar)
      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      final poppedContainer = animatedContainers.firstWhere(
        (c) => c.transform != null && c.transform!.getTranslation().y < -5.0,
      );
      expect(poppedContainer.transform!.getTranslation().y, -8.0);
    });
  });

  group('ShopScreen Tests', () {
    testWidgets('renders club shop header and clean reward ad option',
        (WidgetTester tester) async {
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
            home: ShopScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CLUB SHOP'), findsOneWidget);
      expect(find.text('REWARD ADS'), findsOneWidget);
      expect(find.text('Free Coins Refill'), findsOneWidget);
      expect(find.text('WATCH VIDEO (+50 COINS)'), findsOneWidget);
      expect(find.text('COMING SOON'), findsNothing);
    });

    testWidgets('tapping watch video ad opens simulated sponsor dialog and awards +50 coins',
        (WidgetTester tester) async {
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
            home: ShopScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Watch Video
      await tester.tap(find.text('WATCH VIDEO (+50 COINS)'));
      await tester.pumpAndSettle();

      // Verify dialog is presented
      expect(find.text('SPONSOR PREVIEW'), findsOneWidget);
      expect(find.text('Video Ad Completed!'), findsOneWidget);
      expect(find.text('CLAIM +50 COINS'), findsOneWidget);

      // Tap Claim
      await tester.tap(find.text('CLAIM +50 COINS'));
      await tester.pumpAndSettle();

      // Verify dialog dismissed and SnackBar shown
      expect(find.text('SPONSOR PREVIEW'), findsNothing);
      expect(find.textContaining('+50 Pico Coins'), findsOneWidget);
    });
  });
}

void _noOp(int idx) {}
