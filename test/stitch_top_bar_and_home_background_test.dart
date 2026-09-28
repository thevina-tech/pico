import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_app_bar.dart';

class _FakeCurrentUserProfile extends CurrentUserProfile {
  _FakeCurrentUserProfile(this._profile);
  final UserProfile _profile;

  @override
  FutureOr<UserProfile> build() => _profile;
}

class _FakeMatchesFeed extends MatchesFeed {
  _FakeMatchesFeed(this._matches);
  final List<PicoMatch> _matches;

  @override
  Future<List<PicoMatch>> build() async => _matches;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProfile = UserProfile(
    id: 'user_123',
    username: 'GoldenBoot',
    level: 7,
    xp: 720,
    streak: 4,
    coins: 2450,
    totalPoints: 140,
    currentDivisionKey: 'div_8',
  );

  final testMatch = PicoMatch(
    id: 'match_1',
    providerMatchId: 'besoccer_100',
    homeTeamName: 'Real Madrid',
    awayTeamName: 'Barcelona',
    homeTeamCode: 'RMA',
    awayTeamCode: 'BAR',
    kickoffAt: DateTime.now().add(const Duration(hours: 3)),
    status: MatchStatus.upcoming,
    competitionName: 'La Liga',
  );

  group('Stitch Top Bar & Home Pitch Sky Background Tests', () {
    testWidgets('PicoAppBar renders unified Stitch capsule with LVL, XP, Coins, and Streak',
        (WidgetTester tester) async {
      bool levelTapped = false;
      bool coinsTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: PicoAppBar(
                onProfileTap: () => levelTapped = true,
                onPointsTap: () => coinsTapped = true,
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Division Section
      expect(find.text('DIV 8'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pico_app_bar_division_section')));
      expect(levelTapped, isTrue);

      // 2. Verify PP Progress Label
      expect(find.text('140 / 220 PP'), findsOneWidget);

      // 3. Verify Points Section
      expect(find.text('140 PP'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pico_app_bar_points_section')));
      expect(coinsTapped, isTrue);

      // 4. Verify back button is hidden by default
      expect(find.byKey(const Key('pico_app_bar_back_button')), findsNothing);
    });

    testWidgets('PicoAppBar renders tactile back button and triggers callback when showBackButton is true',
        (WidgetTester tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: PicoAppBar(
                showBackButton: true,
                onBackPressed: () => backTapped = true,
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backBtn = find.byKey(const Key('pico_app_bar_back_button'));
      expect(backBtn, findsOneWidget);

      await tester.tap(backBtn);
      expect(backTapped, isTrue);
    });

    testWidgets('PicoAppBar does not overflow on narrow 320px viewport with back button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320.0, 640.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: PicoAppBar(showBackButton: true),
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow exception should be thrown
      expect(tester.takeException(), isNull);
      expect(find.text('DIV 8'), findsOneWidget);
      expect(find.text('140 PP'), findsOneWidget);
    });

    testWidgets('HomeScreen renders full-bleed stadium pitch background asset with top alignment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed([testMatch]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify the background Image widget with home_pitch_background.png
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/home_pitch_background.png' &&
            widget.fit == BoxFit.cover &&
            widget.alignment == Alignment.topCenter,
      );
      expect(imageFinder, findsOneWidget);

      // 2. Verify Scaffold has transparent background
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, Colors.transparent);

      // 3. Verify Stitch top bar with profile and division pills
      expect(find.byKey(const Key('home_screen_profile_pill')), findsOneWidget);
      expect(find.byKey(const Key('home_screen_division_pill')), findsOneWidget);

      // 4. Verify subheader username badge and match feed
      expect(find.text('GoldenBoot'), findsWidgets);
      expect(find.text('Real Madrid'), findsOneWidget);
      expect(find.text('Barcelona'), findsOneWidget);
    });

    testWidgets('ShopScreen renders with PicoPitchBackground and transparent Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShopScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PicoPitchBackground), findsOneWidget);
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('ProfileScreen renders with PicoPitchBackground and transparent Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PicoPitchBackground), findsOneWidget);
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, Colors.transparent);
    });
  });
}
