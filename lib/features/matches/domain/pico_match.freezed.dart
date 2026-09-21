// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pico_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PicoMatch {

 String get id;@JsonKey(name: 'provider_match_id') String? get providerMatchId;@JsonKey(name: 'competition_id') String? get competitionId;@JsonKey(name: 'home_team_id') String? get homeTeamId;@JsonKey(name: 'away_team_id') String? get awayTeamId;@JsonKey(name: 'kickoff_at') DateTime get kickoffAt; MatchStatus get status;@JsonKey(name: 'home_score') int? get homeScore;@JsonKey(name: 'away_score') int? get awayScore; bool get settled; DateTime? get lockAt; String get competitionName; String get competitionBadgeUrl; String get homeTeamName; String get homeTeamCode; String get homeTeamBadgeUrl; String get awayTeamName; String get awayTeamCode; String get awayTeamBadgeUrl; String? get round; String? get leagueId; String? get rawResult; Competition? get competition; Team? get homeTeam; Team? get awayTeam;
/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PicoMatchCopyWith<PicoMatch> get copyWith => _$PicoMatchCopyWithImpl<PicoMatch>(this as PicoMatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PicoMatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PicoMatch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.providerMatchId, _this.providerMatchId) || other.providerMatchId == _this.providerMatchId)&&(identical(other.competitionId, _this.competitionId) || other.competitionId == _this.competitionId)&&(identical(other.homeTeamId, _this.homeTeamId) || other.homeTeamId == _this.homeTeamId)&&(identical(other.awayTeamId, _this.awayTeamId) || other.awayTeamId == _this.awayTeamId)&&(identical(other.kickoffAt, _this.kickoffAt) || other.kickoffAt == _this.kickoffAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.homeScore, _this.homeScore) || other.homeScore == _this.homeScore)&&(identical(other.awayScore, _this.awayScore) || other.awayScore == _this.awayScore)&&(identical(other.settled, _this.settled) || other.settled == _this.settled)&&(identical(other.lockAt, _this.lockAt) || other.lockAt == _this.lockAt)&&(identical(other.competitionName, _this.competitionName) || other.competitionName == _this.competitionName)&&(identical(other.competitionBadgeUrl, _this.competitionBadgeUrl) || other.competitionBadgeUrl == _this.competitionBadgeUrl)&&(identical(other.homeTeamName, _this.homeTeamName) || other.homeTeamName == _this.homeTeamName)&&(identical(other.homeTeamCode, _this.homeTeamCode) || other.homeTeamCode == _this.homeTeamCode)&&(identical(other.homeTeamBadgeUrl, _this.homeTeamBadgeUrl) || other.homeTeamBadgeUrl == _this.homeTeamBadgeUrl)&&(identical(other.awayTeamName, _this.awayTeamName) || other.awayTeamName == _this.awayTeamName)&&(identical(other.awayTeamCode, _this.awayTeamCode) || other.awayTeamCode == _this.awayTeamCode)&&(identical(other.awayTeamBadgeUrl, _this.awayTeamBadgeUrl) || other.awayTeamBadgeUrl == _this.awayTeamBadgeUrl)&&(identical(other.round, _this.round) || other.round == _this.round)&&(identical(other.leagueId, _this.leagueId) || other.leagueId == _this.leagueId)&&(identical(other.rawResult, _this.rawResult) || other.rawResult == _this.rawResult)&&(identical(other.competition, _this.competition) || other.competition == _this.competition)&&(identical(other.homeTeam, _this.homeTeam) || other.homeTeam == _this.homeTeam)&&(identical(other.awayTeam, _this.awayTeam) || other.awayTeam == _this.awayTeam));
}


@override
int get hashCode {
  final _this = this as PicoMatch;
  return Object.hashAll([runtimeType,_this.id,_this.providerMatchId,_this.competitionId,_this.homeTeamId,_this.awayTeamId,_this.kickoffAt,_this.status,_this.homeScore,_this.awayScore,_this.settled,_this.lockAt,_this.competitionName,_this.competitionBadgeUrl,_this.homeTeamName,_this.homeTeamCode,_this.homeTeamBadgeUrl,_this.awayTeamName,_this.awayTeamCode,_this.awayTeamBadgeUrl,_this.round,_this.leagueId,_this.rawResult,_this.competition,_this.homeTeam,_this.awayTeam]);
}

@override
String toString() {
  final _this = this as PicoMatch;
  return 'PicoMatch(id: ${_this.id}, providerMatchId: ${_this.providerMatchId}, competitionId: ${_this.competitionId}, homeTeamId: ${_this.homeTeamId}, awayTeamId: ${_this.awayTeamId}, kickoffAt: ${_this.kickoffAt}, status: ${_this.status}, homeScore: ${_this.homeScore}, awayScore: ${_this.awayScore}, settled: ${_this.settled}, lockAt: ${_this.lockAt}, competitionName: ${_this.competitionName}, competitionBadgeUrl: ${_this.competitionBadgeUrl}, homeTeamName: ${_this.homeTeamName}, homeTeamCode: ${_this.homeTeamCode}, homeTeamBadgeUrl: ${_this.homeTeamBadgeUrl}, awayTeamName: ${_this.awayTeamName}, awayTeamCode: ${_this.awayTeamCode}, awayTeamBadgeUrl: ${_this.awayTeamBadgeUrl}, round: ${_this.round}, leagueId: ${_this.leagueId}, rawResult: ${_this.rawResult}, competition: ${_this.competition}, homeTeam: ${_this.homeTeam}, awayTeam: ${_this.awayTeam})';
}


}

/// @nodoc
abstract mixin class $PicoMatchCopyWith<$Res>  {
  factory $PicoMatchCopyWith(PicoMatch value, $Res Function(PicoMatch) _then) = _$PicoMatchCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'provider_match_id') String? providerMatchId,@JsonKey(name: 'competition_id') String? competitionId,@JsonKey(name: 'home_team_id') String? homeTeamId,@JsonKey(name: 'away_team_id') String? awayTeamId,@JsonKey(name: 'kickoff_at') DateTime kickoffAt, MatchStatus status,@JsonKey(name: 'home_score') int? homeScore,@JsonKey(name: 'away_score') int? awayScore, bool settled, DateTime? lockAt, String competitionName, String competitionBadgeUrl, String homeTeamName, String homeTeamCode, String homeTeamBadgeUrl, String awayTeamName, String awayTeamCode, String awayTeamBadgeUrl, String? round, String? leagueId, String? rawResult, Competition? competition, Team? homeTeam, Team? awayTeam
});


$CompetitionCopyWith<$Res>? get competition;$TeamCopyWith<$Res>? get homeTeam;$TeamCopyWith<$Res>? get awayTeam;

}
/// @nodoc
class _$PicoMatchCopyWithImpl<$Res>
    implements $PicoMatchCopyWith<$Res> {
  _$PicoMatchCopyWithImpl(this._self, this._then);

  final PicoMatch _self;
  final $Res Function(PicoMatch) _then;

/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? providerMatchId = freezed,Object? competitionId = freezed,Object? homeTeamId = freezed,Object? awayTeamId = freezed,Object? kickoffAt = null,Object? status = null,Object? homeScore = freezed,Object? awayScore = freezed,Object? settled = null,Object? lockAt = freezed,Object? competitionName = null,Object? competitionBadgeUrl = null,Object? homeTeamName = null,Object? homeTeamCode = null,Object? homeTeamBadgeUrl = null,Object? awayTeamName = null,Object? awayTeamCode = null,Object? awayTeamBadgeUrl = null,Object? round = freezed,Object? leagueId = freezed,Object? rawResult = freezed,Object? competition = freezed,Object? homeTeam = freezed,Object? awayTeam = freezed,}) {
  return _then(PicoMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerMatchId: freezed == providerMatchId ? _self.providerMatchId : providerMatchId // ignore: cast_nullable_to_non_nullable
as String?,competitionId: freezed == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String?,homeTeamId: freezed == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String?,awayTeamId: freezed == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String?,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,settled: null == settled ? _self.settled : settled // ignore: cast_nullable_to_non_nullable
as bool,lockAt: freezed == lockAt ? _self.lockAt : lockAt // ignore: cast_nullable_to_non_nullable
as DateTime?,competitionName: null == competitionName ? _self.competitionName : competitionName // ignore: cast_nullable_to_non_nullable
as String,competitionBadgeUrl: null == competitionBadgeUrl ? _self.competitionBadgeUrl : competitionBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,homeTeamName: null == homeTeamName ? _self.homeTeamName : homeTeamName // ignore: cast_nullable_to_non_nullable
as String,homeTeamCode: null == homeTeamCode ? _self.homeTeamCode : homeTeamCode // ignore: cast_nullable_to_non_nullable
as String,homeTeamBadgeUrl: null == homeTeamBadgeUrl ? _self.homeTeamBadgeUrl : homeTeamBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,awayTeamName: null == awayTeamName ? _self.awayTeamName : awayTeamName // ignore: cast_nullable_to_non_nullable
as String,awayTeamCode: null == awayTeamCode ? _self.awayTeamCode : awayTeamCode // ignore: cast_nullable_to_non_nullable
as String,awayTeamBadgeUrl: null == awayTeamBadgeUrl ? _self.awayTeamBadgeUrl : awayTeamBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,round: freezed == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String?,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String?,rawResult: freezed == rawResult ? _self.rawResult : rawResult // ignore: cast_nullable_to_non_nullable
as String?,competition: freezed == competition ? _self.competition : competition // ignore: cast_nullable_to_non_nullable
as Competition?,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as Team?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as Team?,
  ));
}
/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get competition {
    if (_self.competition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.competition!, (value) {
    return _then(_self.copyWith(competition: value));
  });
}/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
}


/// Adds pattern-matching-related methods to [PicoMatch].
extension PicoMatchPatterns on PicoMatch {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PicoMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PicoMatch() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PicoMatch value)  $default,){
final _that = this;
switch (_that) {
case _PicoMatch():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PicoMatch value)?  $default,){
final _that = this;
switch (_that) {
case _PicoMatch() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'provider_match_id')  String? providerMatchId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'home_team_id')  String? homeTeamId, @JsonKey(name: 'away_team_id')  String? awayTeamId, @JsonKey(name: 'kickoff_at')  DateTime kickoffAt,  MatchStatus status, @JsonKey(name: 'home_score')  int? homeScore, @JsonKey(name: 'away_score')  int? awayScore,  bool settled,  DateTime? lockAt,  String competitionName,  String competitionBadgeUrl,  String homeTeamName,  String homeTeamCode,  String homeTeamBadgeUrl,  String awayTeamName,  String awayTeamCode,  String awayTeamBadgeUrl,  String? round,  String? leagueId,  String? rawResult,  Competition? competition,  Team? homeTeam,  Team? awayTeam)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PicoMatch() when $default != null:
return $default(_that.id,_that.providerMatchId,_that.competitionId,_that.homeTeamId,_that.awayTeamId,_that.kickoffAt,_that.status,_that.homeScore,_that.awayScore,_that.settled,_that.lockAt,_that.competitionName,_that.competitionBadgeUrl,_that.homeTeamName,_that.homeTeamCode,_that.homeTeamBadgeUrl,_that.awayTeamName,_that.awayTeamCode,_that.awayTeamBadgeUrl,_that.round,_that.leagueId,_that.rawResult,_that.competition,_that.homeTeam,_that.awayTeam);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'provider_match_id')  String? providerMatchId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'home_team_id')  String? homeTeamId, @JsonKey(name: 'away_team_id')  String? awayTeamId, @JsonKey(name: 'kickoff_at')  DateTime kickoffAt,  MatchStatus status, @JsonKey(name: 'home_score')  int? homeScore, @JsonKey(name: 'away_score')  int? awayScore,  bool settled,  DateTime? lockAt,  String competitionName,  String competitionBadgeUrl,  String homeTeamName,  String homeTeamCode,  String homeTeamBadgeUrl,  String awayTeamName,  String awayTeamCode,  String awayTeamBadgeUrl,  String? round,  String? leagueId,  String? rawResult,  Competition? competition,  Team? homeTeam,  Team? awayTeam)  $default,) {final _that = this;
switch (_that) {
case _PicoMatch():
return $default(_that.id,_that.providerMatchId,_that.competitionId,_that.homeTeamId,_that.awayTeamId,_that.kickoffAt,_that.status,_that.homeScore,_that.awayScore,_that.settled,_that.lockAt,_that.competitionName,_that.competitionBadgeUrl,_that.homeTeamName,_that.homeTeamCode,_that.homeTeamBadgeUrl,_that.awayTeamName,_that.awayTeamCode,_that.awayTeamBadgeUrl,_that.round,_that.leagueId,_that.rawResult,_that.competition,_that.homeTeam,_that.awayTeam);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'provider_match_id')  String? providerMatchId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'home_team_id')  String? homeTeamId, @JsonKey(name: 'away_team_id')  String? awayTeamId, @JsonKey(name: 'kickoff_at')  DateTime kickoffAt,  MatchStatus status, @JsonKey(name: 'home_score')  int? homeScore, @JsonKey(name: 'away_score')  int? awayScore,  bool settled,  DateTime? lockAt,  String competitionName,  String competitionBadgeUrl,  String homeTeamName,  String homeTeamCode,  String homeTeamBadgeUrl,  String awayTeamName,  String awayTeamCode,  String awayTeamBadgeUrl,  String? round,  String? leagueId,  String? rawResult,  Competition? competition,  Team? homeTeam,  Team? awayTeam)?  $default,) {final _that = this;
switch (_that) {
case _PicoMatch() when $default != null:
return $default(_that.id,_that.providerMatchId,_that.competitionId,_that.homeTeamId,_that.awayTeamId,_that.kickoffAt,_that.status,_that.homeScore,_that.awayScore,_that.settled,_that.lockAt,_that.competitionName,_that.competitionBadgeUrl,_that.homeTeamName,_that.homeTeamCode,_that.homeTeamBadgeUrl,_that.awayTeamName,_that.awayTeamCode,_that.awayTeamBadgeUrl,_that.round,_that.leagueId,_that.rawResult,_that.competition,_that.homeTeam,_that.awayTeam);case _:
  return null;

}
}

}

/// @nodoc


class _PicoMatch extends PicoMatch {
  const _PicoMatch({required this.id, @JsonKey(name: 'provider_match_id') this.providerMatchId, @JsonKey(name: 'competition_id') this.competitionId, @JsonKey(name: 'home_team_id') this.homeTeamId, @JsonKey(name: 'away_team_id') this.awayTeamId, @JsonKey(name: 'kickoff_at') required this.kickoffAt, this.status = MatchStatus.upcoming, @JsonKey(name: 'home_score') this.homeScore, @JsonKey(name: 'away_score') this.awayScore, this.settled = false, this.lockAt, this.competitionName = '', this.competitionBadgeUrl = '', this.homeTeamName = '', this.homeTeamCode = '', this.homeTeamBadgeUrl = '', this.awayTeamName = '', this.awayTeamCode = '', this.awayTeamBadgeUrl = '', this.round, this.leagueId, this.rawResult, this.competition, this.homeTeam, this.awayTeam}): super._();
  

@override final  String id;
@override@JsonKey(name: 'provider_match_id') final  String? providerMatchId;
@override@JsonKey(name: 'competition_id') final  String? competitionId;
@override@JsonKey(name: 'home_team_id') final  String? homeTeamId;
@override@JsonKey(name: 'away_team_id') final  String? awayTeamId;
@override@JsonKey(name: 'kickoff_at') final  DateTime kickoffAt;
@override@JsonKey() final  MatchStatus status;
@override@JsonKey(name: 'home_score') final  int? homeScore;
@override@JsonKey(name: 'away_score') final  int? awayScore;
@override@JsonKey() final  bool settled;
@override final  DateTime? lockAt;
@override@JsonKey() final  String competitionName;
@override@JsonKey() final  String competitionBadgeUrl;
@override@JsonKey() final  String homeTeamName;
@override@JsonKey() final  String homeTeamCode;
@override@JsonKey() final  String homeTeamBadgeUrl;
@override@JsonKey() final  String awayTeamName;
@override@JsonKey() final  String awayTeamCode;
@override@JsonKey() final  String awayTeamBadgeUrl;
@override final  String? round;
@override final  String? leagueId;
@override final  String? rawResult;
@override final  Competition? competition;
@override final  Team? homeTeam;
@override final  Team? awayTeam;

/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PicoMatchCopyWith<_PicoMatch> get copyWith => __$PicoMatchCopyWithImpl<_PicoMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PicoMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.providerMatchId, providerMatchId) || other.providerMatchId == providerMatchId)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.settled, settled) || other.settled == settled)&&(identical(other.lockAt, lockAt) || other.lockAt == lockAt)&&(identical(other.competitionName, competitionName) || other.competitionName == competitionName)&&(identical(other.competitionBadgeUrl, competitionBadgeUrl) || other.competitionBadgeUrl == competitionBadgeUrl)&&(identical(other.homeTeamName, homeTeamName) || other.homeTeamName == homeTeamName)&&(identical(other.homeTeamCode, homeTeamCode) || other.homeTeamCode == homeTeamCode)&&(identical(other.homeTeamBadgeUrl, homeTeamBadgeUrl) || other.homeTeamBadgeUrl == homeTeamBadgeUrl)&&(identical(other.awayTeamName, awayTeamName) || other.awayTeamName == awayTeamName)&&(identical(other.awayTeamCode, awayTeamCode) || other.awayTeamCode == awayTeamCode)&&(identical(other.awayTeamBadgeUrl, awayTeamBadgeUrl) || other.awayTeamBadgeUrl == awayTeamBadgeUrl)&&(identical(other.round, round) || other.round == round)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.rawResult, rawResult) || other.rawResult == rawResult)&&(identical(other.competition, competition) || other.competition == competition)&&(identical(other.homeTeam, homeTeam) || other.homeTeam == homeTeam)&&(identical(other.awayTeam, awayTeam) || other.awayTeam == awayTeam));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,providerMatchId,competitionId,homeTeamId,awayTeamId,kickoffAt,status,homeScore,awayScore,settled,lockAt,competitionName,competitionBadgeUrl,homeTeamName,homeTeamCode,homeTeamBadgeUrl,awayTeamName,awayTeamCode,awayTeamBadgeUrl,round,leagueId,rawResult,competition,homeTeam,awayTeam]);
}

@override
String toString() {
    return 'PicoMatch(id: $id, providerMatchId: $providerMatchId, competitionId: $competitionId, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, kickoffAt: $kickoffAt, status: $status, homeScore: $homeScore, awayScore: $awayScore, settled: $settled, lockAt: $lockAt, competitionName: $competitionName, competitionBadgeUrl: $competitionBadgeUrl, homeTeamName: $homeTeamName, homeTeamCode: $homeTeamCode, homeTeamBadgeUrl: $homeTeamBadgeUrl, awayTeamName: $awayTeamName, awayTeamCode: $awayTeamCode, awayTeamBadgeUrl: $awayTeamBadgeUrl, round: $round, leagueId: $leagueId, rawResult: $rawResult, competition: $competition, homeTeam: $homeTeam, awayTeam: $awayTeam)';
}


}

/// @nodoc
abstract mixin class _$PicoMatchCopyWith<$Res> implements $PicoMatchCopyWith<$Res> {
  factory _$PicoMatchCopyWith(_PicoMatch value, $Res Function(_PicoMatch) _then) = __$PicoMatchCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'provider_match_id') String? providerMatchId,@JsonKey(name: 'competition_id') String? competitionId,@JsonKey(name: 'home_team_id') String? homeTeamId,@JsonKey(name: 'away_team_id') String? awayTeamId,@JsonKey(name: 'kickoff_at') DateTime kickoffAt, MatchStatus status,@JsonKey(name: 'home_score') int? homeScore,@JsonKey(name: 'away_score') int? awayScore, bool settled, DateTime? lockAt, String competitionName, String competitionBadgeUrl, String homeTeamName, String homeTeamCode, String homeTeamBadgeUrl, String awayTeamName, String awayTeamCode, String awayTeamBadgeUrl, String? round, String? leagueId, String? rawResult, Competition? competition, Team? homeTeam, Team? awayTeam
});


@override $CompetitionCopyWith<$Res>? get competition;@override $TeamCopyWith<$Res>? get homeTeam;@override $TeamCopyWith<$Res>? get awayTeam;

}
/// @nodoc
class __$PicoMatchCopyWithImpl<$Res>
    implements _$PicoMatchCopyWith<$Res> {
  __$PicoMatchCopyWithImpl(this._self, this._then);

  final _PicoMatch _self;
  final $Res Function(_PicoMatch) _then;

/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? providerMatchId = freezed,Object? competitionId = freezed,Object? homeTeamId = freezed,Object? awayTeamId = freezed,Object? kickoffAt = null,Object? status = null,Object? homeScore = freezed,Object? awayScore = freezed,Object? settled = null,Object? lockAt = freezed,Object? competitionName = null,Object? competitionBadgeUrl = null,Object? homeTeamName = null,Object? homeTeamCode = null,Object? homeTeamBadgeUrl = null,Object? awayTeamName = null,Object? awayTeamCode = null,Object? awayTeamBadgeUrl = null,Object? round = freezed,Object? leagueId = freezed,Object? rawResult = freezed,Object? competition = freezed,Object? homeTeam = freezed,Object? awayTeam = freezed,}) {
  return _then(_PicoMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerMatchId: freezed == providerMatchId ? _self.providerMatchId : providerMatchId // ignore: cast_nullable_to_non_nullable
as String?,competitionId: freezed == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String?,homeTeamId: freezed == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String?,awayTeamId: freezed == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String?,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,settled: null == settled ? _self.settled : settled // ignore: cast_nullable_to_non_nullable
as bool,lockAt: freezed == lockAt ? _self.lockAt : lockAt // ignore: cast_nullable_to_non_nullable
as DateTime?,competitionName: null == competitionName ? _self.competitionName : competitionName // ignore: cast_nullable_to_non_nullable
as String,competitionBadgeUrl: null == competitionBadgeUrl ? _self.competitionBadgeUrl : competitionBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,homeTeamName: null == homeTeamName ? _self.homeTeamName : homeTeamName // ignore: cast_nullable_to_non_nullable
as String,homeTeamCode: null == homeTeamCode ? _self.homeTeamCode : homeTeamCode // ignore: cast_nullable_to_non_nullable
as String,homeTeamBadgeUrl: null == homeTeamBadgeUrl ? _self.homeTeamBadgeUrl : homeTeamBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,awayTeamName: null == awayTeamName ? _self.awayTeamName : awayTeamName // ignore: cast_nullable_to_non_nullable
as String,awayTeamCode: null == awayTeamCode ? _self.awayTeamCode : awayTeamCode // ignore: cast_nullable_to_non_nullable
as String,awayTeamBadgeUrl: null == awayTeamBadgeUrl ? _self.awayTeamBadgeUrl : awayTeamBadgeUrl // ignore: cast_nullable_to_non_nullable
as String,round: freezed == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String?,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String?,rawResult: freezed == rawResult ? _self.rawResult : rawResult // ignore: cast_nullable_to_non_nullable
as String?,competition: freezed == competition ? _self.competition : competition // ignore: cast_nullable_to_non_nullable
as Competition?,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as Team?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as Team?,
  ));
}

/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionCopyWith<$Res>? get competition {
    if (_self.competition == null) {
    return null;
  }

  return $CompetitionCopyWith<$Res>(_self.competition!, (value) {
    return _then(_self.copyWith(competition: value));
  });
}/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}/// Create a copy of PicoMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $TeamCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
}

// dart format on
