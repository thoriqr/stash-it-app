// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_saved_items_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

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
mixin _$ListSavedItemsMetaResponse {

 CursorPageMetaResponse get cursor;
/// Create a copy of ListSavedItemsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListSavedItemsMetaResponseCopyWith<ListSavedItemsMetaResponse> get copyWith => _$ListSavedItemsMetaResponseCopyWithImpl<ListSavedItemsMetaResponse>(this as ListSavedItemsMetaResponse, _$identity);

  /// Serializes this ListSavedItemsMetaResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListSavedItemsMetaResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListSavedItemsMetaResponse&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListSavedItemsMetaResponse;
  return Object.hash(runtimeType,_this.cursor);
}

@override
String toString() {
  final _this = this as ListSavedItemsMetaResponse;
  return 'ListSavedItemsMetaResponse(cursor: ${_this.cursor})';
}


}

/// @nodoc
abstract mixin class $ListSavedItemsMetaResponseCopyWith<$Res>  {
  factory $ListSavedItemsMetaResponseCopyWith(ListSavedItemsMetaResponse value, $Res Function(ListSavedItemsMetaResponse) _then) = _$ListSavedItemsMetaResponseCopyWithImpl;
@useResult
$Res call({
 CursorPageMetaResponse cursor
});


$CursorPageMetaResponseCopyWith<$Res> get cursor;

}
/// @nodoc
class _$ListSavedItemsMetaResponseCopyWithImpl<$Res>
    implements $ListSavedItemsMetaResponseCopyWith<$Res> {
  _$ListSavedItemsMetaResponseCopyWithImpl(this._self, this._then);

  final ListSavedItemsMetaResponse _self;
  final $Res Function(ListSavedItemsMetaResponse) _then;

/// Create a copy of ListSavedItemsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cursor = null,}) {
  return _then(ListSavedItemsMetaResponse(
cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as CursorPageMetaResponse,
  ));
}
/// Create a copy of ListSavedItemsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CursorPageMetaResponseCopyWith<$Res> get cursor {
  
  return $CursorPageMetaResponseCopyWith<$Res>(_self.cursor, (value) {
    return _then(_self.copyWith(cursor: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListSavedItemsMetaResponse].
extension ListSavedItemsMetaResponsePatterns on ListSavedItemsMetaResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListSavedItemsMetaResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListSavedItemsMetaResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListSavedItemsMetaResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsMetaResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListSavedItemsMetaResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsMetaResponse() when $default != null:
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
case _ListSavedItemsMetaResponse() when $default != null:
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
case _ListSavedItemsMetaResponse():
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
case _ListSavedItemsMetaResponse() when $default != null:
return $default(_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListSavedItemsMetaResponse implements ListSavedItemsMetaResponse {
  const _ListSavedItemsMetaResponse({required this.cursor});
  factory _ListSavedItemsMetaResponse.fromJson(Map<String, dynamic> json) => _$ListSavedItemsMetaResponseFromJson(json);

@override final  CursorPageMetaResponse cursor;

/// Create a copy of ListSavedItemsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListSavedItemsMetaResponseCopyWith<_ListSavedItemsMetaResponse> get copyWith => __$ListSavedItemsMetaResponseCopyWithImpl<_ListSavedItemsMetaResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListSavedItemsMetaResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListSavedItemsMetaResponse&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,cursor);
}

@override
String toString() {
    return 'ListSavedItemsMetaResponse(cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$ListSavedItemsMetaResponseCopyWith<$Res> implements $ListSavedItemsMetaResponseCopyWith<$Res> {
  factory _$ListSavedItemsMetaResponseCopyWith(_ListSavedItemsMetaResponse value, $Res Function(_ListSavedItemsMetaResponse) _then) = __$ListSavedItemsMetaResponseCopyWithImpl;
@override @useResult
$Res call({
 CursorPageMetaResponse cursor
});


@override $CursorPageMetaResponseCopyWith<$Res> get cursor;

}
/// @nodoc
class __$ListSavedItemsMetaResponseCopyWithImpl<$Res>
    implements _$ListSavedItemsMetaResponseCopyWith<$Res> {
  __$ListSavedItemsMetaResponseCopyWithImpl(this._self, this._then);

  final _ListSavedItemsMetaResponse _self;
  final $Res Function(_ListSavedItemsMetaResponse) _then;

/// Create a copy of ListSavedItemsMetaResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cursor = null,}) {
  return _then(_ListSavedItemsMetaResponse(
cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as CursorPageMetaResponse,
  ));
}

/// Create a copy of ListSavedItemsMetaResponse
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
mixin _$ListSavedItemsDataResponse {

@JsonKey(name: 'saved_items') List<ListedSavedItemResponse> get savedItems;
/// Create a copy of ListSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListSavedItemsDataResponseCopyWith<ListSavedItemsDataResponse> get copyWith => _$ListSavedItemsDataResponseCopyWithImpl<ListSavedItemsDataResponse>(this as ListSavedItemsDataResponse, _$identity);

  /// Serializes this ListSavedItemsDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListSavedItemsDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListSavedItemsDataResponse&&const DeepCollectionEquality().equals(other.savedItems, _this.savedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListSavedItemsDataResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.savedItems));
}

@override
String toString() {
  final _this = this as ListSavedItemsDataResponse;
  return 'ListSavedItemsDataResponse(savedItems: ${_this.savedItems})';
}


}

/// @nodoc
abstract mixin class $ListSavedItemsDataResponseCopyWith<$Res>  {
  factory $ListSavedItemsDataResponseCopyWith(ListSavedItemsDataResponse value, $Res Function(ListSavedItemsDataResponse) _then) = _$ListSavedItemsDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_items') List<ListedSavedItemResponse> savedItems
});




}
/// @nodoc
class _$ListSavedItemsDataResponseCopyWithImpl<$Res>
    implements $ListSavedItemsDataResponseCopyWith<$Res> {
  _$ListSavedItemsDataResponseCopyWithImpl(this._self, this._then);

  final ListSavedItemsDataResponse _self;
  final $Res Function(ListSavedItemsDataResponse) _then;

/// Create a copy of ListSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItems = null,}) {
  return _then(ListSavedItemsDataResponse(
savedItems: null == savedItems ? _self.savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<ListedSavedItemResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListSavedItemsDataResponse].
extension ListSavedItemsDataResponsePatterns on ListSavedItemsDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListSavedItemsDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListSavedItemsDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListSavedItemsDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items')  List<ListedSavedItemResponse> savedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse() when $default != null:
return $default(_that.savedItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items')  List<ListedSavedItemResponse> savedItems)  $default,) {final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse():
return $default(_that.savedItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_items')  List<ListedSavedItemResponse> savedItems)?  $default,) {final _that = this;
switch (_that) {
case _ListSavedItemsDataResponse() when $default != null:
return $default(_that.savedItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListSavedItemsDataResponse implements ListSavedItemsDataResponse {
  const _ListSavedItemsDataResponse({@JsonKey(name: 'saved_items') required  List<ListedSavedItemResponse> savedItems}): _savedItems = savedItems;
  factory _ListSavedItemsDataResponse.fromJson(Map<String, dynamic> json) => _$ListSavedItemsDataResponseFromJson(json);

 final  List<ListedSavedItemResponse> _savedItems;
@override@JsonKey(name: 'saved_items') List<ListedSavedItemResponse> get savedItems {
  if (_savedItems is EqualUnmodifiableListView) return _savedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedItems);
}


/// Create a copy of ListSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListSavedItemsDataResponseCopyWith<_ListSavedItemsDataResponse> get copyWith => __$ListSavedItemsDataResponseCopyWithImpl<_ListSavedItemsDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListSavedItemsDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListSavedItemsDataResponse&&const DeepCollectionEquality().equals(other.savedItems, _savedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_savedItems));
}

@override
String toString() {
    return 'ListSavedItemsDataResponse(savedItems: $savedItems)';
}


}

/// @nodoc
abstract mixin class _$ListSavedItemsDataResponseCopyWith<$Res> implements $ListSavedItemsDataResponseCopyWith<$Res> {
  factory _$ListSavedItemsDataResponseCopyWith(_ListSavedItemsDataResponse value, $Res Function(_ListSavedItemsDataResponse) _then) = __$ListSavedItemsDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_items') List<ListedSavedItemResponse> savedItems
});




}
/// @nodoc
class __$ListSavedItemsDataResponseCopyWithImpl<$Res>
    implements _$ListSavedItemsDataResponseCopyWith<$Res> {
  __$ListSavedItemsDataResponseCopyWithImpl(this._self, this._then);

  final _ListSavedItemsDataResponse _self;
  final $Res Function(_ListSavedItemsDataResponse) _then;

/// Create a copy of ListSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItems = null,}) {
  return _then(_ListSavedItemsDataResponse(
savedItems: null == savedItems ? _self._savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<ListedSavedItemResponse>,
  ));
}


}


/// @nodoc
mixin _$ListSavedItemsResponse {

 ListSavedItemsDataResponse get data; String? get message; ListSavedItemsMetaResponse? get meta;
/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListSavedItemsResponseCopyWith<ListSavedItemsResponse> get copyWith => _$ListSavedItemsResponseCopyWithImpl<ListSavedItemsResponse>(this as ListSavedItemsResponse, _$identity);

  /// Serializes this ListSavedItemsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListSavedItemsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListSavedItemsResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.meta, _this.meta) || other.meta == _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListSavedItemsResponse;
  return Object.hash(runtimeType,_this.data,_this.message,_this.meta);
}

@override
String toString() {
  final _this = this as ListSavedItemsResponse;
  return 'ListSavedItemsResponse(data: ${_this.data}, message: ${_this.message}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $ListSavedItemsResponseCopyWith<$Res>  {
  factory $ListSavedItemsResponseCopyWith(ListSavedItemsResponse value, $Res Function(ListSavedItemsResponse) _then) = _$ListSavedItemsResponseCopyWithImpl;
@useResult
$Res call({
 ListSavedItemsDataResponse data, String? message, ListSavedItemsMetaResponse? meta
});


$ListSavedItemsDataResponseCopyWith<$Res> get data;$ListSavedItemsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class _$ListSavedItemsResponseCopyWithImpl<$Res>
    implements $ListSavedItemsResponseCopyWith<$Res> {
  _$ListSavedItemsResponseCopyWithImpl(this._self, this._then);

  final ListSavedItemsResponse _self;
  final $Res Function(ListSavedItemsResponse) _then;

/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(ListSavedItemsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListSavedItemsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListSavedItemsMetaResponse?,
  ));
}
/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsDataResponseCopyWith<$Res> get data {
  
  return $ListSavedItemsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListSavedItemsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListSavedItemsResponse].
extension ListSavedItemsResponsePatterns on ListSavedItemsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListSavedItemsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListSavedItemsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListSavedItemsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListSavedItemsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListSavedItemsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListSavedItemsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)  $default,) {final _that = this;
switch (_that) {
case _ListSavedItemsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)?  $default,) {final _that = this;
switch (_that) {
case _ListSavedItemsResponse() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListSavedItemsResponse implements ListSavedItemsResponse {
  const _ListSavedItemsResponse({required this.data, this.message, this.meta});
  factory _ListSavedItemsResponse.fromJson(Map<String, dynamic> json) => _$ListSavedItemsResponseFromJson(json);

@override final  ListSavedItemsDataResponse data;
@override final  String? message;
@override final  ListSavedItemsMetaResponse? meta;

/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListSavedItemsResponseCopyWith<_ListSavedItemsResponse> get copyWith => __$ListSavedItemsResponseCopyWithImpl<_ListSavedItemsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListSavedItemsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListSavedItemsResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message,meta);
}

@override
String toString() {
    return 'ListSavedItemsResponse(data: $data, message: $message, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ListSavedItemsResponseCopyWith<$Res> implements $ListSavedItemsResponseCopyWith<$Res> {
  factory _$ListSavedItemsResponseCopyWith(_ListSavedItemsResponse value, $Res Function(_ListSavedItemsResponse) _then) = __$ListSavedItemsResponseCopyWithImpl;
@override @useResult
$Res call({
 ListSavedItemsDataResponse data, String? message, ListSavedItemsMetaResponse? meta
});


@override $ListSavedItemsDataResponseCopyWith<$Res> get data;@override $ListSavedItemsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class __$ListSavedItemsResponseCopyWithImpl<$Res>
    implements _$ListSavedItemsResponseCopyWith<$Res> {
  __$ListSavedItemsResponseCopyWithImpl(this._self, this._then);

  final _ListSavedItemsResponse _self;
  final $Res Function(_ListSavedItemsResponse) _then;

/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(_ListSavedItemsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListSavedItemsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListSavedItemsMetaResponse?,
  ));
}

/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsDataResponseCopyWith<$Res> get data {
  
  return $ListSavedItemsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListSavedItemsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
