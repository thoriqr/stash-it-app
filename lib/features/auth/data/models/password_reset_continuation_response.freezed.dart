// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_continuation_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordResetContinuationResponse {

 String get email;@JsonKey(name: 'has_password_credential') bool get hasPasswordCredential;
/// Create a copy of PasswordResetContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetContinuationResponseCopyWith<PasswordResetContinuationResponse> get copyWith => _$PasswordResetContinuationResponseCopyWithImpl<PasswordResetContinuationResponse>(this as PasswordResetContinuationResponse, _$identity);

  /// Serializes this PasswordResetContinuationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PasswordResetContinuationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetContinuationResponse&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.hasPasswordCredential, _this.hasPasswordCredential) || other.hasPasswordCredential == _this.hasPasswordCredential));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PasswordResetContinuationResponse;
  return Object.hash(runtimeType,_this.email,_this.hasPasswordCredential);
}

@override
String toString() {
  final _this = this as PasswordResetContinuationResponse;
  return 'PasswordResetContinuationResponse(email: ${_this.email}, hasPasswordCredential: ${_this.hasPasswordCredential})';
}


}

/// @nodoc
abstract mixin class $PasswordResetContinuationResponseCopyWith<$Res>  {
  factory $PasswordResetContinuationResponseCopyWith(PasswordResetContinuationResponse value, $Res Function(PasswordResetContinuationResponse) _then) = _$PasswordResetContinuationResponseCopyWithImpl;
@useResult
$Res call({
 String email,@JsonKey(name: 'has_password_credential') bool hasPasswordCredential
});




}
/// @nodoc
class _$PasswordResetContinuationResponseCopyWithImpl<$Res>
    implements $PasswordResetContinuationResponseCopyWith<$Res> {
  _$PasswordResetContinuationResponseCopyWithImpl(this._self, this._then);

  final PasswordResetContinuationResponse _self;
  final $Res Function(PasswordResetContinuationResponse) _then;

/// Create a copy of PasswordResetContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? hasPasswordCredential = null,}) {
  return _then(PasswordResetContinuationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hasPasswordCredential: null == hasPasswordCredential ? _self.hasPasswordCredential : hasPasswordCredential // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetContinuationResponse].
extension PasswordResetContinuationResponsePatterns on PasswordResetContinuationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetContinuationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetContinuationResponse value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetContinuationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse() when $default != null:
return $default(_that.email,_that.hasPasswordCredential);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse():
return $default(_that.email,_that.hasPasswordCredential);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email, @JsonKey(name: 'has_password_credential')  bool hasPasswordCredential)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetContinuationResponse() when $default != null:
return $default(_that.email,_that.hasPasswordCredential);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetContinuationResponse implements PasswordResetContinuationResponse {
  const _PasswordResetContinuationResponse({required this.email, @JsonKey(name: 'has_password_credential') required this.hasPasswordCredential});
  factory _PasswordResetContinuationResponse.fromJson(Map<String, dynamic> json) => _$PasswordResetContinuationResponseFromJson(json);

@override final  String email;
@override@JsonKey(name: 'has_password_credential') final  bool hasPasswordCredential;

/// Create a copy of PasswordResetContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetContinuationResponseCopyWith<_PasswordResetContinuationResponse> get copyWith => __$PasswordResetContinuationResponseCopyWithImpl<_PasswordResetContinuationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetContinuationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetContinuationResponse&&(identical(other.email, email) || other.email == email)&&(identical(other.hasPasswordCredential, hasPasswordCredential) || other.hasPasswordCredential == hasPasswordCredential));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,hasPasswordCredential);
}

@override
String toString() {
    return 'PasswordResetContinuationResponse(email: $email, hasPasswordCredential: $hasPasswordCredential)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetContinuationResponseCopyWith<$Res> implements $PasswordResetContinuationResponseCopyWith<$Res> {
  factory _$PasswordResetContinuationResponseCopyWith(_PasswordResetContinuationResponse value, $Res Function(_PasswordResetContinuationResponse) _then) = __$PasswordResetContinuationResponseCopyWithImpl;
@override @useResult
$Res call({
 String email,@JsonKey(name: 'has_password_credential') bool hasPasswordCredential
});




}
/// @nodoc
class __$PasswordResetContinuationResponseCopyWithImpl<$Res>
    implements _$PasswordResetContinuationResponseCopyWith<$Res> {
  __$PasswordResetContinuationResponseCopyWithImpl(this._self, this._then);

  final _PasswordResetContinuationResponse _self;
  final $Res Function(_PasswordResetContinuationResponse) _then;

/// Create a copy of PasswordResetContinuationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? hasPasswordCredential = null,}) {
  return _then(_PasswordResetContinuationResponse(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hasPasswordCredential: null == hasPasswordCredential ? _self.hasPasswordCredential : hasPasswordCredential // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
