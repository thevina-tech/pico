import 'package:freezed_annotation/freezed_annotation.dart';
import 'competition.dart';
import 'team.dart';

part 'pico_match.freezed.dart';

/// Match lifecycle status corresponding to `match_status` Postgres ENUM.
enum MatchStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('live')
  live,
  @JsonValue('finished')
  finished,
  @JsonValue('postponed')
  postponed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('locked')
  locked,
}

/// Normalized domain model for the `matches` table in Supabase.
@freezed
abstract class PicoMatch with _$PicoMatch {
  const PicoMatch._();

  const factory PicoMatch({
    required String id,
    @JsonKey(name: 'provider_match_id') String? providerMatchId,
    @JsonKey(name: 'competition_id') String? competitionId,
    @JsonKey(name: 'home_team_id') String? homeTeamId,
    @JsonKey(name: 'away_team_id') String? awayTeamId,
    @JsonKey(name: 'kickoff_at') required DateTime kickoffAt,
    @Default(MatchStatus.upcoming) MatchStatus status,
    @JsonKey(name: 'home_score') int? homeScore,
    @JsonKey(name: 'away_score') int? awayScore,
    @Default(false) bool settled,
    DateTime? lockAt,
    @Default('') String competitionName,
    @Default('') String competitionBadgeUrl,
    @Default('') String homeTeamName,
    @Default('') String homeTeamCode,
    @Default('') String homeTeamBadgeUrl,
    @Default('') String awayTeamName,
    @Default('') String awayTeamCode,
    @Default('') String awayTeamBadgeUrl,
    String? round,
    String? leagueId,
    String? rawResult,
    Competition? competition,
    Team? homeTeam,
    Team? awayTeam,
  }) = _PicoMatch;

  DateTime get effectiveLockAt =>
      lockAt ?? kickoffAt.subtract(const Duration(minutes: 10));

  bool get isLocked =>
      DateTime.now().isAfter(effectiveLockAt) ||
      status == MatchStatus.locked ||
      status == MatchStatus.live ||
      status == MatchStatus.finished;

  String get kickoffTimeFormatted =>
      '${kickoffAt.hour.toString().padLeft(2, '0')}:${kickoffAt.minute.toString().padLeft(2, '0')}';

  String get closesAtTimeFormatted =>
      '${effectiveLockAt.hour.toString().padLeft(2, '0')}:${effectiveLockAt.minute.toString().padLeft(2, '0')}';

  factory PicoMatch.fromJson(Map<String, dynamic> json) {
    String cleanUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      return url.replaceAll(RegExp(r'[?&]v=[^&#]*'), '');
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

    // 1. Check if this is Supabase normalized structure (contains 'kickoff_at' or joined tables)
    if (json.containsKey('kickoff_at')) {
      final id = json['id']?.toString() ?? '';
      final providerId = json['provider_match_id']?.toString();
      final compId = json['competition_id']?.toString();
      final hId = json['home_team_id']?.toString();
      final aId = json['away_team_id']?.toString();
      final kickoff = DateTime.tryParse(json['kickoff_at']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 2));

      // Joined relations
      Competition? comp;
      if (json['competition'] is Map<String, dynamic>) {
        comp = Competition.fromJson(json['competition'] as Map<String, dynamic>);
      }

      Team? hTeam;
      if (json['home_team'] is Map<String, dynamic>) {
        hTeam = Team.fromJson(json['home_team'] as Map<String, dynamic>);
      }

      Team? aTeam;
      if (json['away_team'] is Map<String, dynamic>) {
        aTeam = Team.fromJson(json['away_team'] as Map<String, dynamic>);
      }

      final rawStatus = json['status']?.toString();
      MatchStatus status = MatchStatus.upcoming;
      if (rawStatus == 'finished') {
        status = MatchStatus.finished;
      } else if (rawStatus == 'live') {
        status = MatchStatus.live;
      } else if (rawStatus == 'postponed') {
        status = MatchStatus.postponed;
      } else if (rawStatus == 'cancelled') {
        status = MatchStatus.cancelled;
      } else if (rawStatus == 'locked') {
        status = MatchStatus.locked;
      }

      final homeName = hTeam?.name ?? json['home_team_name']?.toString() ?? '';
      final awayName = aTeam?.name ?? json['away_team_name']?.toString() ?? '';

      return PicoMatch(
        id: id,
        providerMatchId: providerId,
        competitionId: compId,
        homeTeamId: hId,
        awayTeamId: aId,
        kickoffAt: kickoff,
        status: status,
        homeScore: json['home_score'] as int?,
        awayScore: json['away_score'] as int?,
        settled: json['settled'] as bool? ?? false,
        competitionName: comp?.name ?? json['competition_name']?.toString() ?? '',
        competitionBadgeUrl: cleanUrl(comp?.emblemUrl ?? json['competition_badge_url']?.toString()),
        homeTeamName: homeName,
        homeTeamCode: hTeam?.shortName ?? extractCode(null, homeName, 'HOM'),
        homeTeamBadgeUrl: cleanUrl(hTeam?.crestUrl ?? json['home_team_badge_url']?.toString()),
        awayTeamName: awayName,
        awayTeamCode: aTeam?.shortName ?? extractCode(null, awayName, 'AWY'),
        awayTeamBadgeUrl: cleanUrl(aTeam?.crestUrl ?? json['away_team_badge_url']?.toString()),
        competition: comp,
        homeTeam: hTeam,
        awayTeam: aTeam,
      );
    }

    // 2. BeSoccer / Mock JSON format
    final dateStr = (json['date'] as String? ?? '2025-01-01').replaceAll('/', '-');
    final hour = int.tryParse(json['hour']?.toString() ?? '0') ?? 0;
    final minute = int.tryParse(json['minute']?.toString() ?? '0') ?? 0;
    final kickoff = DateTime.tryParse(dateStr)?.add(Duration(hours: hour, minutes: minute)) ??
        DateTime.now().add(const Duration(hours: 2));

    final rawStatus = json['status'];
    MatchStatus matchStatus;
    if (rawStatus == 1 || rawStatus == '1') {
      matchStatus = MatchStatus.finished;
    } else if (rawStatus == 0 || rawStatus == '0') {
      matchStatus = MatchStatus.live;
    } else {
      matchStatus = MatchStatus.upcoming;
    }

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
      id: json['id']?.toString() ?? '',
      providerMatchId: json['id']?.toString(),
      competitionId: json['league_id']?.toString(),
      competitionName: json['competition_name']?.toString() ?? '',
      competitionBadgeUrl: cleanUrl(json['logo']?.toString()),
      homeTeamName: localName,
      homeTeamCode: extractCode(json['local_abbr']?.toString(), localName, 'HOM'),
      homeTeamBadgeUrl: cleanUrl(json['local_shield']?.toString()),
      awayTeamName: visitorName,
      awayTeamCode: extractCode(json['visitor_abbr']?.toString(), visitorName, 'AWY'),
      awayTeamBadgeUrl: cleanUrl(json['visitor_shield']?.toString()),
      kickoffAt: kickoff,
      status: matchStatus,
      homeScore: parsedHomeScore,
      awayScore: parsedAwayScore,
      round: json['round']?.toString(),
      leagueId: json['league_id']?.toString(),
      rawResult: resultStr,
    );
  }
}