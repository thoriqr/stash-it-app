// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_user_feedback_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatedUserFeedbackResponse {

 String get id;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of CreatedUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedUserFeedbackResponseCopyWith<CreatedUserFeedbackResponse> get copyWith => _$CreatedUserFeedbackResponseCopyWithImpl<CreatedUserFeedbackResponse>(this as CreatedUserFeedbackResponse, _$identity);

  /// Serializes this CreatedUserFeedbackResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreatedUserFeedbackResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatedUserFeedbackResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreatedUserFeedbackResponse;
  return Object.hash(runtimeType,_this.id,_this.createdAt);
}

@override
String toString() {
  final _this = this as CreatedUserFeedbackResponse;
  return 'CreatedUserFeedbackResponse(id: ${_this.id}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CreatedUserFeedbackResponseCopyWith<$Res>  {
  factory $CreatedUserFeedbackResponseCopyWith(CreatedUserFeedbackResponse value, $Res Function(CreatedUserFeedbackResponse) _then) = _$CreatedUserFeedbackResponseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$CreatedUserFeedbackResponseCopyWithImpl<$Res>
    implements $CreatedUserFeedbackResponseCopyWith<$Res> {
  _$CreatedUserFeedbackResponseCopyWithImpl(this._self, this._then);

  final CreatedUserFeedbackResponse _self;
  final $Res Function(CreatedUserFeedbackResponse) _then;

/// Create a copy of CreatedUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,}) {
  return _then(CreatedUserFeedbackResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatedUserFeedbackResponse].
extension CreatedUserFeedbackResponsePatterns on CreatedUserFeedbackResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatedUserFeedbackResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatedUserFeedbackResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatedUserFeedbackResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse() when $default != null:
return $default(_that.id,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse():
return $default(_that.id,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CreatedUserFeedbackResponse() when $default != null:
return $default(_that.id,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatedUserFeedbackResponse implements CreatedUserFeedbackResponse {
  const _CreatedUserFeedbackResponse({required this.id, @JsonKey(name: 'created_at') required this.createdAt});
  factory _CreatedUserFeedbackResponse.fromJson(Map<String, dynamic> json) => _$CreatedUserFeedbackResponseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of CreatedUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatedUserFeedbackResponseCopyWith<_CreatedUserFeedbackResponse> get copyWith => __$CreatedUserFeedbackResponseCopyWithImpl<_CreatedUserFeedbackResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatedUserFeedbackResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatedUserFeedbackResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt);
}

@override
String toString() {
    return 'CreatedUserFeedbackResponse(id: $id, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CreatedUserFeedbackResponseCopyWith<$Res> implements $CreatedUserFeedbackResponseCopyWith<$Res> {
  factory _$CreatedUserFeedbackResponseCopyWith(_CreatedUserFeedbackResponse value, $Res Function(_CreatedUserFeedbackResponse) _then) = __$CreatedUserFeedbackResponseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$CreatedUserFeedbackResponseCopyWithImpl<$Res>
    implements _$CreatedUserFeedbackResponseCopyWith<$Res> {
  __$CreatedUserFeedbackResponseCopyWithImpl(this._self, this._then);

  final _CreatedUserFeedbackResponse _self;
  final $Res Function(_CreatedUserFeedbackResponse) _then;

/// Create a copy of CreatedUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,}) {
  return _then(_CreatedUserFeedbackResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateUserFeedbackResponse {

 CreatedUserFeedbackResponse get data; String? get message;
/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUserFeedbackResponseCopyWith<CreateUserFeedbackResponse> get copyWith => _$CreateUserFeedbackResponseCopyWithImpl<CreateUserFeedbackResponse>(this as CreateUserFeedbackResponse, _$identity);

  /// Serializes this CreateUserFeedbackResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateUserFeedbackResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUserFeedbackResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateUserFeedbackResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as CreateUserFeedbackResponse;
  return 'CreateUserFeedbackResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $CreateUserFeedbackResponseCopyWith<$Res>  {
  factory $CreateUserFeedbackResponseCopyWith(CreateUserFeedbackResponse value, $Res Function(CreateUserFeedbackResponse) _then) = _$CreateUserFeedbackResponseCopyWithImpl;
@useResult
$Res call({
 CreatedUserFeedbackResponse data, String? message
});


$CreatedUserFeedbackResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$CreateUserFeedbackResponseCopyWithImpl<$Res>
    implements $CreateUserFeedbackResponseCopyWith<$Res> {
  _$CreateUserFeedbackResponseCopyWithImpl(this._self, this._then);

  final CreateUserFeedbackResponse _self;
  final $Res Function(CreateUserFeedbackResponse) _then;

/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(CreateUserFeedbackResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CreatedUserFeedbackResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatedUserFeedbackResponseCopyWith<$Res> get data {
  
  return $CreatedUserFeedbackResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateUserFeedbackResponse].
extension CreateUserFeedbackResponsePatterns on CreateUserFeedbackResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUserFeedbackResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUserFeedbackResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUserFeedbackResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CreatedUserFeedbackResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse() when $default != null:
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CreatedUserFeedbackResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse():
return $default(_that.data,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CreatedUserFeedbackResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _CreateUserFeedbackResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUserFeedbackResponse implements CreateUserFeedbackResponse {
  const _CreateUserFeedbackResponse({required this.data, this.message});
  factory _CreateUserFeedbackResponse.fromJson(Map<String, dynamic> json) => _$CreateUserFeedbackResponseFromJson(json);

@override final  CreatedUserFeedbackResponse data;
@override final  String? message;

/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUserFeedbackResponseCopyWith<_CreateUserFeedbackResponse> get copyWith => __$CreateUserFeedbackResponseCopyWithImpl<_CreateUserFeedbackResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUserFeedbackResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUserFeedbackResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'CreateUserFeedbackResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CreateUserFeedbackResponseCopyWith<$Res> implements $CreateUserFeedbackResponseCopyWith<$Res> {
  factory _$CreateUserFeedbackResponseCopyWith(_CreateUserFeedbackResponse value, $Res Function(_CreateUserFeedbackResponse) _then) = __$CreateUserFeedbackResponseCopyWithImpl;
@override @useResult
$Res call({
 CreatedUserFeedbackResponse data, String? message
});


@override $CreatedUserFeedbackResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$CreateUserFeedbackResponseCopyWithImpl<$Res>
    implements _$CreateUserFeedbackResponseCopyWith<$Res> {
  __$CreateUserFeedbackResponseCopyWithImpl(this._self, this._then);

  final _CreateUserFeedbackResponse _self;
  final $Res Function(_CreateUserFeedbackResponse) _then;

/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_CreateUserFeedbackResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CreatedUserFeedbackResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateUserFeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatedUserFeedbackResponseCopyWith<$Res> get data {
  
  return $CreatedUserFeedbackResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
