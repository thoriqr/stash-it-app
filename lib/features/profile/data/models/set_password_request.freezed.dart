// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_password_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetPasswordRequest {

@JsonKey(name: 'current_password', includeIfNull: false) String? get currentPassword;@JsonKey(name: 'new_password') String get newPassword;
/// Create a copy of SetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPasswordRequestCopyWith<SetPasswordRequest> get copyWith => _$SetPasswordRequestCopyWithImpl<SetPasswordRequest>(this as SetPasswordRequest, _$identity);

  /// Serializes this SetPasswordRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetPasswordRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPasswordRequest&&(identical(other.currentPassword, _this.currentPassword) || other.currentPassword == _this.currentPassword)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetPasswordRequest;
  return Object.hash(runtimeType,_this.currentPassword,_this.newPassword);
}

@override
String toString() {
  final _this = this as SetPasswordRequest;
  return 'SetPasswordRequest(currentPassword: ${_this.currentPassword}, newPassword: ${_this.newPassword})';
}


}

/// @nodoc
abstract mixin class $SetPasswordRequestCopyWith<$Res>  {
  factory $SetPasswordRequestCopyWith(SetPasswordRequest value, $Res Function(SetPasswordRequest) _then) = _$SetPasswordRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_password', includeIfNull: false) String? currentPassword,@JsonKey(name: 'new_password') String newPassword
});




}
/// @nodoc
class _$SetPasswordRequestCopyWithImpl<$Res>
    implements $SetPasswordRequestCopyWith<$Res> {
  _$SetPasswordRequestCopyWithImpl(this._self, this._then);

  final SetPasswordRequest _self;
  final $Res Function(SetPasswordRequest) _then;

/// Create a copy of SetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = freezed,Object? newPassword = null,}) {
  return _then(SetPasswordRequest(
currentPassword: freezed == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPasswordRequest].
extension SetPasswordRequestPatterns on SetPasswordRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPasswordRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPasswordRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPasswordRequest value)  $default,){
final _that = this;
switch (_that) {
case _SetPasswordRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPasswordRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SetPasswordRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_password', includeIfNull: false)  String? currentPassword, @JsonKey(name: 'new_password')  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPasswordRequest() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_password', includeIfNull: false)  String? currentPassword, @JsonKey(name: 'new_password')  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _SetPasswordRequest():
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_password', includeIfNull: false)  String? currentPassword, @JsonKey(name: 'new_password')  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _SetPasswordRequest() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPasswordRequest implements SetPasswordRequest {
  const _SetPasswordRequest({@JsonKey(name: 'current_password', includeIfNull: false) this.currentPassword, @JsonKey(name: 'new_password') required this.newPassword});
  factory _SetPasswordRequest.fromJson(Map<String, dynamic> json) => _$SetPasswordRequestFromJson(json);

@override@JsonKey(name: 'current_password', includeIfNull: false) final  String? currentPassword;
@override@JsonKey(name: 'new_password') final  String newPassword;

/// Create a copy of SetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPasswordRequestCopyWith<_SetPasswordRequest> get copyWith => __$SetPasswordRequestCopyWithImpl<_SetPasswordRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPasswordRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPasswordRequest&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentPassword,newPassword);
}

@override
String toString() {
    return 'SetPasswordRequest(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$SetPasswordRequestCopyWith<$Res> implements $SetPasswordRequestCopyWith<$Res> {
  factory _$SetPasswordRequestCopyWith(_SetPasswordRequest value, $Res Function(_SetPasswordRequest) _then) = __$SetPasswordRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_password', includeIfNull: false) String? currentPassword,@JsonKey(name: 'new_password') String newPassword
});




}
/// @nodoc
class __$SetPasswordRequestCopyWithImpl<$Res>
    implements _$SetPasswordRequestCopyWith<$Res> {
  __$SetPasswordRequestCopyWithImpl(this._self, this._then);

  final _SetPasswordRequest _self;
  final $Res Function(_SetPasswordRequest) _then;

/// Create a copy of SetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = freezed,Object? newPassword = null,}) {
  return _then(_SetPasswordRequest(
currentPassword: freezed == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
