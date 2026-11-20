// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_user_feedback_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateUserFeedbackRequest {

 String get type; String get message;@JsonKey(name: 'app_version', includeIfNull: false) String? get appVersion;@JsonKey(name: 'app_build', includeIfNull: false) int? get appBuild;
/// Create a copy of CreateUserFeedbackRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUserFeedbackRequestCopyWith<CreateUserFeedbackRequest> get copyWith => _$CreateUserFeedbackRequestCopyWithImpl<CreateUserFeedbackRequest>(this as CreateUserFeedbackRequest, _$identity);

  /// Serializes this CreateUserFeedbackRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateUserFeedbackRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUserFeedbackRequest&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.appVersion, _this.appVersion) || other.appVersion == _this.appVersion)&&(identical(other.appBuild, _this.appBuild) || other.appBuild == _this.appBuild));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateUserFeedbackRequest;
  return Object.hash(runtimeType,_this.type,_this.message,_this.appVersion,_this.appBuild);
}

@override
String toString() {
  final _this = this as CreateUserFeedbackRequest;
  return 'CreateUserFeedbackRequest(type: ${_this.type}, message: ${_this.message}, appVersion: ${_this.appVersion}, appBuild: ${_this.appBuild})';
}


}

/// @nodoc
abstract mixin class $CreateUserFeedbackRequestCopyWith<$Res>  {
  factory $CreateUserFeedbackRequestCopyWith(CreateUserFeedbackRequest value, $Res Function(CreateUserFeedbackRequest) _then) = _$CreateUserFeedbackRequestCopyWithImpl;
@useResult
$Res call({
 String type, String message,@JsonKey(name: 'app_version', includeIfNull: false) String? appVersion,@JsonKey(name: 'app_build', includeIfNull: false) int? appBuild
});




}
/// @nodoc
class _$CreateUserFeedbackRequestCopyWithImpl<$Res>
    implements $CreateUserFeedbackRequestCopyWith<$Res> {
  _$CreateUserFeedbackRequestCopyWithImpl(this._self, this._then);

  final CreateUserFeedbackRequest _self;
  final $Res Function(CreateUserFeedbackRequest) _then;

/// Create a copy of CreateUserFeedbackRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? message = null,Object? appVersion = freezed,Object? appBuild = freezed,}) {
  return _then(CreateUserFeedbackRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,appBuild: freezed == appBuild ? _self.appBuild : appBuild // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUserFeedbackRequest].
extension CreateUserFeedbackRequestPatterns on CreateUserFeedbackRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUserFeedbackRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUserFeedbackRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUserFeedbackRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String message, @JsonKey(name: 'app_version', includeIfNull: false)  String? appVersion, @JsonKey(name: 'app_build', includeIfNull: false)  int? appBuild)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest() when $default != null:
return $default(_that.type,_that.message,_that.appVersion,_that.appBuild);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String message, @JsonKey(name: 'app_version', includeIfNull: false)  String? appVersion, @JsonKey(name: 'app_build', includeIfNull: false)  int? appBuild)  $default,) {final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest():
return $default(_that.type,_that.message,_that.appVersion,_that.appBuild);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String message, @JsonKey(name: 'app_version', includeIfNull: false)  String? appVersion, @JsonKey(name: 'app_build', includeIfNull: false)  int? appBuild)?  $default,) {final _that = this;
switch (_that) {
case _CreateUserFeedbackRequest() when $default != null:
return $default(_that.type,_that.message,_that.appVersion,_that.appBuild);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUserFeedbackRequest implements CreateUserFeedbackRequest {
  const _CreateUserFeedbackRequest({required this.type, required this.message, @JsonKey(name: 'app_version', includeIfNull: false) this.appVersion, @JsonKey(name: 'app_build', includeIfNull: false) this.appBuild});
  factory _CreateUserFeedbackRequest.fromJson(Map<String, dynamic> json) => _$CreateUserFeedbackRequestFromJson(json);

@override final  String type;
@override final  String message;
@override@JsonKey(name: 'app_version', includeIfNull: false) final  String? appVersion;
@override@JsonKey(name: 'app_build', includeIfNull: false) final  int? appBuild;

/// Create a copy of CreateUserFeedbackRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUserFeedbackRequestCopyWith<_CreateUserFeedbackRequest> get copyWith => __$CreateUserFeedbackRequestCopyWithImpl<_CreateUserFeedbackRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUserFeedbackRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUserFeedbackRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.appBuild, appBuild) || other.appBuild == appBuild));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,message,appVersion,appBuild);
}

@override
String toString() {
    return 'CreateUserFeedbackRequest(type: $type, message: $message, appVersion: $appVersion, appBuild: $appBuild)';
}


}

/// @nodoc
abstract mixin class _$CreateUserFeedbackRequestCopyWith<$Res> implements $CreateUserFeedbackRequestCopyWith<$Res> {
  factory _$CreateUserFeedbackRequestCopyWith(_CreateUserFeedbackRequest value, $Res Function(_CreateUserFeedbackRequest) _then) = __$CreateUserFeedbackRequestCopyWithImpl;
@override @useResult
$Res call({
 String type, String message,@JsonKey(name: 'app_version', includeIfNull: false) String? appVersion,@JsonKey(name: 'app_build', includeIfNull: false) int? appBuild
});




}
/// @nodoc
class __$CreateUserFeedbackRequestCopyWithImpl<$Res>
    implements _$CreateUserFeedbackRequestCopyWith<$Res> {
  __$CreateUserFeedbackRequestCopyWithImpl(this._self, this._then);

  final _CreateUserFeedbackRequest _self;
  final $Res Function(_CreateUserFeedbackRequest) _then;

/// Create a copy of CreateUserFeedbackRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? message = null,Object? appVersion = freezed,Object? appBuild = freezed,}) {
  return _then(_CreateUserFeedbackRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,appBuild: freezed == appBuild ? _self.appBuild : appBuild // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
