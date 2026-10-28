// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_password_reset_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestPasswordResetResponse {

@JsonKey(name: 'verification_id') String get verificationId;
/// Create a copy of RequestPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestPasswordResetResponseCopyWith<RequestPasswordResetResponse> get copyWith => _$RequestPasswordResetResponseCopyWithImpl<RequestPasswordResetResponse>(this as RequestPasswordResetResponse, _$identity);

  /// Serializes this RequestPasswordResetResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RequestPasswordResetResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestPasswordResetResponse&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RequestPasswordResetResponse;
  return Object.hash(runtimeType,_this.verificationId);
}

@override
String toString() {
  final _this = this as RequestPasswordResetResponse;
  return 'RequestPasswordResetResponse(verificationId: ${_this.verificationId})';
}


}

/// @nodoc
abstract mixin class $RequestPasswordResetResponseCopyWith<$Res>  {
  factory $RequestPasswordResetResponseCopyWith(RequestPasswordResetResponse value, $Res Function(RequestPasswordResetResponse) _then) = _$RequestPasswordResetResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId
});




}
/// @nodoc
class _$RequestPasswordResetResponseCopyWithImpl<$Res>
    implements $RequestPasswordResetResponseCopyWith<$Res> {
  _$RequestPasswordResetResponseCopyWithImpl(this._self, this._then);

  final RequestPasswordResetResponse _self;
  final $Res Function(RequestPasswordResetResponse) _then;

/// Create a copy of RequestPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationId = null,}) {
  return _then(RequestPasswordResetResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestPasswordResetResponse].
extension RequestPasswordResetResponsePatterns on RequestPasswordResetResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestPasswordResetResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestPasswordResetResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestPasswordResetResponse value)  $default,){
final _that = this;
switch (_that) {
case _RequestPasswordResetResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestPasswordResetResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RequestPasswordResetResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestPasswordResetResponse() when $default != null:
return $default(_that.verificationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId)  $default,) {final _that = this;
switch (_that) {
case _RequestPasswordResetResponse():
return $default(_that.verificationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'verification_id')  String verificationId)?  $default,) {final _that = this;
switch (_that) {
case _RequestPasswordResetResponse() when $default != null:
return $default(_that.verificationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestPasswordResetResponse implements RequestPasswordResetResponse {
  const _RequestPasswordResetResponse({@JsonKey(name: 'verification_id') required this.verificationId});
  factory _RequestPasswordResetResponse.fromJson(Map<String, dynamic> json) => _$RequestPasswordResetResponseFromJson(json);

@override@JsonKey(name: 'verification_id') final  String verificationId;

/// Create a copy of RequestPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestPasswordResetResponseCopyWith<_RequestPasswordResetResponse> get copyWith => __$RequestPasswordResetResponseCopyWithImpl<_RequestPasswordResetResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestPasswordResetResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestPasswordResetResponse&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verificationId);
}

@override
String toString() {
    return 'RequestPasswordResetResponse(verificationId: $verificationId)';
}


}

/// @nodoc
abstract mixin class _$RequestPasswordResetResponseCopyWith<$Res> implements $RequestPasswordResetResponseCopyWith<$Res> {
  factory _$RequestPasswordResetResponseCopyWith(_RequestPasswordResetResponse value, $Res Function(_RequestPasswordResetResponse) _then) = __$RequestPasswordResetResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId
});




}
/// @nodoc
class __$RequestPasswordResetResponseCopyWithImpl<$Res>
    implements _$RequestPasswordResetResponseCopyWith<$Res> {
  __$RequestPasswordResetResponseCopyWithImpl(this._self, this._then);

  final _RequestPasswordResetResponse _self;
  final $Res Function(_RequestPasswordResetResponse) _then;

/// Create a copy of RequestPasswordResetResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationId = null,}) {
  return _then(_RequestPasswordResetResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
