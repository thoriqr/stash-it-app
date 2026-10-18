// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_tokens_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthTokensResponse {

@JsonKey(name: 'access_token') String get accessToken;@JsonKey(name: 'refresh_token') String get refreshToken;
/// Create a copy of AuthTokensResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensResponseCopyWith<AuthTokensResponse> get copyWith => _$AuthTokensResponseCopyWithImpl<AuthTokensResponse>(this as AuthTokensResponse, _$identity);

  /// Serializes this AuthTokensResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthTokensResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokensResponse&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthTokensResponse;
  return Object.hash(runtimeType,_this.accessToken,_this.refreshToken);
}

@override
String toString() {
  final _this = this as AuthTokensResponse;
  return 'AuthTokensResponse(accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken})';
}


}

/// @nodoc
abstract mixin class $AuthTokensResponseCopyWith<$Res>  {
  factory $AuthTokensResponseCopyWith(AuthTokensResponse value, $Res Function(AuthTokensResponse) _then) = _$AuthTokensResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken
});




}
/// @nodoc
class _$AuthTokensResponseCopyWithImpl<$Res>
    implements $AuthTokensResponseCopyWith<$Res> {
  _$AuthTokensResponseCopyWithImpl(this._self, this._then);

  final AuthTokensResponse _self;
  final $Res Function(AuthTokensResponse) _then;

/// Create a copy of AuthTokensResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(AuthTokensResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthTokensResponse].
extension AuthTokensResponsePatterns on AuthTokensResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokensResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokensResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokensResponse value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokensResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokensResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokensResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokensResponse() when $default != null:
return $default(_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _AuthTokensResponse():
return $default(_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokensResponse() when $default != null:
return $default(_that.accessToken,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokensResponse implements AuthTokensResponse {
  const _AuthTokensResponse({@JsonKey(name: 'access_token') required this.accessToken, @JsonKey(name: 'refresh_token') required this.refreshToken});
  factory _AuthTokensResponse.fromJson(Map<String, dynamic> json) => _$AuthTokensResponseFromJson(json);

@override@JsonKey(name: 'access_token') final  String accessToken;
@override@JsonKey(name: 'refresh_token') final  String refreshToken;

/// Create a copy of AuthTokensResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensResponseCopyWith<_AuthTokensResponse> get copyWith => __$AuthTokensResponseCopyWithImpl<_AuthTokensResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokensResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokensResponse&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,refreshToken);
}

@override
String toString() {
    return 'AuthTokensResponse(accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensResponseCopyWith<$Res> implements $AuthTokensResponseCopyWith<$Res> {
  factory _$AuthTokensResponseCopyWith(_AuthTokensResponse value, $Res Function(_AuthTokensResponse) _then) = __$AuthTokensResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken
});




}
/// @nodoc
class __$AuthTokensResponseCopyWithImpl<$Res>
    implements _$AuthTokensResponseCopyWith<$Res> {
  __$AuthTokensResponseCopyWithImpl(this._self, this._then);

  final _AuthTokensResponse _self;
  final $Res Function(_AuthTokensResponse) _then;

/// Create a copy of AuthTokensResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(_AuthTokensResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
