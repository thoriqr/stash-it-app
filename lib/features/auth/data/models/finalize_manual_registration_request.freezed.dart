// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finalize_manual_registration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinalizeManualRegistrationRequest {

@JsonKey(name: 'display_name') String get displayName; String get password;
/// Create a copy of FinalizeManualRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinalizeManualRegistrationRequestCopyWith<FinalizeManualRegistrationRequest> get copyWith => _$FinalizeManualRegistrationRequestCopyWithImpl<FinalizeManualRegistrationRequest>(this as FinalizeManualRegistrationRequest, _$identity);

  /// Serializes this FinalizeManualRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FinalizeManualRegistrationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinalizeManualRegistrationRequest&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FinalizeManualRegistrationRequest;
  return Object.hash(runtimeType,_this.displayName,_this.password);
}

@override
String toString() {
  final _this = this as FinalizeManualRegistrationRequest;
  return 'FinalizeManualRegistrationRequest(displayName: ${_this.displayName}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $FinalizeManualRegistrationRequestCopyWith<$Res>  {
  factory $FinalizeManualRegistrationRequestCopyWith(FinalizeManualRegistrationRequest value, $Res Function(FinalizeManualRegistrationRequest) _then) = _$FinalizeManualRegistrationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'display_name') String displayName, String password
});




}
/// @nodoc
class _$FinalizeManualRegistrationRequestCopyWithImpl<$Res>
    implements $FinalizeManualRegistrationRequestCopyWith<$Res> {
  _$FinalizeManualRegistrationRequestCopyWithImpl(this._self, this._then);

  final FinalizeManualRegistrationRequest _self;
  final $Res Function(FinalizeManualRegistrationRequest) _then;

/// Create a copy of FinalizeManualRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? password = null,}) {
  return _then(FinalizeManualRegistrationRequest(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FinalizeManualRegistrationRequest].
extension FinalizeManualRegistrationRequestPatterns on FinalizeManualRegistrationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinalizeManualRegistrationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinalizeManualRegistrationRequest value)  $default,){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinalizeManualRegistrationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String displayName,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest() when $default != null:
return $default(_that.displayName,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String displayName,  String password)  $default,) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest():
return $default(_that.displayName,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'display_name')  String displayName,  String password)?  $default,) {final _that = this;
switch (_that) {
case _FinalizeManualRegistrationRequest() when $default != null:
return $default(_that.displayName,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinalizeManualRegistrationRequest implements FinalizeManualRegistrationRequest {
  const _FinalizeManualRegistrationRequest({@JsonKey(name: 'display_name') required this.displayName, required this.password});
  factory _FinalizeManualRegistrationRequest.fromJson(Map<String, dynamic> json) => _$FinalizeManualRegistrationRequestFromJson(json);

@override@JsonKey(name: 'display_name') final  String displayName;
@override final  String password;

/// Create a copy of FinalizeManualRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinalizeManualRegistrationRequestCopyWith<_FinalizeManualRegistrationRequest> get copyWith => __$FinalizeManualRegistrationRequestCopyWithImpl<_FinalizeManualRegistrationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinalizeManualRegistrationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinalizeManualRegistrationRequest&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,displayName,password);
}

@override
String toString() {
    return 'FinalizeManualRegistrationRequest(displayName: $displayName, password: $password)';
}


}

/// @nodoc
abstract mixin class _$FinalizeManualRegistrationRequestCopyWith<$Res> implements $FinalizeManualRegistrationRequestCopyWith<$Res> {
  factory _$FinalizeManualRegistrationRequestCopyWith(_FinalizeManualRegistrationRequest value, $Res Function(_FinalizeManualRegistrationRequest) _then) = __$FinalizeManualRegistrationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'display_name') String displayName, String password
});




}
/// @nodoc
class __$FinalizeManualRegistrationRequestCopyWithImpl<$Res>
    implements _$FinalizeManualRegistrationRequestCopyWith<$Res> {
  __$FinalizeManualRegistrationRequestCopyWithImpl(this._self, this._then);

  final _FinalizeManualRegistrationRequest _self;
  final $Res Function(_FinalizeManualRegistrationRequest) _then;

/// Create a copy of FinalizeManualRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? password = null,}) {
  return _then(_FinalizeManualRegistrationRequest(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
