import 'package:freezed_annotation/freezed_annotation.dart';

part 'private_league_member.freezed.dart';
part 'private_league_member.g.dart';

/// Normalized domain model for the `private_league_members` table in Supabase.
@freezed
abstract class PrivateLeagueMember with _$PrivateLeagueMember {
  const factory PrivateLeagueMember({
    @JsonKey(name: 'private_league_id') required String privateLeagueId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'pico_points') @Default(0) int picoPoints,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _PrivateLeagueMember;

  factory PrivateLeagueMember.fromJson(Map<String, dynamic> json) =>
      _$PrivateLeagueMemberFromJson(json);
}
