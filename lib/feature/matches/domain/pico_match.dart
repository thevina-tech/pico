enum MatchStatus { upcoming, locked, live, finished }

class PicoMatch {
  final String id;
  final String competitionName;
  final String competitionBadgeUrl;
  final String homeTeamName;
  final String homeTeamBadgeUrl;
  final String awayTeamName;
  final String awayTeamBadgeUrl;
  final DateTime kickoffAt;
  final DateTime lockAt;
  final MatchStatus status;
  final int? homeScore;
  final int? awayScore;

  PicoMatch({
    required this.id,
    required this.competitionName,
    required this.competitionBadgeUrl,
    required this.homeTeamName,
    required this.homeTeamBadgeUrl,
    required this.awayTeamName,
    required this.awayTeamBadgeUrl,
    required this.kickoffAt,
    required this.status,
    this.homeScore,
    this.awayScore,
  }) : lockAt = kickoffAt.subtract(const Duration(minutes: 10)); // Locks 10 min prior

  bool get isLocked => DateTime.now().isAfter(lockAt) || status != MatchStatus.upcoming;

  factory PicoMatch.fromJson(Map<String, dynamic> json) {
    final dateStr = (json['date'] as String).replaceAll('/', '-');
    final hour = int.parse(json['hour']?.toString() ?? '0');
    final minute = int.parse(json['minute']?.toString() ?? '0');
    final kickoff = DateTime.parse(dateStr).add(Duration(hours: hour, minutes: minute));
    
    // Safely strip any BeSoccer query parameters from images
    String cleanUrl(String? url) => url?.split('&v=').first ?? '';

    return PicoMatch(
      id: json['id'].toString(),
      competitionName: json['competition_name'] ?? '',
      competitionBadgeUrl: cleanUrl(json['logo']),
      homeTeamName: json['local'] ?? '',
      homeTeamBadgeUrl: cleanUrl(json['local_shield']),
      awayTeamName: json['visitor'] ?? '',
      awayTeamBadgeUrl: cleanUrl(json['visitor_shield']),
      kickoffAt: kickoff,
      status: json['status'] == 1 ? MatchStatus.finished : MatchStatus.upcoming,
    );
  }
}