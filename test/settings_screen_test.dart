import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/presentation/settings_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _SpyAuthNotifier extends AuthNotifier {
  bool signOutCalled = false;

  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'test_user_settings',
        appMetadata: {},
        userMetadata: {'full_name': 'Settings Tester'},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    state = const PicoAuthUnauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({_SpyAuthNotifier? authNotifier}) {
    final spy = authNotifier ?? _SpyAuthNotifier();
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(() => spy),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen - Layout & User Actions', () {
    testWidgets('renders header, atmosphere card, and all action options',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // App bar & atmosphere
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Account, sign out & preferences'), findsOneWidget);
      expect(find.text('ACCOUNT SETTINGS'), findsOneWidget);

      // Options
      expect(find.byKey(const Key('settings_sign_out_tile')), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      expect(find.byKey(const Key('settings_delete_account_tile')), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
      expect(
        find.text('Permanently remove your account and data'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Sign Out triggers auth signOut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final spyAuth = _SpyAuthNotifier();
      await tester.pumpWidget(createSubject(authNotifier: spyAuth));
      await tester.pumpAndSettle();

      final signOutTile = find.byKey(const Key('settings_sign_out_tile'));
      expect(signOutTile, findsOneWidget);

      await tester.tap(signOutTile);
      await tester.pumpAndSettle();

      expect(spyAuth.signOutCalled, isTrue);
    });

    testWidgets('tapping Delete Account shows severe destructive confirmation modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final deleteTile = find.byKey(const Key('settings_delete_account_tile'));
      await tester.tap(deleteTile);
      await tester.pumpAndSettle();

      // Dialog contents
      expect(find.text('Delete Account?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure? This will permanently delete your predictions, league memberships, and account data. This cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('confirm_delete_account_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_delete_account_button')), findsOneWidget);
    });

    testWidgets('canceling Delete Account modal leaves user logged in',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final spyAuth = _SpyAuthNotifier();
      await tester.pumpWidget(createSubject(authNotifier: spyAuth));
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.byKey(const Key('settings_delete_account_tile')));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.byKey(const Key('cancel_delete_account_button')));
      await tester.pumpAndSettle();

      // Dialog dismissed, signOut not called
      expect(find.text('Delete Account?'), findsNothing);
      expect(spyAuth.signOutCalled, isFalse);
    });

    testWidgets('confirming Delete Account modal triggers account deletion and signOut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final spyAuth = _SpyAuthNotifier();
      await tester.pumpWidget(createSubject(authNotifier: spyAuth));
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.byKey(const Key('settings_delete_account_tile')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirm_delete_account_button')));
      await tester.pumpAndSettle();

      expect(spyAuth.signOutCalled, isTrue);
    });
  });
}
