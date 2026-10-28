// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finalize_password_reset_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinalizePasswordResetRequest {

 String get password;
/// Create a copy of FinalizePasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinalizePasswordResetRequestCopyWith<FinalizePasswordResetRequest> get copyWith => _$FinalizePasswordResetRequestCopyWithImpl<FinalizePasswordResetRequest>(this as FinalizePasswordResetRequest, _$identity);

  /// Serializes this FinalizePasswordResetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FinalizePasswordResetRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinalizePasswordResetRequest&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FinalizePasswordResetRequest;
  return Object.hash(runtimeType,_this.password);
}

@override
String toString() {
  final _this = this as FinalizePasswordResetRequest;
  return 'FinalizePasswordResetRequest(password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $FinalizePasswordResetRequestCopyWith<$Res>  {
  factory $FinalizePasswordResetRequestCopyWith(FinalizePasswordResetRequest value, $Res Function(FinalizePasswordResetRequest) _then) = _$FinalizePasswordResetRequestCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class _$FinalizePasswordResetRequestCopyWithImpl<$Res>
    implements $FinalizePasswordResetRequestCopyWith<$Res> {
  _$FinalizePasswordResetRequestCopyWithImpl(this._self, this._then);

  final FinalizePasswordResetRequest _self;
  final $Res Function(FinalizePasswordResetRequest) _then;

/// Create a copy of FinalizePasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,}) {
  return _then(FinalizePasswordResetRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FinalizePasswordResetRequest].
extension FinalizePasswordResetRequestPatterns on FinalizePasswordResetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinalizePasswordResetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinalizePasswordResetRequest value)  $default,){
final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinalizePasswordResetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest() when $default != null:
return $default(_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String password)  $default,) {final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest():
return $default(_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String password)?  $default,) {final _that = this;
switch (_that) {
case _FinalizePasswordResetRequest() when $default != null:
return $default(_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinalizePasswordResetRequest implements FinalizePasswordResetRequest {
  const _FinalizePasswordResetRequest({required this.password});
  factory _FinalizePasswordResetRequest.fromJson(Map<String, dynamic> json) => _$FinalizePasswordResetRequestFromJson(json);

@override final  String password;

/// Create a copy of FinalizePasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinalizePasswordResetRequestCopyWith<_FinalizePasswordResetRequest> get copyWith => __$FinalizePasswordResetRequestCopyWithImpl<_FinalizePasswordResetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinalizePasswordResetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinalizePasswordResetRequest&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,password);
}

@override
String toString() {
    return 'FinalizePasswordResetRequest(password: $password)';
}


}

/// @nodoc
abstract mixin class _$FinalizePasswordResetRequestCopyWith<$Res> implements $FinalizePasswordResetRequestCopyWith<$Res> {
  factory _$FinalizePasswordResetRequestCopyWith(_FinalizePasswordResetRequest value, $Res Function(_FinalizePasswordResetRequest) _then) = __$FinalizePasswordResetRequestCopyWithImpl;
@override @useResult
$Res call({
 String password
});




}
/// @nodoc
class __$FinalizePasswordResetRequestCopyWithImpl<$Res>
    implements _$FinalizePasswordResetRequestCopyWith<$Res> {
  __$FinalizePasswordResetRequestCopyWithImpl(this._self, this._then);

  final _FinalizePasswordResetRequest _self;
  final $Res Function(_FinalizePasswordResetRequest) _then;

/// Create a copy of FinalizePasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_FinalizePasswordResetRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
