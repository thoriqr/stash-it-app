// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collections_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionsState {

 List<CollectionSummary> get items; String? get nextCursor; bool get hasMore; bool get isLoadingMore; String get sort;
/// Create a copy of CollectionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionsStateCopyWith<CollectionsState> get copyWith => _$CollectionsStateCopyWithImpl<CollectionsState>(this as CollectionsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CollectionsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionsState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as CollectionsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.nextCursor,_this.hasMore,_this.isLoadingMore,_this.sort);
}

@override
String toString() {
  final _this = this as CollectionsState;
  return 'CollectionsState(items: ${_this.items}, nextCursor: ${_this.nextCursor}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore}, sort: ${_this.sort})';
}


}

/// @nodoc
abstract mixin class $CollectionsStateCopyWith<$Res>  {
  factory $CollectionsStateCopyWith(CollectionsState value, $Res Function(CollectionsState) _then) = _$CollectionsStateCopyWithImpl;
@useResult
$Res call({
 List<CollectionSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, String sort
});




}
/// @nodoc
class _$CollectionsStateCopyWithImpl<$Res>
    implements $CollectionsStateCopyWith<$Res> {
  _$CollectionsStateCopyWithImpl(this._self, this._then);

  final CollectionsState _self;
  final $Res Function(CollectionsState) _then;

/// Create a copy of CollectionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? sort = null,}) {
  return _then(CollectionsState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CollectionSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionsState].
extension CollectionsStatePatterns on CollectionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionsState value)  $default,){
final _that = this;
switch (_that) {
case _CollectionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionsState value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  String sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  String sort)  $default,) {final _that = this;
switch (_that) {
case _CollectionsState():
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CollectionSummary> items,  String? nextCursor,  bool hasMore,  bool isLoadingMore,  String sort)?  $default,) {final _that = this;
switch (_that) {
case _CollectionsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingMore,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionsState implements CollectionsState {
  const _CollectionsState({required  List<CollectionSummary> items, this.nextCursor, this.hasMore = false, this.isLoadingMore = false, this.sort = 'newest'}): _items = items;
  

 final  List<CollectionSummary> _items;
@override List<CollectionSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  String sort;

/// Create a copy of CollectionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionsStateCopyWith<_CollectionsState> get copyWith => __$CollectionsStateCopyWithImpl<_CollectionsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionsState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,isLoadingMore,sort);
}

@override
String toString() {
    return 'CollectionsState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$CollectionsStateCopyWith<$Res> implements $CollectionsStateCopyWith<$Res> {
  factory _$CollectionsStateCopyWith(_CollectionsState value, $Res Function(_CollectionsState) _then) = __$CollectionsStateCopyWithImpl;
@override @useResult
$Res call({
 List<CollectionSummary> items, String? nextCursor, bool hasMore, bool isLoadingMore, String sort
});




}
/// @nodoc
class __$CollectionsStateCopyWithImpl<$Res>
    implements _$CollectionsStateCopyWith<$Res> {
  __$CollectionsStateCopyWithImpl(this._self, this._then);

  final _CollectionsState _self;
  final $Res Function(_CollectionsState) _then;

/// Create a copy of CollectionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingMore = null,Object? sort = null,}) {
  return _then(_CollectionsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CollectionSummary>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
