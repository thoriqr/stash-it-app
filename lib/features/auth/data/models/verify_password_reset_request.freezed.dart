// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_password_reset_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyPasswordResetRequest {

 String get pin;
/// Create a copy of VerifyPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyPasswordResetRequestCopyWith<VerifyPasswordResetRequest> get copyWith => _$VerifyPasswordResetRequestCopyWithImpl<VerifyPasswordResetRequest>(this as VerifyPasswordResetRequest, _$identity);

  /// Serializes this VerifyPasswordResetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifyPasswordResetRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyPasswordResetRequest&&(identical(other.pin, _this.pin) || other.pin == _this.pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifyPasswordResetRequest;
  return Object.hash(runtimeType,_this.pin);
}

@override
String toString() {
  final _this = this as VerifyPasswordResetRequest;
  return 'VerifyPasswordResetRequest(pin: ${_this.pin})';
}


}

/// @nodoc
abstract mixin class $VerifyPasswordResetRequestCopyWith<$Res>  {
  factory $VerifyPasswordResetRequestCopyWith(VerifyPasswordResetRequest value, $Res Function(VerifyPasswordResetRequest) _then) = _$VerifyPasswordResetRequestCopyWithImpl;
@useResult
$Res call({
 String pin
});




}
/// @nodoc
class _$VerifyPasswordResetRequestCopyWithImpl<$Res>
    implements $VerifyPasswordResetRequestCopyWith<$Res> {
  _$VerifyPasswordResetRequestCopyWithImpl(this._self, this._then);

  final VerifyPasswordResetRequest _self;
  final $Res Function(VerifyPasswordResetRequest) _then;

/// Create a copy of VerifyPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pin = null,}) {
  return _then(VerifyPasswordResetRequest(
pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyPasswordResetRequest].
extension VerifyPasswordResetRequestPatterns on VerifyPasswordResetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyPasswordResetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyPasswordResetRequest value)  $default,){
final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyPasswordResetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest() when $default != null:
return $default(_that.pin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pin)  $default,) {final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest():
return $default(_that.pin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pin)?  $default,) {final _that = this;
switch (_that) {
case _VerifyPasswordResetRequest() when $default != null:
return $default(_that.pin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyPasswordResetRequest implements VerifyPasswordResetRequest {
  const _VerifyPasswordResetRequest({required this.pin});
  factory _VerifyPasswordResetRequest.fromJson(Map<String, dynamic> json) => _$VerifyPasswordResetRequestFromJson(json);

@override final  String pin;

/// Create a copy of VerifyPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyPasswordResetRequestCopyWith<_VerifyPasswordResetRequest> get copyWith => __$VerifyPasswordResetRequestCopyWithImpl<_VerifyPasswordResetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyPasswordResetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyPasswordResetRequest&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pin);
}

@override
String toString() {
    return 'VerifyPasswordResetRequest(pin: $pin)';
}


}

/// @nodoc
abstract mixin class _$VerifyPasswordResetRequestCopyWith<$Res> implements $VerifyPasswordResetRequestCopyWith<$Res> {
  factory _$VerifyPasswordResetRequestCopyWith(_VerifyPasswordResetRequest value, $Res Function(_VerifyPasswordResetRequest) _then) = __$VerifyPasswordResetRequestCopyWithImpl;
@override @useResult
$Res call({
 String pin
});




}
/// @nodoc
class __$VerifyPasswordResetRequestCopyWithImpl<$Res>
    implements _$VerifyPasswordResetRequestCopyWith<$Res> {
  __$VerifyPasswordResetRequestCopyWithImpl(this._self, this._then);

  final _VerifyPasswordResetRequest _self;
  final $Res Function(_VerifyPasswordResetRequest) _then;

/// Create a copy of VerifyPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pin = null,}) {
  return _then(_VerifyPasswordResetRequest(
pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
