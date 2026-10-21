// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_saved_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedItemDetailResponse {

 String get id; String get url; String? get domain; String? get platform; String? get title; String? get description;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'enrichment_status') String get enrichmentStatus;@JsonKey(name: 'last_enriched_at') String? get lastEnrichedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of SavedItemDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedItemDetailResponseCopyWith<SavedItemDetailResponse> get copyWith => _$SavedItemDetailResponseCopyWithImpl<SavedItemDetailResponse>(this as SavedItemDetailResponse, _$identity);

  /// Serializes this SavedItemDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavedItemDetailResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedItemDetailResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.enrichmentStatus, _this.enrichmentStatus) || other.enrichmentStatus == _this.enrichmentStatus)&&(identical(other.lastEnrichedAt, _this.lastEnrichedAt) || other.lastEnrichedAt == _this.lastEnrichedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavedItemDetailResponse;
  return Object.hash(runtimeType,_this.id,_this.url,_this.domain,_this.platform,_this.title,_this.description,_this.imageUrl,_this.collectionId,_this.enrichmentStatus,_this.lastEnrichedAt,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SavedItemDetailResponse;
  return 'SavedItemDetailResponse(id: ${_this.id}, url: ${_this.url}, domain: ${_this.domain}, platform: ${_this.platform}, title: ${_this.title}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, collectionId: ${_this.collectionId}, enrichmentStatus: ${_this.enrichmentStatus}, lastEnrichedAt: ${_this.lastEnrichedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SavedItemDetailResponseCopyWith<$Res>  {
  factory $SavedItemDetailResponseCopyWith(SavedItemDetailResponse value, $Res Function(SavedItemDetailResponse) _then) = _$SavedItemDetailResponseCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$SavedItemDetailResponseCopyWithImpl<$Res>
    implements $SavedItemDetailResponseCopyWith<$Res> {
  _$SavedItemDetailResponseCopyWithImpl(this._self, this._then);

  final SavedItemDetailResponse _self;
  final $Res Function(SavedItemDetailResponse) _then;

/// Create a copy of SavedItemDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SavedItemDetailResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,lastEnrichedAt: freezed == lastEnrichedAt ? _self.lastEnrichedAt : lastEnrichedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedItemDetailResponse].
extension SavedItemDetailResponsePatterns on SavedItemDetailResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedItemDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedItemDetailResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedItemDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _SavedItemDetailResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedItemDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SavedItemDetailResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedItemDetailResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SavedItemDetailResponse():
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedItemDetailResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedItemDetailResponse implements SavedItemDetailResponse {
  const _SavedItemDetailResponse({required this.id, required this.url, this.domain, this.platform, this.title, this.description, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'enrichment_status') required this.enrichmentStatus, @JsonKey(name: 'last_enriched_at') this.lastEnrichedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _SavedItemDetailResponse.fromJson(Map<String, dynamic> json) => _$SavedItemDetailResponseFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? domain;
@override final  String? platform;
@override final  String? title;
@override final  String? description;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'collection_id') final  String collectionId;
@override@JsonKey(name: 'enrichment_status') final  String enrichmentStatus;
@override@JsonKey(name: 'last_enriched_at') final  String? lastEnrichedAt;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of SavedItemDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedItemDetailResponseCopyWith<_SavedItemDetailResponse> get copyWith => __$SavedItemDetailResponseCopyWithImpl<_SavedItemDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedItemDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedItemDetailResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.enrichmentStatus, enrichmentStatus) || other.enrichmentStatus == enrichmentStatus)&&(identical(other.lastEnrichedAt, lastEnrichedAt) || other.lastEnrichedAt == lastEnrichedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,domain,platform,title,description,imageUrl,collectionId,enrichmentStatus,lastEnrichedAt,createdAt,updatedAt);
}

@override
String toString() {
    return 'SavedItemDetailResponse(id: $id, url: $url, domain: $domain, platform: $platform, title: $title, description: $description, imageUrl: $imageUrl, collectionId: $collectionId, enrichmentStatus: $enrichmentStatus, lastEnrichedAt: $lastEnrichedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SavedItemDetailResponseCopyWith<$Res> implements $SavedItemDetailResponseCopyWith<$Res> {
  factory _$SavedItemDetailResponseCopyWith(_SavedItemDetailResponse value, $Res Function(_SavedItemDetailResponse) _then) = __$SavedItemDetailResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$SavedItemDetailResponseCopyWithImpl<$Res>
    implements _$SavedItemDetailResponseCopyWith<$Res> {
  __$SavedItemDetailResponseCopyWithImpl(this._self, this._then);

  final _SavedItemDetailResponse _self;
  final $Res Function(_SavedItemDetailResponse) _then;

/// Create a copy of SavedItemDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SavedItemDetailResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,lastEnrichedAt: freezed == lastEnrichedAt ? _self.lastEnrichedAt : lastEnrichedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GetSavedItemDataResponse {

@JsonKey(name: 'saved_item') SavedItemDetailResponse get savedItem; SavedItemCollectionResponse get collection;
/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetSavedItemDataResponseCopyWith<GetSavedItemDataResponse> get copyWith => _$GetSavedItemDataResponseCopyWithImpl<GetSavedItemDataResponse>(this as GetSavedItemDataResponse, _$identity);

  /// Serializes this GetSavedItemDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GetSavedItemDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetSavedItemDataResponse&&(identical(other.savedItem, _this.savedItem) || other.savedItem == _this.savedItem)&&(identical(other.collection, _this.collection) || other.collection == _this.collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GetSavedItemDataResponse;
  return Object.hash(runtimeType,_this.savedItem,_this.collection);
}

@override
String toString() {
  final _this = this as GetSavedItemDataResponse;
  return 'GetSavedItemDataResponse(savedItem: ${_this.savedItem}, collection: ${_this.collection})';
}


}

/// @nodoc
abstract mixin class $GetSavedItemDataResponseCopyWith<$Res>  {
  factory $GetSavedItemDataResponseCopyWith(GetSavedItemDataResponse value, $Res Function(GetSavedItemDataResponse) _then) = _$GetSavedItemDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_item') SavedItemDetailResponse savedItem, SavedItemCollectionResponse collection
});


$SavedItemDetailResponseCopyWith<$Res> get savedItem;$SavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class _$GetSavedItemDataResponseCopyWithImpl<$Res>
    implements $GetSavedItemDataResponseCopyWith<$Res> {
  _$GetSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final GetSavedItemDataResponse _self;
  final $Res Function(GetSavedItemDataResponse) _then;

/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItem = null,Object? collection = null,}) {
  return _then(GetSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as SavedItemDetailResponse,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SavedItemCollectionResponse,
  ));
}
/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemDetailResponseCopyWith<$Res> get savedItem {
  
  return $SavedItemDetailResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetSavedItemDataResponse].
extension GetSavedItemDataResponsePatterns on GetSavedItemDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetSavedItemDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetSavedItemDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetSavedItemDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetSavedItemDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetSavedItemDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem,  SavedItemCollectionResponse collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetSavedItemDataResponse() when $default != null:
return $default(_that.savedItem,_that.collection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem,  SavedItemCollectionResponse collection)  $default,) {final _that = this;
switch (_that) {
case _GetSavedItemDataResponse():
return $default(_that.savedItem,_that.collection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_item')  SavedItemDetailResponse savedItem,  SavedItemCollectionResponse collection)?  $default,) {final _that = this;
switch (_that) {
case _GetSavedItemDataResponse() when $default != null:
return $default(_that.savedItem,_that.collection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetSavedItemDataResponse implements GetSavedItemDataResponse {
  const _GetSavedItemDataResponse({@JsonKey(name: 'saved_item') required this.savedItem, required this.collection});
  factory _GetSavedItemDataResponse.fromJson(Map<String, dynamic> json) => _$GetSavedItemDataResponseFromJson(json);

@override@JsonKey(name: 'saved_item') final  SavedItemDetailResponse savedItem;
@override final  SavedItemCollectionResponse collection;

/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetSavedItemDataResponseCopyWith<_GetSavedItemDataResponse> get copyWith => __$GetSavedItemDataResponseCopyWithImpl<_GetSavedItemDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetSavedItemDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetSavedItemDataResponse&&(identical(other.savedItem, savedItem) || other.savedItem == savedItem)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,savedItem,collection);
}

@override
String toString() {
    return 'GetSavedItemDataResponse(savedItem: $savedItem, collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$GetSavedItemDataResponseCopyWith<$Res> implements $GetSavedItemDataResponseCopyWith<$Res> {
  factory _$GetSavedItemDataResponseCopyWith(_GetSavedItemDataResponse value, $Res Function(_GetSavedItemDataResponse) _then) = __$GetSavedItemDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_item') SavedItemDetailResponse savedItem, SavedItemCollectionResponse collection
});


@override $SavedItemDetailResponseCopyWith<$Res> get savedItem;@override $SavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class __$GetSavedItemDataResponseCopyWithImpl<$Res>
    implements _$GetSavedItemDataResponseCopyWith<$Res> {
  __$GetSavedItemDataResponseCopyWithImpl(this._self, this._then);

  final _GetSavedItemDataResponse _self;
  final $Res Function(_GetSavedItemDataResponse) _then;

/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItem = null,Object? collection = null,}) {
  return _then(_GetSavedItemDataResponse(
savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as SavedItemDetailResponse,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SavedItemCollectionResponse,
  ));
}

/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemDetailResponseCopyWith<$Res> get savedItem {
  
  return $SavedItemDetailResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}/// Create a copy of GetSavedItemDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// @nodoc
mixin _$GetSavedItemResponse {

 GetSavedItemDataResponse get data; String? get message;
/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetSavedItemResponseCopyWith<GetSavedItemResponse> get copyWith => _$GetSavedItemResponseCopyWithImpl<GetSavedItemResponse>(this as GetSavedItemResponse, _$identity);

  /// Serializes this GetSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GetSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetSavedItemResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GetSavedItemResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as GetSavedItemResponse;
  return 'GetSavedItemResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $GetSavedItemResponseCopyWith<$Res>  {
  factory $GetSavedItemResponseCopyWith(GetSavedItemResponse value, $Res Function(GetSavedItemResponse) _then) = _$GetSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 GetSavedItemDataResponse data, String? message
});


$GetSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$GetSavedItemResponseCopyWithImpl<$Res>
    implements $GetSavedItemResponseCopyWith<$Res> {
  _$GetSavedItemResponseCopyWithImpl(this._self, this._then);

  final GetSavedItemResponse _self;
  final $Res Function(GetSavedItemResponse) _then;

/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(GetSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as GetSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetSavedItemDataResponseCopyWith<$Res> get data {
  
  return $GetSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetSavedItemResponse].
extension GetSavedItemResponsePatterns on GetSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GetSavedItemDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GetSavedItemDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _GetSavedItemResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GetSavedItemDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _GetSavedItemResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetSavedItemResponse implements GetSavedItemResponse {
  const _GetSavedItemResponse({required this.data, this.message});
  factory _GetSavedItemResponse.fromJson(Map<String, dynamic> json) => _$GetSavedItemResponseFromJson(json);

@override final  GetSavedItemDataResponse data;
@override final  String? message;

/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetSavedItemResponseCopyWith<_GetSavedItemResponse> get copyWith => __$GetSavedItemResponseCopyWithImpl<_GetSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetSavedItemResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'GetSavedItemResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$GetSavedItemResponseCopyWith<$Res> implements $GetSavedItemResponseCopyWith<$Res> {
  factory _$GetSavedItemResponseCopyWith(_GetSavedItemResponse value, $Res Function(_GetSavedItemResponse) _then) = __$GetSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 GetSavedItemDataResponse data, String? message
});


@override $GetSavedItemDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$GetSavedItemResponseCopyWithImpl<$Res>
    implements _$GetSavedItemResponseCopyWith<$Res> {
  __$GetSavedItemResponseCopyWithImpl(this._self, this._then);

  final _GetSavedItemResponse _self;
  final $Res Function(_GetSavedItemResponse) _then;

/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_GetSavedItemResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as GetSavedItemDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GetSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetSavedItemDataResponseCopyWith<$Res> get data {
  
  return $GetSavedItemDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
