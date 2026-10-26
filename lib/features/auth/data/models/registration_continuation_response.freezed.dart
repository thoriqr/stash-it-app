// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_continuation_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistrationContinuationResponse {

 String get email;@JsonKey(name: 'registration_type') String get registrationType;@JsonKey(name: 'requires_password') bool get requiresPassword;
/// Create a copy of RegistrationContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationContinuationResponseCopyWith<RegistrationContinuationResponse> get copyWith => _$RegistrationContinuationResponseCopyWithImpl<RegistrationContinuationResponse>(this as RegistrationContinuationResponse, _$identity);

  /// Serializes this RegistrationContinuationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegistrationContinuationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationContinuationResponse&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.registrationType, _this.registrationType) || other.registrationType == _this.registrationType)&&(identical(other.requiresPassword, _this.requiresPassword) || other.requiresPassword == _this.requiresPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegistrationContinuationResponse;
  return Object.hash(runtimeType,_this.email,_this.registrationType,_this.requiresPassword);
}

@override
String toString() {
  final _this = this as RegistrationContinuationResponse;
  return 'RegistrationContinuationResponse(email: ${_this.email}, registrationType: ${_this.registrationType}, requiresPassword: ${_this.requiresPassword})';
}


}

/// @nodoc
abstract mixin class $RegistrationContinuationResponseCopyWith<$Res>  {
  factory $RegistrationContinuationResponseCopyWith(RegistrationContinuationResponse value, $Res Function(RegistrationContinuationResponse) _then) = _$RegistrationContinuationResponseCopyWithImpl;
@useResult
$Res call({
 String email,@JsonKey(name: 'registration_type') String registrationType,@JsonKey(name: 'requires_password') bool requiresPassword
});




}
/// @nodoc
class _$RegistrationContinuationResponseCopyWithImpl<$Res>
    implements $RegistrationContinuationResponseCopyWith<$Res> {
  _$RegistrationContinuationResponseCopyWithImpl(this._self, this._then);

  final RegistrationContinuationResponse _self;
  final $Res Function(RegistrationContinuationResponse) _then;

/// Create a copy of RegistrationContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? registrationType = null,Object? requiresPassword = null,}) {
  return _then(RegistrationContinuationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,registrationType: null == registrationType ? _self.registrationType : registrationType // ignore: cast_nullable_to_non_nullable
as String,requiresPassword: null == requiresPassword ? _self.requiresPassword : requiresPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrationContinuationResponse].
extension RegistrationContinuationResponsePatterns on RegistrationContinuationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationContinuationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationContinuationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationContinuationResponse value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationContinuationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationContinuationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationContinuationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'registration_type')  String registrationType, @JsonKey(name: 'requires_password')  bool requiresPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationContinuationResponse() when $default != null:
return $default(_that.email,_that.registrationType,_that.requiresPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'registration_type')  String registrationType, @JsonKey(name: 'requires_password')  bool requiresPassword)  $default,) {final _that = this;
switch (_that) {
case _RegistrationContinuationResponse():
return $default(_that.email,_that.registrationType,_that.requiresPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email, @JsonKey(name: 'registration_type')  String registrationType, @JsonKey(name: 'requires_password')  bool requiresPassword)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationContinuationResponse() when $default != null:
return $default(_that.email,_that.registrationType,_that.requiresPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrationContinuationResponse implements RegistrationContinuationResponse {
  const _RegistrationContinuationResponse({required this.email, @JsonKey(name: 'registration_type') required this.registrationType, @JsonKey(name: 'requires_password') required this.requiresPassword});
  factory _RegistrationContinuationResponse.fromJson(Map<String, dynamic> json) => _$RegistrationContinuationResponseFromJson(json);

@override final  String email;
@override@JsonKey(name: 'registration_type') final  String registrationType;
@override@JsonKey(name: 'requires_password') final  bool requiresPassword;

/// Create a copy of RegistrationContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationContinuationResponseCopyWith<_RegistrationContinuationResponse> get copyWith => __$RegistrationContinuationResponseCopyWithImpl<_RegistrationContinuationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationContinuationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationContinuationResponse&&(identical(other.email, email) || other.email == email)&&(identical(other.registrationType, registrationType) || other.registrationType == registrationType)&&(identical(other.requiresPassword, requiresPassword) || other.requiresPassword == requiresPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,registrationType,requiresPassword);
}

@override
String toString() {
    return 'RegistrationContinuationResponse(email: $email, registrationType: $registrationType, requiresPassword: $requiresPassword)';
}


}

/// @nodoc
abstract mixin class _$RegistrationContinuationResponseCopyWith<$Res> implements $RegistrationContinuationResponseCopyWith<$Res> {
  factory _$RegistrationContinuationResponseCopyWith(_RegistrationContinuationResponse value, $Res Function(_RegistrationContinuationResponse) _then) = __$RegistrationContinuationResponseCopyWithImpl;
@override @useResult
$Res call({
 String email,@JsonKey(name: 'registration_type') String registrationType,@JsonKey(name: 'requires_password') bool requiresPassword
});




}
/// @nodoc
class __$RegistrationContinuationResponseCopyWithImpl<$Res>
    implements _$RegistrationContinuationResponseCopyWith<$Res> {
  __$RegistrationContinuationResponseCopyWithImpl(this._self, this._then);

  final _RegistrationContinuationResponse _self;
  final $Res Function(_RegistrationContinuationResponse) _then;

/// Create a copy of RegistrationContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? registrationType = null,Object? requiresPassword = null,}) {
  return _then(_RegistrationContinuationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,registrationType: null == registrationType ? _self.registrationType : registrationType // ignore: cast_nullable_to_non_nullable
as String,requiresPassword: null == requiresPassword ? _self.requiresPassword : requiresPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
