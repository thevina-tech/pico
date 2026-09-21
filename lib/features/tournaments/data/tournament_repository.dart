import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import '../domain/tournament.dart';
import '../domain/tournament_participant.dart';

part 'tournament_repository.g.dart';

/// Provider for [TournamentRepository].
@Riverpod(keepAlive: true)
TournamentRepository tournamentRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTournamentRepository(supabase);
}

/// Provider exposing the list of tournaments the active authenticated user has joined.
@riverpod
Future<List<Tournament>> enrolledTournaments(Ref ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! PicoAuthAuthenticated || authState.user == null) {
    return const [];
  }
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getEnrolledTournaments(authState.user!.id);
}

/// Abstract contract for tournament operations.
abstract class TournamentRepository {
  Future<List<Tournament>> getPublicTournaments();
  Future<List<Tournament>> getEnrolledTournaments(String userId);
  Future<void> enrollInDefaultTournaments({
    required String userId,
    required List<String> leagueIds,
  });
  Future<List<TournamentParticipant>> getParticipantsForUser(String userId);
}

/// Production Supabase implementation of [TournamentRepository] with offline fallback.
class SupabaseTournamentRepository implements TournamentRepository {
  SupabaseTournamentRepository([this._supabase]);

  final SupabaseClient? _supabase;

  // Pre-configured default official tournaments for top leagues
  static final Map<String, Tournament> _defaultOfficialTournaments = {
    'la_liga': const Tournament(
      id: 'tourn_la_liga',
      name: 'La Liga',
      competitionId: 'la_liga',
    ),
    'premier_league': const Tournament(
      id: 'tourn_premier_league',
      name: 'Premier League',
      competitionId: 'premier_league',
    ),
    'champions_league': const Tournament(
      id: 'tourn_champions_league',
      name: 'Champions League',
      competitionId: 'champions_league',
    ),
    'serie_a': const Tournament(
      id: 'tourn_serie_a',
      name: 'Serie A',
      competitionId: 'serie_a',
    ),
    'bundesliga': const Tournament(
      id: 'tourn_bundesliga',
      name: 'Bundesliga',
      competitionId: 'bundesliga',
    ),
    'ligue_1': const Tournament(
      id: 'tourn_ligue_1',
      name: 'Ligue 1',
      competitionId: 'ligue_1',
    ),
  };

  // Mock in-memory participants storage: userId -> Set of tournament IDs
  final Map<String, Set<String>> _mockParticipants = {};

  @override
  Future<List<Tournament>> getPublicTournaments() async {
    if (_supabase == null) {
      return _defaultOfficialTournaments.values.toList();
    }

    try {
      final response = await _supabase.from('tournaments').select();
      final list = (response as List<dynamic>)
          .map((row) => Tournament.fromJson(row as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
      return _defaultOfficialTournaments.values.toList();
    } catch (e, st) {
      AppLogger.error('Failed to get public tournaments from Supabase', e, st);
      return _defaultOfficialTournaments.values.toList();
    }
  }

  @override
  Future<List<Tournament>> getEnrolledTournaments(String userId) async {
    if (_supabase == null) {
      final enrolledIds = _mockParticipants[userId] ?? {};
      return _defaultOfficialTournaments.values
          .where((t) => enrolledIds.contains(t.id))
          .toList();
    }

    try {
      final response = await _supabase
          .from('tournament_participants')
          .select('''
            tournament_id,
            user_id,
            pico_points,
            joined_at,
            tournament:tournaments(id, name, competition_id, start_date, end_date)
          ''')
          .eq('user_id', userId);

      final list = (response as List<dynamic>).map((row) {
        final rowMap = row as Map<String, dynamic>;
        if (rowMap['tournament'] is Map<String, dynamic>) {
          return Tournament.fromJson(rowMap['tournament'] as Map<String, dynamic>);
        }
        final tId = rowMap['tournament_id']?.toString() ?? '';
        return _defaultOfficialTournaments.values.firstWhere(
          (t) => t.id == tId,
          orElse: () => Tournament(id: tId, name: 'Tournament $tId', competitionId: tId),
        );
      }).toList();

      if (list.isNotEmpty) return list;

      // Fallback to mock participants cache if Supabase table is empty or offline
      final enrolledIds = _mockParticipants[userId] ?? {};
      return _defaultOfficialTournaments.values
          .where((t) => enrolledIds.contains(t.id))
          .toList();
    } catch (e, st) {
      AppLogger.error('Failed to get enrolled tournaments for user $userId', e, st);
      final enrolledIds = _mockParticipants[userId] ?? {};
      return _defaultOfficialTournaments.values
          .where((t) => enrolledIds.contains(t.id))
          .toList();
    }
  }

  @override
  Future<List<TournamentParticipant>> getParticipantsForUser(String userId) async {
    if (_supabase == null) {
      final enrolledIds = _mockParticipants[userId] ?? {};
      return enrolledIds.map((tId) {
        final t = _defaultOfficialTournaments.values.firstWhere(
          (tourn) => tourn.id == tId,
          orElse: () => Tournament(id: tId, name: 'Tournament $tId', competitionId: tId),
        );
        return TournamentParticipant(
          tournamentId: tId,
          userId: userId,
          picoPoints: 0,
          joinedAt: DateTime.now(),
          tournament: t,
        );
      }).toList();
    }

    try {
      final response = await _supabase
          .from('tournament_participants')
          .select('''
            tournament_id,
            user_id,
            pico_points,
            joined_at,
            tournament:tournaments(id, name, competition_id, start_date, end_date)
          ''')
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((row) => TournamentParticipant.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('Failed to get participants for user $userId', e, st);
      return [];
    }
  }

  @override
  Future<void> enrollInDefaultTournaments({
    required String userId,
    required List<String> leagueIds,
  }) async {
    // 1. Maintain in-memory mock cache for immediate test and offline reactivity
    final userEnrolled = _mockParticipants.putIfAbsent(userId, () => <String>{});

    for (final leagueId in leagueIds) {
      final def = _defaultOfficialTournaments[leagueId];
      if (def != null) {
        userEnrolled.add(def.id);
      } else {
        userEnrolled.add('tourn_$leagueId');
      }
    }

    if (_supabase == null) {
      AppLogger.info('Mock auto-enrollment in tournaments for user $userId: $leagueIds');
      return;
    }

    try {
      for (final leagueId in leagueIds) {
        final def = _defaultOfficialTournaments[leagueId];
        final tournamentName = def?.name ?? _formatLeagueName(leagueId);
        final competitionId = def?.competitionId ?? leagueId;
        final resolvedCompId = _resolveCompetitionId(competitionId);

        // 1. Locate public tournament by competition_id or predetermined id
        String? targetTournamentId;
        final existing = await _supabase
            .from('tournaments')
            .select('id')
            .or('competition_id.eq.$competitionId,competition_id.eq.$resolvedCompId')
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          targetTournamentId = existing['id'].toString();
        } else if (def != null) {
          final byId = await _supabase
              .from('tournaments')
              .select('id')
              .eq('id', def.id)
              .maybeSingle();
          if (byId != null && byId['id'] != null) {
            targetTournamentId = byId['id'].toString();
          }
        } else {
          // Check if tournament exists by name
          final byName = await _supabase
              .from('tournaments')
              .select('id')
              .ilike('name', '%$tournamentName%')
              .maybeSingle();
          if (byName != null && byName['id'] != null) {
            targetTournamentId = byName['id'].toString();
          }
        }

        if (targetTournamentId == null) {
          AppLogger.warning(
            'No public tournament found for league $leagueId (comp: $competitionId / $resolvedCompId). Skipping auto-enrollment in DB.',
          );
          continue;
        }

        // 2. Insert row into `public.tournament_participants`
        await _supabase.from('tournament_participants').upsert(
          {
            'tournament_id': targetTournamentId,
            'user_id': userId,
            'pico_points': 0,
          },
          onConflict: 'tournament_id,user_id',
        );
        AppLogger.info(
          'Enrolled user $userId in tournament $targetTournamentId for league $leagueId',
        );
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to auto-enroll user $userId into tournaments for leagues $leagueIds',
        e,
        st,
      );
      // Fallback already cached in _mockParticipants
    }
  }

  static String _resolveCompetitionId(String leagueId) {
    switch (leagueId.toLowerCase()) {
      case 'la_liga':
      case 'laliga':
      case '1':
        return '1';
      case 'premier_league':
      case 'epl':
      case '10':
        return '10';
      case 'champions_league':
      case 'ucl':
      case '6':
        return '6';
      case 'serie_a':
      case '2':
        return '2';
      case 'bundesliga':
      case '3':
        return '3';
      case 'ligue_1':
      case '4':
        return '4';
      default:
        return leagueId;
    }
  }

  static String _formatLeagueName(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
