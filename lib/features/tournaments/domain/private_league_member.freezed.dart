// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'private_league_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrivateLeagueMember {

@JsonKey(name: 'private_league_id') String get privateLeagueId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'pico_points') int get picoPoints;@JsonKey(name: 'joined_at') DateTime? get joinedAt; String? get username;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of PrivateLeagueMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateLeagueMemberCopyWith<PrivateLeagueMember> get copyWith => _$PrivateLeagueMemberCopyWithImpl<PrivateLeagueMember>(this as PrivateLeagueMember, _$identity);

  /// Serializes this PrivateLeagueMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PrivateLeagueMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateLeagueMember&&(identical(other.privateLeagueId, _this.privateLeagueId) || other.privateLeagueId == _this.privateLeagueId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.picoPoints, _this.picoPoints) || other.picoPoints == _this.picoPoints)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PrivateLeagueMember;
  return Object.hash(runtimeType,_this.privateLeagueId,_this.userId,_this.picoPoints,_this.joinedAt,_this.username,_this.avatarUrl);
}

@override
String toString() {
  final _this = this as PrivateLeagueMember;
  return 'PrivateLeagueMember(privateLeagueId: ${_this.privateLeagueId}, userId: ${_this.userId}, picoPoints: ${_this.picoPoints}, joinedAt: ${_this.joinedAt}, username: ${_this.username}, avatarUrl: ${_this.avatarUrl})';
}


}

/// @nodoc
abstract mixin class $PrivateLeagueMemberCopyWith<$Res>  {
  factory $PrivateLeagueMemberCopyWith(PrivateLeagueMember value, $Res Function(PrivateLeagueMember) _then) = _$PrivateLeagueMemberCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'private_league_id') String privateLeagueId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pico_points') int picoPoints,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$PrivateLeagueMemberCopyWithImpl<$Res>
    implements $PrivateLeagueMemberCopyWith<$Res> {
  _$PrivateLeagueMemberCopyWithImpl(this._self, this._then);

  final PrivateLeagueMember _self;
  final $Res Function(PrivateLeagueMember) _then;

/// Create a copy of PrivateLeagueMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? privateLeagueId = null,Object? userId = null,Object? picoPoints = null,Object? joinedAt = freezed,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(PrivateLeagueMember(
privateLeagueId: null == privateLeagueId ? _self.privateLeagueId : privateLeagueId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,picoPoints: null == picoPoints ? _self.picoPoints : picoPoints // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivateLeagueMember].
extension PrivateLeagueMemberPatterns on PrivateLeagueMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateLeagueMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateLeagueMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateLeagueMember value)  $default,){
final _that = this;
switch (_that) {
case _PrivateLeagueMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateLeagueMember value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateLeagueMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'private_league_id')  String privateLeagueId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateLeagueMember() when $default != null:
return $default(_that.privateLeagueId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'private_league_id')  String privateLeagueId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _PrivateLeagueMember():
return $default(_that.privateLeagueId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'private_league_id')  String privateLeagueId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'pico_points')  int picoPoints, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _PrivateLeagueMember() when $default != null:
return $default(_that.privateLeagueId,_that.userId,_that.picoPoints,_that.joinedAt,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivateLeagueMember implements PrivateLeagueMember {
  const _PrivateLeagueMember({@JsonKey(name: 'private_league_id') required this.privateLeagueId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'pico_points') this.picoPoints = 0, @JsonKey(name: 'joined_at') this.joinedAt, this.username, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _PrivateLeagueMember.fromJson(Map<String, dynamic> json) => _$PrivateLeagueMemberFromJson(json);

@override@JsonKey(name: 'private_league_id') final  String privateLeagueId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'pico_points') final  int picoPoints;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override final  String? username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of PrivateLeagueMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateLeagueMemberCopyWith<_PrivateLeagueMember> get copyWith => __$PrivateLeagueMemberCopyWithImpl<_PrivateLeagueMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivateLeagueMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateLeagueMember&&(identical(other.privateLeagueId, privateLeagueId) || other.privateLeagueId == privateLeagueId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.picoPoints, picoPoints) || other.picoPoints == picoPoints)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,privateLeagueId,userId,picoPoints,joinedAt,username,avatarUrl);
}

@override
String toString() {
    return 'PrivateLeagueMember(privateLeagueId: $privateLeagueId, userId: $userId, picoPoints: $picoPoints, joinedAt: $joinedAt, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$PrivateLeagueMemberCopyWith<$Res> implements $PrivateLeagueMemberCopyWith<$Res> {
  factory _$PrivateLeagueMemberCopyWith(_PrivateLeagueMember value, $Res Function(_PrivateLeagueMember) _then) = __$PrivateLeagueMemberCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'private_league_id') String privateLeagueId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pico_points') int picoPoints,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$PrivateLeagueMemberCopyWithImpl<$Res>
    implements _$PrivateLeagueMemberCopyWith<$Res> {
  __$PrivateLeagueMemberCopyWithImpl(this._self, this._then);

  final _PrivateLeagueMember _self;
  final $Res Function(_PrivateLeagueMember) _then;

/// Create a copy of PrivateLeagueMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? privateLeagueId = null,Object? userId = null,Object? picoPoints = null,Object? joinedAt = freezed,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_PrivateLeagueMember(
privateLeagueId: null == privateLeagueId ? _self.privateLeagueId : privateLeagueId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,picoPoints: null == picoPoints ? _self.picoPoints : picoPoints // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
