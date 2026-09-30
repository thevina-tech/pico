import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
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

class _FakePredictionController extends PredictionController {
  _FakePredictionController(this._predictions);
  final Map<String, Prediction> _predictions;

  @override
  FutureOr<Map<String, Prediction>> build() => _predictions;
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
    Map<String, Prediction>? predictions,
  }) {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWith(
          () => _FakeProfileNotifier(profile),
        ),
        if (authNotifier != null)
          authProvider.overrideWith(() => authNotifier),
        if (predictions != null)
          predictionControllerProvider.overrideWith(
            () => _FakePredictionController(predictions),
          ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen - Dark Stadium Gamer Hub Design & Authenticated User', () {
    testWidgets('Renders dynamic profile identity: username kept and horizontal division container removed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Username & Level title
      expect(find.text('CR7_Predictor'), findsOneWidget);
      expect(find.text('Matchday Prophet'), findsNothing);

      // Horizontal division container with progress is removed
      expect(find.text('140 / 220 PP'), findsNothing);
    });

    testWidgets('Renders Quick Stats Grid (Matches count and Division container 50% each, Accuracy removed)',
        (WidgetTester tester) async {
      final mockPredictions = {
        'match_1': Prediction(
          id: 'pred_1',
          userId: 'user_456',
          matchId: 'match_1',
          homeScore: 2,
          awayScore: 1,
          predictedWinner: 'home',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        'match_2': Prediction(
          id: 'pred_2',
          userId: 'user_456',
          matchId: 'match_2',
          homeScore: 1,
          awayScore: 1,
          predictedWinner: 'draw',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };

      await tester.pumpWidget(createSubject(predictions: mockPredictions));
      await tester.pumpAndSettle();

      // Accuracy container is removed
      expect(find.text('70%'), findsNothing);
      expect(find.text('Hit Rate'), findsNothing);
      expect(find.text('↑ +4%'), findsNothing);

      // Matches card shows real predicted count
      expect(find.byKey(const Key('profile_matches_card')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Division card shows real division data
      expect(find.byKey(const Key('profile_division_card')), findsOneWidget);
      expect(find.text('DIV 8'), findsOneWidget);
      expect(find.text('Division 8'), findsOneWidget);
      expect(find.text('140 PP'), findsOneWidget);
    });

    testWidgets('Renders Spotlight Tournament Card and removes Following/History cards',
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

      // Following and History Hub Cards are removed
      expect(find.byKey(const Key('profile_following_card')), findsNothing);
      expect(find.byKey(const Key('profile_history_card')), findsNothing);
      expect(find.text('Following'), findsNothing);
      expect(find.text('History'), findsNothing);
    });

    testWidgets('Achievements and Settings are removed from ProfileScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Achievements'), findsNothing);
      expect(find.text('See all'), findsNothing);
      expect(find.byKey(const Key('profile_settings_action')), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Quick Actions: Rate App, Help & Support, and Settings are displayed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final rateAction = find.byKey(const Key('profile_rate_app_action'));
      expect(rateAction, findsOneWidget);
      expect(find.text('Rate App'), findsOneWidget);

      final helpAction = find.byKey(const Key('profile_help_action'));
      expect(helpAction, findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);

      final settingsAction = find.byKey(const Key('profile_settings_action'));
      expect(settingsAction, findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Standalone Sign Out button is removed from ProfileScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final signOutFinder = find.byKey(const Key('profile_sign_out_button'));
      expect(signOutFinder, findsNothing);
    });

    testWidgets('Tactile "Share the App" button is displayed and triggers share',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final shareButtonFinder = find.byKey(const Key('profile_share_card_button'));
      expect(shareButtonFinder, findsOneWidget);
      expect(find.text('Share the App'), findsOneWidget);

      await tester.tap(shareButtonFinder);
      await tester.pump();
    });
  });
}
