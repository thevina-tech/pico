import 'package:freezed_annotation/freezed_annotation.dart';

part 'private_league.freezed.dart';
part 'private_league.g.dart';

/// Normalized domain model for the `private_leagues` table in Supabase.
@freezed
abstract class PrivateLeague with _$PrivateLeague {
  const factory PrivateLeague({
    required String id,
    required String name,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'admin_id') String? adminId,
    @JsonKey(name: 'competition_id') String? competitionId,
    @JsonKey(name: 'invite_code') required String inviteCode,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default('') String ownerName,
    @Default('') String competitionName,
    @Default(1) int memberCount,
    @Default('') String description,
  }) = _PrivateLeague;

  const PrivateLeague._();

  String get effectiveAdminId => adminId ?? ownerId;

  factory PrivateLeague.fromJson(Map<String, dynamic> json) =>
      _$PrivateLeagueFromJson(json);
}
