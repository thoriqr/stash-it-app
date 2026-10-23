// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_collection_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteCollectionResponse {

 String? get message;
/// Create a copy of DeleteCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteCollectionResponseCopyWith<DeleteCollectionResponse> get copyWith => _$DeleteCollectionResponseCopyWithImpl<DeleteCollectionResponse>(this as DeleteCollectionResponse, _$identity);

  /// Serializes this DeleteCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteCollectionResponse&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteCollectionResponse;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as DeleteCollectionResponse;
  return 'DeleteCollectionResponse(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $DeleteCollectionResponseCopyWith<$Res>  {
  factory $DeleteCollectionResponseCopyWith(DeleteCollectionResponse value, $Res Function(DeleteCollectionResponse) _then) = _$DeleteCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$DeleteCollectionResponseCopyWithImpl<$Res>
    implements $DeleteCollectionResponseCopyWith<$Res> {
  _$DeleteCollectionResponseCopyWithImpl(this._self, this._then);

  final DeleteCollectionResponse _self;
  final $Res Function(DeleteCollectionResponse) _then;

/// Create a copy of DeleteCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,}) {
  return _then(DeleteCollectionResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteCollectionResponse].
extension DeleteCollectionResponsePatterns on DeleteCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeleteCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteCollectionResponse() when $default != null:
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
case _DeleteCollectionResponse() when $default != null:
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
case _DeleteCollectionResponse():
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
case _DeleteCollectionResponse() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteCollectionResponse implements DeleteCollectionResponse {
  const _DeleteCollectionResponse({this.message});
  factory _DeleteCollectionResponse.fromJson(Map<String, dynamic> json) => _$DeleteCollectionResponseFromJson(json);

@override final  String? message;

/// Create a copy of DeleteCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteCollectionResponseCopyWith<_DeleteCollectionResponse> get copyWith => __$DeleteCollectionResponseCopyWithImpl<_DeleteCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteCollectionResponse&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'DeleteCollectionResponse(message: $message)';
}


}

/// @nodoc
abstract mixin class _$DeleteCollectionResponseCopyWith<$Res> implements $DeleteCollectionResponseCopyWith<$Res> {
  factory _$DeleteCollectionResponseCopyWith(_DeleteCollectionResponse value, $Res Function(_DeleteCollectionResponse) _then) = __$DeleteCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$DeleteCollectionResponseCopyWithImpl<$Res>
    implements _$DeleteCollectionResponseCopyWith<$Res> {
  __$DeleteCollectionResponseCopyWithImpl(this._self, this._then);

  final _DeleteCollectionResponse _self;
  final $Res Function(_DeleteCollectionResponse) _then;

/// Create a copy of DeleteCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_DeleteCollectionResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
