import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_view_model.dart';
import 'package:pico/shared/components/match_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PicoMatch JSON Parsing', () {
    test('parses upcoming match from mock json correctly', () {
      final json = {
        "id": "46072",
        "round": "37",
        "competition_name": "Championship",
        "league_id": "67799",
        "logo": "https://t.resfu.com/media/img/league_logos/championship.png?size=120x&lossy=1",
        "local": "Blackpool",
        "visitor": "Queens Park Rangers",
        "local_abbr": "BPO",
        "visitor_abbr": "QPR",
        "local_shield": "https://t.resfu.com/img_data/escudos/medium/508.jpg?size=60x&lossy=1",
        "visitor_shield": "https://t.resfu.com/img_data/escudos/medium/2044.jpg?size=60x&lossy=1",
        "date": "2025/03/14",
        "hour": "20",
        "minute": "45",
        "status": -1,
        "result": "x-x",
        "winner": 0
      };

      final match = PicoMatch.fromJson(json);

      expect(match.id, '46072');
      expect(match.competitionName, 'Championship');
      expect(match.homeTeamName, 'Blackpool');
      expect(match.homeTeamCode, 'BPO');
      expect(match.awayTeamName, 'Queens Park Rangers');
      expect(match.awayTeamCode, 'QPR');
      expect(match.status, MatchStatus.upcoming);
      expect(match.homeScore, isNull);
      expect(match.awayScore, isNull);
      expect(match.kickoffTimeOnly, '20:45');
      expect(match.closesAtTimeOnly, '20:35');
      expect(match.kickoffTimeFormatted, contains('20:45'));
      expect(match.closesAtTimeFormatted, contains('20:35'));
    });

    test('parses finished match with actual scores from result string', () {
      final json = {
        "id": "526460",
        "round": "7",
        "competition_name": "Liga Profesional Argentina",
        "local": "Vélez Sarsfield",
        "visitor": "Platense",
        "local_abbr": "VEL",
        "visitor_abbr": "PLA",
        "date": "2025/03/14",
        "hour": "01",
        "minute": "00",
        "status": 1,
        "result": "2-1",
        "winner": "1"
      };

      final match = PicoMatch.fromJson(json);

      expect(match.status, MatchStatus.finished);
      expect(match.homeScore, 2);
      expect(match.awayScore, 1);
      expect(match.homeTeamCode, 'VEL');
      expect(match.awayTeamCode, 'PLA');
    });
  });

  group('MockMatchRepository', () {
    late MockMatchRepository repo;

    setUp(() {
      repo = MockMatchRepository();
    });

    test('loads mock matches from asset bundle', () async {
      final matches = await repo.getAllMatches();
      expect(matches, isNotEmpty);
      expect(matches.length, greaterThanOrEqualTo(10));
    });

    test('getCompetitions returns distinct competitions', () async {
      final comps = await repo.getCompetitions();
      expect(comps, isNotEmpty);
      expect(comps.toSet().length, comps.length); // no duplicates
      expect(comps.any((c) => c.contains('Champions') || c.contains('Championship')), isTrue);
    });

    test('getHeroMatch returns a valid hero match', () async {
      final hero = await repo.getHeroMatch();
      expect(hero, isNotNull);
      expect(hero!.homeTeamName, isNotEmpty);
      expect(hero.awayTeamName, isNotEmpty);
    });
  });

  group('MatchesViewModel', () {
    late MockMatchRepository repo;
    late MatchesViewModel vm;

    setUp(() {
      repo = MockMatchRepository();
      vm = MatchesViewModel(repo);
    });

    test('loadMatches populates list and filters with All', () async {
      expect(vm.isLoading, isFalse);
      expect(vm.visibleMatches, isEmpty);

      await vm.loadMatches();

      expect(vm.isLoading, isFalse);
      expect(vm.visibleMatches, isNotEmpty);
      expect(vm.filters.first.competitionName, 'All');
      expect(vm.totalCount, vm.visibleMatches.length);
    });

    test('selectFilter filters visibleMatches accordingly', () async {
      await vm.loadMatches();

      final firstCompIndex = vm.filters.indexWhere((f) => f.competitionName != 'All');
      final firstComp = vm.filters[firstCompIndex];
      vm.selectFilter(firstCompIndex);

      expect(vm.selectedFilterIndex, firstCompIndex);
      expect(vm.visibleMatches.every((m) => m.competitionName == firstComp.competitionName), isTrue);

      vm.selectFilter(0); // All
      expect(vm.visibleMatches.length, vm.totalCount);
    });

    test('saving prediction updates viewmodel state safely', () async {
      await vm.loadMatches();
      final matchId = vm.visibleMatches.first.id;

      expect(vm.getPrediction(matchId), isNull);
      vm.savePrediction(matchId, 3, 1);

      final pred = vm.getPrediction(matchId);
      expect(pred, isNotNull);
      expect(pred!.homeScore, 3);
      expect(pred.awayScore, 1);
    });
  });

  group('MatchCard.fromMatch binding', () {
    test('creates correct card states', () {
      final upcomingMatch = PicoMatch(
        id: '1',
        competitionName: 'La Liga',
        competitionBadgeUrl: '',
        homeTeamName: 'Barcelona',
        homeTeamCode: 'FCB',
        homeTeamBadgeUrl: '',
        awayTeamName: 'Real Madrid',
        awayTeamCode: 'RMA',
        awayTeamBadgeUrl: '',
        kickoffAt: DateTime.now().add(const Duration(hours: 5)),
        status: MatchStatus.upcoming,
      );

      final unpredictedCard = MatchCard.fromMatch(match: upcomingMatch);
      expect(unpredictedCard.state, MatchCardState.unpredicted);
      expect(unpredictedCard.homeTeamCode, 'FCB');
      expect(unpredictedCard.awayTeamCode, 'RMA');

      final predictedCard = MatchCard.fromMatch(
        match: upcomingMatch,
        predictedHomeScore: 2,
        predictedAwayScore: 1,
      );
      expect(predictedCard.state, MatchCardState.predicted);
      expect(predictedCard.predictedHomeScore, 2);
      expect(predictedCard.predictedAwayScore, 1);

      final finishedMatch = upcomingMatch.copyWith(
        status: MatchStatus.finished,
        homeScore: 3,
        awayScore: 0,
      );
      final finishedCard = MatchCard.fromMatch(match: finishedMatch);
      expect(finishedCard.state, MatchCardState.finished);
      expect(finishedCard.finalHomeScore, 3);
      expect(finishedCard.finalAwayScore, 0);
    });
  });
}
