// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move_to_collection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoveToCollectionRequest {

@JsonKey(name: 'collection_name') String get collectionName;
/// Create a copy of MoveToCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToCollectionRequestCopyWith<MoveToCollectionRequest> get copyWith => _$MoveToCollectionRequestCopyWithImpl<MoveToCollectionRequest>(this as MoveToCollectionRequest, _$identity);

  /// Serializes this MoveToCollectionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveToCollectionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToCollectionRequest&&(identical(other.collectionName, _this.collectionName) || other.collectionName == _this.collectionName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveToCollectionRequest;
  return Object.hash(runtimeType,_this.collectionName);
}

@override
String toString() {
  final _this = this as MoveToCollectionRequest;
  return 'MoveToCollectionRequest(collectionName: ${_this.collectionName})';
}


}

/// @nodoc
abstract mixin class $MoveToCollectionRequestCopyWith<$Res>  {
  factory $MoveToCollectionRequestCopyWith(MoveToCollectionRequest value, $Res Function(MoveToCollectionRequest) _then) = _$MoveToCollectionRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'collection_name') String collectionName
});




}
/// @nodoc
class _$MoveToCollectionRequestCopyWithImpl<$Res>
    implements $MoveToCollectionRequestCopyWith<$Res> {
  _$MoveToCollectionRequestCopyWithImpl(this._self, this._then);

  final MoveToCollectionRequest _self;
  final $Res Function(MoveToCollectionRequest) _then;

/// Create a copy of MoveToCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionName = null,}) {
  return _then(MoveToCollectionRequest(
collectionName: null == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveToCollectionRequest].
extension MoveToCollectionRequestPatterns on MoveToCollectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveToCollectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveToCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveToCollectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveToCollectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'collection_name')  String collectionName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveToCollectionRequest() when $default != null:
return $default(_that.collectionName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'collection_name')  String collectionName)  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionRequest():
return $default(_that.collectionName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'collection_name')  String collectionName)?  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionRequest() when $default != null:
return $default(_that.collectionName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveToCollectionRequest implements MoveToCollectionRequest {
  const _MoveToCollectionRequest({@JsonKey(name: 'collection_name') required this.collectionName});
  factory _MoveToCollectionRequest.fromJson(Map<String, dynamic> json) => _$MoveToCollectionRequestFromJson(json);

@override@JsonKey(name: 'collection_name') final  String collectionName;

/// Create a copy of MoveToCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveToCollectionRequestCopyWith<_MoveToCollectionRequest> get copyWith => __$MoveToCollectionRequestCopyWithImpl<_MoveToCollectionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToCollectionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveToCollectionRequest&&(identical(other.collectionName, collectionName) || other.collectionName == collectionName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,collectionName);
}

@override
String toString() {
    return 'MoveToCollectionRequest(collectionName: $collectionName)';
}


}

/// @nodoc
abstract mixin class _$MoveToCollectionRequestCopyWith<$Res> implements $MoveToCollectionRequestCopyWith<$Res> {
  factory _$MoveToCollectionRequestCopyWith(_MoveToCollectionRequest value, $Res Function(_MoveToCollectionRequest) _then) = __$MoveToCollectionRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'collection_name') String collectionName
});




}
/// @nodoc
class __$MoveToCollectionRequestCopyWithImpl<$Res>
    implements _$MoveToCollectionRequestCopyWith<$Res> {
  __$MoveToCollectionRequestCopyWithImpl(this._self, this._then);

  final _MoveToCollectionRequest _self;
  final $Res Function(_MoveToCollectionRequest) _then;

/// Create a copy of MoveToCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionName = null,}) {
  return _then(_MoveToCollectionRequest(
collectionName: null == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
