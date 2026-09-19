import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/pico_match.dart';

part 'match_repository.g.dart';

@Riverpod(keepAlive: true)
MatchRepository matchRepository(Ref ref) {
  return MockMatchRepository();
}

abstract class MatchRepository {
  Future<List<PicoMatch>> getAllMatches();
  Future<List<PicoMatch>> getUpcomingMatches();
  Future<List<PicoMatch>> getFinishedMatches();
  Future<PicoMatch?> getHeroMatch();
  Future<List<String>> getCompetitions();
  Future<PicoMatch?> getMatchById(String id);
}

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
    // Prefer Champions League or high-profile upcoming match, else first match
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
