import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/data/onboarding_preferences_repository.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_gate.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/domain/team.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _TestMockProfileRepository implements ProfileRepository {
  _TestMockProfileRepository({this.profile});

  UserProfile? profile;

  @override
  Future<UserProfile?> getProfile(String userId) async => profile;

  @override
  Future<List<Team>> getTeams() async => [
        const Team(id: 'team_madrid', name: 'Real Madrid', shortName: 'RMA'),
        const Team(id: 'team_barca', name: 'Barcelona', shortName: 'FCB'),
      ];

  @override
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async => true;

  @override
  Future<void> updatePersonalization({
    required String userId,
    String? username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  }) async {
    profile = UserProfile(
      id: userId,
      username: username,
      favoriteTeamId: favoriteTeamId,
      favoriteTeamIds: favoriteTeamIds ?? [],
      favoriteLeagueIds: favoriteLeagueIds ?? [],
    );
  }
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier({required this.initialState});
  final PicoAuthState initialState;

  @override
  PicoAuthState build() => initialState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = supa.User(
    id: 'mid_onboarding_user_42',
    email: 'testplayer@example.com',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01',
  );

  group('Onboarding State Persistence Across App Restarts', () {
    test('OnboardingPreferencesRepository correctly stores and clears progress', () async {
      final repo = SharedPrefsOnboardingPreferencesRepository();

      expect((await repo.getProgress()).step, 0);

      await repo.saveStep(2);
      await repo.saveUsername('striker_goat');
      await repo.saveTeamId('team_madrid');
      await repo.saveLeagueIds(['laliga_1', 'ucl_1']);

      final progress = await repo.getProgress();
      expect(progress.step, 2);
      expect(progress.username, 'striker_goat');
      expect(progress.selectedTeamId, 'team_madrid');
      expect(progress.selectedLeagueIds, ['laliga_1', 'ucl_1']);

      await repo.clearProgress();
      final cleared = await repo.getProgress();
      expect(cleared.step, 0);
      expect(cleared.username, isNull);
      expect(cleared.selectedTeamId, isNull);
      expect(cleared.selectedLeagueIds, isEmpty);
    });

    testWidgets(
        'User closes app after signing in with Google but before choosing username -> resumes at Step 3 (Username)',
        (WidgetTester tester) async {
      // Setup saved state simulating user who signed in with Google (step 2 recorded)
      SharedPreferences.setMockInitialValues({
        'pico_onboarding_step': 2,
      });

      final mockRepo = _TestMockProfileRepository(
        profile: const UserProfile(
          id: 'mid_onboarding_user_42',
          username: null, // No username chosen yet
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: testUser,
                  isPersonalized: false,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      // Settle loading animations
      await tester.pumpAndSettle();

      // Verified: Resumes directly on Step 3: What Should We Call You?
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);
      expect(find.text('How Pico Works'), findsNothing);
      expect(find.text('Predict Football.\nCompete with Friends.'), findsNothing);
    });

    testWidgets(
        'User entered username, reached Step 4 (Team Selection), closed app -> resumes at Step 4 with username restored',
        (WidgetTester tester) async {
      // Simulate app was closed at step 3 (index 3 is Step 4/5: Team selection) with username 'ronaldo7'
      SharedPreferences.setMockInitialValues({
        'pico_onboarding_step': 3,
        'pico_onboarding_username': 'ronaldo7',
      });

      final mockRepo = _TestMockProfileRepository(
        profile: const UserProfile(
          id: 'mid_onboarding_user_42',
          username: null, // Profile in db not finalized yet
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: testUser,
                  isPersonalized: false,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verified: Resumes directly at Step 4: Choose Favorite Team
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Choose Favorite Team'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);

      // Verify going back retains the username
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('ronaldo7'), findsOneWidget);
    });

    testWidgets(
        'User picked team, reached Step 5 (Leagues), closed app -> resumes at Step 5 with team preserved',
        (WidgetTester tester) async {
      // Simulate app was closed at step 4 (index 4 is Step 5/5: Leagues selection)
      SharedPreferences.setMockInitialValues({
        'pico_onboarding_step': 4,
        'pico_onboarding_username': 'ronaldo7',
        'pico_onboarding_team_id': 'team_madrid',
      });

      final mockRepo = _TestMockProfileRepository(
        profile: const UserProfile(
          id: 'mid_onboarding_user_42',
          username: null,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: testUser,
                  isPersonalized: false,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verified: Resumes directly at Step 5: Choose Leagues
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Choose Leagues'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets(
        'After completing personalization, onboarding preferences are cleared and app routes to Home',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'pico_onboarding_step': 4,
        'pico_onboarding_username': 'final_player',
        'pico_onboarding_team_id': 'team_madrid',
      });

      final mockRepo = _TestMockProfileRepository(
        profile: const UserProfile(
          id: 'mid_onboarding_user_42',
          username: 'final_player', // Completed
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: testUser,
                  isPersonalized: true,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verified: Directly at Home, onboarding is gone
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
