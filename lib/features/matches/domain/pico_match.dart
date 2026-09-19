import 'package:flutter/foundation.dart';

enum MatchStatus { upcoming, locked, live, finished }

@immutable
class PicoMatch {
  final String id;
  final String competitionName;
  final String competitionBadgeUrl;
  final String homeTeamName;
  final String homeTeamCode;
  final String homeTeamBadgeUrl;
  final String awayTeamName;
  final String awayTeamCode;
  final String awayTeamBadgeUrl;
  final DateTime kickoffAt;
  final DateTime lockAt;
  final MatchStatus status;
  final int? homeScore;
  final int? awayScore;
  final String? round;
  final String? leagueId;
  final String? rawResult;

  PicoMatch({
    required this.id,
    required this.competitionName,
    required this.competitionBadgeUrl,
    required this.homeTeamName,
    required this.homeTeamCode,
    required this.homeTeamBadgeUrl,
    required this.awayTeamName,
    required this.awayTeamCode,
    required this.awayTeamBadgeUrl,
    required this.kickoffAt,
    DateTime? lockAt,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.round,
    this.leagueId,
    this.rawResult,
  }) : lockAt = lockAt ?? kickoffAt.subtract(const Duration(minutes: 10));

  bool get isLocked =>
      DateTime.now().isAfter(lockAt) ||
      status == MatchStatus.locked ||
      status == MatchStatus.live ||
      status == MatchStatus.finished;

  String get kickoffTimeFormatted =>
      '${kickoffAt.hour.toString().padLeft(2, '0')}:${kickoffAt.minute.toString().padLeft(2, '0')}';

  String get closesAtTimeFormatted =>
      '${lockAt.hour.toString().padLeft(2, '0')}:${lockAt.minute.toString().padLeft(2, '0')}';

  factory PicoMatch.fromJson(Map<String, dynamic> json) {
    final dateStr = (json['date'] as String? ?? '2025-01-01').replaceAll('/', '-');
    final hour = int.parse(json['hour']?.toString() ?? '0');
    final minute = int.parse(json['minute']?.toString() ?? '0');
    final kickoff = DateTime.tryParse(dateStr)?.add(Duration(hours: hour, minutes: minute)) ??
        DateTime.now().add(const Duration(hours: 2));

    // Strip BeSoccer query parameters (like &v=) before caching/passing
    String cleanUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      return url.split('&v=').first;
    }

    String extractCode(String? abbr, String? name, String fallback) {
      if (abbr != null && abbr.trim().isNotEmpty) {
        return abbr.trim().toUpperCase();
      }
      if (name != null && name.trim().length >= 3) {
        return name.trim().substring(0, 3).toUpperCase();
      }
      return fallback;
    }

    // Status: 1 = finished, 0 = live, -1 = upcoming
    final rawStatus = json['status'];
    final MatchStatus matchStatus;
    if (rawStatus == 1) {
      matchStatus = MatchStatus.finished;
    } else if (rawStatus == 0) {
      matchStatus = MatchStatus.live;
    } else {
      matchStatus = MatchStatus.upcoming;
    }

    // Parse score from result (e.g. "2-1", "0-0", or "x-x")
    int? parsedHomeScore;
    int? parsedAwayScore;
    final resultStr = json['result']?.toString();
    if (resultStr != null && resultStr.contains('-')) {
      final parts = resultStr.split('-');
      if (parts.length == 2) {
        parsedHomeScore = int.tryParse(parts[0].trim());
        parsedAwayScore = int.tryParse(parts[1].trim());
      }
    }

    final localName = (json['local'] as String?) ?? '';
    final visitorName = (json['visitor'] as String?) ?? '';

    return PicoMatch(
      id: json['id'].toString(),
      competitionName: json['competition_name'] ?? '',
      competitionBadgeUrl: cleanUrl(json['logo']),
      homeTeamName: localName,
      homeTeamCode: extractCode(json['local_abbr'], localName, 'HOM'),
      homeTeamBadgeUrl: cleanUrl(json['local_shield']),
      awayTeamName: visitorName,
      awayTeamCode: extractCode(json['visitor_abbr'], visitorName, 'AWY'),
      awayTeamBadgeUrl: cleanUrl(json['visitor_shield']),
      kickoffAt: kickoff,
      status: matchStatus,
      homeScore: parsedHomeScore,
      awayScore: parsedAwayScore,
      round: json['round']?.toString(),
      leagueId: json['league_id']?.toString(),
      rawResult: resultStr,
    );
  }

  PicoMatch copyWith({
    String? id,
    String? competitionName,
    String? competitionBadgeUrl,
    String? homeTeamName,
    String? homeTeamCode,
    String? homeTeamBadgeUrl,
    String? awayTeamName,
    String? awayTeamCode,
    String? awayTeamBadgeUrl,
    DateTime? kickoffAt,
    DateTime? lockAt,
    MatchStatus? status,
    int? homeScore,
    int? awayScore,
    String? round,
    String? leagueId,
    String? rawResult,
  }) {
    return PicoMatch(
      id: id ?? this.id,
      competitionName: competitionName ?? this.competitionName,
      competitionBadgeUrl: competitionBadgeUrl ?? this.competitionBadgeUrl,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      homeTeamCode: homeTeamCode ?? this.homeTeamCode,
      homeTeamBadgeUrl: homeTeamBadgeUrl ?? this.homeTeamBadgeUrl,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      awayTeamCode: awayTeamCode ?? this.awayTeamCode,
      awayTeamBadgeUrl: awayTeamBadgeUrl ?? this.awayTeamBadgeUrl,
      kickoffAt: kickoffAt ?? this.kickoffAt,
      lockAt: lockAt ?? this.lockAt,
      status: status ?? this.status,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      round: round ?? this.round,
      leagueId: leagueId ?? this.leagueId,
      rawResult: rawResult ?? this.rawResult,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PicoMatch &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}