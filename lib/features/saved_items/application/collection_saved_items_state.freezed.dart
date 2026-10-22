// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_saved_items_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionSavedItemsState {

 String get collectionId; String get collectionName; List<SavedItemSummary> get items; String? get nextCursor; bool get hasMore;/// A page is in flight, so the footer says so and no second page is started.
 bool get isLoadingMore;/// The last page request failed and **has not been retried by the user**.
///
/// It is a separate flag from `isLoadingMore` because it has to *block* the
/// scroll listener. Clearing the loading flag alone — which is what the other
/// listings in this app do — lets the next scroll notification ask for the
/// same cursor again, and a screen that keeps failing becomes a scroll-driven
/// retry loop. **[D23]** asks for manual retry, so the footer's Retry is the
/// only thing that may resume paging.
 bool get loadMoreFailed;
/// Create a copy of CollectionSavedItemsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionSavedItemsStateCopyWith<CollectionSavedItemsState> get copyWith => _$CollectionSavedItemsStateCopyWithImpl<CollectionSavedItemsState>(this as CollectionSavedItemsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CollectionSavedItemsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionSavedItemsState&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.collectionName, _this.collectionName) || other.collectionName == _this.collectionName)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadMoreFailed, _this.loadMoreFailed) || other.loadMoreFailed == _this.loadMoreFailed));
}


@override
int get hashCode {
  final _this = this as CollectionSavedItemsState;
  return Object.hash(runtimeType,_this.collectionId,_this.collectionName,const DeepCollectionEquality().hash(_this.items),_this.nextCursor,_this.hasMore,_this.isLoadingMore,_this.loadMoreFailed);
}

@override
String toString() {
  final _this = this as CollectionSavedItemsState;
  return 'CollectionSavedItemsState(collectionId: ${_this.collectionId}, collectionName: ${_this.collectionName}, items: ${_this.items}, nextCursor: ${_this.nextCursor}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore}, loadMoreFailed: ${_this.loadMoreFailed})';
}


}

/// @nodoc
abstract mixin class $CollectionSavedItemsStateCopyWith<$Res>  {
  factory $CollectionSavedItemsStateCopyWith(CollectionSavedItemsState value, $Res Function(CollectionSavedItemsState) _then) = _$CollectionSavedItemsStateCopyWithImpl;
@useResult
$Res call({
 String collectionId, String collectionName, List<SavedItemSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class _$CollectionSavedItemsStateCopyWithImpl<$Res>
    implements $CollectionSavedItemsStateCopyWith<$Res> {
  _$CollectionSavedItemsStateCopyWithImpl(this._self, this._then);

  final CollectionSavedItemsState _self;
  final $Res Function(CollectionSavedItemsState) _then;

/// Create a copy of CollectionSavedItemsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionId = null,Object? collectionName = null,Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(CollectionSavedItemsState(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,collectionName: null == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SavedItemSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionSavedItemsState].
extension CollectionSavedItemsStatePatterns on CollectionSavedItemsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionSavedItemsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionSavedItemsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionSavedItemsState value)  $default,){
final _that = this;
switch (_that) {
case _CollectionSavedItemsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionSavedItemsState value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionSavedItemsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String collectionId,  String collectionName,  List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionSavedItemsState() when $default != null:
return $default(_that.collectionId,_that.collectionName,_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String collectionId,  String collectionName,  List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)  $default,) {final _that = this;
switch (_that) {
case _CollectionSavedItemsState():
return $default(_that.collectionId,_that.collectionName,_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String collectionId,  String collectionName,  List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,) {final _that = this;
switch (_that) {
case _CollectionSavedItemsState() when $default != null:
return $default(_that.collectionId,_that.collectionName,_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionSavedItemsState implements CollectionSavedItemsState {
  const _CollectionSavedItemsState({required this.collectionId, required this.collectionName, required  List<SavedItemSummary> items, this.nextCursor, this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false}): _items = items;
  

@override final  String collectionId;
@override final  String collectionName;
 final  List<SavedItemSummary> _items;
@override List<SavedItemSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
/// A page is in flight, so the footer says so and no second page is started.
@override@JsonKey() final  bool isLoadingMore;
/// The last page request failed and **has not been retried by the user**.
///
/// It is a separate flag from `isLoadingMore` because it has to *block* the
/// scroll listener. Clearing the loading flag alone — which is what the other
/// listings in this app do — lets the next scroll notification ask for the
/// same cursor again, and a screen that keeps failing becomes a scroll-driven
/// retry loop. **[D23]** asks for manual retry, so the footer's Retry is the
/// only thing that may resume paging.
@override@JsonKey() final  bool loadMoreFailed;

/// Create a copy of CollectionSavedItemsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionSavedItemsStateCopyWith<_CollectionSavedItemsState> get copyWith => __$CollectionSavedItemsStateCopyWithImpl<_CollectionSavedItemsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionSavedItemsState&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.collectionName, collectionName) || other.collectionName == collectionName)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreFailed, loadMoreFailed) || other.loadMoreFailed == loadMoreFailed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,collectionId,collectionName,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,isLoadingMore,loadMoreFailed);
}

@override
String toString() {
    return 'CollectionSavedItemsState(collectionId: $collectionId, collectionName: $collectionName, items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore, loadMoreFailed: $loadMoreFailed)';
}


}

/// @nodoc
abstract mixin class _$CollectionSavedItemsStateCopyWith<$Res> implements $CollectionSavedItemsStateCopyWith<$Res> {
  factory _$CollectionSavedItemsStateCopyWith(_CollectionSavedItemsState value, $Res Function(_CollectionSavedItemsState) _then) = __$CollectionSavedItemsStateCopyWithImpl;
@override @useResult
$Res call({
 String collectionId, String collectionName, List<SavedItemSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class __$CollectionSavedItemsStateCopyWithImpl<$Res>
    implements _$CollectionSavedItemsStateCopyWith<$Res> {
  __$CollectionSavedItemsStateCopyWithImpl(this._self, this._then);

  final _CollectionSavedItemsState _self;
  final $Res Function(_CollectionSavedItemsState) _then;

/// Create a copy of CollectionSavedItemsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionId = null,Object? collectionName = null,Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(_CollectionSavedItemsState(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,collectionName: null == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SavedItemSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
