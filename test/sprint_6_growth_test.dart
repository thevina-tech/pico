import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _MockReturningProfileRepository extends SupabaseProfileRepository {
  @override
  Future<UserProfile?> getProfile(String userId) async {
    return UserProfile(
      id: userId,
      username: 'returning_legend',
    );
  }
}

class _MockCollisionProfileRepository extends SupabaseProfileRepository {
  @override
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    // Allow step 3 pre-check to pass so we can verify Step 5 final collision rollback
    return true;
  }

  @override
  Future<void> updatePersonalization({
    required String userId,
    String? username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  }) async {
    throw const supa.PostgrestException(
      message: 'duplicate key value violates unique constraint "profiles_username_key"',
      code: '23505',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Sprint 6 - Google Auth & Sequential Onboarding Funnel', () {
    testWidgets('Step 2 displays "Continue with Google" button with Google styling',
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

      expect(find.text('How does it work'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('2/4'), findsOneWidget);
    });

    testWidgets('Step 2: Google sign-in advances to Step 3 for new user',
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

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // New user advances to Step 3: Username
      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);
    });

    testWidgets('Step 2: Returning user with existing username bypasses onboarding to /home',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(initialPage: 1),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(_MockReturningProfileRepository()),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Continue with Google
      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Returning user directly routed to /home
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Step 3 (Username): Rejects empty, too short (< 3), spaces, and special characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingScreen(initialPage: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);

      // 1. Empty submission
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please introduce a username to continue.'), findsOneWidget);

      // 2. Too short (< 3 chars)
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be at least 3 characters'), findsOneWidget);

      // 3. Contains spaces
      await tester.enterText(find.byType(TextField), 'user name');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be alphanumeric with no spaces'), findsOneWidget);

      // 4. Special characters
      await tester.enterText(find.byType(TextField), 'user@name!');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be alphanumeric with no spaces'), findsOneWidget);

      // 5. Valid alphanumeric username with underscores advances to Step 4 (Leagues Selection)
      await tester.enterText(find.byType(TextField), 'valid_user99');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Leagues'), findsOneWidget);
      expect(find.text('4/4'), findsOneWidget);
    });

    testWidgets('Step 3 & 4: Username pre-check identifies existing usernames',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingScreen(initialPage: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Setup collision in mock cache
      final repo = ProviderScope.containerOf(tester.element(find.byType(OnboardingScreen)))
          .read(profileRepositoryProvider);
      await repo.updatePersonalization(
        userId: 'existing_player_id',
        username: 'champion99',
      );

      // Enter taken username on Step 3
      await tester.enterText(find.byType(TextField), 'champion99');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Displays username taken error and stays on Step 3
      expect(find.text('This username is already taken. Please choose another one.'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);
    });

    testWidgets('Step 4: Database unique collision rolls back to Step 3 with error alert',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(_MockCollisionProfileRepository()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingScreen(initialPage: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 3: Enter username and advance directly to Step 4 (Leagues)
      await tester.enterText(find.byType(TextField), 'striker_ace');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: Pick league and finish
      expect(find.text('Choose Leagues'), findsOneWidget);
      await tester.tap(find.text('La Liga'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Finish'));
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Rollback to Step 3: Username is displayed with collision alert
      expect(find.text('What Should We Call You?'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);
      expect(find.text('This username is already taken. Please choose another one.'), findsWidgets);
    });
  });
}
