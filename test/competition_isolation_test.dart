import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';

void main() {
  group('Competition Matching & Isolation Tests', () {
    test('isSameCompetition isolates Bundesliga (8) and Conference League (2492)', () {
      // Must NOT match each other
      expect(isSameCompetition('2492', '8'), isFalse);
      expect(isSameCompetition('8', '2492'), isFalse);

      // Must match their own aliases
      expect(isSameCompetition('8', 'bundesliga'), isTrue);
      expect(isSameCompetition('bundesliga', '8'), isTrue);
      expect(isSameCompetition('2492', 'uecl'), isTrue);
      expect(isSameCompetition('2492', 'conference_league'), isTrue);
    });

    test('isSameCompetition isolates Serie A (7) and Europa League (117)', () {
      // Must NOT match each other
      expect(isSameCompetition('117', '7'), isFalse);
      expect(isSameCompetition('7', '117'), isFalse);

      // Must match their own aliases
      expect(isSameCompetition('7', 'serie_a'), isTrue);
      expect(isSameCompetition('117', 'uel'), isTrue);
      expect(isSameCompetition('117', 'europa_league'), isTrue);
    });

    test('matchBelongsToTournament rejects Conference League match in Bundesliga tournament', () {
      const bundesligaTournament = Tournament(
        id: 'bundesliga-tournament-id',
        name: 'Bundesliga',
        competitionId: '8',
      );

      final conferenceLeagueMatch = PicoMatch(
        id: 'uecl-match-1',
        homeTeamName: 'Universitatea Craiova',
        awayTeamName: 'Getafe',
        competitionId: '2492',
        competitionName: 'Conference League',
        kickoffAt: DateTime.parse('2026-10-15T20:00:00Z'),
        status: MatchStatus.upcoming,
      );

      final bundesligaMatch = PicoMatch(
        id: 'buli-match-1',
        homeTeamName: 'Bayern München',
        awayTeamName: 'Borussia Dortmund',
        competitionId: '8',
        competitionName: 'Bundesliga',
        kickoffAt: DateTime.parse('2026-10-18T15:30:00Z'),
        status: MatchStatus.upcoming,
      );

      expect(matchBelongsToTournament(conferenceLeagueMatch, bundesligaTournament), isFalse);
      expect(matchBelongsToTournament(bundesligaMatch, bundesligaTournament), isTrue);
    });
  });
}
