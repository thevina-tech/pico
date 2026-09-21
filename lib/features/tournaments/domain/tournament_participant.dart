import 'package:freezed_annotation/freezed_annotation.dart';
import 'tournament.dart';

part 'tournament_participant.freezed.dart';
part 'tournament_participant.g.dart';

/// Normalized domain model for the `tournament_participants` table in Supabase.
@freezed
abstract class TournamentParticipant with _$TournamentParticipant {
  const factory TournamentParticipant({
    @JsonKey(name: 'tournament_id') required String tournamentId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'pico_points') @Default(0) int picoPoints,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    Tournament? tournament,
  }) = _TournamentParticipant;

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) =>
      _$TournamentParticipantFromJson(json);
}
