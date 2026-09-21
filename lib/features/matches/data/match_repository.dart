import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import '../domain/pico_match.dart';

part 'match_repository.g.dart';

/// Riverpod provider exposing the active [MatchRepository].
@Riverpod(keepAlive: true)
MatchRepository matchRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseMatchRepository(supabase);
}

/// Abstract contract for match retrieval.
abstract class MatchRepository {
  Future<List<PicoMatch>> getAllMatches();
  Future<List<PicoMatch>> getUpcomingMatches();
  Future<List<PicoMatch>> getFinishedMatches();
  Future<PicoMatch?> getHeroMatch();
  Future<List<String>> getCompetitions();
  Future<PicoMatch?> getMatchById(String id);
}

/// Production Supabase implementation querying the `matches`, `competitions`,
/// and `teams` normalized tables.
class SupabaseMatchRepository implements MatchRepository {
  SupabaseMatchRepository([this._supabase, MockMatchRepository? fallbackRepository])
      : _mockFallback = fallbackRepository ?? MockMatchRepository();

  final SupabaseClient? _supabase;
  final MockMatchRepository _mockFallback;

  @override
  Future<List<PicoMatch>> getAllMatches() async {
    if (_supabase == null) {
      return await _mockFallback.getAllMatches();
    }
    try {
      final response = await _supabase.from('matches').select('''
        id,
        provider_match_id,
        competition_id,
        home_team_id,
        away_team_id,
        kickoff_at,
        status,
        home_score,
        away_score,
        settled,
        competition:competitions(id, name, emblem_url),
        home_team:teams!matches_home_team_id_fkey(id, name, short_name, crest_url),
        away_team:teams!matches_away_team_id_fkey(id, name, short_name, crest_url)
      ''').order('kickoff_at', ascending: true);

      final list = (response as List<dynamic>)
          .map((row) => PicoMatch.fromJson(row as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        return list;
      }
      AppLogger.info('Supabase matches table is empty; using fallback data.');
      return await _mockFallback.getAllMatches();
    } catch (e, st) {
      AppLogger.error('Failed to query matches from Supabase; using fallback', e, st);
      return await _mockFallback.getAllMatches();
    }
  }

  @override
  Future<List<PicoMatch>> getUpcomingMatches() async {
    final all = await getAllMatches();
    return all.where((m) => m.status == MatchStatus.upcoming).toList();
  }

  @override
  Future<List<PicoMatch>> getFinishedMatches() async {
    final all = await getAllMatches();
    return all.where((m) => m.status == MatchStatus.finished).toList();
  }

  @override
  Future<PicoMatch?> getHeroMatch() async {
    final all = await getAllMatches();
    if (all.isEmpty) return null;
    return all.firstWhere(
      (m) =>
          m.competitionName.toLowerCase().contains('champions') &&
          m.status == MatchStatus.upcoming,
      orElse: () => all.firstWhere(
        (m) => m.status == MatchStatus.upcoming,
        orElse: () => all.first,
      ),
    );
  }

  @override
  Future<List<String>> getCompetitions() async {
    if (_supabase == null) {
      return await _mockFallback.getCompetitions();
    }
    try {
      final response = await _supabase
          .from('competitions')
          .select('name')
          .order('name', ascending: true);
      final comps = (response as List<dynamic>)
          .map((row) => (row as Map<String, dynamic>)['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
      if (comps.isNotEmpty) {
        return comps;
      }
    } catch (e, st) {
      AppLogger.error('Failed to load competitions from Supabase', e, st);
    }
    return await _mockFallback.getCompetitions();
  }

  @override
  Future<PicoMatch?> getMatchById(String id) async {
    final all = await getAllMatches();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Standalone mock repository for hermetic unit and widget testing.
class MockMatchRepository implements MatchRepository {
  List<PicoMatch>? _cache;

  @override
  Future<List<PicoMatch>> getAllMatches() async {
    if (_cache != null) return _cache!;
    try {
      final jsonString = await rootBundle.loadString('assets/mock/matches.json');
      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      final List<dynamic> rawMatches = data['matches'] as List<dynamic>? ?? [];
      _cache = rawMatches
          .map((m) => PicoMatch.fromJson(m as Map<String, dynamic>))
          .toList();
      return _cache!;
    } catch (e) {
      throw Exception('Failed to load mock matches: $e');
    }
  }

  @override
  Future<List<PicoMatch>> getUpcomingMatches() async {
    final all = await getAllMatches();
    return all.where((m) => m.status == MatchStatus.upcoming).toList();
  }

  @override
  Future<List<PicoMatch>> getFinishedMatches() async {
    final all = await getAllMatches();
    return all.where((m) => m.status == MatchStatus.finished).toList();
  }

  @override
  Future<PicoMatch?> getHeroMatch() async {
    final all = await getAllMatches();
    if (all.isEmpty) return null;
    return all.firstWhere(
      (m) =>
          m.competitionName.toLowerCase().contains('champions') &&
          m.status == MatchStatus.upcoming,
      orElse: () => all.firstWhere(
        (m) => m.status == MatchStatus.upcoming,
        orElse: () => all.first,
      ),
    );
  }

  @override
  Future<List<String>> getCompetitions() async {
    final all = await getAllMatches();
    final competitions = <String>{};
    for (final match in all) {
      if (match.competitionName.isNotEmpty) {
        competitions.add(match.competitionName);
      }
    }
    return competitions.toList();
  }

  @override
  Future<PicoMatch?> getMatchById(String id) async {
    final all = await getAllMatches();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
