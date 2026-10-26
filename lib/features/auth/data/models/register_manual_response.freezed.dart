// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_manual_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterManualResponse {

@JsonKey(name: 'verification_id') String get verificationId;@JsonKey(name: 'verification_status') String? get verificationStatus;
/// Create a copy of RegisterManualResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterManualResponseCopyWith<RegisterManualResponse> get copyWith => _$RegisterManualResponseCopyWithImpl<RegisterManualResponse>(this as RegisterManualResponse, _$identity);

  /// Serializes this RegisterManualResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterManualResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterManualResponse&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId)&&(identical(other.verificationStatus, _this.verificationStatus) || other.verificationStatus == _this.verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterManualResponse;
  return Object.hash(runtimeType,_this.verificationId,_this.verificationStatus);
}

@override
String toString() {
  final _this = this as RegisterManualResponse;
  return 'RegisterManualResponse(verificationId: ${_this.verificationId}, verificationStatus: ${_this.verificationStatus})';
}


}

/// @nodoc
abstract mixin class $RegisterManualResponseCopyWith<$Res>  {
  factory $RegisterManualResponseCopyWith(RegisterManualResponse value, $Res Function(RegisterManualResponse) _then) = _$RegisterManualResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId,@JsonKey(name: 'verification_status') String? verificationStatus
});




}
/// @nodoc
class _$RegisterManualResponseCopyWithImpl<$Res>
    implements $RegisterManualResponseCopyWith<$Res> {
  _$RegisterManualResponseCopyWithImpl(this._self, this._then);

  final RegisterManualResponse _self;
  final $Res Function(RegisterManualResponse) _then;

/// Create a copy of RegisterManualResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationId = null,Object? verificationStatus = freezed,}) {
  return _then(RegisterManualResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterManualResponse].
extension RegisterManualResponsePatterns on RegisterManualResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterManualResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterManualResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterManualResponse value)  $default,){
final _that = this;
switch (_that) {
case _RegisterManualResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterManualResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterManualResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId, @JsonKey(name: 'verification_status')  String? verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterManualResponse() when $default != null:
return $default(_that.verificationId,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId, @JsonKey(name: 'verification_status')  String? verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _RegisterManualResponse():
return $default(_that.verificationId,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'verification_id')  String verificationId, @JsonKey(name: 'verification_status')  String? verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _RegisterManualResponse() when $default != null:
return $default(_that.verificationId,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterManualResponse extends RegisterManualResponse {
  const _RegisterManualResponse({@JsonKey(name: 'verification_id') required this.verificationId, @JsonKey(name: 'verification_status') this.verificationStatus}): super._();
  factory _RegisterManualResponse.fromJson(Map<String, dynamic> json) => _$RegisterManualResponseFromJson(json);

@override@JsonKey(name: 'verification_id') final  String verificationId;
@override@JsonKey(name: 'verification_status') final  String? verificationStatus;

/// Create a copy of RegisterManualResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterManualResponseCopyWith<_RegisterManualResponse> get copyWith => __$RegisterManualResponseCopyWithImpl<_RegisterManualResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterManualResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterManualResponse&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verificationId,verificationStatus);
}

@override
String toString() {
    return 'RegisterManualResponse(verificationId: $verificationId, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$RegisterManualResponseCopyWith<$Res> implements $RegisterManualResponseCopyWith<$Res> {
  factory _$RegisterManualResponseCopyWith(_RegisterManualResponse value, $Res Function(_RegisterManualResponse) _then) = __$RegisterManualResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId,@JsonKey(name: 'verification_status') String? verificationStatus
});




}
/// @nodoc
class __$RegisterManualResponseCopyWithImpl<$Res>
    implements _$RegisterManualResponseCopyWith<$Res> {
  __$RegisterManualResponseCopyWithImpl(this._self, this._then);

  final _RegisterManualResponse _self;
  final $Res Function(_RegisterManualResponse) _then;

/// Create a copy of RegisterManualResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationId = null,Object? verificationStatus = freezed,}) {
  return _then(_RegisterManualResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
