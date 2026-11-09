// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_saved_item_note_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteSavedItemNoteDataResponse {



  /// Serializes this DeleteSavedItemNoteDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSavedItemNoteDataResponse);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeleteSavedItemNoteDataResponse()';
}


}

/// @nodoc
class $DeleteSavedItemNoteDataResponseCopyWith<$Res>  {
$DeleteSavedItemNoteDataResponseCopyWith(DeleteSavedItemNoteDataResponse _, $Res Function(DeleteSavedItemNoteDataResponse) __);
}


/// Adds pattern-matching-related methods to [DeleteSavedItemNoteDataResponse].
extension DeleteSavedItemNoteDataResponsePatterns on DeleteSavedItemNoteDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteSavedItemNoteDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteSavedItemNoteDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteSavedItemNoteDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function()?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse() when $default != null:
return $default();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function()  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse():
return $default();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function()?  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteDataResponse() when $default != null:
return $default();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteSavedItemNoteDataResponse implements DeleteSavedItemNoteDataResponse {
  const _DeleteSavedItemNoteDataResponse();
  factory _DeleteSavedItemNoteDataResponse.fromJson(Map<String, dynamic> json) => _$DeleteSavedItemNoteDataResponseFromJson(json);




@override
Map<String, dynamic> toJson() {
  return _$DeleteSavedItemNoteDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteSavedItemNoteDataResponse);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DeleteSavedItemNoteDataResponse()';
}


}





/// @nodoc
mixin _$DeleteSavedItemNoteResponse {

 DeleteSavedItemNoteDataResponse get data; String? get message;
/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteSavedItemNoteResponseCopyWith<DeleteSavedItemNoteResponse> get copyWith => _$DeleteSavedItemNoteResponseCopyWithImpl<DeleteSavedItemNoteResponse>(this as DeleteSavedItemNoteResponse, _$identity);

  /// Serializes this DeleteSavedItemNoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteSavedItemNoteResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSavedItemNoteResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteSavedItemNoteResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as DeleteSavedItemNoteResponse;
  return 'DeleteSavedItemNoteResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $DeleteSavedItemNoteResponseCopyWith<$Res>  {
  factory $DeleteSavedItemNoteResponseCopyWith(DeleteSavedItemNoteResponse value, $Res Function(DeleteSavedItemNoteResponse) _then) = _$DeleteSavedItemNoteResponseCopyWithImpl;
@useResult
$Res call({
 DeleteSavedItemNoteDataResponse data, String? message
});


$DeleteSavedItemNoteDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$DeleteSavedItemNoteResponseCopyWithImpl<$Res>
    implements $DeleteSavedItemNoteResponseCopyWith<$Res> {
  _$DeleteSavedItemNoteResponseCopyWithImpl(this._self, this._then);

  final DeleteSavedItemNoteResponse _self;
  final $Res Function(DeleteSavedItemNoteResponse) _then;

/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(DeleteSavedItemNoteResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DeleteSavedItemNoteDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteSavedItemNoteDataResponseCopyWith<$Res> get data {
  
  return $DeleteSavedItemNoteDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeleteSavedItemNoteResponse].
extension DeleteSavedItemNoteResponsePatterns on DeleteSavedItemNoteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteSavedItemNoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteSavedItemNoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteSavedItemNoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeleteSavedItemNoteDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeleteSavedItemNoteDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeleteSavedItemNoteDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemNoteResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteSavedItemNoteResponse implements DeleteSavedItemNoteResponse {
  const _DeleteSavedItemNoteResponse({required this.data, this.message});
  factory _DeleteSavedItemNoteResponse.fromJson(Map<String, dynamic> json) => _$DeleteSavedItemNoteResponseFromJson(json);

@override final  DeleteSavedItemNoteDataResponse data;
@override final  String? message;

/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteSavedItemNoteResponseCopyWith<_DeleteSavedItemNoteResponse> get copyWith => __$DeleteSavedItemNoteResponseCopyWithImpl<_DeleteSavedItemNoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteSavedItemNoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteSavedItemNoteResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'DeleteSavedItemNoteResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DeleteSavedItemNoteResponseCopyWith<$Res> implements $DeleteSavedItemNoteResponseCopyWith<$Res> {
  factory _$DeleteSavedItemNoteResponseCopyWith(_DeleteSavedItemNoteResponse value, $Res Function(_DeleteSavedItemNoteResponse) _then) = __$DeleteSavedItemNoteResponseCopyWithImpl;
@override @useResult
$Res call({
 DeleteSavedItemNoteDataResponse data, String? message
});


@override $DeleteSavedItemNoteDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$DeleteSavedItemNoteResponseCopyWithImpl<$Res>
    implements _$DeleteSavedItemNoteResponseCopyWith<$Res> {
  __$DeleteSavedItemNoteResponseCopyWithImpl(this._self, this._then);

  final _DeleteSavedItemNoteResponse _self;
  final $Res Function(_DeleteSavedItemNoteResponse) _then;

/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_DeleteSavedItemNoteResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DeleteSavedItemNoteDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DeleteSavedItemNoteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteSavedItemNoteDataResponseCopyWith<$Res> get data {
  
  return $DeleteSavedItemNoteDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
