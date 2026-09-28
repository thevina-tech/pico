// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'private_league.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrivateLeague {

 String get id; String get name;@JsonKey(name: 'owner_id') String get ownerId;@JsonKey(name: 'admin_id') String? get adminId;@JsonKey(name: 'competition_id') String? get competitionId;@JsonKey(name: 'invite_code') String get inviteCode;@JsonKey(name: 'created_at') DateTime? get createdAt; String get ownerName; String get competitionName; int get memberCount; String get description;@JsonKey(name: 'max_capacity') int get maxCapacity;
/// Create a copy of PrivateLeague
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateLeagueCopyWith<PrivateLeague> get copyWith => _$PrivateLeagueCopyWithImpl<PrivateLeague>(this as PrivateLeague, _$identity);

  /// Serializes this PrivateLeague to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PrivateLeague;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateLeague&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.adminId, _this.adminId) || other.adminId == _this.adminId)&&(identical(other.competitionId, _this.competitionId) || other.competitionId == _this.competitionId)&&(identical(other.inviteCode, _this.inviteCode) || other.inviteCode == _this.inviteCode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.competitionName, _this.competitionName) || other.competitionName == _this.competitionName)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.maxCapacity, _this.maxCapacity) || other.maxCapacity == _this.maxCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PrivateLeague;
  return Object.hash(runtimeType,_this.id,_this.name,_this.ownerId,_this.adminId,_this.competitionId,_this.inviteCode,_this.createdAt,_this.ownerName,_this.competitionName,_this.memberCount,_this.description,_this.maxCapacity);
}

@override
String toString() {
  final _this = this as PrivateLeague;
  return 'PrivateLeague(id: ${_this.id}, name: ${_this.name}, ownerId: ${_this.ownerId}, adminId: ${_this.adminId}, competitionId: ${_this.competitionId}, inviteCode: ${_this.inviteCode}, createdAt: ${_this.createdAt}, ownerName: ${_this.ownerName}, competitionName: ${_this.competitionName}, memberCount: ${_this.memberCount}, description: ${_this.description}, maxCapacity: ${_this.maxCapacity})';
}


}

/// @nodoc
abstract mixin class $PrivateLeagueCopyWith<$Res>  {
  factory $PrivateLeagueCopyWith(PrivateLeague value, $Res Function(PrivateLeague) _then) = _$PrivateLeagueCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'owner_id') String ownerId,@JsonKey(name: 'admin_id') String? adminId,@JsonKey(name: 'competition_id') String? competitionId,@JsonKey(name: 'invite_code') String inviteCode,@JsonKey(name: 'created_at') DateTime? createdAt, String ownerName, String competitionName, int memberCount, String description,@JsonKey(name: 'max_capacity') int maxCapacity
});




}
/// @nodoc
class _$PrivateLeagueCopyWithImpl<$Res>
    implements $PrivateLeagueCopyWith<$Res> {
  _$PrivateLeagueCopyWithImpl(this._self, this._then);

  final PrivateLeague _self;
  final $Res Function(PrivateLeague) _then;

/// Create a copy of PrivateLeague
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? adminId = freezed,Object? competitionId = freezed,Object? inviteCode = null,Object? createdAt = freezed,Object? ownerName = null,Object? competitionName = null,Object? memberCount = null,Object? description = null,Object? maxCapacity = null,}) {
  return _then(PrivateLeague(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,adminId: freezed == adminId ? _self.adminId : adminId // ignore: cast_nullable_to_non_nullable
as String?,competitionId: freezed == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,competitionName: null == competitionName ? _self.competitionName : competitionName // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivateLeague].
extension PrivateLeaguePatterns on PrivateLeague {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateLeague value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateLeague() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateLeague value)  $default,){
final _that = this;
switch (_that) {
case _PrivateLeague():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateLeague value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateLeague() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'admin_id')  String? adminId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'created_at')  DateTime? createdAt,  String ownerName,  String competitionName,  int memberCount,  String description, @JsonKey(name: 'max_capacity')  int maxCapacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateLeague() when $default != null:
return $default(_that.id,_that.name,_that.ownerId,_that.adminId,_that.competitionId,_that.inviteCode,_that.createdAt,_that.ownerName,_that.competitionName,_that.memberCount,_that.description,_that.maxCapacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'admin_id')  String? adminId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'created_at')  DateTime? createdAt,  String ownerName,  String competitionName,  int memberCount,  String description, @JsonKey(name: 'max_capacity')  int maxCapacity)  $default,) {final _that = this;
switch (_that) {
case _PrivateLeague():
return $default(_that.id,_that.name,_that.ownerId,_that.adminId,_that.competitionId,_that.inviteCode,_that.createdAt,_that.ownerName,_that.competitionName,_that.memberCount,_that.description,_that.maxCapacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'admin_id')  String? adminId, @JsonKey(name: 'competition_id')  String? competitionId, @JsonKey(name: 'invite_code')  String inviteCode, @JsonKey(name: 'created_at')  DateTime? createdAt,  String ownerName,  String competitionName,  int memberCount,  String description, @JsonKey(name: 'max_capacity')  int maxCapacity)?  $default,) {final _that = this;
switch (_that) {
case _PrivateLeague() when $default != null:
return $default(_that.id,_that.name,_that.ownerId,_that.adminId,_that.competitionId,_that.inviteCode,_that.createdAt,_that.ownerName,_that.competitionName,_that.memberCount,_that.description,_that.maxCapacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivateLeague extends PrivateLeague {
  const _PrivateLeague({required this.id, required this.name, @JsonKey(name: 'owner_id') required this.ownerId, @JsonKey(name: 'admin_id') this.adminId, @JsonKey(name: 'competition_id') this.competitionId, @JsonKey(name: 'invite_code') required this.inviteCode, @JsonKey(name: 'created_at') this.createdAt, this.ownerName = '', this.competitionName = '', this.memberCount = 1, this.description = '', @JsonKey(name: 'max_capacity') this.maxCapacity = 25}): super._();
  factory _PrivateLeague.fromJson(Map<String, dynamic> json) => _$PrivateLeagueFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override@JsonKey(name: 'admin_id') final  String? adminId;
@override@JsonKey(name: 'competition_id') final  String? competitionId;
@override@JsonKey(name: 'invite_code') final  String inviteCode;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey() final  String ownerName;
@override@JsonKey() final  String competitionName;
@override@JsonKey() final  int memberCount;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'max_capacity') final  int maxCapacity;

/// Create a copy of PrivateLeague
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateLeagueCopyWith<_PrivateLeague> get copyWith => __$PrivateLeagueCopyWithImpl<_PrivateLeague>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivateLeagueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateLeague&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.adminId, adminId) || other.adminId == adminId)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.competitionName, competitionName) || other.competitionName == competitionName)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.description, description) || other.description == description)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,ownerId,adminId,competitionId,inviteCode,createdAt,ownerName,competitionName,memberCount,description,maxCapacity);
}

@override
String toString() {
    return 'PrivateLeague(id: $id, name: $name, ownerId: $ownerId, adminId: $adminId, competitionId: $competitionId, inviteCode: $inviteCode, createdAt: $createdAt, ownerName: $ownerName, competitionName: $competitionName, memberCount: $memberCount, description: $description, maxCapacity: $maxCapacity)';
}


}

/// @nodoc
abstract mixin class _$PrivateLeagueCopyWith<$Res> implements $PrivateLeagueCopyWith<$Res> {
  factory _$PrivateLeagueCopyWith(_PrivateLeague value, $Res Function(_PrivateLeague) _then) = __$PrivateLeagueCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'owner_id') String ownerId,@JsonKey(name: 'admin_id') String? adminId,@JsonKey(name: 'competition_id') String? competitionId,@JsonKey(name: 'invite_code') String inviteCode,@JsonKey(name: 'created_at') DateTime? createdAt, String ownerName, String competitionName, int memberCount, String description,@JsonKey(name: 'max_capacity') int maxCapacity
});




}
/// @nodoc
class __$PrivateLeagueCopyWithImpl<$Res>
    implements _$PrivateLeagueCopyWith<$Res> {
  __$PrivateLeagueCopyWithImpl(this._self, this._then);

  final _PrivateLeague _self;
  final $Res Function(_PrivateLeague) _then;

/// Create a copy of PrivateLeague
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerId = null,Object? adminId = freezed,Object? competitionId = freezed,Object? inviteCode = null,Object? createdAt = freezed,Object? ownerName = null,Object? competitionName = null,Object? memberCount = null,Object? description = null,Object? maxCapacity = null,}) {
  return _then(_PrivateLeague(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,adminId: freezed == adminId ? _self.adminId : adminId // ignore: cast_nullable_to_non_nullable
as String?,competitionId: freezed == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,competitionName: null == competitionName ? _self.competitionName : competitionName // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
