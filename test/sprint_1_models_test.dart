import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/domain/team.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 1 - Domain Models Generation (@freezed)', () {
    test('Competition: fromJson, toJson, copyWith, and null-safety', () {
      final json = {
        'id': 'comp_1',
        'name': 'Premier League',
        'emblem_url': 'https://cdn.pico.app/emblems/pl.png',
      };

      final comp = Competition.fromJson(json);

      expect(comp.id, 'comp_1');
      expect(comp.name, 'Premier League');
      expect(comp.emblemUrl, 'https://cdn.pico.app/emblems/pl.png');

      final serialized = comp.toJson();
      expect(serialized['id'], 'comp_1');
      expect(serialized['name'], 'Premier League');
      expect(serialized['emblem_url'], 'https://cdn.pico.app/emblems/pl.png');

      final updated = comp.copyWith(name: 'English Premier League');
      expect(updated.name, 'English Premier League');
      expect(updated.id, 'comp_1');

      // Null handling
      final fallbackComp = Competition.fromJson({'id': 'comp_2'});
      expect(fallbackComp.id, 'comp_2');
      expect(fallbackComp.name, '');
      expect(fallbackComp.emblemUrl, isNull);
    });

    test('Team: fromJson, toJson, copyWith, and null-safety', () {
      final json = {
        'id': 'team_arsenal',
        'name': 'Arsenal FC',
        'short_name': 'ARS',
        'crest_url': 'https://cdn.pico.app/crests/arsenal.png',
      };

      final team = Team.fromJson(json);

      expect(team.id, 'team_arsenal');
      expect(team.name, 'Arsenal FC');
      expect(team.shortName, 'ARS');
      expect(team.crestUrl, 'https://cdn.pico.app/crests/arsenal.png');

      final serialized = team.toJson();
      expect(serialized['id'], 'team_arsenal');
      expect(serialized['name'], 'Arsenal FC');
      expect(serialized['short_name'], 'ARS');
      expect(
        serialized['crest_url'],
        'https://cdn.pico.app/crests/arsenal.png',
      );

      final updated = team.copyWith(shortName: 'AFC');
      expect(updated.shortName, 'AFC');
      expect(updated.name, 'Arsenal FC');

      // Null handling
      final fallbackTeam = Team.fromJson({'id': 'team_empty'});
      expect(fallbackTeam.id, 'team_empty');
      expect(fallbackTeam.name, '');
      expect(fallbackTeam.shortName, isNull);
    });

    test('UserProfile: fromJson, toJson, defaults, and copyWith', () {
      final json = {
        'id': 'user_123',
        'email': 'player@pico.app',
        'username': 'joao_pico',
        'avatar_url': 'https://cdn.pico.app/avatars/joao.png',
        'level': 5,
        'xp': 450,
        'streak': 7,
        'coins': 120,
        'private_leagues_created': 2,
        'created_at': '2026-03-01T10:00:00Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user_123');
      expect(profile.email, 'player@pico.app');
      expect(profile.username, 'joao_pico');
      expect(profile.avatarUrl, 'https://cdn.pico.app/avatars/joao.png');
      expect(profile.level, 5);
      expect(profile.xp, 450);
      expect(profile.streak, 7);
      expect(profile.coins, 120);
      expect(profile.privateLeaguesCreated, 2);
      expect(profile.createdAt, DateTime.parse('2026-03-01T10:00:00Z'));

      // Test defaults when optional fields are omitted
      final minimalJson = {'id': 'user_new'};
      final minimalProfile = UserProfile.fromJson(minimalJson);
      expect(minimalProfile.id, 'user_new');
      expect(minimalProfile.level, 1);
      expect(minimalProfile.xp, 0);
      expect(minimalProfile.streak, 0);
      expect(minimalProfile.coins, 0);
      expect(minimalProfile.privateLeaguesCreated, 0);
      expect(minimalProfile.email, isNull);
      expect(minimalProfile.username, isNull);

      final updated = minimalProfile.copyWith(level: 2, xp: 100);
      expect(updated.level, 2);
      expect(updated.xp, 100);
    });

    test('Prediction: fromJson, toJson, winner evaluation, and helpers', () {
      final json = {
        'id': 'pred_999',
        'user_id': 'user_123',
        'match_id': 'match_456',
        'home_score': 2,
        'away_score': 1,
        'predicted_winner': 'home',
        'created_at': '2026-03-15T12:00:00Z',
      };

      final pred = Prediction.fromJson(json);

      expect(pred.id, 'pred_999');
      expect(pred.userId, 'user_123');
      expect(pred.matchId, 'match_456');
      expect(pred.homeScore, 2);
      expect(pred.awayScore, 1);
      expect(pred.predictedWinner, 'home');

      // Verify settlement helpers
      expect(pred.isExactScore(2, 1), isTrue);
      expect(pred.isExactScore(3, 1), isFalse);
      expect(pred.isCorrectWinner(2, 0), isTrue); // home won
      expect(pred.isCorrectWinner(1, 2), isFalse); // away won
      expect(pred.isCorrectWinner(2, 2), isFalse); // draw

      final serialized = pred.toJson();
      expect(serialized['id'], 'pred_999');
      expect(serialized['home_score'], 2);
      expect(serialized['away_score'], 1);
      expect(serialized['predicted_winner'], 'home');
    });

    test('PicoMatch: from Supabase row format with joined relations', () {
      final supabaseRow = {
        'id': 'f7d3a8b2-1111-2222-3333-444455556666',
        'provider_match_id': 'besoccer_1001',
        'competition_id': 'pl_2025',
        'home_team_id': 'arsenal',
        'away_team_id': 'chelsea',
        'kickoff_at': '2026-03-22T17:30:00Z',
        'status': 'upcoming',
        'home_score': null,
        'away_score': null,
        'settled': false,
        'competition': {
          'id': 'pl_2025',
          'name': 'Premier League',
          'emblem_url': 'https://cdn.pico.app/pl.png?v=999',
        },
        'home_team': {
          'id': 'arsenal',
          'name': 'Arsenal',
          'short_name': 'ARS',
          'crest_url': 'https://cdn.pico.app/arsenal.png&v=123',
        },
        'away_team': {
          'id': 'chelsea',
          'name': 'Chelsea',
          'short_name': 'CHE',
          'crest_url': 'https://cdn.pico.app/chelsea.png',
        },
      };

      final match = PicoMatch.fromJson(supabaseRow);

      expect(match.id, 'f7d3a8b2-1111-2222-3333-444455556666');
      expect(match.providerMatchId, 'besoccer_1001');
      expect(match.competitionName, 'Premier League');
      expect(match.homeTeamName, 'Arsenal');
      expect(match.homeTeamCode, 'ARS');
      expect(match.awayTeamName, 'Chelsea');
      expect(match.awayTeamCode, 'CHE');
      expect(match.status, MatchStatus.upcoming);
      expect(match.homeScore, isNull);
      expect(match.awayScore, isNull);
      expect(match.settled, isFalse);

      // Verify image sanitization (&v= / ?v= stripped)
      expect(match.competitionBadgeUrl.contains('v='), isFalse);
      expect(match.homeTeamBadgeUrl.contains('v='), isFalse);
    });
  });

  group('Sprint 1 - Riverpod Repository & MatchesFeed Provider', () {
    test(
      'matchesFeedProvider returns empty when not enrolled and filters by joined tournaments',
      () async {
        // 1. Container without enrolled tournaments returns empty list
        final emptyContainer = ProviderContainer(
          overrides: [
            matchRepositoryProvider.overrideWithValue(MockMatchRepository()),
            enrolledTournamentsProvider.overrideWith((ref) async => const []),
          ],
        );
        addTearDown(emptyContainer.dispose);

        final emptyMatches = await emptyContainer.read(matchesFeedProvider.future);
        expect(emptyMatches, isEmpty);

        // 2. Container with enrolled tournament returns ONLY matches for that tournament's competition
        final enrolledContainer = ProviderContainer(
          overrides: [
            matchRepositoryProvider.overrideWithValue(MockMatchRepository()),
            enrolledTournamentsProvider.overrideWith(
              (ref) async => const [
                Tournament(
                  id: 'tourn_champions',
                  name: 'Champions League',
                  competitionId: '70393',
                ),
              ],
            ),
          ],
        );
        addTearDown(enrolledContainer.dispose);

        final matches = await enrolledContainer.read(matchesFeedProvider.future);
        expect(matches, isNotEmpty);
        expect(
          matches.every(
            (m) =>
                m.competitionName.contains('Champions') ||
                m.competitionId == '70393',
          ),
          isTrue,
        );
      },
    );

    test(
      'SupabaseMatchRepository fallback behavior when offline/unconnected',
      () async {
        final repo = SupabaseMatchRepository(null, MockMatchRepository());

        final matches = await repo.getAllMatches();
        expect(matches, isNotEmpty);

        final comps = await repo.getCompetitions();
        expect(comps, isNotEmpty);
      },
    );
  });
}
