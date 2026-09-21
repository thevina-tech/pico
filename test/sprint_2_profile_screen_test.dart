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

  group('Sprint 2: ProfileScreen - Visuals & Data Consistency', () {
    testWidgets('Renders dynamic profile identity: username, level, streak, coins, and XP',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Username & Level title
      expect(find.text('CR7_Predictor'), findsOneWidget);
      expect(find.text('Matchday Prophet'), findsOneWidget);

      // Level badge
      expect(find.text('LVL 12'), findsOneWidget);

      // Streak & Coins pills
      expect(find.textContaining('14 Streak'), findsOneWidget);
      expect(find.textContaining('3,200 Coins'), findsOneWidget);

      // Tactical stats grid
      expect(find.text('HIT RATE'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('MATCHES'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
      expect(find.text('PODIUMS'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('CLUB RANK'), findsOneWidget);
      expect(find.text('#12'), findsNWidgets(2));

      // XP Progress to next level
      expect(find.text('XP Progress to LVL 13'), findsOneWidget);
      expect(find.textContaining('450', findRichText: true), findsOneWidget);
      expect(find.textContaining('/ 1,000 XP', findRichText: true), findsOneWidget);
    });

    testWidgets('Renders all 4 Stitch expandable accordions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Tournaments'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Tournaments is expanded by default: check for content
      expect(find.text('La Liga Weekly'), findsOneWidget);
      expect(find.text('The Friday Five'), findsOneWidget);

      // Following is expanded by default: check for followed teams
      expect(find.text('Real Madrid'), findsOneWidget);
      expect(find.text('Arsenal'), findsOneWidget);
    });

    testWidgets('Toggles accordion expansion when tapping accordion header',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final crossFades =
          tester.widgetList<AnimatedCrossFade>(find.byType(AnimatedCrossFade)).toList();
      expect(crossFades[0].crossFadeState, CrossFadeState.showSecond);
      expect(crossFades[1].crossFadeState, CrossFadeState.showSecond);
      expect(crossFades[2].crossFadeState, CrossFadeState.showFirst);
      expect(crossFades[3].crossFadeState, CrossFadeState.showFirst);

      // Tap History accordion header
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      final updatedCrossFades =
          tester.widgetList<AnimatedCrossFade>(find.byType(AnimatedCrossFade)).toList();
      expect(updatedCrossFades[2].crossFadeState, CrossFadeState.showSecond);

      // Tap Tournaments accordion header to collapse it
      await tester.tap(find.text('Tournaments'));
      await tester.pumpAndSettle();

      final afterTournamentsToggle =
          tester.widgetList<AnimatedCrossFade>(find.byType(AnimatedCrossFade)).toList();
      expect(afterTournamentsToggle[0].crossFadeState, CrossFadeState.showFirst);
    });

    testWidgets('Floating "Share Matchday Card" CTA opens bottom sheet modal',
        (WidgetTester tester) async {
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

    testWidgets('Settings accordion Sign Out button triggers auth signOut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final spyAuth = _SpyAuthNotifier();
      await tester.pumpWidget(createSubject(authNotifier: spyAuth));
      await tester.pumpAndSettle();

      // Expand Settings accordion
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final signOutFinder = find.byKey(const Key('profile_sign_out_button'));
      expect(signOutFinder, findsOneWidget);

      await tester.tap(signOutFinder);
      await tester.pumpAndSettle();

      expect(spyAuth.signOutCalled, isTrue);
    });
  });
}
