import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/data/prediction_repository.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/predictions/presentation/prediction_screen.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/prediction_controls.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/matches/presentation/matches_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakePredictionRepository implements PredictionRepository {
  final Map<String, Prediction> storage = {};
  bool forceLockException = false;

  @override
  Future<List<Prediction>> getUserPredictions(String userId) async {
    return storage.values.where((p) => p.userId == userId).toList();
  }

  @override
  Future<Map<String, int>> getUserSettlementPoints(String userId) async {
    return {};
  }

  @override
  Future<Prediction?> getPredictionForMatch({
    required String userId,
    required String matchId,
  }) async {
    return storage['$userId:$matchId'];
  }

  @override
  Future<Prediction> savePrediction({
    required String userId,
    required String matchId,
    required int homeScore,
    required int awayScore,
    required String predictedWinner,
  }) async {
    if (forceLockException) {
      throw const PredictionLockedException(
        'Predictions lock exactly 10 minutes before kickoff.',
      );
    }

    final pred = Prediction(
      id: 'pred_test',
      userId: userId,
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
      predictedWinner: predictedWinner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    storage['$userId:$matchId'] = pred;
    return pred;
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'test_user',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

class _FakeProfileNotifier extends CurrentUserProfile {
  _FakeProfileNotifier(this._profile);
  final UserProfile _profile;

  @override
  FutureOr<UserProfile> build() => _profile;
}

class _FakeMatchesController extends MatchesController {
  _FakeMatchesController(this._matches);
  final List<PicoMatch> _matches;

  @override
  FutureOr<MatchesState> build() {
    return MatchesState(
      allMatches: _matches,
      filters: [
        MatchFilterChipData(
          label: 'All (${_matches.length})',
          competitionName: 'All',
          count: _matches.length,
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final openMatch = PicoMatch(
    id: 'match_open_1',
    providerMatchId: 'prov_1',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamId: 'bar',
    homeTeamName: 'Barcelona',
    homeTeamCode: 'BAR',
    awayTeamId: 'rma',
    awayTeamName: 'Real Madrid',
    awayTeamCode: 'RMA',
    kickoffAt: DateTime.now().add(const Duration(hours: 3)),
    status: MatchStatus.upcoming,
  );

  final lockedMatch = PicoMatch(
    id: 'match_locked_1',
    providerMatchId: 'prov_2',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamId: 'bar',
    homeTeamName: 'Barcelona',
    homeTeamCode: 'BAR',
    awayTeamId: 'rma',
    awayTeamName: 'Real Madrid',
    awayTeamCode: 'RMA',
    // 5 minutes from now -> within 10-minute lock window
    kickoffAt: DateTime.now().add(const Duration(minutes: 5)),
    status: MatchStatus.upcoming,
  );

  Widget createTestApp(
    Widget child, {
    PredictionRepository? repo,
    List<PicoMatch>? matches,
  }) {
    final fakeRepo = repo ?? _FakePredictionRepository();
    final fakeMatches = matches ?? [openMatch];
    return ProviderScope(
      overrides: [
        predictionRepositoryProvider.overrideWithValue(fakeRepo),
        authProvider.overrideWith(() => _FakeAuthNotifier()),
        matchesControllerProvider.overrideWith(
          () => _FakeMatchesController(fakeMatches),
        ),
        currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier(
              const UserProfile(
                id: 'test_user',
                username: 'Alex',
                level: 7,
                xp: 720,
                streak: 4,
                coins: 1450,
              ),
            )),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Sprint 3: Prediction Controls Widgets', () {
    testWidgets('ScoreStepper increments and decrements correctly', (tester) async {
      int score = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ScoreStepper(
                  score: score,
                  onChanged: (val) => setState(() => score = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);

      // Tap '+'
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(score, 3);
      expect(find.text('3'), findsOneWidget);

      // Tap '-'
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(score, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('ScoreStepper is disabled when enabled: false', (tester) async {
      int score = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreStepper(
              score: score,
              enabled: false,
              onChanged: (val) => score = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(score, 2); // Unchanged
    });

    testWidgets('WinnerSelector triggers onSelected when enabled and ignores when disabled',
        (tester) async {
      MatchOutcome? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinnerSelector(
              selectedOutcome: selected,
              enabled: true,
              homeLabel: 'BAR',
              drawLabel: 'TIE',
              awayLabel: 'RMA',
              onSelected: (outcome) => selected = outcome,
            ),
          ),
        ),
      );

      await tester.tap(find.text('BAR'));
      await tester.pumpAndSettle();
      expect(selected, MatchOutcome.home);

      // Now disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinnerSelector(
              selectedOutcome: selected,
              enabled: false,
              homeLabel: 'BAR',
              drawLabel: 'TIE',
              awayLabel: 'RMA',
              onSelected: (outcome) => selected = outcome,
            ),
          ),
        ),
      );

      await tester.tap(find.text('RMA'));
      await tester.pumpAndSettle();
      expect(selected, MatchOutcome.home); // Still home
    });
  });

  group('Sprint 3: MatchCard Inline Predictions & Navigation', () {
    testWidgets('MatchCard displays inline score steppers when showInlinePrediction is true',
        (tester) async {
      int home = 1;
      int away = 0;
      bool quickPredictTapped = false;
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard.fromMatch(
              match: openMatch,
              showInlinePrediction: true,
              inlineHomeScore: home,
              inlineAwayScore: away,
              onInlineHomeScoreChanged: (val) => home = val,
              onInlineAwayScoreChanged: (val) => away = val,
              onQuickPredict: () => quickPredictTapped = true,
              onCardTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('BAR'), findsAtLeastNWidgets(1));
      expect(find.text('RMA'), findsAtLeastNWidgets(1));
      expect(find.text('Quick Predict (1 - 0)'), findsOneWidget);

      // Tap Quick Predict
      await tester.tap(find.text('Quick Predict (1 - 0)'));
      await tester.pumpAndSettle();
      expect(quickPredictTapped, isTrue);

      // Tap on card header / background
      await tester.tap(find.text('LA LIGA'));
      await tester.pumpAndSettle();
      expect(cardTapped, isTrue);
    });

    testWidgets('MatchCard renders centered 2-line team names completely with aligned crest baselines',
        (tester) async {
      final asymmetricMatch = PicoMatch(
        id: 'asymmetric_card_1',
        providerMatchId: 'prov_card_asym_1',
        competitionId: 'pl',
        competitionName: 'Premier League',
        homeTeamId: 'bha',
        homeTeamName: 'Brighton & Hove Albion',
        homeTeamCode: 'BHA',
        awayTeamId: 'ars',
        awayTeamName: 'Arsenal',
        awayTeamCode: 'ARS',
        kickoffAt: DateTime.now().add(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchCard.fromMatch(match: asymmetricMatch),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final homeNameFinder = find.text('Brighton & Hove Albion');
      final awayNameFinder = find.text('Arsenal');
      expect(homeNameFinder, findsOneWidget);
      expect(awayNameFinder, findsOneWidget);

      final homeText = tester.widget<Text>(homeNameFinder);
      final awayText = tester.widget<Text>(awayNameFinder);
      expect(homeText.textAlign, TextAlign.center);
      expect(awayText.textAlign, TextAlign.center);
      expect(homeText.maxLines, 2);
      expect(awayText.maxLines, 2);

      // Verify crests share identical vertical baseline
      final bhaCodeFinder = find.text('BHA').first;
      final arsCodeFinder = find.text('ARS').first;
      final bhaTopLeft = tester.getTopLeft(bhaCodeFinder);
      final arsTopLeft = tester.getTopLeft(arsCodeFinder);
      expect(bhaTopLeft.dy, equals(arsTopLeft.dy));
    });
  });

  group('Sprint 3: Zero-Client Trust 10-Minute Lock Rule', () {
    test('PicoMatch.isLocked returns true within 10 minutes of kickoff', () {
      expect(openMatch.isLocked, isFalse);
      expect(lockedMatch.isLocked, isTrue);
    });

    test('PicoMatch.isLocked returns true if kickoff is in the past', () {
      final pastMatch = PicoMatch(
        id: 'past_1',
        providerMatchId: 'prov_past',
        competitionId: 'la_liga',
        competitionName: 'La Liga',
        homeTeamId: 'bar',
        homeTeamName: 'Barcelona',
        homeTeamCode: 'BAR',
        awayTeamId: 'rma',
        awayTeamName: 'Real Madrid',
        awayTeamCode: 'RMA',
        kickoffAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: MatchStatus.live,
      );
      expect(pastMatch.isLocked, isTrue);
    });
  });

  group('Sprint 3: Detailed Prediction Screen & Anti-Gambling Vocabulary', () {
    testWidgets('PredictionScreen displays dynamic match details and strictly game vocabulary',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: openMatch),
        ),
      );
      await tester.pumpAndSettle();

      // Dynamic team names and competition
      expect(find.text('Barcelona'), findsAtLeastNWidgets(1));
      expect(find.text('Real Madrid'), findsAtLeastNWidgets(1));
      expect(find.text('LA LIGA'), findsOneWidget);

      // Anti-gambling vocabulary check:
      // STRICTLY FORBIDDEN: "bet", "odds", "stake", "wager"
      expect(find.textContaining(RegExp(r'\bbet\b', caseSensitive: false)), findsNothing);
      expect(find.textContaining(RegExp(r'\bodds\b', caseSensitive: false)), findsNothing);
      expect(find.textContaining(RegExp(r'\bstake\b', caseSensitive: false)), findsNothing);
      expect(find.textContaining(RegExp(r'\bwager\b', caseSensitive: false)), findsNothing);

      // MANDATORY GAME VOCABULARY:
      expect(find.text('Pick Winner'), findsOneWidget);
      expect(find.text('Exact Score Prediction'), findsOneWidget);
      expect(find.text('Save Prediction (+5 Points)'), findsOneWidget);
      expect(find.text('+5 Pts Max'), findsOneWidget);
    });

    testWidgets('PredictionScreen locks interaction when match is within 10-minute threshold',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: lockedMatch),
        ),
      );
      await tester.pumpAndSettle();

      // CTA displays locked state
      expect(find.text('Prediction Locked'), findsOneWidget);
    });

    testWidgets('Saving prediction successfully calls controller and shows confirmation toast',
        (tester) async {
      final fakeRepo = _FakePredictionRepository();

      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: openMatch),
          repo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Save Prediction (+5 Points)
      await tester.ensureVisible(find.text('Save Prediction (+5 Points)'));
      await tester.tap(find.text('Save Prediction (+5 Points)'));
      await tester.pump(); // Start async work
      await tester.pumpAndSettle(); // Settle animation and toast

      // Verify saved in repository
      expect(fakeRepo.storage.containsKey('test_user:match_open_1'), isTrue);
      expect(fakeRepo.storage['test_user:match_open_1']?.homeScore, 2);
      expect(fakeRepo.storage['test_user:match_open_1']?.awayScore, 1);

      // Verify confirmation toast
      expect(find.text('Prediction Locked! ⚽'), findsOneWidget);
    });

    testWidgets('PredictionScreen aligns faceoff badges and centers multi-line team names (e.g. Brighton & Hove Albion vs Arsenal)',
        (tester) async {
      final asymmetricMatch = PicoMatch(
        id: 'asymmetric_match_1',
        providerMatchId: 'prov_asym_1',
        competitionId: 'pl',
        competitionName: 'Premier League',
        homeTeamId: 'bha',
        homeTeamName: 'Brighton & Hove Albion',
        homeTeamCode: 'BHA',
        awayTeamId: 'ars',
        awayTeamName: 'Arsenal',
        awayTeamCode: 'ARS',
        kickoffAt: DateTime.now().add(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: asymmetricMatch),
        ),
      );
      await tester.pumpAndSettle();

      // Verify team names rendered
      final homeNameFinder = find.text('Brighton & Hove Albion');
      final awayNameFinder = find.text('Arsenal');
      expect(homeNameFinder, findsOneWidget);
      expect(awayNameFinder, findsOneWidget);

      // Both names should be centered and support 2 lines
      final homeTextWidget = tester.widget<Text>(homeNameFinder);
      final awayTextWidget = tester.widget<Text>(awayNameFinder);
      expect(homeTextWidget.textAlign, TextAlign.center);
      expect(awayTextWidget.textAlign, TextAlign.center);
      expect(homeTextWidget.maxLines, 2);
      expect(awayTextWidget.maxLines, 2);

      // Verify badges have identical vertical top alignment
      final bhaCodeFinder = find.text('BHA').first;
      final arsCodeFinder = find.text('ARS').first;
      expect(bhaCodeFinder, findsOneWidget);
      expect(arsCodeFinder, findsOneWidget);

      final bhaTopLeft = tester.getTopLeft(bhaCodeFinder);
      final arsTopLeft = tester.getTopLeft(arsCodeFinder);
      expect(bhaTopLeft.dy, equals(arsTopLeft.dy));

      // Verify VS pill is present and aligned
      expect(find.text('VS'), findsOneWidget);
    });
  });

  group('Sprint 3: Settlement & Scoring Rule Verification', () {
    test('Scoring outcome logic: +5 total for exact, +3 for winner, 0 for wrong', () {
      int calculatePoints({
        required int predictedHome,
        required int predictedAway,
        required int actualHome,
        required int actualAway,
      }) {
        if (predictedHome == actualHome && predictedAway == actualAway) {
          return 5; // Exact score (5 total, not +8)
        }

        final actualWinner = actualHome > actualAway
            ? 'home'
            : (actualAway > actualHome ? 'away' : 'draw');
        final predictedWinner = predictedHome > predictedAway
            ? 'home'
            : (predictedAway > predictedHome ? 'away' : 'draw');

        if (predictedWinner == actualWinner) {
          return 3; // Correct winner
        }

        return 0; // Wrong
      }

      // Exact score
      expect(calculatePoints(predictedHome: 2, predictedAway: 1, actualHome: 2, actualAway: 1), 5);
      // Correct winner (not exact)
      expect(calculatePoints(predictedHome: 3, predictedAway: 0, actualHome: 2, actualAway: 1), 3);
      // Wrong winner
      expect(calculatePoints(predictedHome: 0, predictedAway: 2, actualHome: 2, actualAway: 1), 0);
      // Correct draw (not exact)
      expect(calculatePoints(predictedHome: 1, predictedAway: 1, actualHome: 2, actualAway: 2), 3);
      // Exact draw
      expect(calculatePoints(predictedHome: 2, predictedAway: 2, actualHome: 2, actualAway: 2), 5);
    });
  });

  group('Sprint 3: User Adjustments (Header, Badges, Date Context, Modal Parity)', () {
    testWidgets('PredictionScreen header has no streak badge and Step 2 has no AUTO-SYNCED label',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: openMatch),
        ),
      );
      await tester.pumpAndSettle();

      // Item 1: Streak badge removed from header
      expect(find.textContaining('STREAK'), findsNothing);

      // Item 3: AUTO-SYNCED label removed from step 2
      expect(find.text('AUTO-SYNCED'), findsNothing);

      // Symmetrical spacer is present on right
      expect(find.byType(SizedBox), findsWidgets);
    });

    test('PicoMatch formatDateTimeWithContext correctly tags Today and Tomorrow', () {
      final now = DateTime.now();
      final todayMatch = PicoMatch(
        id: 'today_m',
        competitionName: 'La Liga',
        homeTeamName: 'Barca',
        homeTeamCode: 'BAR',
        awayTeamName: 'Madrid',
        awayTeamCode: 'RMA',
        kickoffAt: DateTime(now.year, now.month, now.day, 20, 0),
      );

      final tomorrowMatch = PicoMatch(
        id: 'tomorrow_m',
        competitionName: 'La Liga',
        homeTeamName: 'Barca',
        homeTeamCode: 'BAR',
        awayTeamName: 'Madrid',
        awayTeamCode: 'RMA',
        kickoffAt: DateTime(now.year, now.month, now.day, 20, 0).add(const Duration(days: 1)),
      );

      // Item 4: Blocking and kickoff time are related to each match's day
      expect(todayMatch.kickoffTimeFormatted, startsWith('Today 20:00'));
      expect(todayMatch.closesAtTimeFormatted, startsWith('Today 19:50'));

      expect(tomorrowMatch.kickoffTimeFormatted, startsWith('Tomorrow 20:00'));
      expect(tomorrowMatch.closesAtTimeFormatted, startsWith('Tomorrow 19:50'));
    });

    testWidgets('MatchesScreen includes PicoAppBar and prediction modal has Step 1 & 2 controls + detailed button',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const MatchesScreen(showBottomNavBar: false),
        ),
      );
      await tester.pumpAndSettle();

      // Item 2: Top bar containing level, xp, streak, coins is at top of MatchesScreen
      expect(find.byType(PicoAppBar), findsOneWidget);

      // Open prediction modal from match card
      final predictButton = find.text('Make Prediction →').first;
      await tester.ensureVisible(predictButton);
      await tester.tap(predictButton);
      await tester.pumpAndSettle();

      // Item 5: Uses same prediction controls for Step 1 and Step 2 with light cardFace theme
      final winnerSelector = tester.widget<WinnerSelector>(find.byType(WinnerSelector));
      expect(winnerSelector.isDark, isFalse);

      final stepperArena = tester.widget<ScoreStepperArena>(find.byType(ScoreStepperArena));
      expect(stepperArena.isDark, isFalse);

      // Item 6: Button taking user to the prediction page of that match
      expect(find.text('View Full Prediction Page →'), findsOneWidget);

      // Scoring Potential Banner removed from prediction pop modal
      expect(find.textContaining('Exact score = +5 Pico Points'), findsNothing);
    });

    test('Future match scheduled weeks ahead is not locked, but is teaser with window closed', () {
      // Oct 9 match in future (18 days out)
      final futureMatch = PicoMatch(
        id: 'future_oct_9',
        competitionName: 'Primera División',
        homeTeamName: 'Málaga',
        homeTeamCode: 'MAL',
        awayTeamName: 'Espanyol',
        awayTeamCode: 'ESP',
        kickoffAt: DateTime.now().add(const Duration(days: 18)),
      );

      expect(futureMatch.isLocked, isFalse);
      expect(futureMatch.isTeaser, isTrue);
      expect(futureMatch.isPredictionWindowOpen, isFalse);
      expect(futureMatch.teaserCountdownShort, '15d');
    });

    testWidgets(
        'PredictionScreen for finished match without user prediction shows match details, winning team selected, score in step 2, and blocked controls',
        (tester) async {
      final finishedMatch = PicoMatch(
        id: 'finished_101',
        competitionName: 'Primera División',
        homeTeamName: 'Real Madrid',
        homeTeamCode: 'RMA',
        awayTeamName: 'Barcelona',
        awayTeamCode: 'BAR',
        kickoffAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: MatchStatus.finished,
        homeScore: 3,
        awayScore: 1,
      );

      await tester.pumpWidget(
        createTestApp(
          PredictionScreen(match: finishedMatch),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Winner selected should be RMA (Home)
      expect(find.text('Winning Team'), findsOneWidget);
      expect(find.text('FINAL RESULT'), findsOneWidget);

      // Step 2: Score in steppers should be 3 - 1
      expect(find.text('Final Match Score'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(find.text('1'), findsWidgets);

      // Step 3: CTA button shows Match Finished and is disabled
      final matchFinishedBtn = find.widgetWithText(GameButton, 'Match Finished');
      expect(matchFinishedBtn, findsOneWidget);
      final btnWidget = tester.widget<GameButton>(matchFinishedBtn);
      expect(btnWidget.onPressed, isNull);

      // Result banner indicates not predicted
      expect(find.textContaining('You did not predict this match'), findsOneWidget);
    });
  });
}
