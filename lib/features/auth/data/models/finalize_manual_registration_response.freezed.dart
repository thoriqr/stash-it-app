// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finalize_manual_registration_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinalizeManualRegistrationResponse {

 String get email;@JsonKey(name: 'display_name') String get displayName;
/// Create a copy of FinalizeManualRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinalizeManualRegistrationResponseCopyWith<FinalizeManualRegistrationResponse> get copyWith => _$FinalizeManualRegistrationResponseCopyWithImpl<FinalizeManualRegistrationResponse>(this as FinalizeManualRegistrationResponse, _$identity);

  /// Serializes this FinalizeManualRegistrationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FinalizeManualRegistrationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinalizeManualRegistrationResponse&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FinalizeManualRegistrationResponse;
  return Object.hash(runtimeType,_this.email,_this.displayName);
}

@override
String toString() {
  final _this = this as FinalizeManualRegistrationResponse;
  return 'FinalizeManualRegistrationResponse(email: ${_this.email}, displayName: ${_this.displayName})';
}


}

/// @nodoc
abstract mixin class $FinalizeManualRegistrationResponseCopyWith<$Res>  {
  factory $FinalizeManualRegistrationResponseCopyWith(FinalizeManualRegistrationResponse value, $Res Function(FinalizeManualRegistrationResponse) _then) = _$FinalizeManualRegistrationResponseCopyWithImpl;
@useResult
$Res call({
 String email,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class _$FinalizeManualRegistrationResponseCopyWithImpl<$Res>
    implements $FinalizeManualRegistrationResponseCopyWith<$Res> {
  _$FinalizeManualRegistrationResponseCopyWithImpl(this._self, this._then);

  final FinalizeManualRegistrationResponse _self;
  final $Res Function(FinalizeManualRegistrationResponse) _then;

/// Create a copy of FinalizeManualRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? displayName = null,}) {
  return _then(FinalizeManualRegistrationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FinalizeManualRegistrationResponse].
extension FinalizeManualRegistrationResponsePatterns on FinalizeManualRegistrationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinalizeManualRegistrationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinalizeManualRegistrationResponse value)  $default,){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinalizeManualRegistrationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'display_name')  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse() when $default != null:
return $default(_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'display_name')  String displayName)  $default,) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse():
return $default(_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email, @JsonKey(name: 'display_name')  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationResponse() when $default != null:
return $default(_that.email,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinalizeManualRegistrationResponse implements FinalizeManualRegistrationResponse {
  const _FinalizeManualRegistrationResponse({required this.email, @JsonKey(name: 'display_name') required this.displayName});
  factory _FinalizeManualRegistrationResponse.fromJson(Map<String, dynamic> json) => _$FinalizeManualRegistrationResponseFromJson(json);

@override final  String email;
@override@JsonKey(name: 'display_name') final  String displayName;

/// Create a copy of FinalizeManualRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinalizeManualRegistrationResponseCopyWith<_FinalizeManualRegistrationResponse> get copyWith => __$FinalizeManualRegistrationResponseCopyWithImpl<_FinalizeManualRegistrationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinalizeManualRegistrationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinalizeManualRegistrationResponse&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,displayName);
}

@override
String toString() {
    return 'FinalizeManualRegistrationResponse(email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$FinalizeManualRegistrationResponseCopyWith<$Res> implements $FinalizeManualRegistrationResponseCopyWith<$Res> {
  factory _$FinalizeManualRegistrationResponseCopyWith(_FinalizeManualRegistrationResponse value, $Res Function(_FinalizeManualRegistrationResponse) _then) = __$FinalizeManualRegistrationResponseCopyWithImpl;
@override @useResult
$Res call({
 String email,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class __$FinalizeManualRegistrationResponseCopyWithImpl<$Res>
    implements _$FinalizeManualRegistrationResponseCopyWith<$Res> {
  __$FinalizeManualRegistrationResponseCopyWithImpl(this._self, this._then);

  final _FinalizeManualRegistrationResponse _self;
  final $Res Function(_FinalizeManualRegistrationResponse) _then;

/// Create a copy of FinalizeManualRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? displayName = null,}) {
  return _then(_FinalizeManualRegistrationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
