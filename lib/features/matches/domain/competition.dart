import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

/// Normalized domain model for the `competitions` table in Supabase.
@freezed
abstract class Competition with _$Competition {
  const factory Competition({
    required String id,
    @Default('') String name,
    @JsonKey(name: 'short_name') String? shortName,
    @Default('🏆') String flag,
    @JsonKey(name: 'emblem_url') String? emblemUrl,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}

extension CompetitionExtension on Competition {
  String get displayFlag => flag.isNotEmpty ? flag : '🏆';
  String get displayName => shortName != null && shortName!.isNotEmpty ? shortName! : name;
}
