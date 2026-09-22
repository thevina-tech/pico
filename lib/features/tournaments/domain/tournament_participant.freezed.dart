// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentParticipant {

@JsonKey(name: 'tournament_id') String get tournamentId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'pico_points') int get picoPoints;@JsonKey(name: 'joined_at') DateTime? get joinedAt; String? get username;@JsonKey(name: 'avatar_url') String? get avatarUrl; Tournament? get tournament;
/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentParticipantCopyWith<TournamentParticipant> get copyWith => _$TournamentParticipantCopyWithImpl<TournamentParticipant>(this as TournamentParticipant, _$identity);

  /// Serializes this TournamentParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TournamentParticipant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentParticipant&&(identical(other.tournamentId, _this.tournamentId) || other.tournamentId == _this.tournamentId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.picoPoints, _this.picoPoints) || other.picoPoints == _this.picoPoints)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.tournament, _this.tournament) || other.tournament == _this.tournament));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TournamentParticipant;
  return Object.hash(runtimeType,_this.tournamentId,_this.userId,_this.picoPoints,_this.joinedAt,_this.username,_this.avatarUrl,_this.tournament);
}

@override
String toString() {
  final _this = this as TournamentParticipant;
  return 'TournamentParticipant(tournamentId: ${_this.tournamentId}, userId: ${_this.userId}, picoPoints: ${_this.picoPoints}, joinedAt: ${_this.joinedAt}, username: ${_this.username}, avatarUrl: ${_this.avatarUrl}, tournament: ${_this.tournament})';
}


}

/// @nodoc
abstract mixin class $TournamentParticipantCopyWith<$Res>  {
  factory $TournamentParticipantCopyWith(TournamentParticipant value, $Res Function(TournamentParticipant) _then) = _$TournamentParticipantCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'tournament_id') String tournamentId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pico_points') int picoPoints,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl, Tournament? tournament
});


$TournamentCopyWith<$Res>? get tournament;

}
/// @nodoc
class _$TournamentParticipantCopyWithImpl<$Res>
    implements $TournamentParticipantCopyWith<$Res> {
  _$TournamentParticipantCopyWithImpl(this._self, this._then);

  final TournamentParticipant _self;
  final $Res Function(TournamentParticipant) _then;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tournamentId = null,Object? userId = null,Object? picoPoints = null,Object? joinedAt = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? tournament = freezed,}) {
  return _then(TournamentParticipant(
tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,picoPoints: null == picoPoints ? _self.picoPoints : picoPoints // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,tournament: freezed == tournament ? _self.tournament : tournament // ignore: cast_nullable_to_non_nullable
as Tournament?,
  ));
}
/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TournamentCopyWith<$Res>? get tournament {
    if (_self.tournament == null) {
    return null;
  }

  return $TournamentCopyWith<$Res>(_self.tournament!, (value) {
    return _then(_self.copyWith(tournament: value));
  });
}
}


/// Adds pattern-matching-related methods to [TournamentParticipant].
extension TournamentParticipantPatterns on TournamentParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentParticipant value)  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'tournament_id')  String tournamentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  Tournament? tournament)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
return $default(_that.tournamentId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl,_that.tournament);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'tournament_id')  String tournamentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  Tournament? tournament)  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipant():
return $default(_that.tournamentId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl,_that.tournament);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'tournament_id')  String tournamentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  Tournament? tournament)?  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
return $default(_that.tournamentId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl,_that.tournament);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentParticipant implements TournamentParticipant {
  const _TournamentParticipant({@JsonKey(name: 'tournament_id') required this.tournamentId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'pico_points') this.picoPoints = 0, @JsonKey(name: 'joined_at') this.joinedAt, this.username, @JsonKey(name: 'avatar_url') this.avatarUrl, this.tournament});
  factory _TournamentParticipant.fromJson(Map<String, dynamic> json) => _$TournamentParticipantFromJson(json);

@override@JsonKey(name: 'tournament_id') final  String tournamentId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'pico_points') final  int picoPoints;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override final  String? username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  Tournament? tournament;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentParticipantCopyWith<_TournamentParticipant> get copyWith => __$TournamentParticipantCopyWithImpl<_TournamentParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentParticipant&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.picoPoints, picoPoints) || other.picoPoints == picoPoints)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.tournament, tournament) || other.tournament == tournament));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tournamentId,userId,picoPoints,joinedAt,username,avatarUrl,tournament);
}

@override
String toString() {
    return 'TournamentParticipant(tournamentId: $tournamentId, userId: $userId, picoPoints: $picoPoints, joinedAt: $joinedAt, username: $username, avatarUrl: $avatarUrl, tournament: $tournament)';
}


}

/// @nodoc
abstract mixin class _$TournamentParticipantCopyWith<$Res> implements $TournamentParticipantCopyWith<$Res> {
  factory _$TournamentParticipantCopyWith(_TournamentParticipant value, $Res Function(_TournamentParticipant) _then) = __$TournamentParticipantCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'tournament_id') String tournamentId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pico_points') int picoPoints,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl, Tournament? tournament
});


@override $TournamentCopyWith<$Res>? get tournament;

}
/// @nodoc
class __$TournamentParticipantCopyWithImpl<$Res>
    implements _$TournamentParticipantCopyWith<$Res> {
  __$TournamentParticipantCopyWithImpl(this._self, this._then);

  final _TournamentParticipant _self;
  final $Res Function(_TournamentParticipant) _then;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tournamentId = null,Object? userId = null,Object? picoPoints = null,Object? joinedAt = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? tournament = freezed,}) {
  return _then(_TournamentParticipant(
tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,picoPoints: null == picoPoints ? _self.picoPoints : picoPoints // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,tournament: freezed == tournament ? _self.tournament : tournament // ignore: cast_nullable_to_non_nullable
as Tournament?,
  ));
}

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TournamentCopyWith<$Res>? get tournament {
    if (_self.tournament == null) {
    return null;
  }

  return $TournamentCopyWith<$Res>(_self.tournament!, (value) {
    return _then(_self.copyWith(tournament: value));
  });
}
}

// dart format on
