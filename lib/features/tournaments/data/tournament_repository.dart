import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import '../domain/league_message.dart';
import '../domain/private_league.dart';
import '../domain/private_league_exceptions.dart';
import '../domain/private_league_member.dart';
import '../domain/tournament.dart';
import '../domain/tournament_participant.dart';

part 'tournament_repository.g.dart';

/// Provider for [TournamentRepository].
@Riverpod(keepAlive: true)
TournamentRepository tournamentRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTournamentRepository(supabase);
}

/// Provider exposing supported competitions dynamically loaded from Supabase database.
@Riverpod(keepAlive: true)
Future<List<Competition>> supportedCompetitions(Ref ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getCompetitions();
}

/// Provider exposing a map of competitions by ID for fast lookup.
@Riverpod(keepAlive: true)
Future<Map<String, Competition>> competitionsMap(Ref ref) async {
  final list = await ref.watch(supportedCompetitionsProvider.future);
  return {for (final c in list) c.id: c};
}

/// Provider exposing the list of official public tournaments.
@Riverpod(keepAlive: true)
Future<List<Tournament>> publicTournaments(Ref ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getPublicTournaments();
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

/// Provider exposing the list of private leagues the active authenticated user has joined or owns.
@riverpod
Future<List<PrivateLeague>> userPrivateLeagues(Ref ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! PicoAuthAuthenticated || authState.user == null) {
    return const [];
  }
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getUserPrivateLeagues(authState.user!.id);
}

/// Provider for public tournament details by ID.
@riverpod
Future<Tournament?> tournamentDetails(Ref ref, String id) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getTournamentById(id);
}

/// Provider for a tournament's public leaderboard.
@riverpod
Future<List<TournamentParticipant>> tournamentLeaderboard(
  Ref ref,
  String tournamentId,
) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getTournamentLeaderboard(tournamentId);
}

/// Provider for a private league's details by ID.
@riverpod
Future<PrivateLeague?> privateLeagueDetails(Ref ref, String id) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getPrivateLeagueById(id);
}

/// Provider for a private league's member leaderboard.
@riverpod
Future<List<PrivateLeagueMember>> privateLeagueMembers(
  Ref ref,
  String leagueId,
) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getPrivateLeagueMembers(leagueId);
}

/// Provider for a private league's message feed.
@riverpod
Future<List<LeagueMessage>> leagueMessages(
  Ref ref,
  String leagueId,
) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getLeagueMessages(leagueId);
}

/// Provider for matches filtered by competition ID.
@riverpod
Future<List<PicoMatch>> competitionMatches(
  Ref ref,
  String competitionId,
) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final all = await matchRepo.getAllMatches();
  if (competitionId.isEmpty) return all;
  return all.where((m) {
    if (m.competitionId == competitionId) return true;
    return isSameCompetition(m.competitionId ?? '', competitionId);
  }).toList();
}

/// Abstract contract for tournament & private league operations.
abstract class TournamentRepository {
  Future<List<Competition>> getCompetitions();
  Future<List<Tournament>> getPublicTournaments();
  Future<List<Tournament>> getEnrolledTournaments(String userId);
  Future<void> enrollInDefaultTournaments({
    required String userId,
    required List<String> leagueIds,
  });
  Future<void> enrollInTournament({
    required String userId,
    required String tournamentId,
  });
  Future<List<TournamentParticipant>> getParticipantsForUser(String userId);

  // Tournament Details & Leaderboard
  Future<Tournament?> getTournamentById(String tournamentId);
  Future<List<TournamentParticipant>> getTournamentLeaderboard(String tournamentId);

  // Private Leagues
  Future<List<PrivateLeague>> getUserPrivateLeagues(String userId);
  Future<PrivateLeague?> getPrivateLeagueById(String leagueId);
  Future<PrivateLeague> createPrivateLeague({
    required String name,
    required String competitionId,
    required String userId,
    String description = '',
  });
  Future<PrivateLeague> joinPrivateLeagueByCode({
    required String inviteCode,
    required String userId,
  });
  Future<List<PrivateLeagueMember>> getPrivateLeagueMembers(String leagueId);
  Future<void> deletePrivateLeague({
    required String leagueId,
    required String userId,
  });
  Future<void> removeMemberFromPrivateLeague({
    required String leagueId,
    required String targetUserId,
    required String adminUserId,
  });
  Future<void> leavePrivateLeague({
    required String leagueId,
    required String userId,
  });

  // League Chat
  Future<List<LeagueMessage>> getLeagueMessages(String leagueId, {int limit = 50});
  Future<LeagueMessage> sendLeagueMessage({
    required String leagueId,
    required String userId,
    required String message,
    String? username,
    String? avatarUrl,
  });
}

/// Production Supabase implementation of [TournamentRepository] with offline fallback.
class SupabaseTournamentRepository implements TournamentRepository {
  SupabaseTournamentRepository([this._supabase]);

  final SupabaseClient? _supabase;

  // Fallback competitions when offline or uninitialized
  static final List<Competition> _fallbackCompetitions = [
    const Competition(
      id: '1',
      name: 'Primera División (La Liga)',
      shortName: 'La Liga',
      flag: '🇪🇸',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/1.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '10',
      name: 'Premier League',
      shortName: 'Premier League',
      flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/10.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '7',
      name: 'Serie A',
      shortName: 'Serie A',
      flag: '🇮🇹',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/7.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '8',
      name: 'Bundesliga',
      shortName: 'Bundesliga',
      flag: '🇩🇪',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/8.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '16',
      name: 'Ligue 1',
      shortName: 'Ligue 1',
      flag: '🇫🇷',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/16.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '107',
      name: 'Champions League',
      shortName: 'UCL',
      flag: '⭐',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/107.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '117',
      name: 'Europa League',
      shortName: 'UEL',
      flag: '🟠',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/117.png?size=120x&lossy=1',
    ),
    const Competition(
      id: '2492',
      name: 'Conference League',
      shortName: 'UECL',
      flag: '🟢',
      emblemUrl: 'https://t.resfu.com/img_data/competiciones/logo/2492.png?size=120x&lossy=1',
    ),
  ];

  // Pre-configured default official tournaments for the 8 curated top-tier leagues
  static final Map<String, Tournament> _defaultOfficialTournaments = {
    '1': const Tournament(
      id: '10000000-0000-0000-0000-000000000001',
      name: 'Primera División',
      competitionId: '1',
    ),
    '10': const Tournament(
      id: '10000000-0000-0000-0000-000000000010',
      name: 'Premier League',
      competitionId: '10',
    ),
    '7': const Tournament(
      id: '10000000-0000-0000-0000-000000000007',
      name: 'Serie A',
      competitionId: '7',
    ),
    '8': const Tournament(
      id: '10000000-0000-0000-0000-000000000008',
      name: 'Bundesliga',
      competitionId: '8',
    ),
    '16': const Tournament(
      id: '10000000-0000-0000-0000-000000000016',
      name: 'Ligue 1',
      competitionId: '16',
    ),
    '107': const Tournament(
      id: '10000000-0000-0000-0000-000000000107',
      name: 'Champions League',
      competitionId: '107',
    ),
    '117': const Tournament(
      id: '10000000-0000-0000-0000-000000000117',
      name: 'Europa League',
      competitionId: '117',
    ),
    '2492': const Tournament(
      id: '10000000-0000-0000-0000-000000002492',
      name: 'Conference League',
      competitionId: '2492',
    ),
  };

  // Mock in-memory storage for offline / unit test execution
  final Map<String, Set<String>> _mockParticipants = {};
  final Map<String, PrivateLeague> _mockPrivateLeagues = {};
  final Map<String, Set<String>> _mockLeagueMembers = {};
  final Map<String, List<LeagueMessage>> _mockLeagueMessages = {};

  @override
  Future<List<Competition>> getCompetitions() async {
    if (_supabase == null) {
      return _fallbackCompetitions;
    }

    try {
      final response = await _supabase
          .from('competitions')
          .select()
          .order('name');
      final list = (response as List<dynamic>)
          .map((row) => Competition.fromJson(row as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
      return _fallbackCompetitions;
    } catch (e, st) {
      AppLogger.error('Failed to fetch competitions from Supabase, using fallback: $e', e, st);
      return _fallbackCompetitions;
    }
  }

  @override
  Future<List<Tournament>> getPublicTournaments() async {
    if (_supabase == null) {
      return _defaultOfficialTournaments.values.toList();
    }

    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .order('name');
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
    final userEnrolled = _mockParticipants.putIfAbsent(userId, () => <String>{});

    for (final leagueId in leagueIds) {
      final competitionId = _resolveCompetitionId(leagueId);
      final targetId = _defaultOfficialTournaments[competitionId]?.id ?? 'tourn_$competitionId';
      userEnrolled.add(targetId);
    }

    if (_supabase == null) {
      AppLogger.info('Mock auto-enrollment in tournaments for user $userId: $leagueIds');
      return;
    }

    try {
      for (final leagueId in leagueIds) {
        final competitionId = _resolveCompetitionId(leagueId);

        String? targetTournamentId;
        final existing = await _supabase
            .from('tournaments')
            .select('id')
            .eq('competition_id', competitionId)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          targetTournamentId = existing['id'].toString();
        } else {
          targetTournamentId = _defaultOfficialTournaments[competitionId]?.id;
        }

        if (targetTournamentId == null) {
          AppLogger.warning(
            'No public tournament found for league $leagueId (comp: $competitionId). Skipping auto-enrollment in DB.',
          );
          continue;
        }

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
    }
  }

  @override
  Future<void> enrollInTournament({
    required String userId,
    required String tournamentId,
  }) async {
    _mockParticipants.putIfAbsent(userId, () => <String>{}).add(tournamentId);

    if (_supabase == null) {
      AppLogger.info('Mock enrollment of user $userId into tournament $tournamentId');
      return;
    }

    try {
      await _supabase.from('tournament_participants').upsert(
        {
          'tournament_id': tournamentId,
          'user_id': userId,
          'pico_points': 0,
        },
        onConflict: 'tournament_id,user_id',
      );
      AppLogger.info('Enrolled user $userId into tournament $tournamentId');
    } catch (e, st) {
      AppLogger.error('Failed to enroll user $userId into tournament $tournamentId', e, st);
      rethrow;
    }
  }

  @override
  Future<List<PrivateLeague>> getUserPrivateLeagues(String userId) async {
    if (_supabase == null) {
      final enrolledLeagues = _mockPrivateLeagues.values
          .where((l) => _mockLeagueMembers[l.id]?.contains(userId) ?? false)
          .toList();
      return enrolledLeagues;
    }

    try {
      final response = await _supabase
          .from('private_league_members')
          .select('''
            private_league_id,
            user_id,
            pico_points,
            joined_at,
            league:private_leagues(
              id,
              name,
              description,
              owner_id,
              competition_id,
              invite_code,
              created_at,
              max_capacity,
              owner:profiles!private_leagues_owner_id_fkey(username)
            )
          ''')
          .eq('user_id', userId);

      final list = <PrivateLeague>[];
      final leagueRows = (response as List<dynamic>)
          .map((row) => row as Map<String, dynamic>)
          .where((row) => row['league'] is Map<String, dynamic>)
          .toList();

      if (leagueRows.isEmpty) return [];

      // Batch query member counts in ONE single call to eliminate N+1 API calls
      final leagueIds = leagueRows
          .map((r) => (r['league'] as Map<String, dynamic>)['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final memberCounts = <String, int>{};
      if (leagueIds.isNotEmpty) {
        final allMembers = await _supabase
            .from('private_league_members')
            .select('private_league_id')
            .inFilter('private_league_id', leagueIds);

        for (final m in allMembers as List<dynamic>) {
          final lId = (m as Map<String, dynamic>)['private_league_id']?.toString();
          if (lId != null) {
            memberCounts[lId] = (memberCounts[lId] ?? 0) + 1;
          }
        }
      }

      for (final rowMap in leagueRows) {
        final leagueData = Map<String, dynamic>.from(rowMap['league'] as Map<String, dynamic>);
        final leagueId = leagueData['id']?.toString() ?? '';
        final ownerData = leagueData['owner'] as Map<String, dynamic>?;
        final compId = leagueData['competition_id']?.toString() ?? '';
        final comp = _fallbackCompetitions.firstWhere(
          (c) => c.id == compId,
          orElse: () => Competition(id: compId, name: compId),
        );

        list.add(PrivateLeague.fromJson({
          ...leagueData,
          'ownerName': ownerData?['username'] ?? '',
          'competitionName': comp.name,
          'memberCount': memberCounts[leagueId] ?? 1,
        }));
      }
      return list;
    } catch (e, st) {
      AppLogger.error('Failed to get user private leagues for $userId', e, st);
      return [];
    }
  }

  @override
  Future<PrivateLeague> createPrivateLeague({
    required String name,
    required String competitionId,
    required String userId,
    String description = '',
  }) async {
    final cleanName = InputSanitizer.sanitizeLeagueName(name);
    if (!InputSanitizer.isValidLeagueName(cleanName)) {
      throw ArgumentError('League name must be between 3 and 30 characters.');
    }

    final resolvedCompId = _resolveCompetitionId(competitionId);
    final comp = _fallbackCompetitions
        .where((c) => c.id == resolvedCompId)
        .firstOrNull;

    if (_supabase == null) {
      final mockId = 'mock_priv_${DateTime.now().millisecondsSinceEpoch}';
      final mockCode = 'K9X2P1';
      final newLeague = PrivateLeague(
        id: mockId,
        name: cleanName,
        description: description.trim(),
        ownerId: userId,
        competitionId: resolvedCompId,
        inviteCode: mockCode,
        createdAt: DateTime.now(),
        competitionName: comp?.name ?? resolvedCompId,
        memberCount: 1,
      );
      _mockPrivateLeagues[mockId] = newLeague;
      _mockLeagueMembers.putIfAbsent(mockId, () => <String>{}).add(userId);
      return newLeague;
    }

    try {
      final insertData = {
        'name': cleanName,
        'description': description.trim(),
        'owner_id': userId,
        'competition_id': resolvedCompId,
      };

      final response = await _supabase
          .from('private_leagues')
          .insert(insertData)
          .select('''
            id,
            name,
            description,
            owner_id,
            competition_id,
            invite_code,
            created_at,
            max_capacity
          ''')
          .single();

      final leagueMap = Map<String, dynamic>.from(response);
      return PrivateLeague.fromJson({
        ...leagueMap,
        'competitionName': comp?.name ?? resolvedCompId,
        'memberCount': 1,
      });
    } catch (e, st) {
      AppLogger.error('Failed to create private league', e, st);
      rethrow;
    }
  }

  @override
  Future<PrivateLeague> joinPrivateLeagueByCode({
    required String inviteCode,
    required String userId,
  }) async {
    final cleanCode = InputSanitizer.sanitizeInviteCode(inviteCode);
    if (!InputSanitizer.isValidInviteCode(cleanCode)) {
      throw const LeagueNotFoundException();
    }
    if (_supabase == null) {
      final found = _mockPrivateLeagues.values.firstWhere(
        (l) => l.inviteCode == cleanCode,
        orElse: () => throw const LeagueNotFoundException(),
      );
      if (found.ownerId == userId) {
        throw const LeagueCreatorCannotRejoinException();
      }
      final members = _mockLeagueMembers[found.id] ?? {};
      if (members.contains(userId)) {
        throw const LeagueAlreadyMemberException();
      }
      if (members.length >= found.maxCapacity) {
        throw const LeagueCapacityReachedException();
      }
      _mockLeagueMembers.putIfAbsent(found.id, () => <String>{}).add(userId);
      return found;
    }

    try {
      final rpcResult = await _supabase.rpc('join_private_league', params: {
        'p_invite_code': cleanCode,
        'p_user_id': userId,
      });

      if (rpcResult == null) {
        throw const LeagueNotFoundException();
      }

      final leagueMap = Map<String, dynamic>.from(rpcResult as Map<String, dynamic>);
      final compId = leagueMap['competition_id']?.toString() ?? '';
      final comp = _fallbackCompetitions.firstWhere(
        (c) => c.id == compId,
        orElse: () => Competition(id: compId, name: compId),
      );

      return PrivateLeague.fromJson({
        ...leagueMap,
        'competitionName': comp.name,
      });
    } on PostgrestException catch (e) {
      AppLogger.warning('Postgrest error joining private league: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('maximum capacity') ||
          msg.contains('capacity') ||
          msg.contains('league is full') ||
          msg.contains('league full')) {
        throw const LeagueCapacityReachedException();
      }
      if (msg.contains('creator_cannot_rejoin') || msg.contains('creator')) {
        throw const LeagueCreatorCannotRejoinException();
      }
      if (msg.contains('already_member') || msg.contains('already a member')) {
        throw const LeagueAlreadyMemberException();
      }
      if (msg.contains('league_not_found') ||
          msg.contains('no league found') ||
          msg.contains('invalid invite code')) {
        throw const LeagueNotFoundException();
      }
      throw LeagueGenericException(e.message);
    } catch (e, st) {
      AppLogger.error('Failed to join private league with code $cleanCode', e, st);
      rethrow;
    }
  }

  @override
  Future<Tournament?> getTournamentById(String tournamentId) async {
    if (_supabase == null) {
      return _defaultOfficialTournaments.values
          .where((t) => t.id == tournamentId || t.competitionId == tournamentId)
          .firstOrNull;
    }
    try {
      final response = await _supabase
          .from('tournaments')
          .select()
          .eq('id', tournamentId)
          .maybeSingle();
      if (response != null) {
        return Tournament.fromJson(response);
      }
      return _defaultOfficialTournaments.values
          .where((t) => t.id == tournamentId || t.competitionId == tournamentId)
          .firstOrNull;
    } catch (e, st) {
      AppLogger.error('Failed to get tournament by id $tournamentId', e, st);
      return _defaultOfficialTournaments.values
          .where((t) => t.id == tournamentId || t.competitionId == tournamentId)
          .firstOrNull;
    }
  }

  @override
  Future<List<TournamentParticipant>> getTournamentLeaderboard(String tournamentId) async {
    if (_supabase == null) {
      final participants = <TournamentParticipant>[];
      for (final entry in _mockParticipants.entries) {
        if (entry.value.contains(tournamentId)) {
          participants.add(TournamentParticipant(
            tournamentId: tournamentId,
            userId: entry.key,
            picoPoints: 0,
            username: 'Player ${entry.key.substring(0, entry.key.length.clamp(0, 5))}',
          ));
        }
      }
      return participants;
    }
    try {
      final response = await _supabase
          .from('tournament_participants')
          .select('''
            tournament_id,
            user_id,
            pico_points,
            joined_at,
            profile:profiles(username, avatar_url)
          ''')
          .eq('tournament_id', tournamentId)
          .order('pico_points', ascending: false);

      return (response as List<dynamic>).map((row) {
        final rowMap = row as Map<String, dynamic>;
        final profile = rowMap['profile'] as Map<String, dynamic>?;
        return TournamentParticipant.fromJson({
          ...rowMap,
          'username': profile?['username'] ?? 'Player',
          'avatar_url': profile?['avatar_url'],
        });
      }).toList();
    } catch (e, st) {
      AppLogger.error('Failed to get leaderboard for tournament $tournamentId', e, st);
      return [];
    }
  }

  @override
  Future<PrivateLeague?> getPrivateLeagueById(String leagueId) async {
    if (_supabase == null) {
      final league = _mockPrivateLeagues[leagueId];
      if (league == null) return null;
      final count = _mockLeagueMembers[leagueId]?.length ?? 1;
      return league.copyWith(memberCount: count);
    }
    try {
      final response = await _supabase
          .from('private_leagues')
          .select('''
            id,
            name,
            description,
            owner_id,
            competition_id,
            invite_code,
            created_at,
            max_capacity,
            owner:profiles!private_leagues_owner_id_fkey(username)
          ''')
          .eq('id', leagueId)
          .maybeSingle();

      if (response == null) return null;

      final leagueData = Map<String, dynamic>.from(response);
      final ownerData = leagueData['owner'] as Map<String, dynamic>?;
      final compId = leagueData['competition_id']?.toString() ?? '';
      final comp = _fallbackCompetitions.firstWhere(
        (c) => c.id == compId,
        orElse: () => Competition(id: compId, name: compId),
      );

      final members = await _supabase
          .from('private_league_members')
          .select('user_id')
          .eq('private_league_id', leagueId);
      final count = (members as List<dynamic>).length;

      return PrivateLeague.fromJson({
        ...leagueData,
        'ownerName': ownerData?['username'] ?? '',
        'competitionName': comp.name,
        'memberCount': count > 0 ? count : 1,
      });
    } catch (e, st) {
      AppLogger.error('Failed to get private league by id $leagueId', e, st);
      return null;
    }
  }

  @override
  Future<List<PrivateLeagueMember>> getPrivateLeagueMembers(String leagueId) async {
    if (_supabase == null) {
      final memberIds = _mockLeagueMembers[leagueId] ?? {};
      return memberIds.map((uId) => PrivateLeagueMember(
        privateLeagueId: leagueId,
        userId: uId,
        picoPoints: 0,
        username: uId == 'test_owner_123' ? 'PicoChamp' : 'Player $uId',
        joinedAt: DateTime.now(),
      )).toList();
    }

    try {
      final response = await _supabase
          .from('private_league_members')
          .select('''
            private_league_id,
            user_id,
            pico_points,
            joined_at,
            profile:profiles(username, avatar_url)
          ''')
          .eq('private_league_id', leagueId)
          .order('pico_points', ascending: false);

      return (response as List<dynamic>).map((row) {
        final rowMap = row as Map<String, dynamic>;
        final profile = rowMap['profile'] as Map<String, dynamic>?;
        return PrivateLeagueMember.fromJson({
          ...rowMap,
          'username': profile?['username'] ?? 'Player',
          'avatar_url': profile?['avatar_url'],
        });
      }).toList();
    } catch (e, st) {
      AppLogger.error('Failed to get members for private league $leagueId', e, st);
      return [];
    }
  }

  @override
  Future<void> deletePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    if (_supabase == null) {
      final league = _mockPrivateLeagues[leagueId];
      if (league != null && league.ownerId != userId) {
        throw const LeagueNotOwnerException();
      }
      _mockPrivateLeagues.remove(leagueId);
      _mockLeagueMembers.remove(leagueId);
      return;
    }

    try {
      await _supabase.rpc('delete_private_league', params: {
        'p_league_id': leagueId,
      });
    } on PostgrestException catch (e) {
      AppLogger.warning('Postgrest error deleting private league: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('not_league_owner')) {
        throw const LeagueNotOwnerException();
      }
      if (msg.contains('league_not_found')) {
        throw const LeagueNotFoundException();
      }
      throw LeagueGenericException(e.message);
    } catch (e, st) {
      AppLogger.error('Failed to delete private league $leagueId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> removeMemberFromPrivateLeague({
    required String leagueId,
    required String targetUserId,
    required String adminUserId,
  }) async {
    if (_supabase == null) {
      final league = _mockPrivateLeagues[leagueId];
      if (league != null && league.ownerId != adminUserId) {
        throw const LeagueNotOwnerException();
      }
      if (targetUserId == adminUserId) {
        throw const LeagueOwnerCannotBeRemovedException();
      }
      _mockLeagueMembers[leagueId]?.remove(targetUserId);
      return;
    }

    try {
      await _supabase.rpc('remove_private_league_member', params: {
        'p_league_id': leagueId,
        'p_target_user_id': targetUserId,
      });
    } on PostgrestException catch (e) {
      AppLogger.warning('Postgrest error removing member: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('not_league_owner')) {
        throw const LeagueNotOwnerException();
      }
      if (msg.contains('owner_cannot_be_removed')) {
        throw const LeagueOwnerCannotBeRemovedException();
      }
      throw LeagueGenericException(e.message);
    } catch (e, st) {
      AppLogger.error('Failed to remove member $targetUserId from league $leagueId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> leavePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    if (_supabase == null) {
      final league = _mockPrivateLeagues[leagueId];
      if (league != null && league.ownerId == userId) {
        final remaining = (_mockLeagueMembers[leagueId] ?? {}).where((id) => id != userId).toList();
        if (remaining.isNotEmpty) {
          _mockPrivateLeagues[leagueId] = league.copyWith(ownerId: remaining.first, adminId: remaining.first);
        } else {
          _mockPrivateLeagues.remove(leagueId);
        }
      }
      _mockLeagueMembers[leagueId]?.remove(userId);
      return;
    }

    try {
      await _supabase.rpc('leave_private_league', params: {
        'p_league_id': leagueId,
        'p_user_id': userId,
      });
    } on PostgrestException catch (e) {
      AppLogger.warning('Postgrest error leaving league: ${e.message}');
      throw LeagueGenericException(e.message);
    } catch (e, st) {
      AppLogger.error('Failed to leave private league $leagueId', e, st);
      rethrow;
    }
  }

  @override
  Future<List<LeagueMessage>> getLeagueMessages(String leagueId, {int limit = 50}) async {
    if (_supabase == null) {
      return List<LeagueMessage>.from(_mockLeagueMessages[leagueId] ?? []);
    }

    try {
      final response = await _supabase
          .from('league_messages')
          .select('''
            id,
            league_id,
            user_id,
            message,
            created_at,
            profile:profiles(username, avatar_url)
          ''')
          .eq('league_id', leagueId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>).map((row) {
        final rowMap = Map<String, dynamic>.from(row as Map);
        final profile = (rowMap['profile'] ?? rowMap['profiles']) as Map<String, dynamic>?;
        return LeagueMessage.fromJson({
          ...rowMap,
          'username': profile?['username'] ?? 'Player',
          'avatar_url': profile?['avatar_url'],
        });
      }).toList();
    } catch (e, st) {
      AppLogger.error('Failed to get league messages for $leagueId', e, st);
      return [];
    }
  }

  @override
  Future<LeagueMessage> sendLeagueMessage({
    required String leagueId,
    required String userId,
    required String message,
    String? username,
    String? avatarUrl,
  }) async {
    final cleanMessage = InputSanitizer.sanitizeChatMessage(message);
    if (cleanMessage.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    if (_supabase == null) {
      final newMsg = LeagueMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        leagueId: leagueId,
        userId: userId,
        message: cleanMessage,
        createdAt: DateTime.now(),
        username: username ?? 'You',
        avatarUrl: avatarUrl,
      );
      _mockLeagueMessages.putIfAbsent(leagueId, () => []).insert(0, newMsg);
      return newMsg;
    }

    try {
      final response = await _supabase
          .from('league_messages')
          .insert({
            'league_id': leagueId,
            'user_id': userId,
            'message': cleanMessage,
          })
          .select('''
            id,
            league_id,
            user_id,
            message,
            created_at,
            profile:profiles(username, avatar_url)
          ''')
          .single();

      final rowMap = Map<String, dynamic>.from(response);
      final profile = (rowMap['profile'] ?? rowMap['profiles']) as Map<String, dynamic>?;
      return LeagueMessage.fromJson({
        ...rowMap,
        'username': profile?['username'] ?? username ?? 'Player',
        'avatar_url': profile?['avatar_url'] ?? avatarUrl,
      });
    } catch (e, st) {
      AppLogger.error('Failed to send league message', e, st);
      rethrow;
    }
  }

  static String _resolveCompetitionId(String rawId) {
    final clean = rawId.trim().toLowerCase();
    switch (clean) {
      case 'la_liga':
      case '1':
        return '1';
      case 'premier_league':
      case '10':
        return '10';
      case 'serie_a':
      case '7':
        return '7';
      case 'bundesliga':
      case '8':
        return '8';
      case 'ligue_1':
      case '16':
        return '16';
      case 'champions_league':
      case '107':
        return '107';
      case 'europa_league':
      case '117':
        return '117';
      case 'conference_league':
      case '2492':
        return '2492';
      default:
        return rawId;
    }
  }
}
