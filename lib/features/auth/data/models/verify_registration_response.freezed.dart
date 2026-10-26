// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_registration_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyRegistrationResponse {

@JsonKey(name: 'registration_continuation_token') String get registrationContinuationToken;
/// Create a copy of VerifyRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyRegistrationResponseCopyWith<VerifyRegistrationResponse> get copyWith => _$VerifyRegistrationResponseCopyWithImpl<VerifyRegistrationResponse>(this as VerifyRegistrationResponse, _$identity);

  /// Serializes this VerifyRegistrationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifyRegistrationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyRegistrationResponse&&(identical(other.registrationContinuationToken, _this.registrationContinuationToken) || other.registrationContinuationToken == _this.registrationContinuationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifyRegistrationResponse;
  return Object.hash(runtimeType,_this.registrationContinuationToken);
}

@override
String toString() {
  final _this = this as VerifyRegistrationResponse;
  return 'VerifyRegistrationResponse(registrationContinuationToken: ${_this.registrationContinuationToken})';
}


}

/// @nodoc
abstract mixin class $VerifyRegistrationResponseCopyWith<$Res>  {
  factory $VerifyRegistrationResponseCopyWith(VerifyRegistrationResponse value, $Res Function(VerifyRegistrationResponse) _then) = _$VerifyRegistrationResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'registration_continuation_token') String registrationContinuationToken
});




}
/// @nodoc
class _$VerifyRegistrationResponseCopyWithImpl<$Res>
    implements $VerifyRegistrationResponseCopyWith<$Res> {
  _$VerifyRegistrationResponseCopyWithImpl(this._self, this._then);

  final VerifyRegistrationResponse _self;
  final $Res Function(VerifyRegistrationResponse) _then;

/// Create a copy of VerifyRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registrationContinuationToken = null,}) {
  return _then(VerifyRegistrationResponse(
registrationContinuationToken: null == registrationContinuationToken ? _self.registrationContinuationToken : registrationContinuationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyRegistrationResponse].
extension VerifyRegistrationResponsePatterns on VerifyRegistrationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyRegistrationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyRegistrationResponse value)  $default,){
final _that = this;
switch (_that) {
case _VerifyRegistrationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyRegistrationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'registration_continuation_token')  String registrationContinuationToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyRegistrationResponse() when $default != null:
return $default(_that.registrationContinuationToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'registration_continuation_token')  String registrationContinuationToken)  $default,) {final _that = this;
switch (_that) {
case _VerifyRegistrationResponse():
return $default(_that.registrationContinuationToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'registration_continuation_token')  String registrationContinuationToken)?  $default,) {final _that = this;
switch (_that) {
case _VerifyRegistrationResponse() when $default != null:
return $default(_that.registrationContinuationToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyRegistrationResponse implements VerifyRegistrationResponse {
  const _VerifyRegistrationResponse({@JsonKey(name: 'registration_continuation_token') required this.registrationContinuationToken});
  factory _VerifyRegistrationResponse.fromJson(Map<String, dynamic> json) => _$VerifyRegistrationResponseFromJson(json);

@override@JsonKey(name: 'registration_continuation_token') final  String registrationContinuationToken;

/// Create a copy of VerifyRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyRegistrationResponseCopyWith<_VerifyRegistrationResponse> get copyWith => __$VerifyRegistrationResponseCopyWithImpl<_VerifyRegistrationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyRegistrationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyRegistrationResponse&&(identical(other.registrationContinuationToken, registrationContinuationToken) || other.registrationContinuationToken == registrationContinuationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,registrationContinuationToken);
}

@override
String toString() {
    return 'VerifyRegistrationResponse(registrationContinuationToken: $registrationContinuationToken)';
}


}

/// @nodoc
abstract mixin class _$VerifyRegistrationResponseCopyWith<$Res> implements $VerifyRegistrationResponseCopyWith<$Res> {
  factory _$VerifyRegistrationResponseCopyWith(_VerifyRegistrationResponse value, $Res Function(_VerifyRegistrationResponse) _then) = __$VerifyRegistrationResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'registration_continuation_token') String registrationContinuationToken
});




}
/// @nodoc
class __$VerifyRegistrationResponseCopyWithImpl<$Res>
    implements _$VerifyRegistrationResponseCopyWith<$Res> {
  __$VerifyRegistrationResponseCopyWithImpl(this._self, this._then);

  final _VerifyRegistrationResponse _self;
  final $Res Function(_VerifyRegistrationResponse) _then;

/// Create a copy of VerifyRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registrationContinuationToken = null,}) {
  return _then(_VerifyRegistrationResponse(
registrationContinuationToken: null == registrationContinuationToken ? _self.registrationContinuationToken : registrationContinuationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
