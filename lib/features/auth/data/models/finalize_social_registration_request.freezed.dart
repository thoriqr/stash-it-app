// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finalize_social_registration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinalizeSocialRegistrationRequest {

@JsonKey(name: 'display_name') String get displayName;
/// Create a copy of FinalizeSocialRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinalizeSocialRegistrationRequestCopyWith<FinalizeSocialRegistrationRequest> get copyWith => _$FinalizeSocialRegistrationRequestCopyWithImpl<FinalizeSocialRegistrationRequest>(this as FinalizeSocialRegistrationRequest, _$identity);

  /// Serializes this FinalizeSocialRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FinalizeSocialRegistrationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinalizeSocialRegistrationRequest&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FinalizeSocialRegistrationRequest;
  return Object.hash(runtimeType,_this.displayName);
}

@override
String toString() {
  final _this = this as FinalizeSocialRegistrationRequest;
  return 'FinalizeSocialRegistrationRequest(displayName: ${_this.displayName})';
}


}

/// @nodoc
abstract mixin class $FinalizeSocialRegistrationRequestCopyWith<$Res>  {
  factory $FinalizeSocialRegistrationRequestCopyWith(FinalizeSocialRegistrationRequest value, $Res Function(FinalizeSocialRegistrationRequest) _then) = _$FinalizeSocialRegistrationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class _$FinalizeSocialRegistrationRequestCopyWithImpl<$Res>
    implements $FinalizeSocialRegistrationRequestCopyWith<$Res> {
  _$FinalizeSocialRegistrationRequestCopyWithImpl(this._self, this._then);

  final FinalizeSocialRegistrationRequest _self;
  final $Res Function(FinalizeSocialRegistrationRequest) _then;

/// Create a copy of FinalizeSocialRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,}) {
  return _then(FinalizeSocialRegistrationRequest(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FinalizeSocialRegistrationRequest].
extension FinalizeSocialRegistrationRequestPatterns on FinalizeSocialRegistrationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinalizeSocialRegistrationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinalizeSocialRegistrationRequest value)  $default,){
final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinalizeSocialRegistrationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest() when $default != null:
return $default(_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String displayName)  $default,) {final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest():
return $default(_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'display_name')  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _FinalizeSocialRegistrationRequest() when $default != null:
return $default(_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinalizeSocialRegistrationRequest implements FinalizeSocialRegistrationRequest {
  const _FinalizeSocialRegistrationRequest({@JsonKey(name: 'display_name') required this.displayName});
  factory _FinalizeSocialRegistrationRequest.fromJson(Map<String, dynamic> json) => _$FinalizeSocialRegistrationRequestFromJson(json);

@override@JsonKey(name: 'display_name') final  String displayName;

/// Create a copy of FinalizeSocialRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinalizeSocialRegistrationRequestCopyWith<_FinalizeSocialRegistrationRequest> get copyWith => __$FinalizeSocialRegistrationRequestCopyWithImpl<_FinalizeSocialRegistrationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinalizeSocialRegistrationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinalizeSocialRegistrationRequest&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,displayName);
}

@override
String toString() {
    return 'FinalizeSocialRegistrationRequest(displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$FinalizeSocialRegistrationRequestCopyWith<$Res> implements $FinalizeSocialRegistrationRequestCopyWith<$Res> {
  factory _$FinalizeSocialRegistrationRequestCopyWith(_FinalizeSocialRegistrationRequest value, $Res Function(_FinalizeSocialRegistrationRequest) _then) = __$FinalizeSocialRegistrationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class __$FinalizeSocialRegistrationRequestCopyWithImpl<$Res>
    implements _$FinalizeSocialRegistrationRequestCopyWith<$Res> {
  __$FinalizeSocialRegistrationRequestCopyWithImpl(this._self, this._then);

  final _FinalizeSocialRegistrationRequest _self;
  final $Res Function(_FinalizeSocialRegistrationRequest) _then;

/// Create a copy of FinalizeSocialRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,}) {
  return _then(_FinalizeSocialRegistrationRequest(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
