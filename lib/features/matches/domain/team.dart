import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

/// Normalized domain model for the `teams` table in Supabase.
@freezed
abstract class Team with _$Team {
  const factory Team({
    required String id,
    @Default('') String name,
    @JsonKey(name: 'short_name') String? shortName,
    @JsonKey(name: 'crest_url') String? crestUrl,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}
