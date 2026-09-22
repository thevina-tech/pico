import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

/// Normalized domain model for the `competitions` table in Supabase.
@freezed
abstract class Competition with _$Competition {
  const factory Competition({
    required String id,
    @Default('') String name,
    @JsonKey(name: 'emblem_url') String? emblemUrl,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}

extension CompetitionExtension on Competition {
  String get flag {
    switch (id) {
      case '1':
        return '🇪🇸';
      case '10':
        return '🏴󠁧󠁢󠁥󠁮󠁧󠁿';
      case '7':
        return '🇮🇹';
      case '8':
        return '🇩🇪';
      case '16':
        return '🇫🇷';
      case '107':
        return '⭐';
      case '117':
        return '🟠';
      case '2492':
        return '🟢';
      default:
        return '🏆';
    }
  }

  String get shortName {
    switch (id) {
      case '1':
        return 'La Liga';
      case '10':
        return 'Premier League';
      case '7':
        return 'Serie A';
      case '8':
        return 'Bundesliga';
      case '16':
        return 'Ligue 1';
      case '107':
        return 'UCL';
      case '117':
        return 'UEL';
      case '2492':
        return 'UECL';
      default:
        return name;
    }
  }
}
