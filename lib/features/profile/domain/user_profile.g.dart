// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  email: json['email'] as String?,
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  level: (json['level'] as num?)?.toInt() ?? 1,
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
  currentDivisionKey: json['current_division_key'] as String?,
  privateLeaguesCreated:
      (json['private_leagues_created'] as num?)?.toInt() ?? 0,
  favoriteTeamId: json['favorite_team_id'] as String?,
  favoriteTeamIds:
      (json['favorite_team_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  favoriteLeagueIds:
      (json['favorite_league_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'level': instance.level,
      'xp': instance.xp,
      'streak': instance.streak,
      'coins': instance.coins,
      'total_points': instance.totalPoints,
      'current_division_key': instance.currentDivisionKey,
      'private_leagues_created': instance.privateLeaguesCreated,
      'favorite_team_id': instance.favoriteTeamId,
      'favorite_team_ids': instance.favoriteTeamIds,
      'favorite_league_ids': instance.favoriteLeagueIds,
      'created_at': instance.createdAt?.toIso8601String(),
    };
