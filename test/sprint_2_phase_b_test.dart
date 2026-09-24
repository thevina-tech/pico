import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/domain/team.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/main.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);
  final UserProfile profile;

  @override
  Future<UserProfile?> getProfile(String userId) async => profile;

  @override
  Future<List<Team>> getTeams() async => [];

  @override
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async => true;

  @override
  Future<void> updatePersonalization({
    required String userId,
    String? username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  }) async {}
}

class _FakeAuthenticatedNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'user_123',
        appMetadata: {},
        userMetadata: {'full_name': 'Cristiano_Fan'},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

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
    username: 'Alex',
    level: 7,
    xp: 720,
    streak: 4,
    coins: 1450,
  );

  final testMatches = [
    PicoMatch(
      id: 'match_1',
      providerMatchId: 'prov_1',
      competitionId: 'la_liga',
      competitionName: 'La Liga',
      homeTeamId: 'real_madrid',
      homeTeamName: 'Real Madrid',
      homeTeamCode: 'RMA',
      awayTeamId: 'barcelona',
      awayTeamName: 'Barcelona',
      awayTeamCode: 'BAR',
      kickoffAt: DateTime.now().add(const Duration(hours: 4)),
      status: MatchStatus.upcoming,
    ),
    PicoMatch(
      id: 'match_2',
      providerMatchId: 'prov_2',
      competitionId: 'premier_league',
      competitionName: 'Premier League',
      homeTeamId: 'arsenal',
      homeTeamName: 'Arsenal',
      homeTeamCode: 'ARS',
      awayTeamId: 'chelsea',
      awayTeamName: 'Chelsea',
      awayTeamCode: 'CHE',
      kickoffAt: DateTime.now().add(const Duration(hours: 8)),
      status: MatchStatus.upcoming,
    ),
  ];

  group('Sprint 2 - Phase B: UserProfile Extension & Helpers', () {
    test('Calculates XP progress ratio, labels, and formats coins', () {
      expect(testProfile.xpInLevel, 720);
      expect(testProfile.xpProgressRatio, closeTo(0.72, 0.001));
      expect(testProfile.xpDisplayLabel, '720/1,000');
      expect(testProfile.formattedCoins, '1,450');

      const zeroProfile = UserProfile(id: 'zero', xp: 0, coins: 0);
      expect(zeroProfile.xpProgressRatio, 0.0);
      expect(zeroProfile.xpDisplayLabel, '0/1,000');
      expect(zeroProfile.formattedCoins, '0');

      expect(UserProfileXpX.formatNumberWithCommas(0), '0');
      expect(UserProfileXpX.formatNumberWithCommas(999), '999');
      expect(UserProfileXpX.formatNumberWithCommas(1000), '1,000');
      expect(UserProfileXpX.formatNumberWithCommas(1234567), '1,234,567');
    });
  });

  group('Sprint 2 - Phase B: PicoAppBar Component', () {
    testWidgets('Renders level shield, XP label, coins pill, and streak pill',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: PicoAppBar(),
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Level shield
      expect(find.text('LVL 7'), findsOneWidget);

      // Check XP progress label
      expect(find.textContaining('720'), findsOneWidget);

      // Check Coins pill
      expect(find.text('1,450'), findsOneWidget);
      expect(find.byKey(const Key('pico_app_bar_coins_section')), findsOneWidget);

      // Check Streak pill
      expect(find.text('4'), findsOneWidget);
      expect(find.byKey(const Key('pico_app_bar_streak_section')), findsOneWidget);

      // Back button should NOT be rendered when canPop is false
      expect(find.byKey(const Key('pico_app_bar_back_button')), findsNothing);
    });

    testWidgets('Renders back button when canPop is true and triggers callback',
        (WidgetTester tester) async {
      bool backPressed = false;

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
                onBackPressed: () => backPressed = true,
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(const Key('pico_app_bar_back_button'));
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
    });
  });

  group('Sprint 2 - Phase B: HomeScreen UI & Shell', () {
    testWidgets('Renders PicoAppBar, subheader row with username, and menu button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed(testMatches),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              showBottomNavBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify PicoAppBar is at the top
      expect(find.byType(PicoAppBar), findsOneWidget);
      expect(find.textContaining('720'), findsOneWidget);
      expect(find.text('1,450'), findsOneWidget);

      // 2. Verify subheader row with username on far left
      expect(find.text('Alex'), findsWidgets);

      // 3. Verify hamburger menu button on far right
      final menuButton = find.byKey(const Key('home_screen_menu_button'));
      expect(menuButton, findsOneWidget);

      // 4. Verify Mascot Greeting
      expect(find.textContaining('Big match tonight, Alex!'), findsOneWidget);

      // 5. Verify Tournament Card
      expect(find.text('La Liga Season Hub'), findsOneWidget);

      // 6. Verify single featured Match Card on Home screen
      expect(find.byType(MatchCard), findsOneWidget);
      expect(find.text('Real Madrid'), findsOneWidget);
      expect(find.text('Barcelona'), findsOneWidget);
      expect(find.text('Arsenal'), findsNothing);
      expect(find.text('Chelsea'), findsNothing);
      expect(find.text('+1 more fixtures in Matches'), findsOneWidget);
      expect(find.text('VIEW ALL'), findsOneWidget);
    });

    testWidgets('Tapping VIEW ALL or explore banner navigates to Matches tab',
        (WidgetTester tester) async {
      int navigateMatchesCalled = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed(testMatches),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              showBottomNavBar: false,
              onNavigateMatches: () => navigateMatchesCalled++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewAllBtn = find.byKey(const Key('home_screen_view_all_matches_button'));
      expect(viewAllBtn, findsOneWidget);
      await tester.tap(viewAllBtn);
      await tester.pumpAndSettle();
      expect(navigateMatchesCalled, 1);

      final exploreBanner = find.byKey(const Key('home_screen_explore_matches_banner'));
      expect(exploreBanner, findsOneWidget);
      await tester.tap(exploreBanner);
      await tester.pumpAndSettle();
      expect(navigateMatchesCalled, 2);
    });

    testWidgets('Tapping menu button displays the settings bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed(testMatches),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              showBottomNavBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final menuButton = find.byKey(const Key('home_screen_menu_button'));
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('Settings & Menu'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.textContaining('1,450 Coins'), findsOneWidget);
    });

    testWidgets('Renders empty state when matches list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed([]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              showBottomNavBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(
        find.text('No upcoming matches right now. Check back soon!'),
        findsOneWidget,
      );
    });

    testWidgets('Android device back button triggers game exit options modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(testProfile),
            ),
            matchesFeedProvider.overrideWith(
              () => _FakeMatchesFeed(testMatches),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(
              showBottomNavBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no dialog is showing initially
      expect(find.text('Leaving the Pitch?'), findsNothing);

      // Simulate Android back button / back gesture
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Verify exit options dialog is displayed
      expect(find.text('Leaving the Pitch?'), findsOneWidget);
      expect(find.text('STAY & PREDICT'), findsOneWidget);
      expect(find.text('Leave Game'), findsOneWidget);

      // Tapping "STAY & PREDICT" dismisses the modal
      await tester.tap(find.text('STAY & PREDICT'));
      await tester.pumpAndSettle();

      expect(find.text('Leaving the Pitch?'), findsNothing);
    });
  });

  group('Sprint 2 - Phase B: CurrentUserProfile Riverpod Integration', () {
    test('Loads profile from ProfileRepository when authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthenticatedNotifier()),
          profileRepositoryProvider.overrideWith(
            (ref) => _FakeProfileRepository(
              const UserProfile(
                id: 'user_123',
                username: 'CR7_GOAT',
                level: 10,
                xp: 950,
                coins: 5000,
                streak: 15,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(currentUserProfileProvider.future);
      expect(profile.username, 'CR7_GOAT');
      expect(profile.level, 10);
      expect(profile.coins, 5000);
      expect(profile.streak, 15);
      expect(profile.formattedCoins, '5,000');
    });
  });

  group('Sprint 2 - Phase B: App Bar Consistency Across Screens (Game Feel)', () {
    testWidgets('MatchesScreen renders PicoAppBar without top back button',
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
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PicoAppBar), findsOneWidget);
      // No top back button on game tab pages (Clash Royale feel)
      expect(find.byKey(const Key('pico_app_bar_back_button')), findsNothing);
      expect(find.text('1,450'), findsOneWidget);
    });

    testWidgets('TournamentsScreen renders PicoAppBar without top back button',
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
            home: TournamentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PicoAppBar), findsOneWidget);
      // No top back button on game tab pages (Clash Royale feel)
      expect(find.byKey(const Key('pico_app_bar_back_button')), findsNothing);
      expect(find.text('1,450'), findsOneWidget);
    });

    testWidgets('ProfileScreen does NOT render PicoAppBar',
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

      expect(find.byType(PicoAppBar), findsNothing);
      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('showGameExitDialog renders tactile modal and dismisses on stay',
        (WidgetTester tester) async {
      bool? exitResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    exitResult = await showGameExitDialog(context);
                  },
                  child: const Text('Trigger Exit'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Exit'));
      await tester.pumpAndSettle();

      // Verify exit dialog content
      expect(find.text('Leaving the Pitch?'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to quit Pico?'), findsOneWidget);
      expect(find.byKey(const Key('game_exit_dialog_stay_button')), findsOneWidget);
      expect(find.byKey(const Key('game_exit_dialog_exit_button')), findsOneWidget);

      // Tap STAY & PREDICT
      await tester.tap(find.byKey(const Key('game_exit_dialog_stay_button')));
      await tester.pumpAndSettle();

      expect(find.text('Leaving the Pitch?'), findsNothing);
      expect(exitResult, isFalse);
    });

    testWidgets('showGameExitDialog returns true when tapping Leave Game',
        (WidgetTester tester) async {
      bool? exitResult;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    exitResult = await showGameExitDialog(context);
                  },
                  child: const Text('Trigger Exit'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Exit'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Game'), findsOneWidget);

      // Tap Leave Game button
      await tester.tap(find.byKey(const Key('game_exit_dialog_exit_button')));
      await tester.pumpAndSettle();

      expect(exitResult, isTrue);
    });

    testWidgets('showGameExitDialog renders Spanish localized text when locale is Spanish',
        (WidgetTester tester) async {
      bool? exitResult;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    exitResult = await showGameExitDialog(context);
                  },
                  child: const Text('Trigger Exit'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Exit'));
      await tester.pumpAndSettle();

      // Verify Spanish localized strings
      expect(find.text('¿Abandonar la Cancha?'), findsOneWidget);
      expect(find.textContaining('¿Seguro que quieres salir de Pico?'), findsOneWidget);
      expect(find.text('QUEDARSE Y PREDECIR'), findsOneWidget);
      expect(find.text('Salir del Juego'), findsOneWidget);

      // Tap Salir del Juego
      await tester.tap(find.text('Salir del Juego'));
      await tester.pumpAndSettle();

      expect(exitResult, isTrue);
    });

    testWidgets('handlePopRoute on PicoApp shell triggers exit dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthenticatedNotifier()),
          ],
          child: const PicoApp(),
        ),
      );
      await tester.pumpAndSettle();

      final handled = await tester.binding.handlePopRoute();
      debugPrint('DEBUG handlePopRoute returned: $handled');
      await tester.pumpAndSettle();
      debugPrint(
        'DEBUG Leaving the pitch found: ${find.text("Leaving the Pitch?").evaluate().length}',
      );
      expect(find.text('Leaving the Pitch?'), findsOneWidget);
    });
  });
}
