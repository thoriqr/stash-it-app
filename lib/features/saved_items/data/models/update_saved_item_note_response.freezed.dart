// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_saved_item_note_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateSavedItemNoteDataResponse {

 String? get note;
/// Create a copy of UpdateSavedItemNoteDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSavedItemNoteDataResponseCopyWith<UpdateSavedItemNoteDataResponse> get copyWith => _$UpdateSavedItemNoteDataResponseCopyWithImpl<UpdateSavedItemNoteDataResponse>(this as UpdateSavedItemNoteDataResponse, _$identity);

  /// Serializes this UpdateSavedItemNoteDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateSavedItemNoteDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSavedItemNoteDataResponse&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateSavedItemNoteDataResponse;
  return Object.hash(runtimeType,_this.note);
}

@override
String toString() {
  final _this = this as UpdateSavedItemNoteDataResponse;
  return 'UpdateSavedItemNoteDataResponse(note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $UpdateSavedItemNoteDataResponseCopyWith<$Res>  {
  factory $UpdateSavedItemNoteDataResponseCopyWith(UpdateSavedItemNoteDataResponse value, $Res Function(UpdateSavedItemNoteDataResponse) _then) = _$UpdateSavedItemNoteDataResponseCopyWithImpl;
@useResult
$Res call({
 String? note
});




}
/// @nodoc
class _$UpdateSavedItemNoteDataResponseCopyWithImpl<$Res>
    implements $UpdateSavedItemNoteDataResponseCopyWith<$Res> {
  _$UpdateSavedItemNoteDataResponseCopyWithImpl(this._self, this._then);

  final UpdateSavedItemNoteDataResponse _self;
  final $Res Function(UpdateSavedItemNoteDataResponse) _then;

/// Create a copy of UpdateSavedItemNoteDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,}) {
  return _then(UpdateSavedItemNoteDataResponse(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateSavedItemNoteDataResponse].
extension UpdateSavedItemNoteDataResponsePatterns on UpdateSavedItemNoteDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSavedItemNoteDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse() when $default != null:
return $default(_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? note)  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse():
return $default(_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? note)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteDataResponse() when $default != null:
return $default(_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateSavedItemNoteDataResponse implements UpdateSavedItemNoteDataResponse {
  const _UpdateSavedItemNoteDataResponse({this.note});
  factory _UpdateSavedItemNoteDataResponse.fromJson(Map<String, dynamic> json) => _$UpdateSavedItemNoteDataResponseFromJson(json);

@override final  String? note;

/// Create a copy of UpdateSavedItemNoteDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSavedItemNoteDataResponseCopyWith<_UpdateSavedItemNoteDataResponse> get copyWith => __$UpdateSavedItemNoteDataResponseCopyWithImpl<_UpdateSavedItemNoteDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSavedItemNoteDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSavedItemNoteDataResponse&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,note);
}

@override
String toString() {
    return 'UpdateSavedItemNoteDataResponse(note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateSavedItemNoteDataResponseCopyWith<$Res> implements $UpdateSavedItemNoteDataResponseCopyWith<$Res> {
  factory _$UpdateSavedItemNoteDataResponseCopyWith(_UpdateSavedItemNoteDataResponse value, $Res Function(_UpdateSavedItemNoteDataResponse) _then) = __$UpdateSavedItemNoteDataResponseCopyWithImpl;
@override @useResult
$Res call({
 String? note
});




}
/// @nodoc
class __$UpdateSavedItemNoteDataResponseCopyWithImpl<$Res>
    implements _$UpdateSavedItemNoteDataResponseCopyWith<$Res> {
  __$UpdateSavedItemNoteDataResponseCopyWithImpl(this._self, this._then);

  final _UpdateSavedItemNoteDataResponse _self;
  final $Res Function(_UpdateSavedItemNoteDataResponse) _then;

/// Create a copy of UpdateSavedItemNoteDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,}) {
  return _then(_UpdateSavedItemNoteDataResponse(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateSavedItemNoteResponse {

 UpdateSavedItemNoteDataResponse get data; String? get message;
/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSavedItemNoteResponseCopyWith<UpdateSavedItemNoteResponse> get copyWith => _$UpdateSavedItemNoteResponseCopyWithImpl<UpdateSavedItemNoteResponse>(this as UpdateSavedItemNoteResponse, _$identity);

  /// Serializes this UpdateSavedItemNoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateSavedItemNoteResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSavedItemNoteResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateSavedItemNoteResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as UpdateSavedItemNoteResponse;
  return 'UpdateSavedItemNoteResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $UpdateSavedItemNoteResponseCopyWith<$Res>  {
  factory $UpdateSavedItemNoteResponseCopyWith(UpdateSavedItemNoteResponse value, $Res Function(UpdateSavedItemNoteResponse) _then) = _$UpdateSavedItemNoteResponseCopyWithImpl;
@useResult
$Res call({
 UpdateSavedItemNoteDataResponse data, String? message
});


$UpdateSavedItemNoteDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$UpdateSavedItemNoteResponseCopyWithImpl<$Res>
    implements $UpdateSavedItemNoteResponseCopyWith<$Res> {
  _$UpdateSavedItemNoteResponseCopyWithImpl(this._self, this._then);

  final UpdateSavedItemNoteResponse _self;
  final $Res Function(UpdateSavedItemNoteResponse) _then;

/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(UpdateSavedItemNoteResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UpdateSavedItemNoteDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateSavedItemNoteDataResponseCopyWith<$Res> get data {
  
  return $UpdateSavedItemNoteDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateSavedItemNoteResponse].
extension UpdateSavedItemNoteResponsePatterns on UpdateSavedItemNoteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSavedItemNoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpdateSavedItemNoteDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpdateSavedItemNoteDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpdateSavedItemNoteDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateSavedItemNoteResponse implements UpdateSavedItemNoteResponse {
  const _UpdateSavedItemNoteResponse({required this.data, this.message});
  factory _UpdateSavedItemNoteResponse.fromJson(Map<String, dynamic> json) => _$UpdateSavedItemNoteResponseFromJson(json);

@override final  UpdateSavedItemNoteDataResponse data;
@override final  String? message;

/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSavedItemNoteResponseCopyWith<_UpdateSavedItemNoteResponse> get copyWith => __$UpdateSavedItemNoteResponseCopyWithImpl<_UpdateSavedItemNoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSavedItemNoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSavedItemNoteResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'UpdateSavedItemNoteResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UpdateSavedItemNoteResponseCopyWith<$Res> implements $UpdateSavedItemNoteResponseCopyWith<$Res> {
  factory _$UpdateSavedItemNoteResponseCopyWith(_UpdateSavedItemNoteResponse value, $Res Function(_UpdateSavedItemNoteResponse) _then) = __$UpdateSavedItemNoteResponseCopyWithImpl;
@override @useResult
$Res call({
 UpdateSavedItemNoteDataResponse data, String? message
});


@override $UpdateSavedItemNoteDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$UpdateSavedItemNoteResponseCopyWithImpl<$Res>
    implements _$UpdateSavedItemNoteResponseCopyWith<$Res> {
  __$UpdateSavedItemNoteResponseCopyWithImpl(this._self, this._then);

  final _UpdateSavedItemNoteResponse _self;
  final $Res Function(_UpdateSavedItemNoteResponse) _then;

/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_UpdateSavedItemNoteResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UpdateSavedItemNoteDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpdateSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateSavedItemNoteDataResponseCopyWith<$Res> get data {
  
  return $UpdateSavedItemNoteDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
