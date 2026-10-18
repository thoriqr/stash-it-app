// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_items_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedItemsState {

 List<SavedItemSummary> get items; String? get nextCursor; bool get hasMore; bool get isLoadingMore;
/// Create a copy of SavedItemsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedItemsStateCopyWith<SavedItemsState> get copyWith => _$SavedItemsStateCopyWithImpl<SavedItemsState>(this as SavedItemsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SavedItemsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedItemsState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore));
}


@override
int get hashCode {
  final _this = this as SavedItemsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.nextCursor,_this.hasMore,_this.isLoadingMore);
}

@override
String toString() {
  final _this = this as SavedItemsState;
  return 'SavedItemsState(items: ${_this.items}, nextCursor: ${_this.nextCursor}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore})';
}


}

/// @nodoc
abstract mixin class $SavedItemsStateCopyWith<$Res>  {
  factory $SavedItemsStateCopyWith(SavedItemsState value, $Res Function(SavedItemsState) _then) = _$SavedItemsStateCopyWithImpl;
@useResult
$Res call({
 List<SavedItemSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class _$SavedItemsStateCopyWithImpl<$Res>
    implements $SavedItemsStateCopyWith<$Res> {
  _$SavedItemsStateCopyWithImpl(this._self, this._then);

  final SavedItemsState _self;
  final $Res Function(SavedItemsState) _then;

/// Create a copy of SavedItemsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(SavedItemsState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SavedItemSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedItemsState].
extension SavedItemsStatePatterns on SavedItemsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedItemsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedItemsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedItemsState value)  $default,){
final _that = this;
switch (_that) {
case _SavedItemsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedItemsState value)?  $default,){
final _that = this;
switch (_that) {
case _SavedItemsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedItemsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore)  $default,) {final _that = this;
switch (_that) {
case _SavedItemsState():
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedItemSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore)?  $default,) {final _that = this;
switch (_that) {
case _SavedItemsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore);case _:
  return null;

}
}

}

/// @nodoc


class _SavedItemsState implements SavedItemsState {
  const _SavedItemsState({required  List<SavedItemSummary> items, this.nextCursor, this.hasMore = false, this.isLoadingMore = false}): _items = items;
  

 final  List<SavedItemSummary> _items;
@override List<SavedItemSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;

/// Create a copy of SavedItemsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedItemsStateCopyWith<_SavedItemsState> get copyWith => __$SavedItemsStateCopyWithImpl<_SavedItemsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedItemsState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,isLoadingMore);
}

@override
String toString() {
    return 'SavedItemsState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$SavedItemsStateCopyWith<$Res> implements $SavedItemsStateCopyWith<$Res> {
  factory _$SavedItemsStateCopyWith(_SavedItemsState value, $Res Function(_SavedItemsState) _then) = __$SavedItemsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedItemSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class __$SavedItemsStateCopyWithImpl<$Res>
    implements _$SavedItemsStateCopyWith<$Res> {
  __$SavedItemsStateCopyWithImpl(this._self, this._then);

  final _SavedItemsState _self;
  final $Res Function(_SavedItemsState) _then;

/// Create a copy of SavedItemsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(_SavedItemsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SavedItemSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
