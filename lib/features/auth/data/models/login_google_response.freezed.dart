// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_google_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginGoogleResponse {

 String get outcome;@JsonKey(name: 'access_token') String? get accessToken;@JsonKey(name: 'refresh_token') String? get refreshToken; AuthUser? get user; String? get provider;@JsonKey(name: 'confirmation_id') String? get confirmationId;@JsonKey(name: 'verification_id') String? get verificationId;
/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginGoogleResponseCopyWith<LoginGoogleResponse> get copyWith => _$LoginGoogleResponseCopyWithImpl<LoginGoogleResponse>(this as LoginGoogleResponse, _$identity);

  /// Serializes this LoginGoogleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoginGoogleResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginGoogleResponse&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.confirmationId, _this.confirmationId) || other.confirmationId == _this.confirmationId)&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoginGoogleResponse;
  return Object.hash(runtimeType,_this.outcome,_this.accessToken,_this.refreshToken,_this.user,_this.provider,_this.confirmationId,_this.verificationId);
}

@override
String toString() {
  final _this = this as LoginGoogleResponse;
  return 'LoginGoogleResponse(outcome: ${_this.outcome}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, user: ${_this.user}, provider: ${_this.provider}, confirmationId: ${_this.confirmationId}, verificationId: ${_this.verificationId})';
}


}

/// @nodoc
abstract mixin class $LoginGoogleResponseCopyWith<$Res>  {
  factory $LoginGoogleResponseCopyWith(LoginGoogleResponse value, $Res Function(LoginGoogleResponse) _then) = _$LoginGoogleResponseCopyWithImpl;
@useResult
$Res call({
 String outcome,@JsonKey(name: 'access_token') String? accessToken,@JsonKey(name: 'refresh_token') String? refreshToken, AuthUser? user, String? provider,@JsonKey(name: 'confirmation_id') String? confirmationId,@JsonKey(name: 'verification_id') String? verificationId
});


$AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$LoginGoogleResponseCopyWithImpl<$Res>
    implements $LoginGoogleResponseCopyWith<$Res> {
  _$LoginGoogleResponseCopyWithImpl(this._self, this._then);

  final LoginGoogleResponse _self;
  final $Res Function(LoginGoogleResponse) _then;

/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcome = null,Object? accessToken = freezed,Object? refreshToken = freezed,Object? user = freezed,Object? provider = freezed,Object? confirmationId = freezed,Object? verificationId = freezed,}) {
  return _then(LoginGoogleResponse(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,confirmationId: freezed == confirmationId ? _self.confirmationId : confirmationId // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginGoogleResponse].
extension LoginGoogleResponsePatterns on LoginGoogleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginGoogleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginGoogleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginGoogleResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginGoogleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginGoogleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginGoogleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outcome, @JsonKey(name: 'access_token')  String? accessToken, @JsonKey(name: 'refresh_token')  String? refreshToken,  AuthUser? user,  String? provider, @JsonKey(name: 'confirmation_id')  String? confirmationId, @JsonKey(name: 'verification_id')  String? verificationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginGoogleResponse() when $default != null:
return $default(_that.outcome,_that.accessToken,_that.refreshToken,_that.user,_that.provider,_that.confirmationId,_that.verificationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outcome, @JsonKey(name: 'access_token')  String? accessToken, @JsonKey(name: 'refresh_token')  String? refreshToken,  AuthUser? user,  String? provider, @JsonKey(name: 'confirmation_id')  String? confirmationId, @JsonKey(name: 'verification_id')  String? verificationId)  $default,) {final _that = this;
switch (_that) {
case _LoginGoogleResponse():
return $default(_that.outcome,_that.accessToken,_that.refreshToken,_that.user,_that.provider,_that.confirmationId,_that.verificationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outcome, @JsonKey(name: 'access_token')  String? accessToken, @JsonKey(name: 'refresh_token')  String? refreshToken,  AuthUser? user,  String? provider, @JsonKey(name: 'confirmation_id')  String? confirmationId, @JsonKey(name: 'verification_id')  String? verificationId)?  $default,) {final _that = this;
switch (_that) {
case _LoginGoogleResponse() when $default != null:
return $default(_that.outcome,_that.accessToken,_that.refreshToken,_that.user,_that.provider,_that.confirmationId,_that.verificationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginGoogleResponse implements LoginGoogleResponse {
  const _LoginGoogleResponse({required this.outcome, @JsonKey(name: 'access_token') this.accessToken, @JsonKey(name: 'refresh_token') this.refreshToken, this.user, this.provider, @JsonKey(name: 'confirmation_id') this.confirmationId, @JsonKey(name: 'verification_id') this.verificationId});
  factory _LoginGoogleResponse.fromJson(Map<String, dynamic> json) => _$LoginGoogleResponseFromJson(json);

@override final  String outcome;
@override@JsonKey(name: 'access_token') final  String? accessToken;
@override@JsonKey(name: 'refresh_token') final  String? refreshToken;
@override final  AuthUser? user;
@override final  String? provider;
@override@JsonKey(name: 'confirmation_id') final  String? confirmationId;
@override@JsonKey(name: 'verification_id') final  String? verificationId;

/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginGoogleResponseCopyWith<_LoginGoogleResponse> get copyWith => __$LoginGoogleResponseCopyWithImpl<_LoginGoogleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginGoogleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginGoogleResponse&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.user, user) || other.user == user)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.confirmationId, confirmationId) || other.confirmationId == confirmationId)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,outcome,accessToken,refreshToken,user,provider,confirmationId,verificationId);
}

@override
String toString() {
    return 'LoginGoogleResponse(outcome: $outcome, accessToken: $accessToken, refreshToken: $refreshToken, user: $user, provider: $provider, confirmationId: $confirmationId, verificationId: $verificationId)';
}


}

/// @nodoc
abstract mixin class _$LoginGoogleResponseCopyWith<$Res> implements $LoginGoogleResponseCopyWith<$Res> {
  factory _$LoginGoogleResponseCopyWith(_LoginGoogleResponse value, $Res Function(_LoginGoogleResponse) _then) = __$LoginGoogleResponseCopyWithImpl;
@override @useResult
$Res call({
 String outcome,@JsonKey(name: 'access_token') String? accessToken,@JsonKey(name: 'refresh_token') String? refreshToken, AuthUser? user, String? provider,@JsonKey(name: 'confirmation_id') String? confirmationId,@JsonKey(name: 'verification_id') String? verificationId
});


@override $AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$LoginGoogleResponseCopyWithImpl<$Res>
    implements _$LoginGoogleResponseCopyWith<$Res> {
  __$LoginGoogleResponseCopyWithImpl(this._self, this._then);

  final _LoginGoogleResponse _self;
  final $Res Function(_LoginGoogleResponse) _then;

/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcome = null,Object? accessToken = freezed,Object? refreshToken = freezed,Object? user = freezed,Object? provider = freezed,Object? confirmationId = freezed,Object? verificationId = freezed,}) {
  return _then(_LoginGoogleResponse(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,confirmationId: freezed == confirmationId ? _self.confirmationId : confirmationId // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LoginGoogleResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
