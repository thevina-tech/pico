import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/pico_match.dart';

abstract class MatchRepository {
  Future<List<PicoMatch>> getUpcomingMatches();
}

class MockMatchRepository implements MatchRepository {
  List<PicoMatch>? _cache;

  @override
  Future<List<PicoMatch>> getUpcomingMatches() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString('assets/mock/matches.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> rawMatches = data['matches'];
    _cache = rawMatches.map((m) => PicoMatch.fromJson(m as Map<String, dynamic>)).toList();
    return _cache!;
  }
}