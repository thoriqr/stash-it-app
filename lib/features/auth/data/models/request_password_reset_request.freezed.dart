// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_password_reset_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestPasswordResetRequest {

 String get email;
/// Create a copy of RequestPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestPasswordResetRequestCopyWith<RequestPasswordResetRequest> get copyWith => _$RequestPasswordResetRequestCopyWithImpl<RequestPasswordResetRequest>(this as RequestPasswordResetRequest, _$identity);

  /// Serializes this RequestPasswordResetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RequestPasswordResetRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestPasswordResetRequest&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RequestPasswordResetRequest;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as RequestPasswordResetRequest;
  return 'RequestPasswordResetRequest(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $RequestPasswordResetRequestCopyWith<$Res>  {
  factory $RequestPasswordResetRequestCopyWith(RequestPasswordResetRequest value, $Res Function(RequestPasswordResetRequest) _then) = _$RequestPasswordResetRequestCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$RequestPasswordResetRequestCopyWithImpl<$Res>
    implements $RequestPasswordResetRequestCopyWith<$Res> {
  _$RequestPasswordResetRequestCopyWithImpl(this._self, this._then);

  final RequestPasswordResetRequest _self;
  final $Res Function(RequestPasswordResetRequest) _then;

/// Create a copy of RequestPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(RequestPasswordResetRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestPasswordResetRequest].
extension RequestPasswordResetRequestPatterns on RequestPasswordResetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestPasswordResetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestPasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestPasswordResetRequest value)  $default,){
final _that = this;
switch (_that) {
case _RequestPasswordResetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestPasswordResetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RequestPasswordResetRequest() when $default != null:
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
case _RequestPasswordResetRequest() when $default != null:
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
case _RequestPasswordResetRequest():
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
case _RequestPasswordResetRequest() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestPasswordResetRequest implements RequestPasswordResetRequest {
  const _RequestPasswordResetRequest({required this.email});
  factory _RequestPasswordResetRequest.fromJson(Map<String, dynamic> json) => _$RequestPasswordResetRequestFromJson(json);

@override final  String email;

/// Create a copy of RequestPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestPasswordResetRequestCopyWith<_RequestPasswordResetRequest> get copyWith => __$RequestPasswordResetRequestCopyWithImpl<_RequestPasswordResetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestPasswordResetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestPasswordResetRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'RequestPasswordResetRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class _$RequestPasswordResetRequestCopyWith<$Res> implements $RequestPasswordResetRequestCopyWith<$Res> {
  factory _$RequestPasswordResetRequestCopyWith(_RequestPasswordResetRequest value, $Res Function(_RequestPasswordResetRequest) _then) = __$RequestPasswordResetRequestCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$RequestPasswordResetRequestCopyWithImpl<$Res>
    implements _$RequestPasswordResetRequestCopyWith<$Res> {
  __$RequestPasswordResetRequestCopyWithImpl(this._self, this._then);

  final _RequestPasswordResetRequest _self;
  final $Res Function(_RequestPasswordResetRequest) _then;

/// Create a copy of RequestPasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_RequestPasswordResetRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
