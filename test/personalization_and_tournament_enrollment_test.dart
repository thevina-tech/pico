import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/presentation/personalization_controller.dart';
import 'package:pico/features/profile/presentation/personalization_screen.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/l10n/app_localizations.dart';

class _FakeMatchRepository implements MatchRepository {
  _FakeMatchRepository(this.matches);
  final List<PicoMatch> matches;

  @override
  Future<List<PicoMatch>> getAllMatches() async => matches;

  @override
  Future<List<PicoMatch>> getUpcomingMatches() async =>
      matches.where((m) => m.status == MatchStatus.upcoming).toList();

  @override
  Future<List<PicoMatch>> getFinishedMatches() async =>
      matches.where((m) => m.status == MatchStatus.finished).toList();

  @override
  Future<PicoMatch?> getHeroMatch() async => matches.isNotEmpty ? matches.first : null;

  @override
  Future<List<String>> getCompetitions() async =>
      matches.map((m) => m.competitionName).toSet().toList();

  @override
  Future<PicoMatch?> getMatchById(String id) async =>
      matches.firstWhere((m) => m.id == id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final multiLeagueMatches = [
    PicoMatch(
      id: 'match_pl_1',
      providerMatchId: 'pl_1',
      competitionId: 'premier_league',
      competitionName: 'Premier League',
      homeTeamId: 'arsenal',
      homeTeamName: 'Arsenal',
      homeTeamCode: 'ARS',
      awayTeamId: 'chelsea',
      awayTeamName: 'Chelsea',
      awayTeamCode: 'CHE',
      kickoffAt: DateTime.now().add(const Duration(hours: 3)),
      status: MatchStatus.upcoming,
    ),
    PicoMatch(
      id: 'match_pl_2',
      providerMatchId: 'pl_2',
      competitionId: 'premier_league',
      competitionName: 'Premier League',
      homeTeamId: 'liverpool',
      homeTeamName: 'Liverpool',
      homeTeamCode: 'LIV',
      awayTeamId: 'man_city',
      awayTeamName: 'Man City',
      awayTeamCode: 'MCI',
      kickoffAt: DateTime.now().add(const Duration(hours: 5)),
      status: MatchStatus.upcoming,
    ),
    PicoMatch(
      id: 'match_laliga_1',
      providerMatchId: 'laliga_1',
      competitionId: 'la_liga',
      competitionName: 'La Liga',
      homeTeamId: 'real_madrid',
      homeTeamName: 'Real Madrid',
      homeTeamCode: 'RMA',
      awayTeamId: 'barcelona',
      awayTeamName: 'Barcelona',
      awayTeamCode: 'BAR',
      kickoffAt: DateTime.now().add(const Duration(hours: 6)),
      status: MatchStatus.upcoming,
    ),
    PicoMatch(
      id: 'match_serie_a_1',
      providerMatchId: 'sa_1',
      competitionId: 'serie_a',
      competitionName: 'Serie A',
      homeTeamId: 'juventus',
      homeTeamName: 'Juventus',
      homeTeamCode: 'JUV',
      awayTeamId: 'milan',
      awayTeamName: 'AC Milan',
      awayTeamCode: 'MIL',
      kickoffAt: DateTime.now().add(const Duration(hours: 7)),
      status: MatchStatus.upcoming,
    ),
    PicoMatch(
      id: 'match_bundesliga_1',
      providerMatchId: 'bun_1',
      competitionId: 'bundesliga',
      competitionName: 'Bundesliga',
      homeTeamId: 'bayern',
      homeTeamName: 'Bayern Munich',
      homeTeamCode: 'BAY',
      awayTeamId: 'dortmund',
      awayTeamName: 'Borussia Dortmund',
      awayTeamCode: 'BVB',
      kickoffAt: DateTime.now().add(const Duration(hours: 8)),
      status: MatchStatus.upcoming,
    ),
  ];

  group('Personalization Flow: Selection Constraints & Auto-Enrollment', () {
    test('PersonalizationController enforces single-team and max-2 leagues cap', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(personalizationControllerProvider.notifier);
      var state = container.read(personalizationControllerProvider);

      // Default state: exactly 1 team and 2 leagues
      expect(state.selectedTeamIds.length, 1);
      expect(state.selectedLeagueIds.length, 2);

      // Single-team constraint: selecting a team replaces previous selection
      controller.selectTeam('barcelona');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedTeamIds, equals({'barcelona'}));
      expect(state.selectedTeamId, 'barcelona');

      controller.selectTeam('man_city');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedTeamIds, equals({'man_city'}));
      expect(state.selectedTeamId, 'man_city');

      // Max-2 leagues cap: adding when 2 leagues are selected does nothing
      expect(state.selectedLeagueIds.length, 2);
      controller.toggleLeague('champions_league');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.length, 2);
      expect(state.selectedLeagueIds.contains('champions_league'), isFalse);

      // Removing a league allows adding another up to 2
      final firstLeague = state.selectedLeagueIds.first;
      controller.toggleLeague(firstLeague);
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.length, 1);

      controller.toggleLeague('champions_league');
      state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds.length, 2);
      expect(state.selectedLeagueIds.contains('champions_league'), isTrue);
    });

    test('Submitting personalization auto-enrolls user in tournament_participants',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).signInAnonymously();
      final auth = container.read(authProvider) as PicoAuthAuthenticated;

      final controller = container.read(personalizationControllerProvider.notifier);
      controller.setUsername('SpeedyStriker');

      // Ensure specific leagues are selected (e.g. premier_league & la_liga)
      final state = container.read(personalizationControllerProvider);
      expect(state.selectedLeagueIds, contains('premier_league'));
      expect(state.selectedLeagueIds, contains('la_liga'));

      final success = await controller.submit();
      expect(success, isTrue);

      // Verify tournament_participants in tournamentRepository
      final tournamentRepo = container.read(tournamentRepositoryProvider);
      final enrolled = await tournamentRepo.getEnrolledTournaments(auth.user!.id);
      expect(enrolled.length, 2);

      final enrolledCompIds = enrolled.map((t) => t.competitionId).toSet();
      expect(enrolledCompIds, contains('premier_league'));
      expect(enrolledCompIds, contains('la_liga'));

      final participants = await tournamentRepo.getParticipantsForUser(auth.user!.id);
      expect(participants.length, 2);
      expect(participants.every((p) => p.userId == auth.user!.id), isTrue);
    });

    testWidgets('PersonalizationScreen displays localized microcopy in Spanish',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PersonalizationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Puedes cambiar tu equipo favorito y unirte a más torneos en cualquier momento.'),
        findsOneWidget,
      );
    });
  });

  group('Matches Screen Feed & Dynamic Filter Pills', () {
    test(
      'matchesFeedProvider ONLY returns matches linked to joined tournaments',
      () async {
        final container = ProviderContainer(
          overrides: [
            matchRepositoryProvider.overrideWithValue(
              _FakeMatchRepository(multiLeagueMatches),
            ),
            enrolledTournamentsProvider.overrideWith(
              (ref) async => const [
                Tournament(
                  id: 'tourn_pl',
                  name: 'Premier League',
                  competitionId: 'premier_league',
                ),
                Tournament(
                  id: 'tourn_laliga',
                  name: 'La Liga',
                  competitionId: 'la_liga',
                ),
              ],
            ),
          ],
        );
        addTearDown(container.dispose);

        final feedMatches = await container.read(matchesFeedProvider.future);

        // Expect exactly the 3 matches belonging to Premier League (2) and La Liga (1)
        expect(feedMatches.length, 3);
        expect(feedMatches.any((m) => m.competitionId == 'serie_a'), isFalse);
        expect(feedMatches.any((m) => m.competitionId == 'bundesliga'), isFalse);
        expect(feedMatches.where((m) => m.competitionId == 'premier_league').length, 2);
        expect(feedMatches.where((m) => m.competitionId == 'la_liga').length, 1);
      },
    );

    testWidgets(
      'MatchesScreen dynamic pills reflect enrolled tournaments and filter feed',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              matchRepositoryProvider.overrideWithValue(
                _FakeMatchRepository(multiLeagueMatches),
              ),
              enrolledTournamentsProvider.overrideWith(
                (ref) async => const [
                  Tournament(
                    id: 'tourn_pl',
                    name: 'Premier League',
                    competitionId: 'premier_league',
                  ),
                  Tournament(
                    id: 'tourn_laliga',
                    name: 'La Liga',
                    competitionId: 'la_liga',
                  ),
                ],
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MatchesScreen(showBottomNavBar: false),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Dynamic pills must reflect: All (3), Premier League (2), La Liga (1)
        expect(find.text('All (3)'), findsOneWidget);
        expect(find.text('Premier League (2)'), findsOneWidget);
        expect(find.text('La Liga (1)'), findsOneWidget);

        // Generic unjoined leagues must NOT appear as filter pills
        expect(find.textContaining('Serie A'), findsNothing);
        expect(find.textContaining('Bundesliga'), findsNothing);

        // Initially 'All (3)' is selected: shows Arsenal, Liverpool, Real Madrid
        expect(find.text('Arsenal'), findsOneWidget);
        expect(find.text('Liverpool'), findsOneWidget);
        expect(find.text('Real Madrid'), findsOneWidget);
        expect(find.text('Juventus'), findsNothing);
        expect(find.text('Bayern Munich'), findsNothing);

        // Drag horizontal filter bar left to bring 'La Liga (1)' into view and tap it
        await tester.drag(find.byType(ListView).first, const Offset(-150, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text('La Liga (1)'));
        await tester.pumpAndSettle();

        // Now only Real Madrid vs Barcelona is visible
        expect(find.text('Real Madrid'), findsOneWidget);
        expect(find.text('Arsenal'), findsNothing);
        expect(find.text('Liverpool'), findsNothing);

        // Drag horizontal filter bar right to reveal 'Premier League (2)' and tap it
        await tester.drag(find.byType(ListView).first, const Offset(150, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Premier League (2)'));
        await tester.pumpAndSettle();

        expect(find.text('Arsenal'), findsOneWidget);
        expect(find.text('Liverpool'), findsOneWidget);
        expect(find.text('Real Madrid'), findsNothing);

        // Tap 'All (3)' pill to restore full joined feed
        await tester.tap(find.text('All (3)'));
        await tester.pumpAndSettle();

        expect(find.text('Arsenal'), findsOneWidget);
        expect(find.text('Liverpool'), findsOneWidget);
        expect(find.text('Real Madrid'), findsOneWidget);
      },
    );

    testWidgets(
      'La Liga filter with backend competition_id "1" and competitionName "Primera División" correctly filters matches',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final backendMatches = [
          PicoMatch(
            id: 'match_pl_db',
            providerMatchId: '10_1',
            competitionId: '10',
            competitionName: 'Premier League',
            homeTeamId: 'arsenal',
            homeTeamName: 'Arsenal',
            homeTeamCode: 'ARS',
            awayTeamId: 'chelsea',
            awayTeamName: 'Chelsea',
            awayTeamCode: 'CHE',
            kickoffAt: DateTime.now().add(const Duration(hours: 3)),
            status: MatchStatus.upcoming,
          ),
          PicoMatch(
            id: 'match_laliga_db',
            providerMatchId: '1_1',
            competitionId: '1',
            competitionName: 'Primera División', // As returned by BeSoccer/Supabase
            homeTeamId: 'real_madrid',
            homeTeamName: 'Real Madrid',
            homeTeamCode: 'RMA',
            awayTeamId: 'barcelona',
            awayTeamName: 'Barcelona',
            awayTeamCode: 'BAR',
            kickoffAt: DateTime.now().add(const Duration(hours: 6)),
            status: MatchStatus.upcoming,
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              matchRepositoryProvider.overrideWithValue(
                _FakeMatchRepository(backendMatches),
              ),
              enrolledTournamentsProvider.overrideWith(
                (ref) async => const [
                  Tournament(
                    id: '10000000-0000-0000-0000-000000000010',
                    name: 'Premier League',
                    competitionId: '10',
                  ),
                  Tournament(
                    id: '10000000-0000-0000-0000-000000000001',
                    name: 'La Liga',
                    competitionId: '1',
                  ),
                ],
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MatchesScreen(showBottomNavBar: false),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Pills: All (2), Premier League (1), La Liga (1)
        expect(find.text('All (2)'), findsOneWidget);
        expect(find.text('Premier League (1)'), findsOneWidget);
        expect(find.text('La Liga (1)'), findsOneWidget);

        // Ensure 'La Liga (1)' pill is scrolled into view and tap it
        await tester.ensureVisible(find.text('La Liga (1)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('La Liga (1)'));
        await tester.pumpAndSettle();

        // Matches screen MUST show Real Madrid vs Barcelona, NOT "No matches found"
        expect(find.text('No matches found'), findsNothing);
        expect(find.text('Real Madrid'), findsOneWidget);
        expect(find.text('Arsenal'), findsNothing);
      },
    );
  });
}
