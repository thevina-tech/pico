// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_league_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrivateLeagueMember _$PrivateLeagueMemberFromJson(Map<String, dynamic> json) =>
    _PrivateLeagueMember(
      privateLeagueId: json['private_league_id'] as String,
      userId: json['user_id'] as String,
      picoPoints: (json['pico_points'] as num?)?.toInt() ?? 0,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$PrivateLeagueMemberToJson(
  _PrivateLeagueMember instance,
) => <String, dynamic>{
  'private_league_id': instance.privateLeagueId,
  'user_id': instance.userId,
  'pico_points': instance.picoPoints,
  'joined_at': instance.joinedAt?.toIso8601String(),
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
};
