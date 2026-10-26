// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationStatusResponse {

@JsonKey(name: 'verification_id') String get verificationId; String get status;@JsonKey(name: 'pin_issued') bool get pinIssued;@JsonKey(name: 'resend_in_seconds') int get resendInSeconds;
/// Create a copy of VerificationStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationStatusResponseCopyWith<VerificationStatusResponse> get copyWith => _$VerificationStatusResponseCopyWithImpl<VerificationStatusResponse>(this as VerificationStatusResponse, _$identity);

  /// Serializes this VerificationStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerificationStatusResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationStatusResponse&&(identical(other.verificationId, _this.verificationId) || other.verificationId == _this.verificationId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pinIssued, _this.pinIssued) || other.pinIssued == _this.pinIssued)&&(identical(other.resendInSeconds, _this.resendInSeconds) || other.resendInSeconds == _this.resendInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerificationStatusResponse;
  return Object.hash(runtimeType,_this.verificationId,_this.status,_this.pinIssued,_this.resendInSeconds);
}

@override
String toString() {
  final _this = this as VerificationStatusResponse;
  return 'VerificationStatusResponse(verificationId: ${_this.verificationId}, status: ${_this.status}, pinIssued: ${_this.pinIssued}, resendInSeconds: ${_this.resendInSeconds})';
}


}

/// @nodoc
abstract mixin class $VerificationStatusResponseCopyWith<$Res>  {
  factory $VerificationStatusResponseCopyWith(VerificationStatusResponse value, $Res Function(VerificationStatusResponse) _then) = _$VerificationStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId, String status,@JsonKey(name: 'pin_issued') bool pinIssued,@JsonKey(name: 'resend_in_seconds') int resendInSeconds
});




}
/// @nodoc
class _$VerificationStatusResponseCopyWithImpl<$Res>
    implements $VerificationStatusResponseCopyWith<$Res> {
  _$VerificationStatusResponseCopyWithImpl(this._self, this._then);

  final VerificationStatusResponse _self;
  final $Res Function(VerificationStatusResponse) _then;

/// Create a copy of VerificationStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationId = null,Object? status = null,Object? pinIssued = null,Object? resendInSeconds = null,}) {
  return _then(VerificationStatusResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pinIssued: null == pinIssued ? _self.pinIssued : pinIssued // ignore: cast_nullable_to_non_nullable
as bool,resendInSeconds: null == resendInSeconds ? _self.resendInSeconds : resendInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationStatusResponse].
extension VerificationStatusResponsePatterns on VerificationStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _VerificationStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId,  String status, @JsonKey(name: 'pin_issued')  bool pinIssued, @JsonKey(name: 'resend_in_seconds')  int resendInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationStatusResponse() when $default != null:
return $default(_that.verificationId,_that.status,_that.pinIssued,_that.resendInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'verification_id')  String verificationId,  String status, @JsonKey(name: 'pin_issued')  bool pinIssued, @JsonKey(name: 'resend_in_seconds')  int resendInSeconds)  $default,) {final _that = this;
switch (_that) {
case _VerificationStatusResponse():
return $default(_that.verificationId,_that.status,_that.pinIssued,_that.resendInSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'verification_id')  String verificationId,  String status, @JsonKey(name: 'pin_issued')  bool pinIssued, @JsonKey(name: 'resend_in_seconds')  int resendInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _VerificationStatusResponse() when $default != null:
return $default(_that.verificationId,_that.status,_that.pinIssued,_that.resendInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationStatusResponse implements VerificationStatusResponse {
  const _VerificationStatusResponse({@JsonKey(name: 'verification_id') required this.verificationId, required this.status, @JsonKey(name: 'pin_issued') required this.pinIssued, @JsonKey(name: 'resend_in_seconds') required this.resendInSeconds});
  factory _VerificationStatusResponse.fromJson(Map<String, dynamic> json) => _$VerificationStatusResponseFromJson(json);

@override@JsonKey(name: 'verification_id') final  String verificationId;
@override final  String status;
@override@JsonKey(name: 'pin_issued') final  bool pinIssued;
@override@JsonKey(name: 'resend_in_seconds') final  int resendInSeconds;

/// Create a copy of VerificationStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationStatusResponseCopyWith<_VerificationStatusResponse> get copyWith => __$VerificationStatusResponseCopyWithImpl<_VerificationStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationStatusResponse&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pinIssued, pinIssued) || other.pinIssued == pinIssued)&&(identical(other.resendInSeconds, resendInSeconds) || other.resendInSeconds == resendInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verificationId,status,pinIssued,resendInSeconds);
}

@override
String toString() {
    return 'VerificationStatusResponse(verificationId: $verificationId, status: $status, pinIssued: $pinIssued, resendInSeconds: $resendInSeconds)';
}


}

/// @nodoc
abstract mixin class _$VerificationStatusResponseCopyWith<$Res> implements $VerificationStatusResponseCopyWith<$Res> {
  factory _$VerificationStatusResponseCopyWith(_VerificationStatusResponse value, $Res Function(_VerificationStatusResponse) _then) = __$VerificationStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'verification_id') String verificationId, String status,@JsonKey(name: 'pin_issued') bool pinIssued,@JsonKey(name: 'resend_in_seconds') int resendInSeconds
});




}
/// @nodoc
class __$VerificationStatusResponseCopyWithImpl<$Res>
    implements _$VerificationStatusResponseCopyWith<$Res> {
  __$VerificationStatusResponseCopyWithImpl(this._self, this._then);

  final _VerificationStatusResponse _self;
  final $Res Function(_VerificationStatusResponse) _then;

/// Create a copy of VerificationStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationId = null,Object? status = null,Object? pinIssued = null,Object? resendInSeconds = null,}) {
  return _then(_VerificationStatusResponse(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pinIssued: null == pinIssued ? _self.pinIssued : pinIssued // ignore: cast_nullable_to_non_nullable
as bool,resendInSeconds: null == resendInSeconds ? _self.resendInSeconds : resendInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
