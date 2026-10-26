// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_registration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyRegistrationRequest {

@JsonKey(name: 'pin') String get pin;
/// Create a copy of VerifyRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyRegistrationRequestCopyWith<VerifyRegistrationRequest> get copyWith => _$VerifyRegistrationRequestCopyWithImpl<VerifyRegistrationRequest>(this as VerifyRegistrationRequest, _$identity);

  /// Serializes this VerifyRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifyRegistrationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyRegistrationRequest&&(identical(other.pin, _this.pin) || other.pin == _this.pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifyRegistrationRequest;
  return Object.hash(runtimeType,_this.pin);
}

@override
String toString() {
  final _this = this as VerifyRegistrationRequest;
  return 'VerifyRegistrationRequest(pin: ${_this.pin})';
}


}

/// @nodoc
abstract mixin class $VerifyRegistrationRequestCopyWith<$Res>  {
  factory $VerifyRegistrationRequestCopyWith(VerifyRegistrationRequest value, $Res Function(VerifyRegistrationRequest) _then) = _$VerifyRegistrationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pin') String pin
});




}
/// @nodoc
class _$VerifyRegistrationRequestCopyWithImpl<$Res>
    implements $VerifyRegistrationRequestCopyWith<$Res> {
  _$VerifyRegistrationRequestCopyWithImpl(this._self, this._then);

  final VerifyRegistrationRequest _self;
  final $Res Function(VerifyRegistrationRequest) _then;

/// Create a copy of VerifyRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pin = null,}) {
  return _then(VerifyRegistrationRequest(
pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyRegistrationRequest].
extension VerifyRegistrationRequestPatterns on VerifyRegistrationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyRegistrationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyRegistrationRequest value)  $default,){
final _that = this;
switch (_that) {
case _VerifyRegistrationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyRegistrationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pin')  String pin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pin')  String pin)  $default,) {final _that = this;
switch (_that) {
case _VerifyRegistrationRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pin')  String pin)?  $default,) {final _that = this;
switch (_that) {
case _VerifyRegistrationRequest() when $default != null:
return $default(_that.pin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyRegistrationRequest implements VerifyRegistrationRequest {
  const _VerifyRegistrationRequest({@JsonKey(name: 'pin') required this.pin});
  factory _VerifyRegistrationRequest.fromJson(Map<String, dynamic> json) => _$VerifyRegistrationRequestFromJson(json);

@override@JsonKey(name: 'pin') final  String pin;

/// Create a copy of VerifyRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyRegistrationRequestCopyWith<_VerifyRegistrationRequest> get copyWith => __$VerifyRegistrationRequestCopyWithImpl<_VerifyRegistrationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyRegistrationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyRegistrationRequest&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pin);
}

@override
String toString() {
    return 'VerifyRegistrationRequest(pin: $pin)';
}


}

/// @nodoc
abstract mixin class _$VerifyRegistrationRequestCopyWith<$Res> implements $VerifyRegistrationRequestCopyWith<$Res> {
  factory _$VerifyRegistrationRequestCopyWith(_VerifyRegistrationRequest value, $Res Function(_VerifyRegistrationRequest) _then) = __$VerifyRegistrationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pin') String pin
});




}
/// @nodoc
class __$VerifyRegistrationRequestCopyWithImpl<$Res>
    implements _$VerifyRegistrationRequestCopyWith<$Res> {
  __$VerifyRegistrationRequestCopyWithImpl(this._self, this._then);

  final _VerifyRegistrationRequest _self;
  final $Res Function(_VerifyRegistrationRequest) _then;

/// Create a copy of VerifyRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pin = null,}) {
  return _then(_VerifyRegistrationRequest(
pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
