// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_saved_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatedSavedItemResponse {

 String get id; String get url;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'enrichment_status') String get enrichmentStatus;
/// Create a copy of CreatedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedSavedItemResponseCopyWith<CreatedSavedItemResponse> get copyWith => _$CreatedSavedItemResponseCopyWithImpl<CreatedSavedItemResponse>(this as CreatedSavedItemResponse, _$identity);

  /// Serializes this CreatedSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreatedSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatedSavedItemResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.enrichmentStatus, _this.enrichmentStatus) || other.enrichmentStatus == _this.enrichmentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreatedSavedItemResponse;
  return Object.hash(runtimeType,_this.id,_this.url,_this.collectionId,_this.enrichmentStatus);
}

@override
String toString() {
  final _this = this as CreatedSavedItemResponse;
  return 'CreatedSavedItemResponse(id: ${_this.id}, url: ${_this.url}, collectionId: ${_this.collectionId}, enrichmentStatus: ${_this.enrichmentStatus})';
}


}

/// @nodoc
abstract mixin class $CreatedSavedItemResponseCopyWith<$Res>  {
  factory $CreatedSavedItemResponseCopyWith(CreatedSavedItemResponse value, $Res Function(CreatedSavedItemResponse) _then) = _$CreatedSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 String id, String url,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus
});




}
/// @nodoc
class _$CreatedSavedItemResponseCopyWithImpl<$Res>
    implements $CreatedSavedItemResponseCopyWith<$Res> {
  _$CreatedSavedItemResponseCopyWithImpl(this._self, this._then);

  final CreatedSavedItemResponse _self;
  final $Res Function(CreatedSavedItemResponse) _then;

/// Create a copy of CreatedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? collectionId = null,Object? enrichmentStatus = null,}) {
  return _then(CreatedSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatedSavedItemResponse].
extension CreatedSavedItemResponsePatterns on CreatedSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatedSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatedSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatedSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatedSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatedSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatedSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatedSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.collectionId,_that.enrichmentStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus)  $default,) {final _that = this;
switch (_that) {
case _CreatedSavedItemResponse():
return $default(_that.id,_that.url,_that.collectionId,_that.enrichmentStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus)?  $default,) {final _that = this;
switch (_that) {
case _CreatedSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.collectionId,_that.enrichmentStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatedSavedItemResponse implements CreatedSavedItemResponse {
  const _CreatedSavedItemResponse({required this.id, required this.url, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'enrichment_status') required this.enrichmentStatus});
  factory _CreatedSavedItemResponse.fromJson(Map<String, dynamic> json) => _$CreatedSavedItemResponseFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey(name: 'collection_id') final  String collectionId;
@override@JsonKey(name: 'enrichment_status') final  String enrichmentStatus;

/// Create a copy of CreatedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatedSavedItemResponseCopyWith<_CreatedSavedItemResponse> get copyWith => __$CreatedSavedItemResponseCopyWithImpl<_CreatedSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatedSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatedSavedItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.enrichmentStatus, enrichmentStatus) || other.enrichmentStatus == enrichmentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,collectionId,enrichmentStatus);
}

@override
String toString() {
    return 'CreatedSavedItemResponse(id: $id, url: $url, collectionId: $collectionId, enrichmentStatus: $enrichmentStatus)';
}


}

/// @nodoc
abstract mixin class _$CreatedSavedItemResponseCopyWith<$Res> implements $CreatedSavedItemResponseCopyWith<$Res> {
  factory _$CreatedSavedItemResponseCopyWith(_CreatedSavedItemResponse value, $Res Function(_CreatedSavedItemResponse) _then) = __$CreatedSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String url,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus
});




}
/// @nodoc
class __$CreatedSavedItemResponseCopyWithImpl<$Res>
    implements _$CreatedSavedItemResponseCopyWith<$Res> {
  __$CreatedSavedItemResponseCopyWithImpl(this._self, this._then);

  final _CreatedSavedItemResponse _self;
  final $Res Function(_CreatedSavedItemResponse) _then;

/// Create a copy of CreatedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? collectionId = null,Object? enrichmentStatus = null,}) {
  return _then(_CreatedSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateSavedItemDataResponse {

@JsonKey(name: 'saved_item') CreatedSavedItemResponse get savedItem;
/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSavedItemDataResponseCopyWith<CreateSavedItemDataResponse> get copyWith => _$CreateSavedItemDataResponseCopyWithImpl<CreateSavedItemDataResponse>(this as CreateSavedItemDataResponse, _$identity);

  /// Serializes this CreateSavedItemDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSavedItemDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSavedItemDataResponse&&(identical(other.savedItem, _this.savedItem) || other.savedItem == _this.savedItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSavedItemDataResponse;
  return Object.hash(runtimeType,_this.savedItem);
}

@override
String toString() {
  final _this = this as CreateSavedItemDataResponse;
  return 'CreateSavedItemDataResponse(savedItem: ${_this.savedItem})';
}


}

/// @nodoc
abstract mixin class $CreateSavedItemDataResponseCopyWith<$Res>  {
  factory $CreateSavedItemDataResponseCopyWith(CreateSavedItemDataResponse value, $Res Function(CreateSavedItemDataResponse) _then) = _$CreateSavedItemDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_item') CreatedSavedItemResponse savedItem
});


$CreatedSavedItemResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class _$CreateSavedItemDataResponseCopyWithImpl<$Res>
    implements $CreateSavedItemDataResponseCopyWith<$Res> {
  _$CreateSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final CreateSavedItemDataResponse _self;
  final $Res Function(CreateSavedItemDataResponse) _then;

/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItem = null,}) {
  return _then(CreateSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as CreatedSavedItemResponse,
  ));
}
/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatedSavedItemResponseCopyWith<$Res> get savedItem {
  
  return $CreatedSavedItemResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateSavedItemDataResponse].
extension CreateSavedItemDataResponsePatterns on CreateSavedItemDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSavedItemDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSavedItemDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSavedItemDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  CreatedSavedItemResponse savedItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  CreatedSavedItemResponse savedItem)  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_item')  CreatedSavedItemResponse savedItem)?  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemDataResponse() when $default != null:
return $default(_that.savedItem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSavedItemDataResponse implements CreateSavedItemDataResponse {
  const _CreateSavedItemDataResponse({@JsonKey(name: 'saved_item') required this.savedItem});
  factory _CreateSavedItemDataResponse.fromJson(Map<String, dynamic> json) => _$CreateSavedItemDataResponseFromJson(json);

@override@JsonKey(name: 'saved_item') final  CreatedSavedItemResponse savedItem;

/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSavedItemDataResponseCopyWith<_CreateSavedItemDataResponse> get copyWith => __$CreateSavedItemDataResponseCopyWithImpl<_CreateSavedItemDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSavedItemDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSavedItemDataResponse&&(identical(other.savedItem, savedItem) || other.savedItem == savedItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,savedItem);
}

@override
String toString() {
    return 'CreateSavedItemDataResponse(savedItem: $savedItem)';
}


}

/// @nodoc
abstract mixin class _$CreateSavedItemDataResponseCopyWith<$Res> implements $CreateSavedItemDataResponseCopyWith<$Res> {
  factory _$CreateSavedItemDataResponseCopyWith(_CreateSavedItemDataResponse value, $Res Function(_CreateSavedItemDataResponse) _then) = __$CreateSavedItemDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_item') CreatedSavedItemResponse savedItem
});


@override $CreatedSavedItemResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class __$CreateSavedItemDataResponseCopyWithImpl<$Res>
    implements _$CreateSavedItemDataResponseCopyWith<$Res> {
  __$CreateSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final _CreateSavedItemDataResponse _self;
  final $Res Function(_CreateSavedItemDataResponse) _then;

/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItem = null,}) {
  return _then(_CreateSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as CreatedSavedItemResponse,
  ));
}

/// Create a copy of CreateSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatedSavedItemResponseCopyWith<$Res> get savedItem {
  
  return $CreatedSavedItemResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// @nodoc
mixin _$CreateSavedItemResponse {

 CreateSavedItemDataResponse get data; String? get message;
/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSavedItemResponseCopyWith<CreateSavedItemResponse> get copyWith => _$CreateSavedItemResponseCopyWithImpl<CreateSavedItemResponse>(this as CreateSavedItemResponse, _$identity);

  /// Serializes this CreateSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSavedItemResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSavedItemResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as CreateSavedItemResponse;
  return 'CreateSavedItemResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $CreateSavedItemResponseCopyWith<$Res>  {
  factory $CreateSavedItemResponseCopyWith(CreateSavedItemResponse value, $Res Function(CreateSavedItemResponse) _then) = _$CreateSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 CreateSavedItemDataResponse data, String? message
});


$CreateSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$CreateSavedItemResponseCopyWithImpl<$Res>
    implements $CreateSavedItemResponseCopyWith<$Res> {
  _$CreateSavedItemResponseCopyWithImpl(this._self, this._then);

  final CreateSavedItemResponse _self;
  final $Res Function(CreateSavedItemResponse) _then;

/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(CreateSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CreateSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateSavedItemDataResponseCopyWith<$Res> get data {
  
  return $CreateSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateSavedItemResponse].
extension CreateSavedItemResponsePatterns on CreateSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CreateSavedItemDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CreateSavedItemDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CreateSavedItemDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSavedItemResponse implements CreateSavedItemResponse {
  const _CreateSavedItemResponse({required this.data, this.message});
  factory _CreateSavedItemResponse.fromJson(Map<String, dynamic> json) => _$CreateSavedItemResponseFromJson(json);

@override final  CreateSavedItemDataResponse data;
@override final  String? message;

/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSavedItemResponseCopyWith<_CreateSavedItemResponse> get copyWith => __$CreateSavedItemResponseCopyWithImpl<_CreateSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSavedItemResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'CreateSavedItemResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CreateSavedItemResponseCopyWith<$Res> implements $CreateSavedItemResponseCopyWith<$Res> {
  factory _$CreateSavedItemResponseCopyWith(_CreateSavedItemResponse value, $Res Function(_CreateSavedItemResponse) _then) = __$CreateSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 CreateSavedItemDataResponse data, String? message
});


@override $CreateSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$CreateSavedItemResponseCopyWithImpl<$Res>
    implements _$CreateSavedItemResponseCopyWith<$Res> {
  __$CreateSavedItemResponseCopyWithImpl(this._self, this._then);

  final _CreateSavedItemResponse _self;
  final $Res Function(_CreateSavedItemResponse) _then;

/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_CreateSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CreateSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateSavedItemDataResponseCopyWith<$Res> get data {
  
  return $CreateSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
