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

  static String formatDateTimeWithContext(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = targetDate.difference(today).inDays;

    final timeString =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (differenceInDays == 0) {
      return 'Today $timeString';
    } else if (differenceInDays == 1) {
      return 'Tomorrow $timeString';
    } else if (differenceInDays == -1) {
      return 'Yesterday $timeString';
    } else if (differenceInDays > 1 && differenceInDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekday = weekdays[dateTime.weekday - 1];
      return '$weekday $timeString';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      return '$month ${dateTime.day}, $timeString';
    }
  }

  String get kickoffTimeFormatted => formatDateTimeWithContext(kickoffAt);

  String get closesAtTimeFormatted => formatDateTimeWithContext(effectiveLockAt);

  String get kickoffTimeOnly =>
      '${kickoffAt.hour.toString().padLeft(2, '0')}:${kickoffAt.minute.toString().padLeft(2, '0')}';

  String get closesAtTimeOnly =>
      '${effectiveLockAt.hour.toString().padLeft(2, '0')}:${effectiveLockAt.minute.toString().padLeft(2, '0')}';

  /// Whether this match is in the rolling teaser window (between 7 and 14 days out).
  bool get isTeaser {
    if (status != MatchStatus.upcoming) return false;
    final now = DateTime.now();
    final sevenDays = now.add(const Duration(days: 7));
    final fourteenDays = now.add(const Duration(days: 14));
    return kickoffAt.isAfter(sevenDays) && kickoffAt.isBefore(fourteenDays);
  }

  /// Whether the rolling prediction window is currently open (upcoming and <= 7 days before kickoff).
  bool get isPredictionWindowOpen {
    if (status != MatchStatus.upcoming) return false;
    final now = DateTime.now();
    final sevenDays = now.add(const Duration(days: 7));
    return !kickoffAt.isAfter(sevenDays) && !isLocked;
  }

  /// The time remaining until the 7-day prediction window opens.
  Duration get teaserCountdown {
    final opensAt = kickoffAt.subtract(const Duration(days: 7));
    final diff = opensAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formatted teaser countdown (e.g., "2d", "14h", "45m").
  String get teaserCountdownShort {
    final diff = teaserCountdown;
    if (diff.inDays >= 1) {
      return '${diff.inDays}d';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h';
    } else {
      final mins = diff.inMinutes.clamp(1, 60);
      return '${mins}m';
    }
  }

  /// Calculates Pico Points outcome for this match given predicted scores.
  /// Rule 13: Exact score = 5 total, Correct winner = 3 total, Wrong = 0.
  int? calculateSettlementPoints(int? predHome, int? predAway) {
    if (status != MatchStatus.finished || homeScore == null || awayScore == null) {
      return null;
    }
    if (predHome == null || predAway == null) {
      return null;
    }
    if (predHome == homeScore && predAway == awayScore) {
      return 5;
    }
    final actualWinner = homeScore! > awayScore!
        ? 'home'
        : (awayScore! > homeScore! ? 'away' : 'draw');
    final predWinner = predHome > predAway
        ? 'home'
        : (predAway > predHome ? 'away' : 'draw');
    if (actualWinner == predWinner) {
      return 3;
    }
    return 0;
  }

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