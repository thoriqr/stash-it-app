// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_collection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteCollectionRequest {

@JsonKey(name: 'saved_items_action') String get savedItemsAction;@JsonKey(name: 'target_collection_id', includeIfNull: true) String? get targetCollectionId;
/// Create a copy of DeleteCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteCollectionRequestCopyWith<DeleteCollectionRequest> get copyWith => _$DeleteCollectionRequestCopyWithImpl<DeleteCollectionRequest>(this as DeleteCollectionRequest, _$identity);

  /// Serializes this DeleteCollectionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteCollectionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteCollectionRequest&&(identical(other.savedItemsAction, _this.savedItemsAction) || other.savedItemsAction == _this.savedItemsAction)&&(identical(other.targetCollectionId, _this.targetCollectionId) || other.targetCollectionId == _this.targetCollectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteCollectionRequest;
  return Object.hash(runtimeType,_this.savedItemsAction,_this.targetCollectionId);
}

@override
String toString() {
  final _this = this as DeleteCollectionRequest;
  return 'DeleteCollectionRequest(savedItemsAction: ${_this.savedItemsAction}, targetCollectionId: ${_this.targetCollectionId})';
}


}

/// @nodoc
abstract mixin class $DeleteCollectionRequestCopyWith<$Res>  {
  factory $DeleteCollectionRequestCopyWith(DeleteCollectionRequest value, $Res Function(DeleteCollectionRequest) _then) = _$DeleteCollectionRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_items_action') String savedItemsAction,@JsonKey(name: 'target_collection_id', includeIfNull: true) String? targetCollectionId
});




}
/// @nodoc
class _$DeleteCollectionRequestCopyWithImpl<$Res>
    implements $DeleteCollectionRequestCopyWith<$Res> {
  _$DeleteCollectionRequestCopyWithImpl(this._self, this._then);

  final DeleteCollectionRequest _self;
  final $Res Function(DeleteCollectionRequest) _then;

/// Create a copy of DeleteCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItemsAction = null,Object? targetCollectionId = freezed,}) {
  return _then(DeleteCollectionRequest(
savedItemsAction: null == savedItemsAction ? _self.savedItemsAction : savedItemsAction // ignore: cast_nullable_to_non_nullable
as String,targetCollectionId: freezed == targetCollectionId ? _self.targetCollectionId : targetCollectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteCollectionRequest].
extension DeleteCollectionRequestPatterns on DeleteCollectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteCollectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteCollectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _DeleteCollectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteCollectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items_action')  String savedItemsAction, @JsonKey(name: 'target_collection_id', includeIfNull: true)  String? targetCollectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteCollectionRequest() when $default != null:
return $default(_that.savedItemsAction,_that.targetCollectionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items_action')  String savedItemsAction, @JsonKey(name: 'target_collection_id', includeIfNull: true)  String? targetCollectionId)  $default,) {final _that = this;
switch (_that) {
case _DeleteCollectionRequest():
return $default(_that.savedItemsAction,_that.targetCollectionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_items_action')  String savedItemsAction, @JsonKey(name: 'target_collection_id', includeIfNull: true)  String? targetCollectionId)?  $default,) {final _that = this;
switch (_that) {
case _DeleteCollectionRequest() when $default != null:
return $default(_that.savedItemsAction,_that.targetCollectionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteCollectionRequest implements DeleteCollectionRequest {
  const _DeleteCollectionRequest({@JsonKey(name: 'saved_items_action') required this.savedItemsAction, @JsonKey(name: 'target_collection_id', includeIfNull: true) required this.targetCollectionId});
  factory _DeleteCollectionRequest.fromJson(Map<String, dynamic> json) => _$DeleteCollectionRequestFromJson(json);

@override@JsonKey(name: 'saved_items_action') final  String savedItemsAction;
@override@JsonKey(name: 'target_collection_id', includeIfNull: true) final  String? targetCollectionId;

/// Create a copy of DeleteCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteCollectionRequestCopyWith<_DeleteCollectionRequest> get copyWith => __$DeleteCollectionRequestCopyWithImpl<_DeleteCollectionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteCollectionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteCollectionRequest&&(identical(other.savedItemsAction, savedItemsAction) || other.savedItemsAction == savedItemsAction)&&(identical(other.targetCollectionId, targetCollectionId) || other.targetCollectionId == targetCollectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,savedItemsAction,targetCollectionId);
}

@override
String toString() {
    return 'DeleteCollectionRequest(savedItemsAction: $savedItemsAction, targetCollectionId: $targetCollectionId)';
}


}

/// @nodoc
abstract mixin class _$DeleteCollectionRequestCopyWith<$Res> implements $DeleteCollectionRequestCopyWith<$Res> {
  factory _$DeleteCollectionRequestCopyWith(_DeleteCollectionRequest value, $Res Function(_DeleteCollectionRequest) _then) = __$DeleteCollectionRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_items_action') String savedItemsAction,@JsonKey(name: 'target_collection_id', includeIfNull: true) String? targetCollectionId
});




}
/// @nodoc
class __$DeleteCollectionRequestCopyWithImpl<$Res>
    implements _$DeleteCollectionRequestCopyWith<$Res> {
  __$DeleteCollectionRequestCopyWithImpl(this._self, this._then);

  final _DeleteCollectionRequest _self;
  final $Res Function(_DeleteCollectionRequest) _then;

/// Create a copy of DeleteCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItemsAction = null,Object? targetCollectionId = freezed,}) {
  return _then(_DeleteCollectionRequest(
savedItemsAction: null == savedItemsAction ? _self.savedItemsAction : savedItemsAction // ignore: cast_nullable_to_non_nullable
as String,targetCollectionId: freezed == targetCollectionId ? _self.targetCollectionId : targetCollectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
