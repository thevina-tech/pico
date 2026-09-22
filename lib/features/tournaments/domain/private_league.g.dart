// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_league.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrivateLeague _$PrivateLeagueFromJson(Map<String, dynamic> json) =>
    _PrivateLeague(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      competitionId: json['competition_id'] as String?,
      inviteCode: json['invite_code'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      ownerName: json['ownerName'] as String? ?? '',
      competitionName: json['competitionName'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PrivateLeagueToJson(_PrivateLeague instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner_id': instance.ownerId,
      'competition_id': instance.competitionId,
      'invite_code': instance.inviteCode,
      'created_at': instance.createdAt?.toIso8601String(),
      'ownerName': instance.ownerName,
      'competitionName': instance.competitionName,
      'memberCount': instance.memberCount,
    };
