import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/core/routing/app_router.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/personalization_controller.dart';
import 'package:pico/features/profile/presentation/personalization_screen.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 2 - Domain Model: UserProfile (@freezed)', () {
    test('UserProfile: parses full json with favorite team and leagues', () {
      final json = {
        'id': 'user_12345',
        'email': 'joao@pico.app',
        'username': 'joao_pico',
        'avatar_url': 'https://cdn.pico.app/avatars/joao.png',
        'level': 4,
        'xp': 420,
        'streak': 6,
        'coins': 50,
        'private_leagues_created': 2,
        'favorite_team_id': 'real_madrid',
        'favorite_team_ids': ['real_madrid', 'barcelona'],
        'favorite_league_ids': ['la_liga', 'champions_league'],
        'created_at': '2026-03-01T12:00:00.000Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user_12345');
      expect(profile.email, 'joao@pico.app');
      expect(profile.username, 'joao_pico');
      expect(profile.avatarUrl, 'https://cdn.pico.app/avatars/joao.png');
      expect(profile.level, 4);
      expect(profile.xp, 420);
      expect(profile.streak, 6);
      expect(profile.coins, 50);
      expect(profile.privateLeaguesCreated, 2);
      expect(profile.favoriteTeamId, 'real_madrid');
      expect(profile.favoriteTeamIds, ['real_madrid', 'barcelona']);
      expect(profile.favoriteLeagueIds, ['la_liga', 'champions_league']);
      expect(profile.createdAt, DateTime.parse('2026-03-01T12:00:00.000Z'));
    });

    test('UserProfile: safely handles missing optional fields and defaults', () {
      final json = {
        'id': 'user_minimal',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user_minimal');
      expect(profile.email, isNull);
      expect(profile.username, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.level, 1);
      expect(profile.xp, 0);
      expect(profile.streak, 0);
      expect(profile.coins, 0);
      expect(profile.privateLeaguesCreated, 0);
      expect(profile.favoriteTeamId, isNull);
      expect(profile.favoriteLeagueIds, isEmpty);
      expect(profile.createdAt, isNull);
    });

    test('UserProfile: copyWith creates updated immutable instance', () {
      const initial = UserProfile(
        id: 'u_1',
        username: 'old_name',
      );

      final updated = initial.copyWith(
        username: 'new_name',
        favoriteTeamId: 'arsenal',
        favoriteLeagueIds: ['premier_league'],
      );

      expect(updated.id, 'u_1');
      expect(updated.username, 'new_name');
      expect(updated.favoriteTeamId, 'arsenal');
      expect(updated.favoriteLeagueIds, ['premier_league']);
      expect(initial.username, 'old_name'); // Immutability preserved
    });
  });

  group('Sprint 2 - Domain Model: PicoAuthState', () {
    test('PicoAuthState subclasses and equality', () {
      const unauth1 = PicoAuthUnauthenticated();
      const unauth2 = PicoAuthUnauthenticated();
      expect(unauth1, equals(unauth2));

      const auth1 = PicoAuthAuthenticated(
        user: supa.User(
          id: 'test_u1',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: false,
      );

      const auth2 = PicoAuthAuthenticated(
        user: supa.User(
          id: 'test_u1',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: false,
      );

      expect(auth1, equals(auth2));
      expect(auth1.hashCode, equals(auth2.hashCode));

      final personalized = auth1.copyWith(isPersonalized: true);
      expect(personalized.isPersonalized, isTrue);
      expect(personalized, isNot(equals(auth1)));

      const err1 = PicoAuthError('network error');
      const err2 = PicoAuthError('network error');
      expect(err1, equals(err2));
    });
  });

  group('Sprint 2 - Data Layer: SupabaseProfileRepository', () {
    test('Offline mode returns fallback profile and persists updates in memory',
        () async {
      final repo = SupabaseProfileRepository();

      final initialProfile = await repo.getProfile('guest_123456');
      expect(initialProfile, isNotNull);
      expect(initialProfile!.id, 'guest_123456');
      expect(initialProfile.username, 'Guest_guest_');

      await repo.updatePersonalization(
        userId: 'guest_123456',
        username: ' striker99 ',
        favoriteTeamId: 'real_madrid',
        favoriteLeagueIds: ['la_liga'],
      );

      final updatedProfile = await repo.getProfile('guest_123456');
      expect(updatedProfile, isNotNull);
      expect(updatedProfile!.username, ' striker99 ');
      expect(updatedProfile.favoriteTeamId, 'real_madrid');
      expect(updatedProfile.favoriteLeagueIds, ['la_liga']);
    });
  });

  group('Sprint 2 - Riverpod AuthNotifier & Controller', () {
    test('AuthNotifier: initializes to unauthenticated and signs in anonymously',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialAuth = container.read(authProvider);
      expect(initialAuth, isA<PicoAuthUnauthenticated>());

      final notifier = container.read(authProvider.notifier);
      await notifier.signInAnonymously();

      final authenticatedState = container.read(authProvider);
      expect(authenticatedState, isA<PicoAuthAuthenticated>());
      final auth = authenticatedState as PicoAuthAuthenticated;
      expect(auth.user?.id, 'guest_test_id');
      expect(auth.isPersonalized, isFalse);

      notifier.markPersonalized();
      final personalizedState = container.read(authProvider) as PicoAuthAuthenticated;
      expect(personalizedState.isPersonalized, isTrue);

      await notifier.signOut();
      expect(container.read(authProvider), isA<PicoAuthUnauthenticated>());
    });

    test('PersonalizationController: tracks selections, validates, and submits',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Sign in anonymously first so controller has authenticated user
      await container.read(authProvider.notifier).signInAnonymously();

      final controller = container.read(personalizationControllerProvider.notifier);
      var state = container.read(personalizationControllerProvider);

      // Default leagues & club
      expect(state.selectedLeagueIds, contains('premier_league'));
      expect(state.selectedLeagueIds, contains('la_liga'));
      expect(state.selectedLeagueIds.length, 2);
      expect(state.selectedTeamId, 'arsenal');
      expect(state.selectedTeamIds.length, 1);

      // Max-2 league selection cap: trying to add a 3rd league is capped/ignored
      controller.toggleLeague('bundesliga');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.contains('bundesliga'), isFalse);
      expect(state.selectedLeagueIds.length, 2);

      // Toggle leagues: removing a league works
      controller.toggleLeague('premier_league');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.contains('premier_league'), isFalse);
      expect(state.selectedLeagueIds.length, 1);

      // Adding up to 2 leagues works
      controller.toggleLeague('serie_a');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.contains('serie_a'), isTrue);
      expect(state.selectedLeagueIds.length, 2);

      // Single-team constraint: selecting a team replaces the previous selection (exactly 1 team)
      controller.toggleTeam('real_madrid');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedTeamIds, equals({'real_madrid'}));
      expect(state.selectedTeamId, 'real_madrid');
      expect(state.selectedTeamIds.length, 1);

      controller.toggleTeam('barcelona');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedTeamIds, equals({'barcelona'}));
      expect(state.selectedTeamId, 'barcelona');
      expect(state.selectedTeamIds.length, 1);

      // Validate empty username
      controller.setUsername('');
      final successEmpty = await controller.submit();
      expect(successEmpty, isFalse);
      expect(
        container.read(personalizationControllerProvider).errorMessage,
        'Please introduce a username to continue.',
      );

      // Validate short username (< 3 chars)
      controller.setUsername('ab');
      final successShort = await controller.submit();
      expect(successShort, isFalse);
      expect(
        container.read(personalizationControllerProvider).errorMessage,
        'Username must be at least 3 characters.',
      );

      // Valid username submission
      controller.setUsername('AlexStriker');
      final successValid = await controller.submit();
      expect(successValid, isTrue);
      expect(container.read(personalizationControllerProvider).errorMessage, isNull);

      // Auth notifier should now be marked personalized
      final authState = container.read(authProvider) as PicoAuthAuthenticated;
      expect(authState.isPersonalized, isTrue);

      // Verify tournament_participants row creation for selected leagues (la_liga & serie_a)
      final tournamentRepo = container.read(tournamentRepositoryProvider);
      final enrolled = await tournamentRepo.getEnrolledTournaments(authState.user!.id);
      expect(enrolled.length, 2);
      final enrolledCompIds = enrolled.map((t) => t.competitionId).toSet();
      expect(enrolledCompIds.contains('la_liga'), isTrue);
      expect(enrolledCompIds.contains('serie_a'), isTrue);

      final participants = await tournamentRepo.getParticipantsForUser(authState.user!.id);
      expect(participants.length, 2);
      expect(participants.every((p) => p.userId == authState.user!.id), isTrue);
    });
  });

  group('Sprint 2 - Routing Guards: AppRouter', () {
    test('resolveRedirect redirects unauthenticated users to /onboarding', () {
      const auth = PicoAuthUnauthenticated();
      expect(AppRouter.resolveRedirect(auth, '/home'), '/onboarding');
      expect(AppRouter.resolveRedirect(auth, '/matches'), '/onboarding');
      expect(AppRouter.resolveRedirect(auth, '/onboarding'), isNull);
    });

    test('resolveRedirect allows in-flight authenticating state', () {
      const auth = PicoAuthAuthenticating();
      expect(AppRouter.resolveRedirect(auth, '/onboarding'), isNull);
      expect(AppRouter.resolveRedirect(auth, '/home'), isNull);
    });

    test('resolveRedirect redirects authenticated unpersonalized users to /personalization',
        () {
      const auth = PicoAuthAuthenticated(
        user: supa.User(
          id: 'test_u',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: false,
      );

      expect(AppRouter.resolveRedirect(auth, '/home'), '/personalization');
      expect(AppRouter.resolveRedirect(auth, '/onboarding'), '/personalization');
      expect(AppRouter.resolveRedirect(auth, '/personalization'), isNull);
    });

    test('resolveRedirect redirects personalized users away from onboarding & personalization to /home',
        () {
      const auth = PicoAuthAuthenticated(
        user: supa.User(
          id: 'test_u',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: true,
      );

      expect(AppRouter.resolveRedirect(auth, '/onboarding'), '/home');
      expect(AppRouter.resolveRedirect(auth, '/personalization'), '/home');
      expect(AppRouter.resolveRedirect(auth, '/home'), isNull);
      expect(AppRouter.resolveRedirect(auth, '/matches'), isNull);
    });
  });

  group('Sprint 2 - Presentation: OnboardingScreen & PersonalizationScreen', () {
    testWidgets('OnboardingScreen renders Stitch aesthetic and triggers guest login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Pico Football'), findsOneWidget);
      expect(find.text('Predict Football.\nCompete with Friends.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Takes less than 1 minute to set up.'), findsOneWidget);

      // Scroll to and tap Get Started
      await tester.ensureVisible(find.text('Get Started'));
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify Step 2/5: How Pico Works is rendered
      expect(find.text('How Pico Works'), findsOneWidget);
      expect(find.text('Simple, fast, and built for matchdays.'), findsOneWidget);
      expect(find.text('Predict the score'), findsOneWidget);
      expect(find.text('Earn points & climb'), findsOneWidget);
      expect(find.text('Win tournament trophies'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);

      // Tap Continue on Step 2
      expect(find.text('Continue'), findsOneWidget);
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    });

    testWidgets('OnboardingScreen Step 2 back button returns to Step 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingScreen(initialPage: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How Pico Works'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Predict Football.\nCompete with Friends.'), findsOneWidget);
    });

    testWidgets('PersonalizationScreen renders Step 3/5, username input, and clubs grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PersonalizationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CUSTOMIZE YOUR FEED'), findsOneWidget);
      expect(find.text('STEP 3/5'), findsOneWidget);
      expect(find.text('Pick Your Favorites'), findsOneWidget);
      expect(find.text('TOP LEAGUES & CUPS'), findsOneWidget);
      expect(find.text('CLUBS YOU FOLLOW'), findsOneWidget);

      // Verify Ligue 1 is rendered in tournament chips
      expect(find.text('Ligue 1'), findsOneWidget);

      // Verify club cards are rendered
      expect(find.text('Real Madrid'), findsOneWidget);
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('Barcelona'), findsOneWidget);
      expect(find.text('Man City'), findsOneWidget);

      // Single-club selection: scroll to and tap Barcelona to select it
      await tester.ensureVisible(find.text('Barcelona'));
      await tester.tap(find.text('Barcelona'));
      await tester.pumpAndSettle();
      expect(find.text('1/1 selected'), findsOneWidget);

      // Verify localized helper microcopy below selectors
      expect(
        find.text('You can change your favorite team and join more tournaments anytime.'),
        findsOneWidget,
      );

      // Verify max-2 leagues cap indicator
      expect(find.text('2/2 selected'), findsOneWidget);

      // Test skip without username triggers friendly error
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please enter a username'),
        findsNothing, // Not generic/ugly
      );
      expect(
        find.textContaining('violates foreign key'),
        findsNothing, // No Postgres leak
      );

      // Verify action button
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
