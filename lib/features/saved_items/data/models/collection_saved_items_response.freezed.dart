// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_saved_items_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListedSavedItemsCollectionResponse {

 String get id; String get name;
/// Create a copy of ListedSavedItemsCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListedSavedItemsCollectionResponseCopyWith<ListedSavedItemsCollectionResponse> get copyWith => _$ListedSavedItemsCollectionResponseCopyWithImpl<ListedSavedItemsCollectionResponse>(this as ListedSavedItemsCollectionResponse, _$identity);

  /// Serializes this ListedSavedItemsCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListedSavedItemsCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListedSavedItemsCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListedSavedItemsCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as ListedSavedItemsCollectionResponse;
  return 'ListedSavedItemsCollectionResponse(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ListedSavedItemsCollectionResponseCopyWith<$Res>  {
  factory $ListedSavedItemsCollectionResponseCopyWith(ListedSavedItemsCollectionResponse value, $Res Function(ListedSavedItemsCollectionResponse) _then) = _$ListedSavedItemsCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ListedSavedItemsCollectionResponseCopyWithImpl<$Res>
    implements $ListedSavedItemsCollectionResponseCopyWith<$Res> {
  _$ListedSavedItemsCollectionResponseCopyWithImpl(this._self, this._then);

  final ListedSavedItemsCollectionResponse _self;
  final $Res Function(ListedSavedItemsCollectionResponse) _then;

/// Create a copy of ListedSavedItemsCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(ListedSavedItemsCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ListedSavedItemsCollectionResponse].
extension ListedSavedItemsCollectionResponsePatterns on ListedSavedItemsCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListedSavedItemsCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListedSavedItemsCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListedSavedItemsCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ListedSavedItemsCollectionResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListedSavedItemsCollectionResponse implements ListedSavedItemsCollectionResponse {
  const _ListedSavedItemsCollectionResponse({required this.id, required this.name});
  factory _ListedSavedItemsCollectionResponse.fromJson(Map<String, dynamic> json) => _$ListedSavedItemsCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of ListedSavedItemsCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListedSavedItemsCollectionResponseCopyWith<_ListedSavedItemsCollectionResponse> get copyWith => __$ListedSavedItemsCollectionResponseCopyWithImpl<_ListedSavedItemsCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListedSavedItemsCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListedSavedItemsCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'ListedSavedItemsCollectionResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ListedSavedItemsCollectionResponseCopyWith<$Res> implements $ListedSavedItemsCollectionResponseCopyWith<$Res> {
  factory _$ListedSavedItemsCollectionResponseCopyWith(_ListedSavedItemsCollectionResponse value, $Res Function(_ListedSavedItemsCollectionResponse) _then) = __$ListedSavedItemsCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ListedSavedItemsCollectionResponseCopyWithImpl<$Res>
    implements _$ListedSavedItemsCollectionResponseCopyWith<$Res> {
  __$ListedSavedItemsCollectionResponseCopyWithImpl(this._self, this._then);

  final _ListedSavedItemsCollectionResponse _self;
  final $Res Function(_ListedSavedItemsCollectionResponse) _then;

/// Create a copy of ListedSavedItemsCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ListedSavedItemsCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CollectionSavedItemResponse {

 String get id; String get url; String? get domain; String? get platform; String? get title; String? get description;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'enrichment_status') String get enrichmentStatus;@JsonKey(name: 'last_enriched_at') String? get lastEnrichedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of CollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionSavedItemResponseCopyWith<CollectionSavedItemResponse> get copyWith => _$CollectionSavedItemResponseCopyWithImpl<CollectionSavedItemResponse>(this as CollectionSavedItemResponse, _$identity);

  /// Serializes this CollectionSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CollectionSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionSavedItemResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.enrichmentStatus, _this.enrichmentStatus) || other.enrichmentStatus == _this.enrichmentStatus)&&(identical(other.lastEnrichedAt, _this.lastEnrichedAt) || other.lastEnrichedAt == _this.lastEnrichedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CollectionSavedItemResponse;
  return Object.hash(runtimeType,_this.id,_this.url,_this.domain,_this.platform,_this.title,_this.description,_this.imageUrl,_this.collectionId,_this.enrichmentStatus,_this.lastEnrichedAt,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as CollectionSavedItemResponse;
  return 'CollectionSavedItemResponse(id: ${_this.id}, url: ${_this.url}, domain: ${_this.domain}, platform: ${_this.platform}, title: ${_this.title}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, collectionId: ${_this.collectionId}, enrichmentStatus: ${_this.enrichmentStatus}, lastEnrichedAt: ${_this.lastEnrichedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $CollectionSavedItemResponseCopyWith<$Res>  {
  factory $CollectionSavedItemResponseCopyWith(CollectionSavedItemResponse value, $Res Function(CollectionSavedItemResponse) _then) = _$CollectionSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$CollectionSavedItemResponseCopyWithImpl<$Res>
    implements $CollectionSavedItemResponseCopyWith<$Res> {
  _$CollectionSavedItemResponseCopyWithImpl(this._self, this._then);

  final CollectionSavedItemResponse _self;
  final $Res Function(CollectionSavedItemResponse) _then;

/// Create a copy of CollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(CollectionSavedItemResponse(
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


/// Adds pattern-matching-related methods to [CollectionSavedItemResponse].
extension CollectionSavedItemResponsePatterns on CollectionSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _CollectionSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionSavedItemResponse() when $default != null:
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
case _CollectionSavedItemResponse() when $default != null:
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
case _CollectionSavedItemResponse():
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
case _CollectionSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionSavedItemResponse implements CollectionSavedItemResponse {
  const _CollectionSavedItemResponse({required this.id, required this.url, this.domain, this.platform, this.title, this.description, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'enrichment_status') required this.enrichmentStatus, @JsonKey(name: 'last_enriched_at') this.lastEnrichedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _CollectionSavedItemResponse.fromJson(Map<String, dynamic> json) => _$CollectionSavedItemResponseFromJson(json);

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

/// Create a copy of CollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionSavedItemResponseCopyWith<_CollectionSavedItemResponse> get copyWith => __$CollectionSavedItemResponseCopyWithImpl<_CollectionSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionSavedItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.enrichmentStatus, enrichmentStatus) || other.enrichmentStatus == enrichmentStatus)&&(identical(other.lastEnrichedAt, lastEnrichedAt) || other.lastEnrichedAt == lastEnrichedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,domain,platform,title,description,imageUrl,collectionId,enrichmentStatus,lastEnrichedAt,createdAt,updatedAt);
}

@override
String toString() {
    return 'CollectionSavedItemResponse(id: $id, url: $url, domain: $domain, platform: $platform, title: $title, description: $description, imageUrl: $imageUrl, collectionId: $collectionId, enrichmentStatus: $enrichmentStatus, lastEnrichedAt: $lastEnrichedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionSavedItemResponseCopyWith<$Res> implements $CollectionSavedItemResponseCopyWith<$Res> {
  factory _$CollectionSavedItemResponseCopyWith(_CollectionSavedItemResponse value, $Res Function(_CollectionSavedItemResponse) _then) = __$CollectionSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$CollectionSavedItemResponseCopyWithImpl<$Res>
    implements _$CollectionSavedItemResponseCopyWith<$Res> {
  __$CollectionSavedItemResponseCopyWithImpl(this._self, this._then);

  final _CollectionSavedItemResponse _self;
  final $Res Function(_CollectionSavedItemResponse) _then;

/// Create a copy of CollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CollectionSavedItemResponse(
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
mixin _$ListCollectionSavedItemsDataResponse {

 ListedSavedItemsCollectionResponse get collection;@JsonKey(name: 'saved_items') List<CollectionSavedItemResponse> get savedItems;
/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListCollectionSavedItemsDataResponseCopyWith<ListCollectionSavedItemsDataResponse> get copyWith => _$ListCollectionSavedItemsDataResponseCopyWithImpl<ListCollectionSavedItemsDataResponse>(this as ListCollectionSavedItemsDataResponse, _$identity);

  /// Serializes this ListCollectionSavedItemsDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListCollectionSavedItemsDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListCollectionSavedItemsDataResponse&&(identical(other.collection, _this.collection) || other.collection == _this.collection)&&const DeepCollectionEquality().equals(other.savedItems, _this.savedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListCollectionSavedItemsDataResponse;
  return Object.hash(runtimeType,_this.collection,const DeepCollectionEquality().hash(_this.savedItems));
}

@override
String toString() {
  final _this = this as ListCollectionSavedItemsDataResponse;
  return 'ListCollectionSavedItemsDataResponse(collection: ${_this.collection}, savedItems: ${_this.savedItems})';
}


}

/// @nodoc
abstract mixin class $ListCollectionSavedItemsDataResponseCopyWith<$Res>  {
  factory $ListCollectionSavedItemsDataResponseCopyWith(ListCollectionSavedItemsDataResponse value, $Res Function(ListCollectionSavedItemsDataResponse) _then) = _$ListCollectionSavedItemsDataResponseCopyWithImpl;
@useResult
$Res call({
 ListedSavedItemsCollectionResponse collection,@JsonKey(name: 'saved_items') List<CollectionSavedItemResponse> savedItems
});


$ListedSavedItemsCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class _$ListCollectionSavedItemsDataResponseCopyWithImpl<$Res>
    implements $ListCollectionSavedItemsDataResponseCopyWith<$Res> {
  _$ListCollectionSavedItemsDataResponseCopyWithImpl(this._self, this._then);

  final ListCollectionSavedItemsDataResponse _self;
  final $Res Function(ListCollectionSavedItemsDataResponse) _then;

/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = null,Object? savedItems = null,}) {
  return _then(ListCollectionSavedItemsDataResponse(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as ListedSavedItemsCollectionResponse,savedItems: null == savedItems ? _self.savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<CollectionSavedItemResponse>,
  ));
}
/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListedSavedItemsCollectionResponseCopyWith<$Res> get collection {
  
  return $ListedSavedItemsCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListCollectionSavedItemsDataResponse].
extension ListCollectionSavedItemsDataResponsePatterns on ListCollectionSavedItemsDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListCollectionSavedItemsDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListCollectionSavedItemsDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListCollectionSavedItemsDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListedSavedItemsCollectionResponse collection, @JsonKey(name: 'saved_items')  List<CollectionSavedItemResponse> savedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse() when $default != null:
return $default(_that.collection,_that.savedItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListedSavedItemsCollectionResponse collection, @JsonKey(name: 'saved_items')  List<CollectionSavedItemResponse> savedItems)  $default,) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse():
return $default(_that.collection,_that.savedItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListedSavedItemsCollectionResponse collection, @JsonKey(name: 'saved_items')  List<CollectionSavedItemResponse> savedItems)?  $default,) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsDataResponse() when $default != null:
return $default(_that.collection,_that.savedItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListCollectionSavedItemsDataResponse implements ListCollectionSavedItemsDataResponse {
  const _ListCollectionSavedItemsDataResponse({required this.collection, @JsonKey(name: 'saved_items') required  List<CollectionSavedItemResponse> savedItems}): _savedItems = savedItems;
  factory _ListCollectionSavedItemsDataResponse.fromJson(Map<String, dynamic> json) => _$ListCollectionSavedItemsDataResponseFromJson(json);

@override final  ListedSavedItemsCollectionResponse collection;
 final  List<CollectionSavedItemResponse> _savedItems;
@override@JsonKey(name: 'saved_items') List<CollectionSavedItemResponse> get savedItems {
  if (_savedItems is EqualUnmodifiableListView) return _savedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedItems);
}


/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListCollectionSavedItemsDataResponseCopyWith<_ListCollectionSavedItemsDataResponse> get copyWith => __$ListCollectionSavedItemsDataResponseCopyWithImpl<_ListCollectionSavedItemsDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListCollectionSavedItemsDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListCollectionSavedItemsDataResponse&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other.savedItems, _savedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(_savedItems));
}

@override
String toString() {
    return 'ListCollectionSavedItemsDataResponse(collection: $collection, savedItems: $savedItems)';
}


}

/// @nodoc
abstract mixin class _$ListCollectionSavedItemsDataResponseCopyWith<$Res> implements $ListCollectionSavedItemsDataResponseCopyWith<$Res> {
  factory _$ListCollectionSavedItemsDataResponseCopyWith(_ListCollectionSavedItemsDataResponse value, $Res Function(_ListCollectionSavedItemsDataResponse) _then) = __$ListCollectionSavedItemsDataResponseCopyWithImpl;
@override @useResult
$Res call({
 ListedSavedItemsCollectionResponse collection,@JsonKey(name: 'saved_items') List<CollectionSavedItemResponse> savedItems
});


@override $ListedSavedItemsCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class __$ListCollectionSavedItemsDataResponseCopyWithImpl<$Res>
    implements _$ListCollectionSavedItemsDataResponseCopyWith<$Res> {
  __$ListCollectionSavedItemsDataResponseCopyWithImpl(this._self, this._then);

  final _ListCollectionSavedItemsDataResponse _self;
  final $Res Function(_ListCollectionSavedItemsDataResponse) _then;

/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? savedItems = null,}) {
  return _then(_ListCollectionSavedItemsDataResponse(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as ListedSavedItemsCollectionResponse,savedItems: null == savedItems ? _self._savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<CollectionSavedItemResponse>,
  ));
}

/// Create a copy of ListCollectionSavedItemsDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListedSavedItemsCollectionResponseCopyWith<$Res> get collection {
  
  return $ListedSavedItemsCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// @nodoc
mixin _$ListCollectionSavedItemsResponse {

 ListCollectionSavedItemsDataResponse get data; String? get message; ListSavedItemsMetaResponse? get meta;
/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListCollectionSavedItemsResponseCopyWith<ListCollectionSavedItemsResponse> get copyWith => _$ListCollectionSavedItemsResponseCopyWithImpl<ListCollectionSavedItemsResponse>(this as ListCollectionSavedItemsResponse, _$identity);

  /// Serializes this ListCollectionSavedItemsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListCollectionSavedItemsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListCollectionSavedItemsResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.meta, _this.meta) || other.meta == _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListCollectionSavedItemsResponse;
  return Object.hash(runtimeType,_this.data,_this.message,_this.meta);
}

@override
String toString() {
  final _this = this as ListCollectionSavedItemsResponse;
  return 'ListCollectionSavedItemsResponse(data: ${_this.data}, message: ${_this.message}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $ListCollectionSavedItemsResponseCopyWith<$Res>  {
  factory $ListCollectionSavedItemsResponseCopyWith(ListCollectionSavedItemsResponse value, $Res Function(ListCollectionSavedItemsResponse) _then) = _$ListCollectionSavedItemsResponseCopyWithImpl;
@useResult
$Res call({
 ListCollectionSavedItemsDataResponse data, String? message, ListSavedItemsMetaResponse? meta
});


$ListCollectionSavedItemsDataResponseCopyWith<$Res> get data;$ListSavedItemsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class _$ListCollectionSavedItemsResponseCopyWithImpl<$Res>
    implements $ListCollectionSavedItemsResponseCopyWith<$Res> {
  _$ListCollectionSavedItemsResponseCopyWithImpl(this._self, this._then);

  final ListCollectionSavedItemsResponse _self;
  final $Res Function(ListCollectionSavedItemsResponse) _then;

/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(ListCollectionSavedItemsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListCollectionSavedItemsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListSavedItemsMetaResponse?,
  ));
}
/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionSavedItemsDataResponseCopyWith<$Res> get data {
  
  return $ListCollectionSavedItemsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListSavedItemsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListCollectionSavedItemsResponse].
extension ListCollectionSavedItemsResponsePatterns on ListCollectionSavedItemsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListCollectionSavedItemsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListCollectionSavedItemsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListCollectionSavedItemsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListCollectionSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListCollectionSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)  $default,) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse():
return $default(_that.data,_that.message,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListCollectionSavedItemsDataResponse data,  String? message,  ListSavedItemsMetaResponse? meta)?  $default,) {final _that = this;
switch (_that) {
case _ListCollectionSavedItemsResponse() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListCollectionSavedItemsResponse implements ListCollectionSavedItemsResponse {
  const _ListCollectionSavedItemsResponse({required this.data, this.message, this.meta});
  factory _ListCollectionSavedItemsResponse.fromJson(Map<String, dynamic> json) => _$ListCollectionSavedItemsResponseFromJson(json);

@override final  ListCollectionSavedItemsDataResponse data;
@override final  String? message;
@override final  ListSavedItemsMetaResponse? meta;

/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListCollectionSavedItemsResponseCopyWith<_ListCollectionSavedItemsResponse> get copyWith => __$ListCollectionSavedItemsResponseCopyWithImpl<_ListCollectionSavedItemsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListCollectionSavedItemsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListCollectionSavedItemsResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message,meta);
}

@override
String toString() {
    return 'ListCollectionSavedItemsResponse(data: $data, message: $message, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ListCollectionSavedItemsResponseCopyWith<$Res> implements $ListCollectionSavedItemsResponseCopyWith<$Res> {
  factory _$ListCollectionSavedItemsResponseCopyWith(_ListCollectionSavedItemsResponse value, $Res Function(_ListCollectionSavedItemsResponse) _then) = __$ListCollectionSavedItemsResponseCopyWithImpl;
@override @useResult
$Res call({
 ListCollectionSavedItemsDataResponse data, String? message, ListSavedItemsMetaResponse? meta
});


@override $ListCollectionSavedItemsDataResponseCopyWith<$Res> get data;@override $ListSavedItemsMetaResponseCopyWith<$Res>? get meta;

}
/// @nodoc
class __$ListCollectionSavedItemsResponseCopyWithImpl<$Res>
    implements _$ListCollectionSavedItemsResponseCopyWith<$Res> {
  __$ListCollectionSavedItemsResponseCopyWithImpl(this._self, this._then);

  final _ListCollectionSavedItemsResponse _self;
  final $Res Function(_ListCollectionSavedItemsResponse) _then;

/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,Object? meta = freezed,}) {
  return _then(_ListCollectionSavedItemsResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ListCollectionSavedItemsDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ListSavedItemsMetaResponse?,
  ));
}

/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListCollectionSavedItemsDataResponseCopyWith<$Res> get data {
  
  return $ListCollectionSavedItemsDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of ListCollectionSavedItemsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListSavedItemsMetaResponseCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $ListSavedItemsMetaResponseCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
