// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_saved_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteSavedItemDataResponse {

@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'collection_empty') bool get collectionEmpty;@JsonKey(name: 'collection_deletable') bool get collectionDeletable;
/// Create a copy of DeleteSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteSavedItemDataResponseCopyWith<DeleteSavedItemDataResponse> get copyWith => _$DeleteSavedItemDataResponseCopyWithImpl<DeleteSavedItemDataResponse>(this as DeleteSavedItemDataResponse, _$identity);

  /// Serializes this DeleteSavedItemDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteSavedItemDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSavedItemDataResponse&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.collectionEmpty, _this.collectionEmpty) || other.collectionEmpty == _this.collectionEmpty)&&(identical(other.collectionDeletable, _this.collectionDeletable) || other.collectionDeletable == _this.collectionDeletable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteSavedItemDataResponse;
  return Object.hash(runtimeType,_this.collectionId,_this.collectionEmpty,_this.collectionDeletable);
}

@override
String toString() {
  final _this = this as DeleteSavedItemDataResponse;
  return 'DeleteSavedItemDataResponse(collectionId: ${_this.collectionId}, collectionEmpty: ${_this.collectionEmpty}, collectionDeletable: ${_this.collectionDeletable})';
}


}

/// @nodoc
abstract mixin class $DeleteSavedItemDataResponseCopyWith<$Res>  {
  factory $DeleteSavedItemDataResponseCopyWith(DeleteSavedItemDataResponse value, $Res Function(DeleteSavedItemDataResponse) _then) = _$DeleteSavedItemDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'collection_empty') bool collectionEmpty,@JsonKey(name: 'collection_deletable') bool collectionDeletable
});




}
/// @nodoc
class _$DeleteSavedItemDataResponseCopyWithImpl<$Res>
    implements $DeleteSavedItemDataResponseCopyWith<$Res> {
  _$DeleteSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final DeleteSavedItemDataResponse _self;
  final $Res Function(DeleteSavedItemDataResponse) _then;

/// Create a copy of DeleteSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionId = null,Object? collectionEmpty = null,Object? collectionDeletable = null,}) {
  return _then(DeleteSavedItemDataResponse(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,collectionEmpty: null == collectionEmpty ? _self.collectionEmpty : collectionEmpty // ignore: cast_nullable_to_non_nullable
as bool,collectionDeletable: null == collectionDeletable ? _self.collectionDeletable : collectionDeletable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteSavedItemDataResponse].
extension DeleteSavedItemDataResponsePatterns on DeleteSavedItemDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteSavedItemDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteSavedItemDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteSavedItemDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'collection_empty')  bool collectionEmpty, @JsonKey(name: 'collection_deletable')  bool collectionDeletable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse() when $default != null:
return $default(_that.collectionId,_that.collectionEmpty,_that.collectionDeletable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'collection_empty')  bool collectionEmpty, @JsonKey(name: 'collection_deletable')  bool collectionDeletable)  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse():
return $default(_that.collectionId,_that.collectionEmpty,_that.collectionDeletable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'collection_empty')  bool collectionEmpty, @JsonKey(name: 'collection_deletable')  bool collectionDeletable)?  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemDataResponse() when $default != null:
return $default(_that.collectionId,_that.collectionEmpty,_that.collectionDeletable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteSavedItemDataResponse implements DeleteSavedItemDataResponse {
  const _DeleteSavedItemDataResponse({@JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'collection_empty') required this.collectionEmpty, @JsonKey(name: 'collection_deletable') required this.collectionDeletable});
  factory _DeleteSavedItemDataResponse.fromJson(Map<String, dynamic> json) => _$DeleteSavedItemDataResponseFromJson(json);

@override@JsonKey(name: 'collection_id') final  String collectionId;
@override@JsonKey(name: 'collection_empty') final  bool collectionEmpty;
@override@JsonKey(name: 'collection_deletable') final  bool collectionDeletable;

/// Create a copy of DeleteSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteSavedItemDataResponseCopyWith<_DeleteSavedItemDataResponse> get copyWith => __$DeleteSavedItemDataResponseCopyWithImpl<_DeleteSavedItemDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteSavedItemDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteSavedItemDataResponse&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.collectionEmpty, collectionEmpty) || other.collectionEmpty == collectionEmpty)&&(identical(other.collectionDeletable, collectionDeletable) || other.collectionDeletable == collectionDeletable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,collectionId,collectionEmpty,collectionDeletable);
}

@override
String toString() {
    return 'DeleteSavedItemDataResponse(collectionId: $collectionId, collectionEmpty: $collectionEmpty, collectionDeletable: $collectionDeletable)';
}


}

/// @nodoc
abstract mixin class _$DeleteSavedItemDataResponseCopyWith<$Res> implements $DeleteSavedItemDataResponseCopyWith<$Res> {
  factory _$DeleteSavedItemDataResponseCopyWith(_DeleteSavedItemDataResponse value, $Res Function(_DeleteSavedItemDataResponse) _then) = __$DeleteSavedItemDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'collection_empty') bool collectionEmpty,@JsonKey(name: 'collection_deletable') bool collectionDeletable
});




}
/// @nodoc
class __$DeleteSavedItemDataResponseCopyWithImpl<$Res>
    implements _$DeleteSavedItemDataResponseCopyWith<$Res> {
  __$DeleteSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final _DeleteSavedItemDataResponse _self;
  final $Res Function(_DeleteSavedItemDataResponse) _then;

/// Create a copy of DeleteSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionId = null,Object? collectionEmpty = null,Object? collectionDeletable = null,}) {
  return _then(_DeleteSavedItemDataResponse(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,collectionEmpty: null == collectionEmpty ? _self.collectionEmpty : collectionEmpty // ignore: cast_nullable_to_non_nullable
as bool,collectionDeletable: null == collectionDeletable ? _self.collectionDeletable : collectionDeletable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DeleteSavedItemResponse {

 DeleteSavedItemDataResponse get data; String? get message;
/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteSavedItemResponseCopyWith<DeleteSavedItemResponse> get copyWith => _$DeleteSavedItemResponseCopyWithImpl<DeleteSavedItemResponse>(this as DeleteSavedItemResponse, _$identity);

  /// Serializes this DeleteSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSavedItemResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteSavedItemResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as DeleteSavedItemResponse;
  return 'DeleteSavedItemResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $DeleteSavedItemResponseCopyWith<$Res>  {
  factory $DeleteSavedItemResponseCopyWith(DeleteSavedItemResponse value, $Res Function(DeleteSavedItemResponse) _then) = _$DeleteSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 DeleteSavedItemDataResponse data, String? message
});


$DeleteSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$DeleteSavedItemResponseCopyWithImpl<$Res>
    implements $DeleteSavedItemResponseCopyWith<$Res> {
  _$DeleteSavedItemResponseCopyWithImpl(this._self, this._then);

  final DeleteSavedItemResponse _self;
  final $Res Function(DeleteSavedItemResponse) _then;

/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(DeleteSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DeleteSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteSavedItemDataResponseCopyWith<$Res> get data {
  
  return $DeleteSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeleteSavedItemResponse].
extension DeleteSavedItemResponsePatterns on DeleteSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeleteSavedItemDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeleteSavedItemDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeleteSavedItemDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _DeleteSavedItemResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteSavedItemResponse implements DeleteSavedItemResponse {
  const _DeleteSavedItemResponse({required this.data, this.message});
  factory _DeleteSavedItemResponse.fromJson(Map<String, dynamic> json) => _$DeleteSavedItemResponseFromJson(json);

@override final  DeleteSavedItemDataResponse data;
@override final  String? message;

/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteSavedItemResponseCopyWith<_DeleteSavedItemResponse> get copyWith => __$DeleteSavedItemResponseCopyWithImpl<_DeleteSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteSavedItemResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'DeleteSavedItemResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DeleteSavedItemResponseCopyWith<$Res> implements $DeleteSavedItemResponseCopyWith<$Res> {
  factory _$DeleteSavedItemResponseCopyWith(_DeleteSavedItemResponse value, $Res Function(_DeleteSavedItemResponse) _then) = __$DeleteSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 DeleteSavedItemDataResponse data, String? message
});


@override $DeleteSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$DeleteSavedItemResponseCopyWithImpl<$Res>
    implements _$DeleteSavedItemResponseCopyWith<$Res> {
  __$DeleteSavedItemResponseCopyWithImpl(this._self, this._then);

  final _DeleteSavedItemResponse _self;
  final $Res Function(_DeleteSavedItemResponse) _then;

/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_DeleteSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DeleteSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DeleteSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteSavedItemDataResponseCopyWith<$Res> get data {
  
  return $DeleteSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
