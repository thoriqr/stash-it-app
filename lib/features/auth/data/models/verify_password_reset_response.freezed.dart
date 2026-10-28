// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_password_reset_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyPasswordResetResponse {

@JsonKey(name: 'password_reset_continuation_token') String get passwordResetContinuationToken;
/// Create a copy of VerifyPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyPasswordResetResponseCopyWith<VerifyPasswordResetResponse> get copyWith => _$VerifyPasswordResetResponseCopyWithImpl<VerifyPasswordResetResponse>(this as VerifyPasswordResetResponse, _$identity);

  /// Serializes this VerifyPasswordResetResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifyPasswordResetResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyPasswordResetResponse&&(identical(other.passwordResetContinuationToken, _this.passwordResetContinuationToken) || other.passwordResetContinuationToken == _this.passwordResetContinuationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifyPasswordResetResponse;
  return Object.hash(runtimeType,_this.passwordResetContinuationToken);
}

@override
String toString() {
  final _this = this as VerifyPasswordResetResponse;
  return 'VerifyPasswordResetResponse(passwordResetContinuationToken: ${_this.passwordResetContinuationToken})';
}


}

/// @nodoc
abstract mixin class $VerifyPasswordResetResponseCopyWith<$Res>  {
  factory $VerifyPasswordResetResponseCopyWith(VerifyPasswordResetResponse value, $Res Function(VerifyPasswordResetResponse) _then) = _$VerifyPasswordResetResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'password_reset_continuation_token') String passwordResetContinuationToken
});




}
/// @nodoc
class _$VerifyPasswordResetResponseCopyWithImpl<$Res>
    implements $VerifyPasswordResetResponseCopyWith<$Res> {
  _$VerifyPasswordResetResponseCopyWithImpl(this._self, this._then);

  final VerifyPasswordResetResponse _self;
  final $Res Function(VerifyPasswordResetResponse) _then;

/// Create a copy of VerifyPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passwordResetContinuationToken = null,}) {
  return _then(VerifyPasswordResetResponse(
passwordResetContinuationToken: null == passwordResetContinuationToken ? _self.passwordResetContinuationToken : passwordResetContinuationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyPasswordResetResponse].
extension VerifyPasswordResetResponsePatterns on VerifyPasswordResetResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyPasswordResetResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyPasswordResetResponse value)  $default,){
final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyPasswordResetResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'password_reset_continuation_token')  String passwordResetContinuationToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse() when $default != null:
return $default(_that.passwordResetContinuationToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'password_reset_continuation_token')  String passwordResetContinuationToken)  $default,) {final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse():
return $default(_that.passwordResetContinuationToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'password_reset_continuation_token')  String passwordResetContinuationToken)?  $default,) {final _that = this;
switch (_that) {
case _VerifyPasswordResetResponse() when $default != null:
return $default(_that.passwordResetContinuationToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyPasswordResetResponse implements VerifyPasswordResetResponse {
  const _VerifyPasswordResetResponse({@JsonKey(name: 'password_reset_continuation_token') required this.passwordResetContinuationToken});
  factory _VerifyPasswordResetResponse.fromJson(Map<String, dynamic> json) => _$VerifyPasswordResetResponseFromJson(json);

@override@JsonKey(name: 'password_reset_continuation_token') final  String passwordResetContinuationToken;

/// Create a copy of VerifyPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyPasswordResetResponseCopyWith<_VerifyPasswordResetResponse> get copyWith => __$VerifyPasswordResetResponseCopyWithImpl<_VerifyPasswordResetResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyPasswordResetResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyPasswordResetResponse&&(identical(other.passwordResetContinuationToken, passwordResetContinuationToken) || other.passwordResetContinuationToken == passwordResetContinuationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,passwordResetContinuationToken);
}

@override
String toString() {
    return 'VerifyPasswordResetResponse(passwordResetContinuationToken: $passwordResetContinuationToken)';
}


}

/// @nodoc
abstract mixin class _$VerifyPasswordResetResponseCopyWith<$Res> implements $VerifyPasswordResetResponseCopyWith<$Res> {
  factory _$VerifyPasswordResetResponseCopyWith(_VerifyPasswordResetResponse value, $Res Function(_VerifyPasswordResetResponse) _then) = __$VerifyPasswordResetResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'password_reset_continuation_token') String passwordResetContinuationToken
});




}
/// @nodoc
class __$VerifyPasswordResetResponseCopyWithImpl<$Res>
    implements _$VerifyPasswordResetResponseCopyWith<$Res> {
  __$VerifyPasswordResetResponseCopyWithImpl(this._self, this._then);

  final _VerifyPasswordResetResponse _self;
  final $Res Function(_VerifyPasswordResetResponse) _then;

/// Create a copy of VerifyPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passwordResetContinuationToken = null,}) {
  return _then(_VerifyPasswordResetResponse(
passwordResetContinuationToken: null == passwordResetContinuationToken ? _self.passwordResetContinuationToken : passwordResetContinuationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
