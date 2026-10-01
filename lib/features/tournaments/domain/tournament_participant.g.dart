// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentParticipant _$TournamentParticipantFromJson(
  Map<String, dynamic> json,
) => _TournamentParticipant(
  tournamentId: json['tournament_id'] as String,
  userId: json['user_id'] as String,
  picoPoints: (json['pico_points'] as num?)?.toInt() ?? 0,
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  tournament: json['tournament'] == null
      ? null
      : Tournament.fromJson(json['tournament'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TournamentParticipantToJson(
  _TournamentParticipant instance,
) => <String, dynamic>{
  'tournament_id': instance.tournamentId,
  'user_id': instance.userId,
  'pico_points': instance.picoPoints,
  'joined_at': instance.joinedAt?.toIso8601String(),
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
  'tournament': instance.tournament,
};
