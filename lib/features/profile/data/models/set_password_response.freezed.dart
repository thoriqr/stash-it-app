// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_password_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetPasswordResponse {

 String? get message;
/// Create a copy of SetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPasswordResponseCopyWith<SetPasswordResponse> get copyWith => _$SetPasswordResponseCopyWithImpl<SetPasswordResponse>(this as SetPasswordResponse, _$identity);

  /// Serializes this SetPasswordResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetPasswordResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPasswordResponse&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetPasswordResponse;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as SetPasswordResponse;
  return 'SetPasswordResponse(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SetPasswordResponseCopyWith<$Res>  {
  factory $SetPasswordResponseCopyWith(SetPasswordResponse value, $Res Function(SetPasswordResponse) _then) = _$SetPasswordResponseCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$SetPasswordResponseCopyWithImpl<$Res>
    implements $SetPasswordResponseCopyWith<$Res> {
  _$SetPasswordResponseCopyWithImpl(this._self, this._then);

  final SetPasswordResponse _self;
  final $Res Function(SetPasswordResponse) _then;

/// Create a copy of SetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,}) {
  return _then(SetPasswordResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPasswordResponse].
extension SetPasswordResponsePatterns on SetPasswordResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPasswordResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPasswordResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPasswordResponse value)  $default,){
final _that = this;
switch (_that) {
case _SetPasswordResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPasswordResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SetPasswordResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPasswordResponse() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? message)  $default,) {final _that = this;
switch (_that) {
case _SetPasswordResponse():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? message)?  $default,) {final _that = this;
switch (_that) {
case _SetPasswordResponse() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPasswordResponse implements SetPasswordResponse {
  const _SetPasswordResponse({this.message});
  factory _SetPasswordResponse.fromJson(Map<String, dynamic> json) => _$SetPasswordResponseFromJson(json);

@override final  String? message;

/// Create a copy of SetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPasswordResponseCopyWith<_SetPasswordResponse> get copyWith => __$SetPasswordResponseCopyWithImpl<_SetPasswordResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPasswordResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPasswordResponse&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'SetPasswordResponse(message: $message)';
}


}

/// @nodoc
abstract mixin class _$SetPasswordResponseCopyWith<$Res> implements $SetPasswordResponseCopyWith<$Res> {
  factory _$SetPasswordResponseCopyWith(_SetPasswordResponse value, $Res Function(_SetPasswordResponse) _then) = __$SetPasswordResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$SetPasswordResponseCopyWithImpl<$Res>
    implements _$SetPasswordResponseCopyWith<$Res> {
  __$SetPasswordResponseCopyWithImpl(this._self, this._then);

  final _SetPasswordResponse _self;
  final $Res Function(_SetPasswordResponse) _then;

/// Create a copy of SetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_SetPasswordResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
