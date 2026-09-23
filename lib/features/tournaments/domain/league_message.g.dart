// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeagueMessage _$LeagueMessageFromJson(Map<String, dynamic> json) =>
    _LeagueMessage(
      id: json['id'] as String,
      leagueId: json['league_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$LeagueMessageToJson(_LeagueMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'league_id': instance.leagueId,
      'user_id': instance.userId,
      'message': instance.message,
      'created_at': instance.createdAt.toIso8601String(),
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };
