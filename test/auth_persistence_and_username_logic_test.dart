import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_gate.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/domain/team.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Mock repository for testing profile state variations
class _MockProfileRepository implements ProfileRepository {
  _MockProfileRepository({this.profile});

  UserProfile? profile;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    return profile;
  }

  @override
  Future<List<Team>> getTeams() async => [];

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

  @override
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async => true;
}

class _CustomAuthNotifier extends AuthNotifier {
  _CustomAuthNotifier({required this.initialState});
  final PicoAuthState initialState;

  @override
  PicoAuthState build() => initialState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HOTFIX 1: Enforce Custom Username (Ignore Google Name)', () {
    test('currentUserProfileProvider does not fall back to Google full_name or email prefix', () async {
      const googleUser = supa.User(
        id: 'google_user_999',
        email: 'cattyto@example.com',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Cattyto Pro Player',
          'name': 'Cattyto',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _CustomAuthNotifier(
              initialState: const PicoAuthAuthenticated(
                user: googleUser,
                isPersonalized: false,
              ),
            ),
          ),
          profileRepositoryProvider.overrideWithValue(_MockProfileRepository(profile: null)),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(currentUserProfileProvider.future);

      // Username MUST be null, ignoring Google full_name and email prefix
      expect(profile.username, isNull);
      expect(profile.id, 'google_user_999');
      expect(profile.email, 'cattyto@example.com');
    });
  });

  group('HOTFIX 2: Auth State Persistence & Auto-Login Routing', () {
    testWidgets('Unauthenticated startup routes to Step 1 (How it works screen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _CustomAuthNotifier(initialState: const PicoAuthUnauthenticated()),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      // First frame is loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Resolved: unauthenticated user lands on How Pico Works (Step 2/5, page index 1)
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('How Pico Works'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Returning User with completed username routes directly to Main Dashboard', (WidgetTester tester) async {
      const returningUser = supa.User(
        id: 'returning_user_1',
        email: 'joao@example.com',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _CustomAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: returningUser,
                  isPersonalized: true,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(
              _MockProfileRepository(
                profile: const UserProfile(
                  id: 'returning_user_1',
                  username: 'joao_pico',
                  level: 3,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Directly routes to HomeScreen without showing any onboarding screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('Incomplete User without username restarts at Step B (Unique Username Selection)', (WidgetTester tester) async {
      const incompleteUser = supa.User(
        id: 'new_google_user',
        email: 'newuser@example.com',
        appMetadata: {},
        userMetadata: {'full_name': 'New Google User'},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _CustomAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: incompleteUser,
                  isPersonalized: false,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(
              _MockProfileRepository(
                profile: const UserProfile(
                  id: 'new_google_user',
                  username: null, // No username chosen yet
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Crucial test: must route to Step B (page index 2: Username Selection)
      // Never show "How it works" or "Welcome"
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('How Pico Works'), findsNothing);
      expect(find.text('Predict Football.\nCompete with Friends.'), findsNothing);
      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('OnboardingScreen directly loaded for authenticated incomplete user skips How it works and starts at Step B', (WidgetTester tester) async {
      const authenticatedUser = supa.User(
        id: 'auth_user_resume',
        email: 'resume@example.com',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _CustomAuthNotifier(
                initialState: const PicoAuthAuthenticated(
                  user: authenticatedUser,
                  isPersonalized: false,
                ),
              ),
            ),
            profileRepositoryProvider.overrideWithValue(
              _MockProfileRepository(
                profile: const UserProfile(
                  id: 'auth_user_resume',
                  username: null,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Even if initialPage is passed as 0 or 1, an authenticated user without username
            // must NOT see How It Works or Welcome, but resume at Step B: Username
            home: OnboardingScreen(initialPage: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How Pico Works'), findsNothing);
      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);
    });
  });
}
