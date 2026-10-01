import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament.freezed.dart';
part 'tournament.g.dart';

/// Normalized domain model for the `tournaments` table in Supabase.
@freezed
abstract class Tournament with _$Tournament {
  const factory Tournament({
    required String id,
    @Default('') String name,
    @JsonKey(name: 'competition_id') @Default('') String competitionId,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);
}
