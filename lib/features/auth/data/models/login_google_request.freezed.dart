// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_google_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginGoogleRequest {

@JsonKey(name: 'id_token') String get idToken;
/// Create a copy of LoginGoogleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginGoogleRequestCopyWith<LoginGoogleRequest> get copyWith => _$LoginGoogleRequestCopyWithImpl<LoginGoogleRequest>(this as LoginGoogleRequest, _$identity);

  /// Serializes this LoginGoogleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoginGoogleRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginGoogleRequest&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoginGoogleRequest;
  return Object.hash(runtimeType,_this.idToken);
}

@override
String toString() {
  final _this = this as LoginGoogleRequest;
  return 'LoginGoogleRequest(idToken: ${_this.idToken})';
}


}

/// @nodoc
abstract mixin class $LoginGoogleRequestCopyWith<$Res>  {
  factory $LoginGoogleRequestCopyWith(LoginGoogleRequest value, $Res Function(LoginGoogleRequest) _then) = _$LoginGoogleRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class _$LoginGoogleRequestCopyWithImpl<$Res>
    implements $LoginGoogleRequestCopyWith<$Res> {
  _$LoginGoogleRequestCopyWithImpl(this._self, this._then);

  final LoginGoogleRequest _self;
  final $Res Function(LoginGoogleRequest) _then;

/// Create a copy of LoginGoogleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,}) {
  return _then(LoginGoogleRequest(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginGoogleRequest].
extension LoginGoogleRequestPatterns on LoginGoogleRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginGoogleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginGoogleRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginGoogleRequest value)  $default,){
final _that = this;
switch (_that) {
case _LoginGoogleRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginGoogleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LoginGoogleRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginGoogleRequest() when $default != null:
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)  $default,) {final _that = this;
switch (_that) {
case _LoginGoogleRequest():
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_token')  String idToken)?  $default,) {final _that = this;
switch (_that) {
case _LoginGoogleRequest() when $default != null:
return $default(_that.idToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginGoogleRequest implements LoginGoogleRequest {
  const _LoginGoogleRequest({@JsonKey(name: 'id_token') required this.idToken});
  factory _LoginGoogleRequest.fromJson(Map<String, dynamic> json) => _$LoginGoogleRequestFromJson(json);

@override@JsonKey(name: 'id_token') final  String idToken;

/// Create a copy of LoginGoogleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginGoogleRequestCopyWith<_LoginGoogleRequest> get copyWith => __$LoginGoogleRequestCopyWithImpl<_LoginGoogleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginGoogleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginGoogleRequest&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idToken);
}

@override
String toString() {
    return 'LoginGoogleRequest(idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class _$LoginGoogleRequestCopyWith<$Res> implements $LoginGoogleRequestCopyWith<$Res> {
  factory _$LoginGoogleRequestCopyWith(_LoginGoogleRequest value, $Res Function(_LoginGoogleRequest) _then) = __$LoginGoogleRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class __$LoginGoogleRequestCopyWithImpl<$Res>
    implements _$LoginGoogleRequestCopyWith<$Res> {
  __$LoginGoogleRequestCopyWithImpl(this._self, this._then);

  final _LoginGoogleRequest _self;
  final $Res Function(_LoginGoogleRequest) _then;

/// Create a copy of LoginGoogleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,}) {
  return _then(_LoginGoogleRequest(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
