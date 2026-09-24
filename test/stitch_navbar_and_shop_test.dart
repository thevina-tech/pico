import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

void main() {
  group('Stitch 5-Tab PicoBottomNavBar Tests', () {
    testWidgets('renders 5 tabs with Shop far-left, Home centered, and Profile far-right',
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

      // Verify semantic keys and ordering
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

      // Tap on Home (index 2 - center)
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
              currentIndex: 2,
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
              currentIndex: 2, // Home active
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

      // 2. Verify all 5 tab icons are rendered at 44x44 without opacity dimming
      expect(find.byType(Image), findsNWidgets(5));
      expect(find.byType(AnimatedOpacity), findsNothing);

      // 3. Verify text colors (active is crisp white, inactive is soft meadow mint)
      final homeText = tester.widget<Text>(find.text('Home'));
      expect(homeText.style?.color, Colors.white);

      final shopText = tester.widget<Text>(find.text('Shop'));
      expect(shopText.style?.color, const Color(0xFFA7D1BC));

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
    testWidgets('renders club shop header, VIP pass, and coin packages',
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
      expect(find.text('PICO PRO'), findsOneWidget);
      expect(find.text('COINS VAULT'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('TACTICAL BOOSTERS'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('TACTICAL BOOSTERS'), findsOneWidget);
      expect(find.text('Streak Shield'), findsOneWidget);
    });
  });
}

void _noOp(int idx) {}
