import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/core/routing/app_router.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeAuthNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'user_123',
        appMetadata: {},
        userMetadata: {'full_name': 'Test User'},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

class _FakeProfileNotifier extends CurrentUserProfile {
  @override
  Future<UserProfile> build() async {
    return const UserProfile(
      id: 'user_123',
      username: 'TestUser',
      level: 5,
      xp: 200,
      streak: 3,
      coins: 50,
      totalPoints: 25,
      currentDivisionKey: 'div_9',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GoRouter navigates to /help-support from profile screen',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier()),
        currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to /profile first
    router.go('/profile');
    await tester.pumpAndSettle();

    // Tap on Help & Support action card
    final helpAction = find.byKey(const Key('profile_help_action'));
    await tester.scrollUntilVisible(helpAction, 300);
    expect(helpAction, findsOneWidget);

    await tester.tap(helpAction);
    await tester.pumpAndSettle();

    // Should now be on HelpSupportScreen without "Page not found" error
    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.text('Page not found'), findsNothing);
  });

  testWidgets('GoRouter supports /profile/help-support sub-route',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier()),
        currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/profile/help-support');
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.text('Page Not Found'), findsNothing);
  });
}
