import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/tournament_participant.dart';
import 'package:pico/features/tournaments/presentation/public_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/widgets/tactile_leaderboard_card.dart';
import 'package:pico/l10n/app_localizations.dart';

Widget _buildTestApp({required Widget child, List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TactileLeaderboardCard Tests', () {
    testWidgets('Renders 1st place gold card with medal 1, points, and crown division', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const TactileLeaderboardCard(
            rank: 1,
            username: 'daumienebi',
            avatarUrl: null,
            picoPoints: 2480,
            isCurrentUser: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('daumienebi'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text(NumberFormat.decimalPattern().format(2480)), findsOneWidget);
      expect(find.text('Pico Points'), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('👑'), findsOneWidget);
    });

    testWidgets('Renders 2nd place silver card with medal 2, points, and star division', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const TactileLeaderboardCard(
            rank: 2,
            username: 'shali',
            avatarUrl: null,
            picoPoints: 2320,
            isCurrentUser: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('shali'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text(NumberFormat.decimalPattern().format(2320)), findsOneWidget);
      expect(find.text('Pico Points'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
      expect(find.text('YOU'), findsNothing);
    });

    testWidgets('Renders 3rd place bronze card with medal 3, points, and fire division', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const TactileLeaderboardCard(
            rank: 3,
            username: 'pico_master',
            avatarUrl: null,
            picoPoints: 2150,
            isCurrentUser: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('pico_master'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text(NumberFormat.decimalPattern().format(2150)), findsOneWidget);
      expect(find.text('Pico Points'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('Renders rank 4+ emerald card with rank number, points, and division', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const TactileLeaderboardCard(
            rank: 4,
            username: 'charlie',
            avatarUrl: null,
            picoPoints: 1980,
            isCurrentUser: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
      expect(find.text('charlie'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text(NumberFormat.decimalPattern().format(1980)), findsOneWidget);
      expect(find.text('Pico Points'), findsOneWidget);
    });
  });

  group('Public Tournament Leaderboard Top 100 Limit Tests', () {
    testWidgets('Displays only top 100 participants when tournament has 120 participants', (tester) async {
      const tournamentId = 'test_tourn_100';
      const tournament = Tournament(
        id: tournamentId,
        name: 'Premier League',
        competitionId: '10',
      );

      // Generate 120 participants
      final mockParticipants = List.generate(
        120,
        (i) => TournamentParticipant(
          tournamentId: tournamentId,
          userId: 'user_$i',
          username: 'Player_$i',
          picoPoints: (120 - i) * 10,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            tournamentDetailsProvider(tournamentId).overrideWith((ref) => Future.value(tournament)),
            tournamentLeaderboardProvider(tournamentId).overrideWith((ref) => Future.value(mockParticipants)),
            enrolledTournamentsProvider.overrideWith((ref) => Future.value([tournament])),
          ],
          child: const PublicTournamentScreen(
            tournamentId: tournamentId,
            initialTournament: tournament,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify TOP 100 PLAYERS header is displayed with count capped to 100
      expect(find.text('TOP 100 PLAYERS'), findsOneWidget);
      expect(find.text('100 / 100'), findsOneWidget);

      // Verify top participants exist
      expect(find.text('Player_0'), findsOneWidget);
      expect(find.text('Player_1'), findsOneWidget);
      expect(find.text('Player_2'), findsOneWidget);

      // Participant index 100 (101st player) should NOT be displayed
      expect(find.text('Player_100'), findsNothing);
      expect(find.text('Player_119'), findsNothing);
    });
  });
}
