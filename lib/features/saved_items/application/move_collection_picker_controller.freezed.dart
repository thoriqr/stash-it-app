// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move_collection_picker_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoveCollectionPickerState {

 List<CollectionSummary> get items; String? get nextCursor; bool get hasMore; bool get isLoadingMore; bool get loadMoreFailed;
/// Create a copy of MoveCollectionPickerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCollectionPickerStateCopyWith<MoveCollectionPickerState> get copyWith => _$MoveCollectionPickerStateCopyWithImpl<MoveCollectionPickerState>(this as MoveCollectionPickerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MoveCollectionPickerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveCollectionPickerState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadMoreFailed, _this.loadMoreFailed) || other.loadMoreFailed == _this.loadMoreFailed));
}


@override
int get hashCode {
  final _this = this as MoveCollectionPickerState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.nextCursor,_this.hasMore,_this.isLoadingMore,_this.loadMoreFailed);
}

@override
String toString() {
  final _this = this as MoveCollectionPickerState;
  return 'MoveCollectionPickerState(items: ${_this.items}, nextCursor: ${_this.nextCursor}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore}, loadMoreFailed: ${_this.loadMoreFailed})';
}


}

/// @nodoc
abstract mixin class $MoveCollectionPickerStateCopyWith<$Res>  {
  factory $MoveCollectionPickerStateCopyWith(MoveCollectionPickerState value, $Res Function(MoveCollectionPickerState) _then) = _$MoveCollectionPickerStateCopyWithImpl;
@useResult
$Res call({
 List<CollectionSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class _$MoveCollectionPickerStateCopyWithImpl<$Res>
    implements $MoveCollectionPickerStateCopyWith<$Res> {
  _$MoveCollectionPickerStateCopyWithImpl(this._self, this._then);

  final MoveCollectionPickerState _self;
  final $Res Function(MoveCollectionPickerState) _then;

/// Create a copy of MoveCollectionPickerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(MoveCollectionPickerState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CollectionSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveCollectionPickerState].
extension MoveCollectionPickerStatePatterns on MoveCollectionPickerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveCollectionPickerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveCollectionPickerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveCollectionPickerState value)  $default,){
final _that = this;
switch (_that) {
case _MoveCollectionPickerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveCollectionPickerState value)?  $default,){
final _that = this;
switch (_that) {
case _MoveCollectionPickerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveCollectionPickerState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)  $default,) {final _that = this;
switch (_that) {
case _MoveCollectionPickerState():
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,) {final _that = this;
switch (_that) {
case _MoveCollectionPickerState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
  return null;

}
}

}

/// @nodoc


class _MoveCollectionPickerState implements MoveCollectionPickerState {
  const _MoveCollectionPickerState({required  List<CollectionSummary> items, this.nextCursor, this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false}): _items = items;
  

 final  List<CollectionSummary> _items;
@override List<CollectionSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool loadMoreFailed;

/// Create a copy of MoveCollectionPickerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveCollectionPickerStateCopyWith<_MoveCollectionPickerState> get copyWith => __$MoveCollectionPickerStateCopyWithImpl<_MoveCollectionPickerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveCollectionPickerState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreFailed, loadMoreFailed) || other.loadMoreFailed == loadMoreFailed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,isLoadingMore,loadMoreFailed);
}

@override
String toString() {
    return 'MoveCollectionPickerState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore, loadMoreFailed: $loadMoreFailed)';
}


}

/// @nodoc
abstract mixin class _$MoveCollectionPickerStateCopyWith<$Res> implements $MoveCollectionPickerStateCopyWith<$Res> {
  factory _$MoveCollectionPickerStateCopyWith(_MoveCollectionPickerState value, $Res Function(_MoveCollectionPickerState) _then) = __$MoveCollectionPickerStateCopyWithImpl;
@override @useResult
$Res call({
 List<CollectionSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class __$MoveCollectionPickerStateCopyWithImpl<$Res>
    implements _$MoveCollectionPickerStateCopyWith<$Res> {
  __$MoveCollectionPickerStateCopyWithImpl(this._self, this._then);

  final _MoveCollectionPickerState _self;
  final $Res Function(_MoveCollectionPickerState) _then;

/// Create a copy of MoveCollectionPickerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(_MoveCollectionPickerState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CollectionSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
