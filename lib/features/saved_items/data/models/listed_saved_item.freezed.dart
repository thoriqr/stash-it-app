// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listed_saved_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedItemCollectionResponse {

 String get id; String get name;
/// Create a copy of SavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedItemCollectionResponseCopyWith<SavedItemCollectionResponse> get copyWith => _$SavedItemCollectionResponseCopyWithImpl<SavedItemCollectionResponse>(this as SavedItemCollectionResponse, _$identity);

  /// Serializes this SavedItemCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavedItemCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedItemCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavedItemCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as SavedItemCollectionResponse;
  return 'SavedItemCollectionResponse(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $SavedItemCollectionResponseCopyWith<$Res>  {
  factory $SavedItemCollectionResponseCopyWith(SavedItemCollectionResponse value, $Res Function(SavedItemCollectionResponse) _then) = _$SavedItemCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$SavedItemCollectionResponseCopyWithImpl<$Res>
    implements $SavedItemCollectionResponseCopyWith<$Res> {
  _$SavedItemCollectionResponseCopyWithImpl(this._self, this._then);

  final SavedItemCollectionResponse _self;
  final $Res Function(SavedItemCollectionResponse) _then;

/// Create a copy of SavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(SavedItemCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedItemCollectionResponse].
extension SavedItemCollectionResponsePatterns on SavedItemCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedItemCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedItemCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedItemCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SavedItemCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedItemCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SavedItemCollectionResponse() when $default != null:
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
case _SavedItemCollectionResponse() when $default != null:
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
case _SavedItemCollectionResponse():
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
case _SavedItemCollectionResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedItemCollectionResponse implements SavedItemCollectionResponse {
  const _SavedItemCollectionResponse({required this.id, required this.name});
  factory _SavedItemCollectionResponse.fromJson(Map<String, dynamic> json) => _$SavedItemCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of SavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedItemCollectionResponseCopyWith<_SavedItemCollectionResponse> get copyWith => __$SavedItemCollectionResponseCopyWithImpl<_SavedItemCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedItemCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedItemCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'SavedItemCollectionResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SavedItemCollectionResponseCopyWith<$Res> implements $SavedItemCollectionResponseCopyWith<$Res> {
  factory _$SavedItemCollectionResponseCopyWith(_SavedItemCollectionResponse value, $Res Function(_SavedItemCollectionResponse) _then) = __$SavedItemCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$SavedItemCollectionResponseCopyWithImpl<$Res>
    implements _$SavedItemCollectionResponseCopyWith<$Res> {
  __$SavedItemCollectionResponseCopyWithImpl(this._self, this._then);

  final _SavedItemCollectionResponse _self;
  final $Res Function(_SavedItemCollectionResponse) _then;

/// Create a copy of SavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_SavedItemCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ListedSavedItemResponse {

 String get id; String get url; String? get domain; String? get platform; String? get title; String? get description;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'enrichment_status') String get enrichmentStatus;@JsonKey(name: 'last_enriched_at') String? get lastEnrichedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; SavedItemCollectionResponse get collection;
/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListedSavedItemResponseCopyWith<ListedSavedItemResponse> get copyWith => _$ListedSavedItemResponseCopyWithImpl<ListedSavedItemResponse>(this as ListedSavedItemResponse, _$identity);

  /// Serializes this ListedSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListedSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListedSavedItemResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.enrichmentStatus, _this.enrichmentStatus) || other.enrichmentStatus == _this.enrichmentStatus)&&(identical(other.lastEnrichedAt, _this.lastEnrichedAt) || other.lastEnrichedAt == _this.lastEnrichedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.collection, _this.collection) || other.collection == _this.collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListedSavedItemResponse;
  return Object.hash(runtimeType,_this.id,_this.url,_this.domain,_this.platform,_this.title,_this.description,_this.imageUrl,_this.collectionId,_this.enrichmentStatus,_this.lastEnrichedAt,_this.createdAt,_this.updatedAt,_this.collection);
}

@override
String toString() {
  final _this = this as ListedSavedItemResponse;
  return 'ListedSavedItemResponse(id: ${_this.id}, url: ${_this.url}, domain: ${_this.domain}, platform: ${_this.platform}, title: ${_this.title}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, collectionId: ${_this.collectionId}, enrichmentStatus: ${_this.enrichmentStatus}, lastEnrichedAt: ${_this.lastEnrichedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, collection: ${_this.collection})';
}


}

/// @nodoc
abstract mixin class $ListedSavedItemResponseCopyWith<$Res>  {
  factory $ListedSavedItemResponseCopyWith(ListedSavedItemResponse value, $Res Function(ListedSavedItemResponse) _then) = _$ListedSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, SavedItemCollectionResponse collection
});


$SavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class _$ListedSavedItemResponseCopyWithImpl<$Res>
    implements $ListedSavedItemResponseCopyWith<$Res> {
  _$ListedSavedItemResponseCopyWithImpl(this._self, this._then);

  final ListedSavedItemResponse _self;
  final $Res Function(ListedSavedItemResponse) _then;

/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? collection = null,}) {
  return _then(ListedSavedItemResponse(
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
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SavedItemCollectionResponse,
  ));
}
/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListedSavedItemResponse].
extension ListedSavedItemResponsePatterns on ListedSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListedSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListedSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListedSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListedSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListedSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListedSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SavedItemCollectionResponse collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListedSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt,_that.collection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SavedItemCollectionResponse collection)  $default,) {final _that = this;
switch (_that) {
case _ListedSavedItemResponse():
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt,_that.collection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String? domain,  String? platform,  String? title,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'enrichment_status')  String enrichmentStatus, @JsonKey(name: 'last_enriched_at')  String? lastEnrichedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SavedItemCollectionResponse collection)?  $default,) {final _that = this;
switch (_that) {
case _ListedSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.description,_that.imageUrl,_that.collectionId,_that.enrichmentStatus,_that.lastEnrichedAt,_that.createdAt,_that.updatedAt,_that.collection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListedSavedItemResponse implements ListedSavedItemResponse {
  const _ListedSavedItemResponse({required this.id, required this.url, this.domain, this.platform, this.title, this.description, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'enrichment_status') required this.enrichmentStatus, @JsonKey(name: 'last_enriched_at') this.lastEnrichedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, required this.collection});
  factory _ListedSavedItemResponse.fromJson(Map<String, dynamic> json) => _$ListedSavedItemResponseFromJson(json);

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
@override final  SavedItemCollectionResponse collection;

/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListedSavedItemResponseCopyWith<_ListedSavedItemResponse> get copyWith => __$ListedSavedItemResponseCopyWithImpl<_ListedSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListedSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListedSavedItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.enrichmentStatus, enrichmentStatus) || other.enrichmentStatus == enrichmentStatus)&&(identical(other.lastEnrichedAt, lastEnrichedAt) || other.lastEnrichedAt == lastEnrichedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,domain,platform,title,description,imageUrl,collectionId,enrichmentStatus,lastEnrichedAt,createdAt,updatedAt,collection);
}

@override
String toString() {
    return 'ListedSavedItemResponse(id: $id, url: $url, domain: $domain, platform: $platform, title: $title, description: $description, imageUrl: $imageUrl, collectionId: $collectionId, enrichmentStatus: $enrichmentStatus, lastEnrichedAt: $lastEnrichedAt, createdAt: $createdAt, updatedAt: $updatedAt, collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$ListedSavedItemResponseCopyWith<$Res> implements $ListedSavedItemResponseCopyWith<$Res> {
  factory _$ListedSavedItemResponseCopyWith(_ListedSavedItemResponse value, $Res Function(_ListedSavedItemResponse) _then) = __$ListedSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'enrichment_status') String enrichmentStatus,@JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, SavedItemCollectionResponse collection
});


@override $SavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class __$ListedSavedItemResponseCopyWithImpl<$Res>
    implements _$ListedSavedItemResponseCopyWith<$Res> {
  __$ListedSavedItemResponseCopyWithImpl(this._self, this._then);

  final _ListedSavedItemResponse _self;
  final $Res Function(_ListedSavedItemResponse) _then;

/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? collectionId = null,Object? enrichmentStatus = null,Object? lastEnrichedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? collection = null,}) {
  return _then(_ListedSavedItemResponse(
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
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SavedItemCollectionResponse,
  ));
}

/// Create a copy of ListedSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on
