// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeagueMessage {

 String get id;@JsonKey(name: 'league_id') String get leagueId;@JsonKey(name: 'user_id') String get userId; String get message;@JsonKey(name: 'created_at') DateTime get createdAt; String? get username;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of LeagueMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueMessageCopyWith<LeagueMessage> get copyWith => _$LeagueMessageCopyWithImpl<LeagueMessage>(this as LeagueMessage, _$identity);

  /// Serializes this LeagueMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeagueMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.leagueId, _this.leagueId) || other.leagueId == _this.leagueId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeagueMessage;
  return Object.hash(runtimeType,_this.id,_this.leagueId,_this.userId,_this.message,_this.createdAt,_this.username,_this.avatarUrl);
}

@override
String toString() {
  final _this = this as LeagueMessage;
  return 'LeagueMessage(id: ${_this.id}, leagueId: ${_this.leagueId}, userId: ${_this.userId}, message: ${_this.message}, createdAt: ${_this.createdAt}, username: ${_this.username}, avatarUrl: ${_this.avatarUrl})';
}


}

/// @nodoc
abstract mixin class $LeagueMessageCopyWith<$Res>  {
  factory $LeagueMessageCopyWith(LeagueMessage value, $Res Function(LeagueMessage) _then) = _$LeagueMessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'league_id') String leagueId,@JsonKey(name: 'user_id') String userId, String message,@JsonKey(name: 'created_at') DateTime createdAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$LeagueMessageCopyWithImpl<$Res>
    implements $LeagueMessageCopyWith<$Res> {
  _$LeagueMessageCopyWithImpl(this._self, this._then);

  final LeagueMessage _self;
  final $Res Function(LeagueMessage) _then;

/// Create a copy of LeagueMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? leagueId = null,Object? userId = null,Object? message = null,Object? createdAt = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(LeagueMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeagueMessage].
extension LeagueMessagePatterns on LeagueMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueMessage value)  $default,){
final _that = this;
switch (_that) {
case _LeagueMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueMessage value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'league_id')  String leagueId, @JsonKey(name: 'user_id')  String userId,  String message, @JsonKey(name: 'created_at')  DateTime createdAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueMessage() when $default != null:
return $default(_that.id,_that.leagueId,_that.userId,_that.message,_that.createdAt,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'league_id')  String leagueId, @JsonKey(name: 'user_id')  String userId,  String message, @JsonKey(name: 'created_at')  DateTime createdAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _LeagueMessage():
return $default(_that.id,_that.leagueId,_that.userId,_that.message,_that.createdAt,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'league_id')  String leagueId, @JsonKey(name: 'user_id')  String userId,  String message, @JsonKey(name: 'created_at')  DateTime createdAt,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _LeagueMessage() when $default != null:
return $default(_that.id,_that.leagueId,_that.userId,_that.message,_that.createdAt,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeagueMessage implements LeagueMessage {
  const _LeagueMessage({required this.id, @JsonKey(name: 'league_id') required this.leagueId, @JsonKey(name: 'user_id') required this.userId, required this.message, @JsonKey(name: 'created_at') required this.createdAt, this.username, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _LeagueMessage.fromJson(Map<String, dynamic> json) => _$LeagueMessageFromJson(json);

@override final  String id;
@override@JsonKey(name: 'league_id') final  String leagueId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String message;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override final  String? username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of LeagueMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueMessageCopyWith<_LeagueMessage> get copyWith => __$LeagueMessageCopyWithImpl<_LeagueMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,leagueId,userId,message,createdAt,username,avatarUrl);
}

@override
String toString() {
    return 'LeagueMessage(id: $id, leagueId: $leagueId, userId: $userId, message: $message, createdAt: $createdAt, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$LeagueMessageCopyWith<$Res> implements $LeagueMessageCopyWith<$Res> {
  factory _$LeagueMessageCopyWith(_LeagueMessage value, $Res Function(_LeagueMessage) _then) = __$LeagueMessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'league_id') String leagueId,@JsonKey(name: 'user_id') String userId, String message,@JsonKey(name: 'created_at') DateTime createdAt, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$LeagueMessageCopyWithImpl<$Res>
    implements _$LeagueMessageCopyWith<$Res> {
  __$LeagueMessageCopyWithImpl(this._self, this._then);

  final _LeagueMessage _self;
  final $Res Function(_LeagueMessage) _then;

/// Create a copy of LeagueMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? leagueId = null,Object? userId = null,Object? message = null,Object? createdAt = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_LeagueMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
