import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeProfileNotifier extends CurrentUserProfile {
  _FakeProfileNotifier(this._profile);
  final UserProfile _profile;

  @override
  FutureOr<UserProfile> build() => _profile;
}

class _SpyAuthNotifier extends AuthNotifier {
  bool signOutCalled = false;

  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'user_456',
        appMetadata: {},
        userMetadata: {'full_name': 'CR7_Predictor'},
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

  const mockProfile = UserProfile(
    id: 'user_456',
    username: 'CR7_Predictor',
    level: 12,
    xp: 450,
    streak: 14,
    coins: 3200,
    totalPoints: 140,
    currentDivisionKey: 'div_8',
    favoriteTeamIds: ['real_madrid', 'arsenal'],
    favoriteLeagueIds: ['la_liga', 'champions_league'],
  );

  Widget createSubject({
    UserProfile profile = mockProfile,
    _SpyAuthNotifier? authNotifier,
  }) {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWith(
          () => _FakeProfileNotifier(profile),
        ),
        if (authNotifier != null)
          authProvider.overrideWith(() => authNotifier),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen - Dark Stadium Gamer Hub Design & Authenticated User', () {
    testWidgets('Renders dynamic profile identity: username, Matchday Prophet, Division, and PP progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Username & Level title
      expect(find.text('CR7_Predictor'), findsOneWidget);
      expect(find.text('Matchday Prophet'), findsOneWidget);

      // Division badge & progress
      expect(find.text('DIV 8'), findsWidgets);
      expect(find.text('Division 8'), findsOneWidget);
      expect(find.text('140 / 220 PP'), findsOneWidget);
    });

    testWidgets('Renders Quick Stats Grid (Hit Rate, Matches, Prediction Points)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Hit Rate
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Hit Rate'), findsOneWidget);
      expect(find.text('↑ +4%'), findsOneWidget);

      // Matches
      expect(find.text('84'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Prediction Points
      expect(find.text('140'), findsOneWidget);
      expect(find.text('PP'), findsOneWidget);
      expect(find.text('DIV 8'), findsWidgets);
    });

    testWidgets('Renders Spotlight Tournament Card and Hub Paired Cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Spotlight Tournament card
      expect(find.text('Tournaments'), findsOneWidget);
      expect(find.text('Active cups & weekly leagues'), findsOneWidget);
      expect(find.text('2 Active'), findsOneWidget);
      expect(find.byKey(const Key('profile_tournaments_card')), findsOneWidget);

      // Following Hub Card
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Clubs, leagues & alerts'), findsOneWidget);
      expect(find.text('4 Pinned'), findsOneWidget);
      expect(find.byKey(const Key('profile_following_card')), findsOneWidget);

      // History Hub Card
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Predictions, archive & past trophies'), findsOneWidget);
      expect(find.text('84 Matches · 70%'), findsOneWidget);
      expect(find.byKey(const Key('profile_history_card')), findsOneWidget);
    });

    testWidgets('Renders Achievements showcase with 4 Hexagon Badges',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);

      expect(find.text('On Fire'), findsOneWidget);
      expect(find.text('14 streak'), findsOneWidget);

      expect(find.text('Sharpshooter'), findsOneWidget);
      expect(find.text('70% hit rate'), findsOneWidget);

      expect(find.text('Podium'), findsOneWidget);
      expect(find.text('3 podiums'), findsOneWidget);

      expect(find.text('10 Streak'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
    });

    testWidgets('Quick Actions: Help & Support opens game rules modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final helpAction = find.byKey(const Key('profile_help_action'));
      expect(helpAction, findsOneWidget);

      await tester.tap(helpAction);
      await tester.pumpAndSettle();

      expect(find.text('Game Rules & Scoring'), findsOneWidget);
      expect(find.text('Scoring Pico Points'), findsOneWidget);
      expect(find.text('Prediction Lock Window'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Game Rules & Scoring'), findsNothing);
    });

    testWidgets('Quick Actions: Settings opens settings modal and Sign Out triggers auth signOut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final spyAuth = _SpyAuthNotifier();
      await tester.pumpWidget(createSubject(authNotifier: spyAuth));
      await tester.pumpAndSettle();

      final settingsAction = find.byKey(const Key('profile_settings_action'));
      expect(settingsAction, findsOneWidget);

      await tester.tap(settingsAction);
      await tester.pumpAndSettle();

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Matchday Haptics'), findsOneWidget);

      final signOutFinder = find.byKey(const Key('profile_sign_out_button'));
      expect(signOutFinder, findsOneWidget);

      await tester.tap(signOutFinder);
      await tester.pumpAndSettle();

      expect(spyAuth.signOutCalled, isTrue);
    });

    testWidgets('Floating "Share Matchday Card" CTA opens modal and copies summary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final shareButtonFinder = find.byKey(const Key('profile_share_card_button'));
      expect(shareButtonFinder, findsOneWidget);

      await tester.tap(shareButtonFinder);
      await tester.pumpAndSettle();

      // Modal bottom sheet appears
      expect(find.text('Matchday Trading Card'), findsOneWidget);
      expect(find.text('Copy Card Summary'), findsOneWidget);
      expect(find.byKey(const Key('copy_card_summary_button')), findsOneWidget);

      // Tap copy summary button to dismiss modal
      await tester.tap(find.byKey(const Key('copy_card_summary_button')));
      await tester.pumpAndSettle();

      // Modal dismissed and snackbar shown
      expect(find.text('Matchday Trading Card'), findsNothing);
      expect(find.text('Profile summary copied to clipboard!'), findsOneWidget);
    });
  });
}
