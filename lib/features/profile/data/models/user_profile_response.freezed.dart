// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserIdentityResponse {

 String get provider;@JsonKey(name: 'linked_at') String get linkedAt;@JsonKey(name: 'email_snapshot') String? get emailSnapshot;@JsonKey(name: 'display_name_snapshot') String? get displayNameSnapshot;
/// Create a copy of UserIdentityResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserIdentityResponseCopyWith<UserIdentityResponse> get copyWith => _$UserIdentityResponseCopyWithImpl<UserIdentityResponse>(this as UserIdentityResponse, _$identity);

  /// Serializes this UserIdentityResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserIdentityResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserIdentityResponse&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.linkedAt, _this.linkedAt) || other.linkedAt == _this.linkedAt)&&(identical(other.emailSnapshot, _this.emailSnapshot) || other.emailSnapshot == _this.emailSnapshot)&&(identical(other.displayNameSnapshot, _this.displayNameSnapshot) || other.displayNameSnapshot == _this.displayNameSnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserIdentityResponse;
  return Object.hash(runtimeType,_this.provider,_this.linkedAt,_this.emailSnapshot,_this.displayNameSnapshot);
}

@override
String toString() {
  final _this = this as UserIdentityResponse;
  return 'UserIdentityResponse(provider: ${_this.provider}, linkedAt: ${_this.linkedAt}, emailSnapshot: ${_this.emailSnapshot}, displayNameSnapshot: ${_this.displayNameSnapshot})';
}


}

/// @nodoc
abstract mixin class $UserIdentityResponseCopyWith<$Res>  {
  factory $UserIdentityResponseCopyWith(UserIdentityResponse value, $Res Function(UserIdentityResponse) _then) = _$UserIdentityResponseCopyWithImpl;
@useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt,@JsonKey(name: 'email_snapshot') String? emailSnapshot,@JsonKey(name: 'display_name_snapshot') String? displayNameSnapshot
});




}
/// @nodoc
class _$UserIdentityResponseCopyWithImpl<$Res>
    implements $UserIdentityResponseCopyWith<$Res> {
  _$UserIdentityResponseCopyWithImpl(this._self, this._then);

  final UserIdentityResponse _self;
  final $Res Function(UserIdentityResponse) _then;

/// Create a copy of UserIdentityResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? linkedAt = null,Object? emailSnapshot = freezed,Object? displayNameSnapshot = freezed,}) {
  return _then(UserIdentityResponse(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,emailSnapshot: freezed == emailSnapshot ? _self.emailSnapshot : emailSnapshot // ignore: cast_nullable_to_non_nullable
as String?,displayNameSnapshot: freezed == displayNameSnapshot ? _self.displayNameSnapshot : displayNameSnapshot // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserIdentityResponse].
extension UserIdentityResponsePatterns on UserIdentityResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserIdentityResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserIdentityResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserIdentityResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserIdentityResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserIdentityResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserIdentityResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt, @JsonKey(name: 'email_snapshot')  String? emailSnapshot, @JsonKey(name: 'display_name_snapshot')  String? displayNameSnapshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserIdentityResponse() when $default != null:
return $default(_that.provider,_that.linkedAt,_that.emailSnapshot,_that.displayNameSnapshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt, @JsonKey(name: 'email_snapshot')  String? emailSnapshot, @JsonKey(name: 'display_name_snapshot')  String? displayNameSnapshot)  $default,) {final _that = this;
switch (_that) {
case _UserIdentityResponse():
return $default(_that.provider,_that.linkedAt,_that.emailSnapshot,_that.displayNameSnapshot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt, @JsonKey(name: 'email_snapshot')  String? emailSnapshot, @JsonKey(name: 'display_name_snapshot')  String? displayNameSnapshot)?  $default,) {final _that = this;
switch (_that) {
case _UserIdentityResponse() when $default != null:
return $default(_that.provider,_that.linkedAt,_that.emailSnapshot,_that.displayNameSnapshot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserIdentityResponse implements UserIdentityResponse {
  const _UserIdentityResponse({required this.provider, @JsonKey(name: 'linked_at') required this.linkedAt, @JsonKey(name: 'email_snapshot') this.emailSnapshot, @JsonKey(name: 'display_name_snapshot') this.displayNameSnapshot});
  factory _UserIdentityResponse.fromJson(Map<String, dynamic> json) => _$UserIdentityResponseFromJson(json);

@override final  String provider;
@override@JsonKey(name: 'linked_at') final  String linkedAt;
@override@JsonKey(name: 'email_snapshot') final  String? emailSnapshot;
@override@JsonKey(name: 'display_name_snapshot') final  String? displayNameSnapshot;

/// Create a copy of UserIdentityResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserIdentityResponseCopyWith<_UserIdentityResponse> get copyWith => __$UserIdentityResponseCopyWithImpl<_UserIdentityResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserIdentityResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserIdentityResponse&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.emailSnapshot, emailSnapshot) || other.emailSnapshot == emailSnapshot)&&(identical(other.displayNameSnapshot, displayNameSnapshot) || other.displayNameSnapshot == displayNameSnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,linkedAt,emailSnapshot,displayNameSnapshot);
}

@override
String toString() {
    return 'UserIdentityResponse(provider: $provider, linkedAt: $linkedAt, emailSnapshot: $emailSnapshot, displayNameSnapshot: $displayNameSnapshot)';
}


}

/// @nodoc
abstract mixin class _$UserIdentityResponseCopyWith<$Res> implements $UserIdentityResponseCopyWith<$Res> {
  factory _$UserIdentityResponseCopyWith(_UserIdentityResponse value, $Res Function(_UserIdentityResponse) _then) = __$UserIdentityResponseCopyWithImpl;
@override @useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt,@JsonKey(name: 'email_snapshot') String? emailSnapshot,@JsonKey(name: 'display_name_snapshot') String? displayNameSnapshot
});




}
/// @nodoc
class __$UserIdentityResponseCopyWithImpl<$Res>
    implements _$UserIdentityResponseCopyWith<$Res> {
  __$UserIdentityResponseCopyWithImpl(this._self, this._then);

  final _UserIdentityResponse _self;
  final $Res Function(_UserIdentityResponse) _then;

/// Create a copy of UserIdentityResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? linkedAt = null,Object? emailSnapshot = freezed,Object? displayNameSnapshot = freezed,}) {
  return _then(_UserIdentityResponse(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,emailSnapshot: freezed == emailSnapshot ? _self.emailSnapshot : emailSnapshot // ignore: cast_nullable_to_non_nullable
as String?,displayNameSnapshot: freezed == displayNameSnapshot ? _self.displayNameSnapshot : displayNameSnapshot // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserResponse {

 String get id; String get email;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'has_password_credential') bool get hasPasswordCredential;@JsonKey(name: 'created_at') String get createdAt; List<UserIdentityResponse> get identities;
/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserResponseCopyWith<UserResponse> get copyWith => _$UserResponseCopyWithImpl<UserResponse>(this as UserResponse, _$identity);

  /// Serializes this UserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.hasPasswordCredential, _this.hasPasswordCredential) || other.hasPasswordCredential == _this.hasPasswordCredential)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.identities, _this.identities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserResponse;
  return Object.hash(runtimeType,_this.id,_this.email,_this.displayName,_this.hasPasswordCredential,_this.createdAt,const DeepCollectionEquality().hash(_this.identities));
}

@override
String toString() {
  final _this = this as UserResponse;
  return 'UserResponse(id: ${_this.id}, email: ${_this.email}, displayName: ${_this.displayName}, hasPasswordCredential: ${_this.hasPasswordCredential}, createdAt: ${_this.createdAt}, identities: ${_this.identities})';
}


}

/// @nodoc
abstract mixin class $UserResponseCopyWith<$Res>  {
  factory $UserResponseCopyWith(UserResponse value, $Res Function(UserResponse) _then) = _$UserResponseCopyWithImpl;
@useResult
$Res call({
 String id, String email,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'has_password_credential') bool hasPasswordCredential,@JsonKey(name: 'created_at') String createdAt, List<UserIdentityResponse> identities
});




}
/// @nodoc
class _$UserResponseCopyWithImpl<$Res>
    implements $UserResponseCopyWith<$Res> {
  _$UserResponseCopyWithImpl(this._self, this._then);

  final UserResponse _self;
  final $Res Function(UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? hasPasswordCredential = null,Object? createdAt = null,Object? identities = null,}) {
  return _then(UserResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,hasPasswordCredential: null == hasPasswordCredential ? _self.hasPasswordCredential : hasPasswordCredential // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,identities: null == identities ? _self.identities : identities // ignore: cast_nullable_to_non_nullable
as List<UserIdentityResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserResponse].
extension UserResponsePatterns on UserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential, @JsonKey(name: 'created_at')  String createdAt,  List<UserIdentityResponse> identities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.hasPasswordCredential,_that.createdAt,_that.identities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential, @JsonKey(name: 'created_at')  String createdAt,  List<UserIdentityResponse> identities)  $default,) {final _that = this;
switch (_that) {
case _UserResponse():
return $default(_that.id,_that.email,_that.displayName,_that.hasPasswordCredential,_that.createdAt,_that.identities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential, @JsonKey(name: 'created_at')  String createdAt,  List<UserIdentityResponse> identities)?  $default,) {final _that = this;
switch (_that) {
case _UserResponse() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.hasPasswordCredential,_that.createdAt,_that.identities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserResponse implements UserResponse {
  const _UserResponse({required this.id, required this.email, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'has_password_credential') required this.hasPasswordCredential, @JsonKey(name: 'created_at') required this.createdAt, required  List<UserIdentityResponse> identities}): _identities = identities;
  factory _UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

@override final  String id;
@override final  String email;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'has_password_credential') final  bool hasPasswordCredential;
@override@JsonKey(name: 'created_at') final  String createdAt;
 final  List<UserIdentityResponse> _identities;
@override List<UserIdentityResponse> get identities {
  if (_identities is EqualUnmodifiableListView) return _identities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identities);
}


/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserResponseCopyWith<_UserResponse> get copyWith => __$UserResponseCopyWithImpl<_UserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.hasPasswordCredential, hasPasswordCredential) || other.hasPasswordCredential == hasPasswordCredential)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.identities, _identities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,displayName,hasPasswordCredential,createdAt,const DeepCollectionEquality().hash(_identities));
}

@override
String toString() {
    return 'UserResponse(id: $id, email: $email, displayName: $displayName, hasPasswordCredential: $hasPasswordCredential, createdAt: $createdAt, identities: $identities)';
}


}

/// @nodoc
abstract mixin class _$UserResponseCopyWith<$Res> implements $UserResponseCopyWith<$Res> {
  factory _$UserResponseCopyWith(_UserResponse value, $Res Function(_UserResponse) _then) = __$UserResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String email,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'has_password_credential') bool hasPasswordCredential,@JsonKey(name: 'created_at') String createdAt, List<UserIdentityResponse> identities
});




}
/// @nodoc
class __$UserResponseCopyWithImpl<$Res>
    implements _$UserResponseCopyWith<$Res> {
  __$UserResponseCopyWithImpl(this._self, this._then);

  final _UserResponse _self;
  final $Res Function(_UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? hasPasswordCredential = null,Object? createdAt = null,Object? identities = null,}) {
  return _then(_UserResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,hasPasswordCredential: null == hasPasswordCredential ? _self.hasPasswordCredential : hasPasswordCredential // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,identities: null == identities ? _self._identities : identities // ignore: cast_nullable_to_non_nullable
as List<UserIdentityResponse>,
  ));
}


}


/// @nodoc
mixin _$UserDataResponse {

 UserResponse get user;
/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDataResponseCopyWith<UserDataResponse> get copyWith => _$UserDataResponseCopyWithImpl<UserDataResponse>(this as UserDataResponse, _$identity);

  /// Serializes this UserDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDataResponse&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserDataResponse;
  return Object.hash(runtimeType,_this.user);
}

@override
String toString() {
  final _this = this as UserDataResponse;
  return 'UserDataResponse(user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $UserDataResponseCopyWith<$Res>  {
  factory $UserDataResponseCopyWith(UserDataResponse value, $Res Function(UserDataResponse) _then) = _$UserDataResponseCopyWithImpl;
@useResult
$Res call({
 UserResponse user
});


$UserResponseCopyWith<$Res> get user;

}
/// @nodoc
class _$UserDataResponseCopyWithImpl<$Res>
    implements $UserDataResponseCopyWith<$Res> {
  _$UserDataResponseCopyWithImpl(this._self, this._then);

  final UserDataResponse _self;
  final $Res Function(UserDataResponse) _then;

/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,}) {
  return _then(UserDataResponse(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserResponse,
  ));
}
/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserResponseCopyWith<$Res> get user {
  
  return $UserResponseCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserDataResponse].
extension UserDataResponsePatterns on UserDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserResponse user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDataResponse() when $default != null:
return $default(_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserResponse user)  $default,) {final _that = this;
switch (_that) {
case _UserDataResponse():
return $default(_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserResponse user)?  $default,) {final _that = this;
switch (_that) {
case _UserDataResponse() when $default != null:
return $default(_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDataResponse implements UserDataResponse {
  const _UserDataResponse({required this.user});
  factory _UserDataResponse.fromJson(Map<String, dynamic> json) => _$UserDataResponseFromJson(json);

@override final  UserResponse user;

/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDataResponseCopyWith<_UserDataResponse> get copyWith => __$UserDataResponseCopyWithImpl<_UserDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDataResponse&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,user);
}

@override
String toString() {
    return 'UserDataResponse(user: $user)';
}


}

/// @nodoc
abstract mixin class _$UserDataResponseCopyWith<$Res> implements $UserDataResponseCopyWith<$Res> {
  factory _$UserDataResponseCopyWith(_UserDataResponse value, $Res Function(_UserDataResponse) _then) = __$UserDataResponseCopyWithImpl;
@override @useResult
$Res call({
 UserResponse user
});


@override $UserResponseCopyWith<$Res> get user;

}
/// @nodoc
class __$UserDataResponseCopyWithImpl<$Res>
    implements _$UserDataResponseCopyWith<$Res> {
  __$UserDataResponseCopyWithImpl(this._self, this._then);

  final _UserDataResponse _self;
  final $Res Function(_UserDataResponse) _then;

/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_UserDataResponse(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserResponse,
  ));
}

/// Create a copy of UserDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserResponseCopyWith<$Res> get user {
  
  return $UserResponseCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$GetUserResponse {

 UserDataResponse get data; String? get message;
/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetUserResponseCopyWith<GetUserResponse> get copyWith => _$GetUserResponseCopyWithImpl<GetUserResponse>(this as GetUserResponse, _$identity);

  /// Serializes this GetUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GetUserResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetUserResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GetUserResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as GetUserResponse;
  return 'GetUserResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $GetUserResponseCopyWith<$Res>  {
  factory $GetUserResponseCopyWith(GetUserResponse value, $Res Function(GetUserResponse) _then) = _$GetUserResponseCopyWithImpl;
@useResult
$Res call({
 UserDataResponse data, String? message
});


$UserDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$GetUserResponseCopyWithImpl<$Res>
    implements $GetUserResponseCopyWith<$Res> {
  _$GetUserResponseCopyWithImpl(this._self, this._then);

  final GetUserResponse _self;
  final $Res Function(GetUserResponse) _then;

/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(GetUserResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataResponseCopyWith<$Res> get data {
  
  return $UserDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetUserResponse].
extension GetUserResponsePatterns on GetUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetUserResponse() when $default != null:
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _GetUserResponse():
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _GetUserResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetUserResponse implements GetUserResponse {
  const _GetUserResponse({required this.data, this.message});
  factory _GetUserResponse.fromJson(Map<String, dynamic> json) => _$GetUserResponseFromJson(json);

@override final  UserDataResponse data;
@override final  String? message;

/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetUserResponseCopyWith<_GetUserResponse> get copyWith => __$GetUserResponseCopyWithImpl<_GetUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetUserResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'GetUserResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$GetUserResponseCopyWith<$Res> implements $GetUserResponseCopyWith<$Res> {
  factory _$GetUserResponseCopyWith(_GetUserResponse value, $Res Function(_GetUserResponse) _then) = __$GetUserResponseCopyWithImpl;
@override @useResult
$Res call({
 UserDataResponse data, String? message
});


@override $UserDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$GetUserResponseCopyWithImpl<$Res>
    implements _$GetUserResponseCopyWith<$Res> {
  __$GetUserResponseCopyWithImpl(this._self, this._then);

  final _GetUserResponse _self;
  final $Res Function(_GetUserResponse) _then;

/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_GetUserResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GetUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataResponseCopyWith<$Res> get data {
  
  return $UserDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$UpdateUserResponse {

 UserDataResponse get data; String? get message;
/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserResponseCopyWith<UpdateUserResponse> get copyWith => _$UpdateUserResponseCopyWithImpl<UpdateUserResponse>(this as UpdateUserResponse, _$identity);

  /// Serializes this UpdateUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateUserResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateUserResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as UpdateUserResponse;
  return 'UpdateUserResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $UpdateUserResponseCopyWith<$Res>  {
  factory $UpdateUserResponseCopyWith(UpdateUserResponse value, $Res Function(UpdateUserResponse) _then) = _$UpdateUserResponseCopyWithImpl;
@useResult
$Res call({
 UserDataResponse data, String? message
});


$UserDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$UpdateUserResponseCopyWithImpl<$Res>
    implements $UpdateUserResponseCopyWith<$Res> {
  _$UpdateUserResponseCopyWithImpl(this._self, this._then);

  final UpdateUserResponse _self;
  final $Res Function(UpdateUserResponse) _then;

/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(UpdateUserResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataResponseCopyWith<$Res> get data {
  
  return $UserDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateUserResponse].
extension UpdateUserResponsePatterns on UpdateUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserResponse() when $default != null:
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserResponse():
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserResponse implements UpdateUserResponse {
  const _UpdateUserResponse({required this.data, this.message});
  factory _UpdateUserResponse.fromJson(Map<String, dynamic> json) => _$UpdateUserResponseFromJson(json);

@override final  UserDataResponse data;
@override final  String? message;

/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserResponseCopyWith<_UpdateUserResponse> get copyWith => __$UpdateUserResponseCopyWithImpl<_UpdateUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'UpdateUserResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserResponseCopyWith<$Res> implements $UpdateUserResponseCopyWith<$Res> {
  factory _$UpdateUserResponseCopyWith(_UpdateUserResponse value, $Res Function(_UpdateUserResponse) _then) = __$UpdateUserResponseCopyWithImpl;
@override @useResult
$Res call({
 UserDataResponse data, String? message
});


@override $UserDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$UpdateUserResponseCopyWithImpl<$Res>
    implements _$UpdateUserResponseCopyWith<$Res> {
  __$UpdateUserResponseCopyWithImpl(this._self, this._then);

  final _UpdateUserResponse _self;
  final $Res Function(_UpdateUserResponse) _then;

/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_UpdateUserResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpdateUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataResponseCopyWith<$Res> get data {
  
  return $UserDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
