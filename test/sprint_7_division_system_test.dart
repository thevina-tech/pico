import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/profile/domain/division.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/profile/presentation/widgets/division_ladder_sheet.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/division_badge.dart';
import 'package:pico/shared/components/pico_app_bar.dart';

class _FakeCurrentUserProfile extends CurrentUserProfile {
  _FakeCurrentUserProfile(this._profile);
  final UserProfile _profile;

  @override
  FutureOr<UserProfile> build() => _profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 7: Division System - DivisionTier Thresholds & Brackets', () {
    test('Accurately maps points to all 11 division tiers at lower and upper boundaries', () {
      // Division 10 (0 - 49)
      expect(DivisionTier.fromPoints(0), DivisionTier.div10);
      expect(DivisionTier.fromPoints(25), DivisionTier.div10);
      expect(DivisionTier.fromPoints(49), DivisionTier.div10);

      // Division 9 (50 - 119)
      expect(DivisionTier.fromPoints(50), DivisionTier.div9);
      expect(DivisionTier.fromPoints(85), DivisionTier.div9);
      expect(DivisionTier.fromPoints(119), DivisionTier.div9);

      // Division 8 (120 - 219)
      expect(DivisionTier.fromPoints(120), DivisionTier.div8);
      expect(DivisionTier.fromPoints(180), DivisionTier.div8);
      expect(DivisionTier.fromPoints(219), DivisionTier.div8);

      // Division 7 (220 - 349)
      expect(DivisionTier.fromPoints(220), DivisionTier.div7);
      expect(DivisionTier.fromPoints(300), DivisionTier.div7);
      expect(DivisionTier.fromPoints(349), DivisionTier.div7);

      // Division 6 (350 - 499)
      expect(DivisionTier.fromPoints(350), DivisionTier.div6);
      expect(DivisionTier.fromPoints(425), DivisionTier.div6);
      expect(DivisionTier.fromPoints(499), DivisionTier.div6);

      // Division 5 (500 - 699)
      expect(DivisionTier.fromPoints(500), DivisionTier.div5);
      expect(DivisionTier.fromPoints(600), DivisionTier.div5);
      expect(DivisionTier.fromPoints(699), DivisionTier.div5);

      // Division 4 (700 - 949)
      expect(DivisionTier.fromPoints(700), DivisionTier.div4);
      expect(DivisionTier.fromPoints(850), DivisionTier.div4);
      expect(DivisionTier.fromPoints(949), DivisionTier.div4);

      // Division 3 (950 - 1249)
      expect(DivisionTier.fromPoints(950), DivisionTier.div3);
      expect(DivisionTier.fromPoints(1100), DivisionTier.div3);
      expect(DivisionTier.fromPoints(1249), DivisionTier.div3);

      // Division 2 (1250 - 1599)
      expect(DivisionTier.fromPoints(1250), DivisionTier.div2);
      expect(DivisionTier.fromPoints(1400), DivisionTier.div2);
      expect(DivisionTier.fromPoints(1599), DivisionTier.div2);

      // Division 1 (1600 - 1999)
      expect(DivisionTier.fromPoints(1600), DivisionTier.div1);
      expect(DivisionTier.fromPoints(1800), DivisionTier.div1);
      expect(DivisionTier.fromPoints(1999), DivisionTier.div1);

      // Elite Division (2000+)
      expect(DivisionTier.fromPoints(2000), DivisionTier.elite);
      expect(DivisionTier.fromPoints(3500), DivisionTier.elite);
    });

    test('fromKey resolves all 11 division keys and defaults to div_10 on null/invalid', () {
      expect(DivisionTier.fromKey('div_10'), DivisionTier.div10);
      expect(DivisionTier.fromKey('div_9'), DivisionTier.div9);
      expect(DivisionTier.fromKey('div_8'), DivisionTier.div8);
      expect(DivisionTier.fromKey('div_7'), DivisionTier.div7);
      expect(DivisionTier.fromKey('div_6'), DivisionTier.div6);
      expect(DivisionTier.fromKey('div_5'), DivisionTier.div5);
      expect(DivisionTier.fromKey('div_4'), DivisionTier.div4);
      expect(DivisionTier.fromKey('div_3'), DivisionTier.div3);
      expect(DivisionTier.fromKey('div_2'), DivisionTier.div2);
      expect(DivisionTier.fromKey('div_1'), DivisionTier.div1);
      expect(DivisionTier.fromKey('elite'), DivisionTier.elite);

      expect(DivisionTier.fromKey(null), DivisionTier.div10);
      expect(DivisionTier.fromKey('unknown_tier'), DivisionTier.div10);
    });

    test('progressRatio and pointsToNext compute accurate metrics within tier bracket', () {
      // Division 10: 0 to 50 bracket span = 50
      final div10 = DivisionTier.div10;
      expect(div10.progressRatio(0), 0.0);
      expect(div10.progressRatio(25), 0.5);
      expect(div10.pointsToNext(25), 25);
      expect(div10.pointsToNext(49), 1);

      // Division 8: 120 to 220 bracket span = 100
      final div8 = DivisionTier.div8;
      expect(div8.progressRatio(120), 0.0);
      expect(div8.progressRatio(170), 0.5);
      expect(div8.pointsToNext(140), 80);
      expect(div8.pointsToNext(219), 1);

      // Elite Division: no ceiling
      final elite = DivisionTier.elite;
      expect(elite.progressRatio(2500), 1.0);
      expect(elite.pointsToNext(2500), 0);
    });
  });

  group('Sprint 7: Match Scoring Engine (5/3/1/0 Tiered)', () {
    test('Prediction.calculatePoints awards 5, 3, 1, or 0 points accurately', () {
      // 1. Exact score match -> 5 PP
      final exactPred = const Prediction(
        id: 'p1',
        userId: 'u1',
        matchId: 'm1',
        homeScore: 2,
        awayScore: 1,
        predictedWinner: 'home',
      );
      expect(exactPred.calculatePoints(2, 1), 5);

      // 2. Correct outcome AND correct goal difference -> 3 PP
      // Predicted 2-0 (home win, diff +2), actual 3-1 (home win, diff +2)
      final diffPred = const Prediction(
        id: 'p2',
        userId: 'u1',
        matchId: 'm1',
        homeScore: 2,
        awayScore: 0,
        predictedWinner: 'home',
      );
      expect(diffPred.calculatePoints(3, 1), 3);

      // 3. Draw with different score -> 3 PP (both draw, diff 0 == diff 0)
      final drawDiffPred = const Prediction(
        id: 'p3',
        userId: 'u1',
        matchId: 'm1',
        homeScore: 1,
        awayScore: 1,
        predictedWinner: 'draw',
      );
      expect(drawDiffPred.calculatePoints(2, 2), 3);

      // Draw exact score -> 5 PP
      expect(drawDiffPred.calculatePoints(1, 1), 5);

      // 4. Correct outcome only -> 1 PP
      // Predicted 2-1 (home win, diff +1), actual 3-0 (home win, diff +3)
      final outcomePred = const Prediction(
        id: 'p4',
        userId: 'u1',
        matchId: 'm1',
        homeScore: 2,
        awayScore: 1,
        predictedWinner: 'home',
      );
      expect(outcomePred.calculatePoints(3, 0), 1);

      // 5. Miss / Incorrect winner -> 0 PP
      final missPred = const Prediction(
        id: 'p5',
        userId: 'u1',
        matchId: 'm1',
        homeScore: 1,
        awayScore: 2,
        predictedWinner: 'away',
      );
      expect(missPred.calculatePoints(2, 1), 0);
    });

    test('PicoMatch.calculateSettlementPoints awards 5, 3, 1, or 0 points', () {
      final finishedMatch = PicoMatch(
        id: 'm1',
        kickoffAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: MatchStatus.finished,
        homeScore: 2,
        awayScore: 1,
      );

      // Exact match
      expect(finishedMatch.calculateSettlementPoints(2, 1), 5);

      // Correct winner + goal difference (+1)
      expect(finishedMatch.calculateSettlementPoints(1, 0), 3);

      // Correct winner only (+2 diff vs +1 diff)
      expect(finishedMatch.calculateSettlementPoints(3, 1), 1);

      // Miss
      expect(finishedMatch.calculateSettlementPoints(0, 2), 0);

      // Unfinished match returns null
      final upcomingMatch = PicoMatch(
        id: 'm2',
        kickoffAt: DateTime.now().add(const Duration(hours: 2)),
        status: MatchStatus.upcoming,
      );
      expect(upcomingMatch.calculateSettlementPoints(2, 1), isNull);
    });
  });

  group('Sprint 7: UserProfile Division Extension', () {
    test('Calculates division, progress ratio, and pointsToNextDivision from totalPoints', () {
      const profile = UserProfile(
        id: 'u1',
        username: 'Striker',
        totalPoints: 140,
        currentDivisionKey: 'div_8',
      );

      expect(profile.division, DivisionTier.div8);
      expect(profile.pointsToNextDivision, 80); // Next is Division 7 at 220
      expect(profile.formattedTotalPoints, '140');
    });

    test('Falls back to fromPoints when currentDivisionKey is null', () {
      const profile = UserProfile(
        id: 'u2',
        username: 'Midfielder',
        totalPoints: 750,
      );

      expect(profile.division, DivisionTier.div4);
      expect(profile.pointsToNextDivision, 200); // Next is Division 3 at 950
      expect(profile.formattedTotalPoints, '750');
    });
  });

  group('Sprint 7: UI Component Widget Tests', () {
    testWidgets('DivisionBadge renders correct label and adapts to size variants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DivisionBadge(tier: DivisionTier.div8, size: DivisionBadgeSize.small),
                DivisionBadge(tier: DivisionTier.div1, size: DivisionBadgeSize.medium),
                DivisionBadge(tier: DivisionTier.elite, size: DivisionBadgeSize.large),
              ],
            ),
          ),
        ),
      );

      expect(find.text('DIV 8'), findsOneWidget);
      expect(find.text('DIV 1'), findsOneWidget);
      expect(find.text('ELITE'), findsOneWidget);
    });

    testWidgets('PicoAppBar renders Division Badge and Prediction Points counter',
        (WidgetTester tester) async {
      const profile = UserProfile(
        id: 'u1',
        username: 'Alex',
        totalPoints: 140,
        currentDivisionKey: 'div_8',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWith(
              () => _FakeCurrentUserProfile(profile),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PicoAppBar(),
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DIV 8'), findsOneWidget);
      expect(find.text('140 / 220 PP'), findsOneWidget);
      expect(find.text('140 PP'), findsOneWidget);
      expect(find.byKey(const Key('pico_app_bar_division_section')), findsOneWidget);
      expect(find.byKey(const Key('pico_app_bar_points_section')), findsOneWidget);
    });

    testWidgets('DivisionLadderSheet displays all 11 tiers and user current badge',
        (WidgetTester tester) async {
      const profile = UserProfile(
        id: 'u1',
        username: 'Alex',
        totalPoints: 2100,
        currentDivisionKey: 'elite',
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DivisionLadderSheet(profile: profile),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Division Ladder'), findsOneWidget);
      expect(find.text('CURRENT'), findsOneWidget);
      expect(find.text('Elite Division'), findsWidgets);
      expect(find.text('Exact Score'), findsOneWidget);
      expect(find.text('+5 PP'), findsOneWidget);
      expect(find.text('+3 PP'), findsOneWidget);
      expect(find.text('+1 PP'), findsOneWidget);
    });
  });
}
