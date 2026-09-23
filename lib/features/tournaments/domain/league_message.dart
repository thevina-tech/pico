import 'package:freezed_annotation/freezed_annotation.dart';

part 'league_message.freezed.dart';
part 'league_message.g.dart';

/// Normalized domain model for the `league_messages` table in Supabase.
@freezed
abstract class LeagueMessage with _$LeagueMessage {
  const factory LeagueMessage({
    required String id,
    @JsonKey(name: 'league_id') required String leagueId,
    @JsonKey(name: 'user_id') required String userId,
    required String message,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _LeagueMessage;

  factory LeagueMessage.fromJson(Map<String, dynamic> json) =>
      _$LeagueMessageFromJson(json);
}
