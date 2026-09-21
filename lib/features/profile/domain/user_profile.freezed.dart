// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String? get email; String? get username;@JsonKey(name: 'avatar_url') String? get avatarUrl; int get level; int get xp; int get streak; int get coins;@JsonKey(name: 'private_leagues_created') int get privateLeaguesCreated;@JsonKey(name: 'favorite_team_id') String? get favoriteTeamId;@JsonKey(name: 'favorite_team_ids') List<String> get favoriteTeamIds;@JsonKey(name: 'favorite_league_ids') List<String> get favoriteLeagueIds;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.xp, _this.xp) || other.xp == _this.xp)&&(identical(other.streak, _this.streak) || other.streak == _this.streak)&&(identical(other.coins, _this.coins) || other.coins == _this.coins)&&(identical(other.privateLeaguesCreated, _this.privateLeaguesCreated) || other.privateLeaguesCreated == _this.privateLeaguesCreated)&&(identical(other.favoriteTeamId, _this.favoriteTeamId) || other.favoriteTeamId == _this.favoriteTeamId)&&const DeepCollectionEquality().equals(other.favoriteTeamIds, _this.favoriteTeamIds)&&const DeepCollectionEquality().equals(other.favoriteLeagueIds, _this.favoriteLeagueIds)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.id,_this.email,_this.username,_this.avatarUrl,_this.level,_this.xp,_this.streak,_this.coins,_this.privateLeaguesCreated,_this.favoriteTeamId,const DeepCollectionEquality().hash(_this.favoriteTeamIds),const DeepCollectionEquality().hash(_this.favoriteLeagueIds),_this.createdAt);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(id: ${_this.id}, email: ${_this.email}, username: ${_this.username}, avatarUrl: ${_this.avatarUrl}, level: ${_this.level}, xp: ${_this.xp}, streak: ${_this.streak}, coins: ${_this.coins}, privateLeaguesCreated: ${_this.privateLeaguesCreated}, favoriteTeamId: ${_this.favoriteTeamId}, favoriteTeamIds: ${_this.favoriteTeamIds}, favoriteLeagueIds: ${_this.favoriteLeagueIds}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? email, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl, int level, int xp, int streak, int coins,@JsonKey(name: 'private_leagues_created') int privateLeaguesCreated,@JsonKey(name: 'favorite_team_id') String? favoriteTeamId,@JsonKey(name: 'favorite_team_ids') List<String> favoriteTeamIds,@JsonKey(name: 'favorite_league_ids') List<String> favoriteLeagueIds,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? level = null,Object? xp = null,Object? streak = null,Object? coins = null,Object? privateLeaguesCreated = null,Object? favoriteTeamId = freezed,Object? favoriteTeamIds = null,Object? favoriteLeagueIds = null,Object? createdAt = freezed,}) {
  return _then(UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,privateLeaguesCreated: null == privateLeaguesCreated ? _self.privateLeaguesCreated : privateLeaguesCreated // ignore: cast_nullable_to_non_nullable
as int,favoriteTeamId: freezed == favoriteTeamId ? _self.favoriteTeamId : favoriteTeamId // ignore: cast_nullable_to_non_nullable
as String?,favoriteTeamIds: null == favoriteTeamIds ? _self.favoriteTeamIds : favoriteTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteLeagueIds: null == favoriteLeagueIds ? _self.favoriteLeagueIds : favoriteLeagueIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? email,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  int level,  int xp,  int streak,  int coins, @JsonKey(name: 'private_leagues_created')  int privateLeaguesCreated, @JsonKey(name: 'favorite_team_id')  String? favoriteTeamId, @JsonKey(name: 'favorite_team_ids')  List<String> favoriteTeamIds, @JsonKey(name: 'favorite_league_ids')  List<String> favoriteLeagueIds, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.avatarUrl,_that.level,_that.xp,_that.streak,_that.coins,_that.privateLeaguesCreated,_that.favoriteTeamId,_that.favoriteTeamIds,_that.favoriteLeagueIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? email,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  int level,  int xp,  int streak,  int coins, @JsonKey(name: 'private_leagues_created')  int privateLeaguesCreated, @JsonKey(name: 'favorite_team_id')  String? favoriteTeamId, @JsonKey(name: 'favorite_team_ids')  List<String> favoriteTeamIds, @JsonKey(name: 'favorite_league_ids')  List<String> favoriteLeagueIds, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.email,_that.username,_that.avatarUrl,_that.level,_that.xp,_that.streak,_that.coins,_that.privateLeaguesCreated,_that.favoriteTeamId,_that.favoriteTeamIds,_that.favoriteLeagueIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? email,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  int level,  int xp,  int streak,  int coins, @JsonKey(name: 'private_leagues_created')  int privateLeaguesCreated, @JsonKey(name: 'favorite_team_id')  String? favoriteTeamId, @JsonKey(name: 'favorite_team_ids')  List<String> favoriteTeamIds, @JsonKey(name: 'favorite_league_ids')  List<String> favoriteLeagueIds, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.avatarUrl,_that.level,_that.xp,_that.streak,_that.coins,_that.privateLeaguesCreated,_that.favoriteTeamId,_that.favoriteTeamIds,_that.favoriteLeagueIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, this.email, this.username, @JsonKey(name: 'avatar_url') this.avatarUrl, this.level = 1, this.xp = 0, this.streak = 0, this.coins = 0, @JsonKey(name: 'private_leagues_created') this.privateLeaguesCreated = 0, @JsonKey(name: 'favorite_team_id') this.favoriteTeamId, @JsonKey(name: 'favorite_team_ids')  List<String> favoriteTeamIds = const <String>[], @JsonKey(name: 'favorite_league_ids')  List<String> favoriteLeagueIds = const <String>[], @JsonKey(name: 'created_at') this.createdAt}): _favoriteTeamIds = favoriteTeamIds,_favoriteLeagueIds = favoriteLeagueIds;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String? email;
@override final  String? username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey() final  int level;
@override@JsonKey() final  int xp;
@override@JsonKey() final  int streak;
@override@JsonKey() final  int coins;
@override@JsonKey(name: 'private_leagues_created') final  int privateLeaguesCreated;
@override@JsonKey(name: 'favorite_team_id') final  String? favoriteTeamId;
 final  List<String> _favoriteTeamIds;
@override@JsonKey(name: 'favorite_team_ids') List<String> get favoriteTeamIds {
  if (_favoriteTeamIds is EqualUnmodifiableListView) return _favoriteTeamIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteTeamIds);
}

 final  List<String> _favoriteLeagueIds;
@override@JsonKey(name: 'favorite_league_ids') List<String> get favoriteLeagueIds {
  if (_favoriteLeagueIds is EqualUnmodifiableListView) return _favoriteLeagueIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteLeagueIds);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.privateLeaguesCreated, privateLeaguesCreated) || other.privateLeaguesCreated == privateLeaguesCreated)&&(identical(other.favoriteTeamId, favoriteTeamId) || other.favoriteTeamId == favoriteTeamId)&&const DeepCollectionEquality().equals(other.favoriteTeamIds, _favoriteTeamIds)&&const DeepCollectionEquality().equals(other.favoriteLeagueIds, _favoriteLeagueIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,username,avatarUrl,level,xp,streak,coins,privateLeaguesCreated,favoriteTeamId,const DeepCollectionEquality().hash(_favoriteTeamIds),const DeepCollectionEquality().hash(_favoriteLeagueIds),createdAt);
}

@override
String toString() {
    return 'UserProfile(id: $id, email: $email, username: $username, avatarUrl: $avatarUrl, level: $level, xp: $xp, streak: $streak, coins: $coins, privateLeaguesCreated: $privateLeaguesCreated, favoriteTeamId: $favoriteTeamId, favoriteTeamIds: $favoriteTeamIds, favoriteLeagueIds: $favoriteLeagueIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? email, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl, int level, int xp, int streak, int coins,@JsonKey(name: 'private_leagues_created') int privateLeaguesCreated,@JsonKey(name: 'favorite_team_id') String? favoriteTeamId,@JsonKey(name: 'favorite_team_ids') List<String> favoriteTeamIds,@JsonKey(name: 'favorite_league_ids') List<String> favoriteLeagueIds,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? level = null,Object? xp = null,Object? streak = null,Object? coins = null,Object? privateLeaguesCreated = null,Object? favoriteTeamId = freezed,Object? favoriteTeamIds = null,Object? favoriteLeagueIds = null,Object? createdAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,privateLeaguesCreated: null == privateLeaguesCreated ? _self.privateLeaguesCreated : privateLeaguesCreated // ignore: cast_nullable_to_non_nullable
as int,favoriteTeamId: freezed == favoriteTeamId ? _self.favoriteTeamId : favoriteTeamId // ignore: cast_nullable_to_non_nullable
as String?,favoriteTeamIds: null == favoriteTeamIds ? _self._favoriteTeamIds : favoriteTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteLeagueIds: null == favoriteLeagueIds ? _self._favoriteLeagueIds : favoriteLeagueIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
