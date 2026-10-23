// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrich_saved_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnrichSavedItemDataResponse {

@JsonKey(name: 'saved_item') SavedItemDetailResponse get savedItem;
/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrichSavedItemDataResponseCopyWith<EnrichSavedItemDataResponse> get copyWith => _$EnrichSavedItemDataResponseCopyWithImpl<EnrichSavedItemDataResponse>(this as EnrichSavedItemDataResponse, _$identity);

  /// Serializes this EnrichSavedItemDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnrichSavedItemDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrichSavedItemDataResponse&&(identical(other.savedItem, _this.savedItem) || other.savedItem == _this.savedItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnrichSavedItemDataResponse;
  return Object.hash(runtimeType,_this.savedItem);
}

@override
String toString() {
  final _this = this as EnrichSavedItemDataResponse;
  return 'EnrichSavedItemDataResponse(savedItem: ${_this.savedItem})';
}


}

/// @nodoc
abstract mixin class $EnrichSavedItemDataResponseCopyWith<$Res>  {
  factory $EnrichSavedItemDataResponseCopyWith(EnrichSavedItemDataResponse value, $Res Function(EnrichSavedItemDataResponse) _then) = _$EnrichSavedItemDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_item') SavedItemDetailResponse savedItem
});


$SavedItemDetailResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class _$EnrichSavedItemDataResponseCopyWithImpl<$Res>
    implements $EnrichSavedItemDataResponseCopyWith<$Res> {
  _$EnrichSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final EnrichSavedItemDataResponse _self;
  final $Res Function(EnrichSavedItemDataResponse) _then;

/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItem = null,}) {
  return _then(EnrichSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as SavedItemDetailResponse,
  ));
}
/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemDetailResponseCopyWith<$Res> get savedItem {
  
  return $SavedItemDetailResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrichSavedItemDataResponse].
extension EnrichSavedItemDataResponsePatterns on EnrichSavedItemDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrichSavedItemDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrichSavedItemDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrichSavedItemDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse() when $default != null:
return $default(_that.savedItem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem)  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse():
return $default(_that.savedItem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem)?  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemDataResponse() when $default != null:
return $default(_that.savedItem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrichSavedItemDataResponse implements EnrichSavedItemDataResponse {
  const _EnrichSavedItemDataResponse({@JsonKey(name: 'saved_item') required this.savedItem});
  factory _EnrichSavedItemDataResponse.fromJson(Map<String, dynamic> json) => _$EnrichSavedItemDataResponseFromJson(json);

@override@JsonKey(name: 'saved_item') final  SavedItemDetailResponse savedItem;

/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrichSavedItemDataResponseCopyWith<_EnrichSavedItemDataResponse> get copyWith => __$EnrichSavedItemDataResponseCopyWithImpl<_EnrichSavedItemDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrichSavedItemDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrichSavedItemDataResponse&&(identical(other.savedItem, savedItem) || other.savedItem == savedItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,savedItem);
}

@override
String toString() {
    return 'EnrichSavedItemDataResponse(savedItem: $savedItem)';
}


}

/// @nodoc
abstract mixin class _$EnrichSavedItemDataResponseCopyWith<$Res> implements $EnrichSavedItemDataResponseCopyWith<$Res> {
  factory _$EnrichSavedItemDataResponseCopyWith(_EnrichSavedItemDataResponse value, $Res Function(_EnrichSavedItemDataResponse) _then) = __$EnrichSavedItemDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_item') SavedItemDetailResponse savedItem
});


@override $SavedItemDetailResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class __$EnrichSavedItemDataResponseCopyWithImpl<$Res>
    implements _$EnrichSavedItemDataResponseCopyWith<$Res> {
  __$EnrichSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final _EnrichSavedItemDataResponse _self;
  final $Res Function(_EnrichSavedItemDataResponse) _then;

/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItem = null,}) {
  return _then(_EnrichSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as SavedItemDetailResponse,
  ));
}

/// Create a copy of EnrichSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemDetailResponseCopyWith<$Res> get savedItem {
  
  return $SavedItemDetailResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// @nodoc
mixin _$EnrichSavedItemResponse {

 EnrichSavedItemDataResponse get data; String? get message;
/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrichSavedItemResponseCopyWith<EnrichSavedItemResponse> get copyWith => _$EnrichSavedItemResponseCopyWithImpl<EnrichSavedItemResponse>(this as EnrichSavedItemResponse, _$identity);

  /// Serializes this EnrichSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnrichSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrichSavedItemResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnrichSavedItemResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as EnrichSavedItemResponse;
  return 'EnrichSavedItemResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $EnrichSavedItemResponseCopyWith<$Res>  {
  factory $EnrichSavedItemResponseCopyWith(EnrichSavedItemResponse value, $Res Function(EnrichSavedItemResponse) _then) = _$EnrichSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 EnrichSavedItemDataResponse data, String? message
});


$EnrichSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$EnrichSavedItemResponseCopyWithImpl<$Res>
    implements $EnrichSavedItemResponseCopyWith<$Res> {
  _$EnrichSavedItemResponseCopyWithImpl(this._self, this._then);

  final EnrichSavedItemResponse _self;
  final $Res Function(EnrichSavedItemResponse) _then;

/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(EnrichSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as EnrichSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichSavedItemDataResponseCopyWith<$Res> get data {
  
  return $EnrichSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrichSavedItemResponse].
extension EnrichSavedItemResponsePatterns on EnrichSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrichSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrichSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrichSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrichSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EnrichSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EnrichSavedItemDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrichSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EnrichSavedItemDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EnrichSavedItemDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _EnrichSavedItemResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrichSavedItemResponse implements EnrichSavedItemResponse {
  const _EnrichSavedItemResponse({required this.data, this.message});
  factory _EnrichSavedItemResponse.fromJson(Map<String, dynamic> json) => _$EnrichSavedItemResponseFromJson(json);

@override final  EnrichSavedItemDataResponse data;
@override final  String? message;

/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrichSavedItemResponseCopyWith<_EnrichSavedItemResponse> get copyWith => __$EnrichSavedItemResponseCopyWithImpl<_EnrichSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrichSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrichSavedItemResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'EnrichSavedItemResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$EnrichSavedItemResponseCopyWith<$Res> implements $EnrichSavedItemResponseCopyWith<$Res> {
  factory _$EnrichSavedItemResponseCopyWith(_EnrichSavedItemResponse value, $Res Function(_EnrichSavedItemResponse) _then) = __$EnrichSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 EnrichSavedItemDataResponse data, String? message
});


@override $EnrichSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$EnrichSavedItemResponseCopyWithImpl<$Res>
    implements _$EnrichSavedItemResponseCopyWith<$Res> {
  __$EnrichSavedItemResponseCopyWithImpl(this._self, this._then);

  final _EnrichSavedItemResponse _self;
  final $Res Function(_EnrichSavedItemResponse) _then;

/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_EnrichSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as EnrichSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EnrichSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichSavedItemDataResponseCopyWith<$Res> get data {
  
  return $EnrichSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
