// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrich_saved_item_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnrichSavedItemRequest {

@JsonKey(includeIfNull: false, toJson: clientMetadataToJson) ClientMetadata? get metadata;
/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrichSavedItemRequestCopyWith<EnrichSavedItemRequest> get copyWith => _$EnrichSavedItemRequestCopyWithImpl<EnrichSavedItemRequest>(this as EnrichSavedItemRequest, _$identity);

  /// Serializes this EnrichSavedItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnrichSavedItemRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrichSavedItemRequest&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnrichSavedItemRequest;
  return Object.hash(runtimeType,_this.metadata);
}

@override
String toString() {
  final _this = this as EnrichSavedItemRequest;
  return 'EnrichSavedItemRequest(metadata: ${_this.metadata})';
}


}

/// @nodoc
abstract mixin class $EnrichSavedItemRequestCopyWith<$Res>  {
  factory $EnrichSavedItemRequestCopyWith(EnrichSavedItemRequest value, $Res Function(EnrichSavedItemRequest) _then) = _$EnrichSavedItemRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false, toJson: clientMetadataToJson) ClientMetadata? metadata
});


$ClientMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$EnrichSavedItemRequestCopyWithImpl<$Res>
    implements $EnrichSavedItemRequestCopyWith<$Res> {
  _$EnrichSavedItemRequestCopyWithImpl(this._self, this._then);

  final EnrichSavedItemRequest _self;
  final $Res Function(EnrichSavedItemRequest) _then;

/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metadata = freezed,}) {
  return _then(EnrichSavedItemRequest(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ClientMetadata?,
  ));
}
/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $ClientMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrichSavedItemRequest].
extension EnrichSavedItemRequestPatterns on EnrichSavedItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrichSavedItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrichSavedItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrichSavedItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrichSavedItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false, toJson: clientMetadataToJson)  ClientMetadata? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrichSavedItemRequest() when $default != null:
return $default(_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false, toJson: clientMetadataToJson)  ClientMetadata? metadata)  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemRequest():
return $default(_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false, toJson: clientMetadataToJson)  ClientMetadata? metadata)?  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemRequest() when $default != null:
return $default(_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrichSavedItemRequest implements EnrichSavedItemRequest {
  const _EnrichSavedItemRequest({@JsonKey(includeIfNull: false, toJson: clientMetadataToJson) this.metadata});
  factory _EnrichSavedItemRequest.fromJson(Map<String, dynamic> json) => _$EnrichSavedItemRequestFromJson(json);

@override@JsonKey(includeIfNull: false, toJson: clientMetadataToJson) final  ClientMetadata? metadata;

/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrichSavedItemRequestCopyWith<_EnrichSavedItemRequest> get copyWith => __$EnrichSavedItemRequestCopyWithImpl<_EnrichSavedItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrichSavedItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrichSavedItemRequest&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,metadata);
}

@override
String toString() {
    return 'EnrichSavedItemRequest(metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$EnrichSavedItemRequestCopyWith<$Res> implements $EnrichSavedItemRequestCopyWith<$Res> {
  factory _$EnrichSavedItemRequestCopyWith(_EnrichSavedItemRequest value, $Res Function(_EnrichSavedItemRequest) _then) = __$EnrichSavedItemRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false, toJson: clientMetadataToJson) ClientMetadata? metadata
});


@override $ClientMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$EnrichSavedItemRequestCopyWithImpl<$Res>
    implements _$EnrichSavedItemRequestCopyWith<$Res> {
  __$EnrichSavedItemRequestCopyWithImpl(this._self, this._then);

  final _EnrichSavedItemRequest _self;
  final $Res Function(_EnrichSavedItemRequest) _then;

/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metadata = freezed,}) {
  return _then(_EnrichSavedItemRequest(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ClientMetadata?,
  ));
}

/// Create a copy of EnrichSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $ClientMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
