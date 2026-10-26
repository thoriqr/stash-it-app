// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resend_verification_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResendVerificationResponse {

@JsonKey(name: 'verification_id') String get verificationId;
/// Create a copy of ResendVerificationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResendVerificationResponseCopyWith<ResendVerificationResponse> get copyWith => _$ResendVerificationResponseCopyWithImpl<ResendVerificationResponse>(this as ResendVerificationResponse, _$identity);

  /// Serializes this ResendVerificationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResendVerificationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResendVerificationResponse&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResendVerificationResponse;
  return Object.hash(runtimeType,_this.verificationId);
}

@override
String toString() {
  final _this = this as ResendVerificationResponse;
  return 'ResendVerificationResponse(verificationId: ${_this.verificationId})';
}


}

/// @nodoc
abstract mixin class $ResendVerificationResponseCopyWith<$Res>  {
  factory $ResendVerificationResponseCopyWith(ResendVerificationResponse value, $Res Function(ResendVerificationResponse) _then) = _$ResendVerificationResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId
});




}
/// @nodoc
class _$ResendVerificationResponseCopyWithImpl<$Res>
    implements $ResendVerificationResponseCopyWith<$Res> {
  _$ResendVerificationResponseCopyWithImpl(this._self, this._then);

  final ResendVerificationResponse _self;
  final $Res Function(ResendVerificationResponse) _then;

/// Create a copy of ResendVerificationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationId = null,}) {
  return _then(ResendVerificationResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResendVerificationResponse].
extension ResendVerificationResponsePatterns on ResendVerificationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResendVerificationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResendVerificationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResendVerificationResponse value)  $default,){
final _that = this;
switch (_that) {
case _ResendVerificationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResendVerificationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ResendVerificationResponse() when $default != null:
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
case _ResendVerificationResponse() when $default != null:
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
case _ResendVerificationResponse():
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
case _ResendVerificationResponse() when $default != null:
return $default(_that.verificationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResendVerificationResponse implements ResendVerificationResponse {
  const _ResendVerificationResponse({@JsonKey(name: 'verification_id') required this.verificationId});
  factory _ResendVerificationResponse.fromJson(Map<String, dynamic> json) => _$ResendVerificationResponseFromJson(json);

@override@JsonKey(name: 'verification_id') final  String verificationId;

/// Create a copy of ResendVerificationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResendVerificationResponseCopyWith<_ResendVerificationResponse> get copyWith => __$ResendVerificationResponseCopyWithImpl<_ResendVerificationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResendVerificationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResendVerificationResponse&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verificationId);
}

@override
String toString() {
    return 'ResendVerificationResponse(verificationId: $verificationId)';
}


}

/// @nodoc
abstract mixin class _$ResendVerificationResponseCopyWith<$Res> implements $ResendVerificationResponseCopyWith<$Res> {
  factory _$ResendVerificationResponseCopyWith(_ResendVerificationResponse value, $Res Function(_ResendVerificationResponse) _then) = __$ResendVerificationResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId
});




}
/// @nodoc
class __$ResendVerificationResponseCopyWithImpl<$Res>
    implements _$ResendVerificationResponseCopyWith<$Res> {
  __$ResendVerificationResponseCopyWithImpl(this._self, this._then);

  final _ResendVerificationResponse _self;
  final $Res Function(_ResendVerificationResponse) _then;

/// Create a copy of ResendVerificationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationId = null,}) {
  return _then(_ResendVerificationResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
