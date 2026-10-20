// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listed_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListedCollectionResponse {

 String get id; String get name; String get type;@JsonKey(name: 'system_key') String? get systemKey;@JsonKey(name: 'saved_items_count') int get savedItemsCount;@JsonKey(name: 'saved_items_count_overflow') bool get savedItemsCountOverflow;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of ListedCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListedCollectionResponseCopyWith<ListedCollectionResponse> get copyWith => _$ListedCollectionResponseCopyWithImpl<ListedCollectionResponse>(this as ListedCollectionResponse, _$identity);

  /// Serializes this ListedCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListedCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListedCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.systemKey, _this.systemKey) || other.systemKey == _this.systemKey)&&(identical(other.savedItemsCount, _this.savedItemsCount) || other.savedItemsCount == _this.savedItemsCount)&&(identical(other.savedItemsCountOverflow, _this.savedItemsCountOverflow) || other.savedItemsCountOverflow == _this.savedItemsCountOverflow)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListedCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.systemKey,_this.savedItemsCount,_this.savedItemsCountOverflow,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as ListedCollectionResponse;
  return 'ListedCollectionResponse(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, systemKey: ${_this.systemKey}, savedItemsCount: ${_this.savedItemsCount}, savedItemsCountOverflow: ${_this.savedItemsCountOverflow}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ListedCollectionResponseCopyWith<$Res>  {
  factory $ListedCollectionResponseCopyWith(ListedCollectionResponse value, $Res Function(ListedCollectionResponse) _then) = _$ListedCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'system_key') String? systemKey,@JsonKey(name: 'saved_items_count') int savedItemsCount,@JsonKey(name: 'saved_items_count_overflow') bool savedItemsCountOverflow,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$ListedCollectionResponseCopyWithImpl<$Res>
    implements $ListedCollectionResponseCopyWith<$Res> {
  _$ListedCollectionResponseCopyWithImpl(this._self, this._then);

  final ListedCollectionResponse _self;
  final $Res Function(ListedCollectionResponse) _then;

/// Create a copy of ListedCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? systemKey = freezed,Object? savedItemsCount = null,Object? savedItemsCountOverflow = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(ListedCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,systemKey: freezed == systemKey ? _self.systemKey : systemKey // ignore: cast_nullable_to_non_nullable
as String?,savedItemsCount: null == savedItemsCount ? _self.savedItemsCount : savedItemsCount // ignore: cast_nullable_to_non_nullable
as int,savedItemsCountOverflow: null == savedItemsCountOverflow ? _self.savedItemsCountOverflow : savedItemsCountOverflow // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ListedCollectionResponse].
extension ListedCollectionResponsePatterns on ListedCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListedCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListedCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListedCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListedCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListedCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListedCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'system_key')  String? systemKey, @JsonKey(name: 'saved_items_count')  int savedItemsCount, @JsonKey(name: 'saved_items_count_overflow')  bool savedItemsCountOverflow, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListedCollectionResponse() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.systemKey,_that.savedItemsCount,_that.savedItemsCountOverflow,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'system_key')  String? systemKey, @JsonKey(name: 'saved_items_count')  int savedItemsCount, @JsonKey(name: 'saved_items_count_overflow')  bool savedItemsCountOverflow, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ListedCollectionResponse():
return $default(_that.id,_that.name,_that.type,_that.systemKey,_that.savedItemsCount,_that.savedItemsCountOverflow,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type, @JsonKey(name: 'system_key')  String? systemKey, @JsonKey(name: 'saved_items_count')  int savedItemsCount, @JsonKey(name: 'saved_items_count_overflow')  bool savedItemsCountOverflow, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListedCollectionResponse() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.systemKey,_that.savedItemsCount,_that.savedItemsCountOverflow,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListedCollectionResponse implements ListedCollectionResponse {
  const _ListedCollectionResponse({required this.id, required this.name, required this.type, @JsonKey(name: 'system_key') this.systemKey, @JsonKey(name: 'saved_items_count') required this.savedItemsCount, @JsonKey(name: 'saved_items_count_overflow') required this.savedItemsCountOverflow, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ListedCollectionResponse.fromJson(Map<String, dynamic> json) => _$ListedCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey(name: 'system_key') final  String? systemKey;
@override@JsonKey(name: 'saved_items_count') final  int savedItemsCount;
@override@JsonKey(name: 'saved_items_count_overflow') final  bool savedItemsCountOverflow;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of ListedCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListedCollectionResponseCopyWith<_ListedCollectionResponse> get copyWith => __$ListedCollectionResponseCopyWithImpl<_ListedCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListedCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListedCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.systemKey, systemKey) || other.systemKey == systemKey)&&(identical(other.savedItemsCount, savedItemsCount) || other.savedItemsCount == savedItemsCount)&&(identical(other.savedItemsCountOverflow, savedItemsCountOverflow) || other.savedItemsCountOverflow == savedItemsCountOverflow)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,systemKey,savedItemsCount,savedItemsCountOverflow,createdAt,updatedAt);
}

@override
String toString() {
    return 'ListedCollectionResponse(id: $id, name: $name, type: $type, systemKey: $systemKey, savedItemsCount: $savedItemsCount, savedItemsCountOverflow: $savedItemsCountOverflow, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListedCollectionResponseCopyWith<$Res> implements $ListedCollectionResponseCopyWith<$Res> {
  factory _$ListedCollectionResponseCopyWith(_ListedCollectionResponse value, $Res Function(_ListedCollectionResponse) _then) = __$ListedCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'system_key') String? systemKey,@JsonKey(name: 'saved_items_count') int savedItemsCount,@JsonKey(name: 'saved_items_count_overflow') bool savedItemsCountOverflow,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$ListedCollectionResponseCopyWithImpl<$Res>
    implements _$ListedCollectionResponseCopyWith<$Res> {
  __$ListedCollectionResponseCopyWithImpl(this._self, this._then);

  final _ListedCollectionResponse _self;
  final $Res Function(_ListedCollectionResponse) _then;

/// Create a copy of ListedCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? systemKey = freezed,Object? savedItemsCount = null,Object? savedItemsCountOverflow = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ListedCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,systemKey: freezed == systemKey ? _self.systemKey : systemKey // ignore: cast_nullable_to_non_nullable
as String?,savedItemsCount: null == savedItemsCount ? _self.savedItemsCount : savedItemsCount // ignore: cast_nullable_to_non_nullable
as int,savedItemsCountOverflow: null == savedItemsCountOverflow ? _self.savedItemsCountOverflow : savedItemsCountOverflow // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ListCollectionsDataResponse {

 List<ListedCollectionResponse> get collections;
/// Create a copy of ListCollectionsDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListCollectionsDataResponseCopyWith<ListCollectionsDataResponse> get copyWith => _$ListCollectionsDataResponseCopyWithImpl<ListCollectionsDataResponse>(this as ListCollectionsDataResponse, _$identity);

  /// Serializes this ListCollectionsDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListCollectionsDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListCollectionsDataResponse&&const DeepCollectionEquality().equals(other.collections, _this.collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListCollectionsDataResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.collections));
}

@override
String toString() {
  final _this = this as ListCollectionsDataResponse;
  return 'ListCollectionsDataResponse(collections: ${_this.collections})';
}


}

/// @nodoc
abstract mixin class $ListCollectionsDataResponseCopyWith<$Res>  {
  factory $ListCollectionsDataResponseCopyWith(ListCollectionsDataResponse value, $Res Function(ListCollectionsDataResponse) _then) = _$ListCollectionsDataResponseCopyWithImpl;
@useResult
$Res call({
 List<ListedCollectionResponse> collections
});




}
/// @nodoc
class _$ListCollectionsDataResponseCopyWithImpl<$Res>
    implements $ListCollectionsDataResponseCopyWith<$Res> {
  _$ListCollectionsDataResponseCopyWithImpl(this._self, this._then);

  final ListCollectionsDataResponse _self;
  final $Res Function(ListCollectionsDataResponse) _then;

/// Create a copy of ListCollectionsDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collections = null,}) {
  return _then(ListCollectionsDataResponse(
collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<ListedCollectionResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListCollectionsDataResponse].
extension ListCollectionsDataResponsePatterns on ListCollectionsDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListCollectionsDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListCollectionsDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListCollectionsDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListCollectionsDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ListedCollectionResponse> collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListCollectionsDataResponse() when $default != null:
return $default(_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ListedCollectionResponse> collections)  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsDataResponse():
return $default(_that.collections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ListedCollectionResponse> collections)?  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsDataResponse() when $default != null:
return $default(_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListCollectionsDataResponse implements ListCollectionsDataResponse {
  const _ListCollectionsDataResponse({required  List<ListedCollectionResponse> collections}): _collections = collections;
  factory _ListCollectionsDataResponse.fromJson(Map<String, dynamic> json) => _$ListCollectionsDataResponseFromJson(json);

 final  List<ListedCollectionResponse> _collections;
@override List<ListedCollectionResponse> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}


/// Create a copy of ListCollectionsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListCollectionsDataResponseCopyWith<_ListCollectionsDataResponse> get copyWith => __$ListCollectionsDataResponseCopyWithImpl<_ListCollectionsDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListCollectionsDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListCollectionsDataResponse&&const DeepCollectionEquality().equals(other.collections, _collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_collections));
}

@override
String toString() {
    return 'ListCollectionsDataResponse(collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$ListCollectionsDataResponseCopyWith<$Res> implements $ListCollectionsDataResponseCopyWith<$Res> {
  factory _$ListCollectionsDataResponseCopyWith(_ListCollectionsDataResponse value, $Res Function(_ListCollectionsDataResponse) _then) = __$ListCollectionsDataResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ListedCollectionResponse> collections
});




}
/// @nodoc
class __$ListCollectionsDataResponseCopyWithImpl<$Res>
    implements _$ListCollectionsDataResponseCopyWith<$Res> {
  __$ListCollectionsDataResponseCopyWithImpl(this._self, this._then);

  final _ListCollectionsDataResponse _self;
  final $Res Function(_ListCollectionsDataResponse) _then;

/// Create a copy of ListCollectionsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collections = null,}) {
  return _then(_ListCollectionsDataResponse(
collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<ListedCollectionResponse>,
  ));
}


}


/// @nodoc
mixin _$CursorPageMetaResponse {

@JsonKey(name: 'has_more') bool get hasMore;@JsonKey(name: 'next_cursor') String? get nextCursor;
/// Create a copy of CursorPageMetaResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorPageMetaResponseCopyWith<CursorPageMetaResponse> get copyWith => _$CursorPageMetaResponseCopyWithImpl<CursorPageMetaResponse>(this as CursorPageMetaResponse, _$identity);

  /// Serializes this CursorPageMetaResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CursorPageMetaResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorPageMetaResponse&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CursorPageMetaResponse;
  return Object.hash(runtimeType,_this.hasMore,_this.nextCursor);
}

@override
String toString() {
  final _this = this as CursorPageMetaResponse;
  return 'CursorPageMetaResponse(hasMore: ${_this.hasMore}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $CursorPageMetaResponseCopyWith<$Res>  {
  factory $CursorPageMetaResponseCopyWith(CursorPageMetaResponse value, $Res Function(CursorPageMetaResponse) _then) = _$CursorPageMetaResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'has_more') bool hasMore,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class _$CursorPageMetaResponseCopyWithImpl<$Res>
    implements $CursorPageMetaResponseCopyWith<$Res> {
  _$CursorPageMetaResponseCopyWithImpl(this._self, this._then);

  final CursorPageMetaResponse _self;
  final $Res Function(CursorPageMetaResponse) _then;

/// Create a copy of CursorPageMetaResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(CursorPageMetaResponse(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CursorPageMetaResponse].
extension CursorPageMetaResponsePatterns on CursorPageMetaResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CursorPageMetaResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CursorPageMetaResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CursorPageMetaResponse value)  $default,){
final _that = this;
switch (_that) {
case _CursorPageMetaResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CursorPageMetaResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CursorPageMetaResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CursorPageMetaResponse() when $default != null:
return $default(_that.hasMore,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'next_cursor')  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _CursorPageMetaResponse():
return $default(_that.hasMore,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _CursorPageMetaResponse() when $default != null:
return $default(_that.hasMore,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CursorPageMetaResponse implements CursorPageMetaResponse {
  const _CursorPageMetaResponse({@JsonKey(name: 'has_more') required this.hasMore, @JsonKey(name: 'next_cursor') this.nextCursor});
  factory _CursorPageMetaResponse.fromJson(Map<String, dynamic> json) => _$CursorPageMetaResponseFromJson(json);

@override@JsonKey(name: 'has_more') final  bool hasMore;
@override@JsonKey(name: 'next_cursor') final  String? nextCursor;

/// Create a copy of CursorPageMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorPageMetaResponseCopyWith<_CursorPageMetaResponse> get copyWith => __$CursorPageMetaResponseCopyWithImpl<_CursorPageMetaResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CursorPageMetaResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorPageMetaResponse&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hasMore,nextCursor);
}

@override
String toString() {
    return 'CursorPageMetaResponse(hasMore: $hasMore, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CursorPageMetaResponseCopyWith<$Res> implements $CursorPageMetaResponseCopyWith<$Res> {
  factory _$CursorPageMetaResponseCopyWith(_CursorPageMetaResponse value, $Res Function(_CursorPageMetaResponse) _then) = __$CursorPageMetaResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'has_more') bool hasMore,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class __$CursorPageMetaResponseCopyWithImpl<$Res>
    implements _$CursorPageMetaResponseCopyWith<$Res> {
  __$CursorPageMetaResponseCopyWithImpl(this._self, this._then);

  final _CursorPageMetaResponse _self;
  final $Res Function(_CursorPageMetaResponse) _then;

/// Create a copy of CursorPageMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasMore = null,Object? nextCursor = freezed,}) {
  return _then(_CursorPageMetaResponse(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListCollectionsMetaResponse {

 CursorPageMetaResponse get cursor;
/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListCollectionsMetaResponseCopyWith<ListCollectionsMetaResponse> get copyWith => _$ListCollectionsMetaResponseCopyWithImpl<ListCollectionsMetaResponse>(this as ListCollectionsMetaResponse, _$identity);

  /// Serializes this ListCollectionsMetaResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListCollectionsMetaResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListCollectionsMetaResponse&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListCollectionsMetaResponse;
  return Object.hash(runtimeType,_this.cursor);
}

@override
String toString() {
  final _this = this as ListCollectionsMetaResponse;
  return 'ListCollectionsMetaResponse(cursor: ${_this.cursor})';
}


}

/// @nodoc
abstract mixin class $ListCollectionsMetaResponseCopyWith<$Res>  {
  factory $ListCollectionsMetaResponseCopyWith(ListCollectionsMetaResponse value, $Res Function(ListCollectionsMetaResponse) _then) = _$ListCollectionsMetaResponseCopyWithImpl;
@useResult
$Res call({
 CursorPageMetaResponse cursor
});


$CursorPageMetaResponseCopyWith<$Res> get cursor;

}
/// @nodoc
class _$ListCollectionsMetaResponseCopyWithImpl<$Res>
    implements $ListCollectionsMetaResponseCopyWith<$Res> {
  _$ListCollectionsMetaResponseCopyWithImpl(this._self, this._then);

  final ListCollectionsMetaResponse _self;
  final $Res Function(ListCollectionsMetaResponse) _then;

/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cursor = null,}) {
  return _then(ListCollectionsMetaResponse(
cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as CursorPageMetaResponse,
  ));
}
/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CursorPageMetaResponseCopyWith<$Res> get cursor {
  
  return $CursorPageMetaResponseCopyWith<$Res>(_self.cursor, (value) {
    return _then(_self.copyWith(cursor: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListCollectionsMetaResponse].
extension ListCollectionsMetaResponsePatterns on ListCollectionsMetaResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListCollectionsMetaResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListCollectionsMetaResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListCollectionsMetaResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CursorPageMetaResponse cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse() when $default != null:
return $default(_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CursorPageMetaResponse cursor)  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse():
return $default(_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CursorPageMetaResponse cursor)?  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsMetaResponse() when $default != null:
return $default(_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListCollectionsMetaResponse implements ListCollectionsMetaResponse {
  const _ListCollectionsMetaResponse({required this.cursor});
  factory _ListCollectionsMetaResponse.fromJson(Map<String, dynamic> json) => _$ListCollectionsMetaResponseFromJson(json);

@override final  CursorPageMetaResponse cursor;

/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListCollectionsMetaResponseCopyWith<_ListCollectionsMetaResponse> get copyWith => __$ListCollectionsMetaResponseCopyWithImpl<_ListCollectionsMetaResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListCollectionsMetaResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListCollectionsMetaResponse&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,cursor);
}

@override
String toString() {
    return 'ListCollectionsMetaResponse(cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$ListCollectionsMetaResponseCopyWith<$Res> implements $ListCollectionsMetaResponseCopyWith<$Res> {
  factory _$ListCollectionsMetaResponseCopyWith(_ListCollectionsMetaResponse value, $Res Function(_ListCollectionsMetaResponse) _then) = __$ListCollectionsMetaResponseCopyWithImpl;
@override @useResult
$Res call({
 CursorPageMetaResponse cursor
});


@override $CursorPageMetaResponseCopyWith<$Res> get cursor;

}
/// @nodoc
class __$ListCollectionsMetaResponseCopyWithImpl<$Res>
    implements _$ListCollectionsMetaResponseCopyWith<$Res> {
  __$ListCollectionsMetaResponseCopyWithImpl(this._self, this._then);

  final _ListCollectionsMetaResponse _self;
  final $Res Function(_ListCollectionsMetaResponse) _then;

/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cursor = null,}) {
  return _then(_ListCollectionsMetaResponse(
cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as CursorPageMetaResponse,
  ));
}

/// Create a copy of ListCollectionsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CursorPageMetaResponseCopyWith<$Res> get cursor {
  
  return $CursorPageMetaResponseCopyWith<$Res>(_self.cursor, (value) {
    return _then(_self.copyWith(cursor: value));
  });
}
}


/// @nodoc
mixin _$ListCollectionsResponse {

 ListCollectionsDataResponse get data; String? get message; ListCollectionsMetaResponse? get meta;
/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListCollectionsResponseCopyWith<ListCollectionsResponse> get copyWith => _$ListCollectionsResponseCopyWithImpl<ListCollectionsResponse>(this as ListCollectionsResponse, _$identity);

  /// Serializes this ListCollectionsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListCollectionsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListCollectionsResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.meta, _this.meta) || other.meta == _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListCollectionsResponse;
  return Object.hash(runtimeType,_this.data,_this.message,_this.meta);
}

@override
String toString() {
  final _this = this as ListCollectionsResponse;
  return 'ListCollectionsResponse(data: ${_this.data}, message: ${_this.message}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $ListCollectionsResponseCopyWith<$Res>  {
  factory $ListCollectionsResponseCopyWith(ListCollectionsResponse value, $Res Function(ListCollectionsResponse) _then) = _$ListCollectionsResponseCopyWithImpl;
@useResult
$Res call({
 ListCollectionsDataResponse data, String? message, ListCollectionsMetaResponse? meta
});


$ListCollectionsDataResponseCopyWith<$Res> get data;$ListCollectionsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class _$ListCollectionsResponseCopyWithImpl<$Res>
    implements $ListCollectionsResponseCopyWith<$Res> {
  _$ListCollectionsResponseCopyWithImpl(this._self, this._then);

  final ListCollectionsResponse _self;
  final $Res Function(ListCollectionsResponse) _then;

/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(ListCollectionsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListCollectionsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListCollectionsMetaResponse?,
  ));
}
/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionsDataResponseCopyWith<$Res> get data {
  
  return $ListCollectionsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListCollectionsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListCollectionsResponse].
extension ListCollectionsResponsePatterns on ListCollectionsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListCollectionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListCollectionsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListCollectionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListCollectionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListCollectionsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListCollectionsDataResponse data,  String? message,  ListCollectionsMetaResponse? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListCollectionsResponse() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListCollectionsDataResponse data,  String? message,  ListCollectionsMetaResponse? meta)  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsResponse():
return $default(_that.data,_that.message,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListCollectionsDataResponse data,  String? message,  ListCollectionsMetaResponse? meta)?  $default,) {final _that = this;
switch (_that) {
case _ListCollectionsResponse() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListCollectionsResponse implements ListCollectionsResponse {
  const _ListCollectionsResponse({required this.data, this.message, this.meta});
  factory _ListCollectionsResponse.fromJson(Map<String, dynamic> json) => _$ListCollectionsResponseFromJson(json);

@override final  ListCollectionsDataResponse data;
@override final  String? message;
@override final  ListCollectionsMetaResponse? meta;

/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListCollectionsResponseCopyWith<_ListCollectionsResponse> get copyWith => __$ListCollectionsResponseCopyWithImpl<_ListCollectionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListCollectionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListCollectionsResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message,meta);
}

@override
String toString() {
    return 'ListCollectionsResponse(data: $data, message: $message, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ListCollectionsResponseCopyWith<$Res> implements $ListCollectionsResponseCopyWith<$Res> {
  factory _$ListCollectionsResponseCopyWith(_ListCollectionsResponse value, $Res Function(_ListCollectionsResponse) _then) = __$ListCollectionsResponseCopyWithImpl;
@override @useResult
$Res call({
 ListCollectionsDataResponse data, String? message, ListCollectionsMetaResponse? meta
});


@override $ListCollectionsDataResponseCopyWith<$Res> get data;@override $ListCollectionsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class __$ListCollectionsResponseCopyWithImpl<$Res>
    implements _$ListCollectionsResponseCopyWith<$Res> {
  __$ListCollectionsResponseCopyWithImpl(this._self, this._then);

  final _ListCollectionsResponse _self;
  final $Res Function(_ListCollectionsResponse) _then;

/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(_ListCollectionsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListCollectionsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListCollectionsMetaResponse?,
  ));
}

/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionsDataResponseCopyWith<$Res> get data {
  
  return $ListCollectionsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListCollectionsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListCollectionsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
