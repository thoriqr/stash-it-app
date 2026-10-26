// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_manual_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterManualRequest {

 String get email;
/// Create a copy of RegisterManualRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterManualRequestCopyWith<RegisterManualRequest> get copyWith => _$RegisterManualRequestCopyWithImpl<RegisterManualRequest>(this as RegisterManualRequest, _$identity);

  /// Serializes this RegisterManualRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterManualRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterManualRequest&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterManualRequest;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as RegisterManualRequest;
  return 'RegisterManualRequest(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $RegisterManualRequestCopyWith<$Res>  {
  factory $RegisterManualRequestCopyWith(RegisterManualRequest value, $Res Function(RegisterManualRequest) _then) = _$RegisterManualRequestCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$RegisterManualRequestCopyWithImpl<$Res>
    implements $RegisterManualRequestCopyWith<$Res> {
  _$RegisterManualRequestCopyWithImpl(this._self, this._then);

  final RegisterManualRequest _self;
  final $Res Function(RegisterManualRequest) _then;

/// Create a copy of RegisterManualRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(RegisterManualRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterManualRequest].
extension RegisterManualRequestPatterns on RegisterManualRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterManualRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterManualRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterManualRequest value)  $default,){
final _that = this;
switch (_that) {
case _RegisterManualRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterManualRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterManualRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterManualRequest() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _RegisterManualRequest():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _RegisterManualRequest() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterManualRequest implements RegisterManualRequest {
  const _RegisterManualRequest({required this.email});
  factory _RegisterManualRequest.fromJson(Map<String, dynamic> json) => _$RegisterManualRequestFromJson(json);

@override final  String email;

/// Create a copy of RegisterManualRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterManualRequestCopyWith<_RegisterManualRequest> get copyWith => __$RegisterManualRequestCopyWithImpl<_RegisterManualRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterManualRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterManualRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'RegisterManualRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class _$RegisterManualRequestCopyWith<$Res> implements $RegisterManualRequestCopyWith<$Res> {
  factory _$RegisterManualRequestCopyWith(_RegisterManualRequest value, $Res Function(_RegisterManualRequest) _then) = __$RegisterManualRequestCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$RegisterManualRequestCopyWithImpl<$Res>
    implements _$RegisterManualRequestCopyWith<$Res> {
  __$RegisterManualRequestCopyWithImpl(this._self, this._then);

  final _RegisterManualRequest _self;
  final $Res Function(_RegisterManualRequest) _then;

/// Create a copy of RegisterManualRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_RegisterManualRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
