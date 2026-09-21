// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Prediction _$PredictionFromJson(Map<String, dynamic> json) => _Prediction(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  matchId: json['match_id'] as String,
  homeScore: (json['home_score'] as num).toInt(),
  awayScore: (json['away_score'] as num).toInt(),
  predictedWinner: json['predicted_winner'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PredictionToJson(_Prediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'match_id': instance.matchId,
      'home_score': instance.homeScore,
      'away_score': instance.awayScore,
      'predicted_winner': instance.predictedWinner,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
