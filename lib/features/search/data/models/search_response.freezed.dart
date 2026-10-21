// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchSavedItemCollectionResponse {

 String get id; String get name;
/// Create a copy of SearchSavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSavedItemCollectionResponseCopyWith<SearchSavedItemCollectionResponse> get copyWith => _$SearchSavedItemCollectionResponseCopyWithImpl<SearchSavedItemCollectionResponse>(this as SearchSavedItemCollectionResponse, _$identity);

  /// Serializes this SearchSavedItemCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchSavedItemCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSavedItemCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchSavedItemCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as SearchSavedItemCollectionResponse;
  return 'SearchSavedItemCollectionResponse(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $SearchSavedItemCollectionResponseCopyWith<$Res>  {
  factory $SearchSavedItemCollectionResponseCopyWith(SearchSavedItemCollectionResponse value, $Res Function(SearchSavedItemCollectionResponse) _then) = _$SearchSavedItemCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$SearchSavedItemCollectionResponseCopyWithImpl<$Res>
    implements $SearchSavedItemCollectionResponseCopyWith<$Res> {
  _$SearchSavedItemCollectionResponseCopyWithImpl(this._self, this._then);

  final SearchSavedItemCollectionResponse _self;
  final $Res Function(SearchSavedItemCollectionResponse) _then;

/// Create a copy of SearchSavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(SearchSavedItemCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchSavedItemCollectionResponse].
extension SearchSavedItemCollectionResponsePatterns on SearchSavedItemCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchSavedItemCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchSavedItemCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchSavedItemCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchSavedItemCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchSavedItemCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchSavedItemCollectionResponse() when $default != null:
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
case _SearchSavedItemCollectionResponse() when $default != null:
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
case _SearchSavedItemCollectionResponse():
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
case _SearchSavedItemCollectionResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchSavedItemCollectionResponse implements SearchSavedItemCollectionResponse {
  const _SearchSavedItemCollectionResponse({required this.id, required this.name});
  factory _SearchSavedItemCollectionResponse.fromJson(Map<String, dynamic> json) => _$SearchSavedItemCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of SearchSavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchSavedItemCollectionResponseCopyWith<_SearchSavedItemCollectionResponse> get copyWith => __$SearchSavedItemCollectionResponseCopyWithImpl<_SearchSavedItemCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchSavedItemCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchSavedItemCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'SearchSavedItemCollectionResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SearchSavedItemCollectionResponseCopyWith<$Res> implements $SearchSavedItemCollectionResponseCopyWith<$Res> {
  factory _$SearchSavedItemCollectionResponseCopyWith(_SearchSavedItemCollectionResponse value, $Res Function(_SearchSavedItemCollectionResponse) _then) = __$SearchSavedItemCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$SearchSavedItemCollectionResponseCopyWithImpl<$Res>
    implements _$SearchSavedItemCollectionResponseCopyWith<$Res> {
  __$SearchSavedItemCollectionResponseCopyWithImpl(this._self, this._then);

  final _SearchSavedItemCollectionResponse _self;
  final $Res Function(_SearchSavedItemCollectionResponse) _then;

/// Create a copy of SearchSavedItemCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_SearchSavedItemCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SearchSavedItemResponse {

 String get id; String? get title; String get url; String? get domain;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'enrichment_status') String get enrichmentStatus; SearchSavedItemCollectionResponse get collection;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSavedItemResponseCopyWith<SearchSavedItemResponse> get copyWith => _$SearchSavedItemResponseCopyWithImpl<SearchSavedItemResponse>(this as SearchSavedItemResponse, _$identity);

  /// Serializes this SearchSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSavedItemResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.enrichmentStatus, _this.enrichmentStatus) || other.enrichmentStatus == _this.enrichmentStatus)&&(identical(other.collection, _this.collection) || other.collection == _this.collection)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchSavedItemResponse;
  return Object.hash(runtimeType,_this.id,_this.title,_this.url,_this.domain,_this.imageUrl,_this.enrichmentStatus,_this.collection,_this.createdAt);
}

@override
String toString() {
  final _this = this as SearchSavedItemResponse;
  return 'SearchSavedItemResponse(id: ${_this.id}, title: ${_this.title}, url: ${_this.url}, domain: ${_this.domain}, imageUrl: ${_this.imageUrl}, enrichmentStatus: ${_this.enrichmentStatus}, collection: ${_this.collection}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SearchSavedItemResponseCopyWith<$Res>  {
  factory $SearchSavedItemResponseCopyWith(SearchSavedItemResponse value, $Res Function(SearchSavedItemResponse) _then) = _$SearchSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String url, String? domain,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'enrichment_status') String enrichmentStatus, SearchSavedItemCollectionResponse collection,@JsonKey(name: 'created_at') String createdAt
});


$SearchSavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class _$SearchSavedItemResponseCopyWithImpl<$Res>
    implements $SearchSavedItemResponseCopyWith<$Res> {
  _$SearchSavedItemResponseCopyWithImpl(this._self, this._then);

  final SearchSavedItemResponse _self;
  final $Res Function(SearchSavedItemResponse) _then;

/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? url = null,Object? domain = freezed,Object? imageUrl = freezed,Object? enrichmentStatus = null,Object? collection = null,Object? createdAt = null,}) {
  return _then(SearchSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SearchSavedItemCollectionResponse,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchSavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SearchSavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchSavedItemResponse].
extension SearchSavedItemResponsePatterns on SearchSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String url,  String? domain, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'enrichment_status')  String enrichmentStatus,  SearchSavedItemCollectionResponse collection, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchSavedItemResponse() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.domain,_that.imageUrl,_that.enrichmentStatus,_that.collection,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String url,  String? domain, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'enrichment_status')  String enrichmentStatus,  SearchSavedItemCollectionResponse collection, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _SearchSavedItemResponse():
return $default(_that.id,_that.title,_that.url,_that.domain,_that.imageUrl,_that.enrichmentStatus,_that.collection,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String url,  String? domain, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'enrichment_status')  String enrichmentStatus,  SearchSavedItemCollectionResponse collection, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SearchSavedItemResponse() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.domain,_that.imageUrl,_that.enrichmentStatus,_that.collection,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchSavedItemResponse implements SearchSavedItemResponse {
  const _SearchSavedItemResponse({required this.id, this.title, required this.url, this.domain, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'enrichment_status') required this.enrichmentStatus, required this.collection, @JsonKey(name: 'created_at') required this.createdAt});
  factory _SearchSavedItemResponse.fromJson(Map<String, dynamic> json) => _$SearchSavedItemResponseFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String url;
@override final  String? domain;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'enrichment_status') final  String enrichmentStatus;
@override final  SearchSavedItemCollectionResponse collection;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchSavedItemResponseCopyWith<_SearchSavedItemResponse> get copyWith => __$SearchSavedItemResponseCopyWithImpl<_SearchSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchSavedItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.enrichmentStatus, enrichmentStatus) || other.enrichmentStatus == enrichmentStatus)&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,url,domain,imageUrl,enrichmentStatus,collection,createdAt);
}

@override
String toString() {
    return 'SearchSavedItemResponse(id: $id, title: $title, url: $url, domain: $domain, imageUrl: $imageUrl, enrichmentStatus: $enrichmentStatus, collection: $collection, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SearchSavedItemResponseCopyWith<$Res> implements $SearchSavedItemResponseCopyWith<$Res> {
  factory _$SearchSavedItemResponseCopyWith(_SearchSavedItemResponse value, $Res Function(_SearchSavedItemResponse) _then) = __$SearchSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String url, String? domain,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'enrichment_status') String enrichmentStatus, SearchSavedItemCollectionResponse collection,@JsonKey(name: 'created_at') String createdAt
});


@override $SearchSavedItemCollectionResponseCopyWith<$Res> get collection;

}
/// @nodoc
class __$SearchSavedItemResponseCopyWithImpl<$Res>
    implements _$SearchSavedItemResponseCopyWith<$Res> {
  __$SearchSavedItemResponseCopyWithImpl(this._self, this._then);

  final _SearchSavedItemResponse _self;
  final $Res Function(_SearchSavedItemResponse) _then;

/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? url = null,Object? domain = freezed,Object? imageUrl = freezed,Object? enrichmentStatus = null,Object? collection = null,Object? createdAt = null,}) {
  return _then(_SearchSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,enrichmentStatus: null == enrichmentStatus ? _self.enrichmentStatus : enrichmentStatus // ignore: cast_nullable_to_non_nullable
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as SearchSavedItemCollectionResponse,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SearchSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchSavedItemCollectionResponseCopyWith<$Res> get collection {
  
  return $SearchSavedItemCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// @nodoc
mixin _$SearchCollectionResponse {

 String get id; String get name;
/// Create a copy of SearchCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchCollectionResponseCopyWith<SearchCollectionResponse> get copyWith => _$SearchCollectionResponseCopyWithImpl<SearchCollectionResponse>(this as SearchCollectionResponse, _$identity);

  /// Serializes this SearchCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as SearchCollectionResponse;
  return 'SearchCollectionResponse(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $SearchCollectionResponseCopyWith<$Res>  {
  factory $SearchCollectionResponseCopyWith(SearchCollectionResponse value, $Res Function(SearchCollectionResponse) _then) = _$SearchCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$SearchCollectionResponseCopyWithImpl<$Res>
    implements $SearchCollectionResponseCopyWith<$Res> {
  _$SearchCollectionResponseCopyWithImpl(this._self, this._then);

  final SearchCollectionResponse _self;
  final $Res Function(SearchCollectionResponse) _then;

/// Create a copy of SearchCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(SearchCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchCollectionResponse].
extension SearchCollectionResponsePatterns on SearchCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchCollectionResponse() when $default != null:
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
case _SearchCollectionResponse() when $default != null:
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
case _SearchCollectionResponse():
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
case _SearchCollectionResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchCollectionResponse implements SearchCollectionResponse {
  const _SearchCollectionResponse({required this.id, required this.name});
  factory _SearchCollectionResponse.fromJson(Map<String, dynamic> json) => _$SearchCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of SearchCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchCollectionResponseCopyWith<_SearchCollectionResponse> get copyWith => __$SearchCollectionResponseCopyWithImpl<_SearchCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'SearchCollectionResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SearchCollectionResponseCopyWith<$Res> implements $SearchCollectionResponseCopyWith<$Res> {
  factory _$SearchCollectionResponseCopyWith(_SearchCollectionResponse value, $Res Function(_SearchCollectionResponse) _then) = __$SearchCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$SearchCollectionResponseCopyWithImpl<$Res>
    implements _$SearchCollectionResponseCopyWith<$Res> {
  __$SearchCollectionResponseCopyWithImpl(this._self, this._then);

  final _SearchCollectionResponse _self;
  final $Res Function(_SearchCollectionResponse) _then;

/// Create a copy of SearchCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_SearchCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SearchDataResponse {

@JsonKey(name: 'saved_items') List<SearchSavedItemResponse> get savedItems; List<SearchCollectionResponse> get collections;
/// Create a copy of SearchDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchDataResponseCopyWith<SearchDataResponse> get copyWith => _$SearchDataResponseCopyWithImpl<SearchDataResponse>(this as SearchDataResponse, _$identity);

  /// Serializes this SearchDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchDataResponse&&const DeepCollectionEquality().equals(other.savedItems, _this.savedItems)&&const DeepCollectionEquality().equals(other.collections, _this.collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchDataResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.savedItems),const DeepCollectionEquality().hash(_this.collections));
}

@override
String toString() {
  final _this = this as SearchDataResponse;
  return 'SearchDataResponse(savedItems: ${_this.savedItems}, collections: ${_this.collections})';
}


}

/// @nodoc
abstract mixin class $SearchDataResponseCopyWith<$Res>  {
  factory $SearchDataResponseCopyWith(SearchDataResponse value, $Res Function(SearchDataResponse) _then) = _$SearchDataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'saved_items') List<SearchSavedItemResponse> savedItems, List<SearchCollectionResponse> collections
});




}
/// @nodoc
class _$SearchDataResponseCopyWithImpl<$Res>
    implements $SearchDataResponseCopyWith<$Res> {
  _$SearchDataResponseCopyWithImpl(this._self, this._then);

  final SearchDataResponse _self;
  final $Res Function(SearchDataResponse) _then;

/// Create a copy of SearchDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedItems = null,Object? collections = null,}) {
  return _then(SearchDataResponse(
savedItems: null == savedItems ? _self.savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<SearchSavedItemResponse>,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<SearchCollectionResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchDataResponse].
extension SearchDataResponsePatterns on SearchDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items')  List<SearchSavedItemResponse> savedItems,  List<SearchCollectionResponse> collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchDataResponse() when $default != null:
return $default(_that.savedItems,_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'saved_items')  List<SearchSavedItemResponse> savedItems,  List<SearchCollectionResponse> collections)  $default,) {final _that = this;
switch (_that) {
case _SearchDataResponse():
return $default(_that.savedItems,_that.collections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'saved_items')  List<SearchSavedItemResponse> savedItems,  List<SearchCollectionResponse> collections)?  $default,) {final _that = this;
switch (_that) {
case _SearchDataResponse() when $default != null:
return $default(_that.savedItems,_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchDataResponse implements SearchDataResponse {
  const _SearchDataResponse({@JsonKey(name: 'saved_items') required  List<SearchSavedItemResponse> savedItems, required  List<SearchCollectionResponse> collections}): _savedItems = savedItems,_collections = collections;
  factory _SearchDataResponse.fromJson(Map<String, dynamic> json) => _$SearchDataResponseFromJson(json);

 final  List<SearchSavedItemResponse> _savedItems;
@override@JsonKey(name: 'saved_items') List<SearchSavedItemResponse> get savedItems {
  if (_savedItems is EqualUnmodifiableListView) return _savedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedItems);
}

 final  List<SearchCollectionResponse> _collections;
@override List<SearchCollectionResponse> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}


/// Create a copy of SearchDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchDataResponseCopyWith<_SearchDataResponse> get copyWith => __$SearchDataResponseCopyWithImpl<_SearchDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchDataResponse&&const DeepCollectionEquality().equals(other.savedItems, _savedItems)&&const DeepCollectionEquality().equals(other.collections, _collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_savedItems),const DeepCollectionEquality().hash(_collections));
}

@override
String toString() {
    return 'SearchDataResponse(savedItems: $savedItems, collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$SearchDataResponseCopyWith<$Res> implements $SearchDataResponseCopyWith<$Res> {
  factory _$SearchDataResponseCopyWith(_SearchDataResponse value, $Res Function(_SearchDataResponse) _then) = __$SearchDataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'saved_items') List<SearchSavedItemResponse> savedItems, List<SearchCollectionResponse> collections
});




}
/// @nodoc
class __$SearchDataResponseCopyWithImpl<$Res>
    implements _$SearchDataResponseCopyWith<$Res> {
  __$SearchDataResponseCopyWithImpl(this._self, this._then);

  final _SearchDataResponse _self;
  final $Res Function(_SearchDataResponse) _then;

/// Create a copy of SearchDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedItems = null,Object? collections = null,}) {
  return _then(_SearchDataResponse(
savedItems: null == savedItems ? _self._savedItems : savedItems // ignore: cast_nullable_to_non_nullable
as List<SearchSavedItemResponse>,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<SearchCollectionResponse>,
  ));
}


}


/// @nodoc
mixin _$SearchResponse {

 SearchDataResponse get data; String? get message;
/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResponseCopyWith<SearchResponse> get copyWith => _$SearchResponseCopyWithImpl<SearchResponse>(this as SearchResponse, _$identity);

  /// Serializes this SearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as SearchResponse;
  return 'SearchResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SearchResponseCopyWith<$Res>  {
  factory $SearchResponseCopyWith(SearchResponse value, $Res Function(SearchResponse) _then) = _$SearchResponseCopyWithImpl;
@useResult
$Res call({
 SearchDataResponse data, String? message
});


$SearchDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$SearchResponseCopyWithImpl<$Res>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._self, this._then);

  final SearchResponse _self;
  final $Res Function(SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(SearchResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SearchDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchDataResponseCopyWith<$Res> get data {
  
  return $SearchDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchResponse].
extension SearchResponsePatterns on SearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _SearchResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResponse implements SearchResponse {
  const _SearchResponse({required this.data, this.message});
  factory _SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);

@override final  SearchDataResponse data;
@override final  String? message;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResponseCopyWith<_SearchResponse> get copyWith => __$SearchResponseCopyWithImpl<_SearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'SearchResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SearchResponseCopyWith<$Res> implements $SearchResponseCopyWith<$Res> {
  factory _$SearchResponseCopyWith(_SearchResponse value, $Res Function(_SearchResponse) _then) = __$SearchResponseCopyWithImpl;
@override @useResult
$Res call({
 SearchDataResponse data, String? message
});


@override $SearchDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$SearchResponseCopyWithImpl<$Res>
    implements _$SearchResponseCopyWith<$Res> {
  __$SearchResponseCopyWithImpl(this._self, this._then);

  final _SearchResponse _self;
  final $Res Function(_SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_SearchResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SearchDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchDataResponseCopyWith<$Res> get data {
  
  return $SearchDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
