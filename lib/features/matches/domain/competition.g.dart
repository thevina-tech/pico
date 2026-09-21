// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Competition _$CompetitionFromJson(Map<String, dynamic> json) => _Competition(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  emblemUrl: json['emblem_url'] as String?,
);

Map<String, dynamic> _$CompetitionToJson(_Competition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emblem_url': instance.emblemUrl,
    };
