// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move_to_collection_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoveToCollectionCollectionResponse {

 String get id; String get name; String get type;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of MoveToCollectionCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToCollectionCollectionResponseCopyWith<MoveToCollectionCollectionResponse> get copyWith => _$MoveToCollectionCollectionResponseCopyWithImpl<MoveToCollectionCollectionResponse>(this as MoveToCollectionCollectionResponse, _$identity);

  /// Serializes this MoveToCollectionCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveToCollectionCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToCollectionCollectionResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveToCollectionCollectionResponse;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MoveToCollectionCollectionResponse;
  return 'MoveToCollectionCollectionResponse(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MoveToCollectionCollectionResponseCopyWith<$Res>  {
  factory $MoveToCollectionCollectionResponseCopyWith(MoveToCollectionCollectionResponse value, $Res Function(MoveToCollectionCollectionResponse) _then) = _$MoveToCollectionCollectionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$MoveToCollectionCollectionResponseCopyWithImpl<$Res>
    implements $MoveToCollectionCollectionResponseCopyWith<$Res> {
  _$MoveToCollectionCollectionResponseCopyWithImpl(this._self, this._then);

  final MoveToCollectionCollectionResponse _self;
  final $Res Function(MoveToCollectionCollectionResponse) _then;

/// Create a copy of MoveToCollectionCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(MoveToCollectionCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveToCollectionCollectionResponse].
extension MoveToCollectionCollectionResponsePatterns on MoveToCollectionCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveToCollectionCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveToCollectionCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveToCollectionCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse():
return $default(_that.id,_that.name,_that.type,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionCollectionResponse() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveToCollectionCollectionResponse implements MoveToCollectionCollectionResponse {
  const _MoveToCollectionCollectionResponse({required this.id, required this.name, required this.type, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _MoveToCollectionCollectionResponse.fromJson(Map<String, dynamic> json) => _$MoveToCollectionCollectionResponseFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of MoveToCollectionCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveToCollectionCollectionResponseCopyWith<_MoveToCollectionCollectionResponse> get copyWith => __$MoveToCollectionCollectionResponseCopyWithImpl<_MoveToCollectionCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToCollectionCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveToCollectionCollectionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,createdAt,updatedAt);
}

@override
String toString() {
    return 'MoveToCollectionCollectionResponse(id: $id, name: $name, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MoveToCollectionCollectionResponseCopyWith<$Res> implements $MoveToCollectionCollectionResponseCopyWith<$Res> {
  factory _$MoveToCollectionCollectionResponseCopyWith(_MoveToCollectionCollectionResponse value, $Res Function(_MoveToCollectionCollectionResponse) _then) = __$MoveToCollectionCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$MoveToCollectionCollectionResponseCopyWithImpl<$Res>
    implements _$MoveToCollectionCollectionResponseCopyWith<$Res> {
  __$MoveToCollectionCollectionResponseCopyWithImpl(this._self, this._then);

  final _MoveToCollectionCollectionResponse _self;
  final $Res Function(_MoveToCollectionCollectionResponse) _then;

/// Create a copy of MoveToCollectionCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MoveToCollectionCollectionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MoveToCollectionSavedItemResponse {

 String get id; String get url; String? get domain; String? get platform; String? get title;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of MoveToCollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToCollectionSavedItemResponseCopyWith<MoveToCollectionSavedItemResponse> get copyWith => _$MoveToCollectionSavedItemResponseCopyWithImpl<MoveToCollectionSavedItemResponse>(this as MoveToCollectionSavedItemResponse, _$identity);

  /// Serializes this MoveToCollectionSavedItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveToCollectionSavedItemResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToCollectionSavedItemResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveToCollectionSavedItemResponse;
  return Object.hash(runtimeType,_this.id,_this.url,_this.domain,_this.platform,_this.title,_this.collectionId,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MoveToCollectionSavedItemResponse;
  return 'MoveToCollectionSavedItemResponse(id: ${_this.id}, url: ${_this.url}, domain: ${_this.domain}, platform: ${_this.platform}, title: ${_this.title}, collectionId: ${_this.collectionId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MoveToCollectionSavedItemResponseCopyWith<$Res>  {
  factory $MoveToCollectionSavedItemResponseCopyWith(MoveToCollectionSavedItemResponse value, $Res Function(MoveToCollectionSavedItemResponse) _then) = _$MoveToCollectionSavedItemResponseCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$MoveToCollectionSavedItemResponseCopyWithImpl<$Res>
    implements $MoveToCollectionSavedItemResponseCopyWith<$Res> {
  _$MoveToCollectionSavedItemResponseCopyWithImpl(this._self, this._then);

  final MoveToCollectionSavedItemResponse _self;
  final $Res Function(MoveToCollectionSavedItemResponse) _then;

/// Create a copy of MoveToCollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? collectionId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(MoveToCollectionSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveToCollectionSavedItemResponse].
extension MoveToCollectionSavedItemResponsePatterns on MoveToCollectionSavedItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveToCollectionSavedItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveToCollectionSavedItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveToCollectionSavedItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.collectionId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String? domain,  String? platform,  String? title, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse():
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.collectionId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String? domain,  String? platform,  String? title, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionSavedItemResponse() when $default != null:
return $default(_that.id,_that.url,_that.domain,_that.platform,_that.title,_that.collectionId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveToCollectionSavedItemResponse implements MoveToCollectionSavedItemResponse {
  const _MoveToCollectionSavedItemResponse({required this.id, required this.url, this.domain, this.platform, this.title, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _MoveToCollectionSavedItemResponse.fromJson(Map<String, dynamic> json) => _$MoveToCollectionSavedItemResponseFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? domain;
@override final  String? platform;
@override final  String? title;
@override@JsonKey(name: 'collection_id') final  String collectionId;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of MoveToCollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveToCollectionSavedItemResponseCopyWith<_MoveToCollectionSavedItemResponse> get copyWith => __$MoveToCollectionSavedItemResponseCopyWithImpl<_MoveToCollectionSavedItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToCollectionSavedItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveToCollectionSavedItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.title, title) || other.title == title)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,domain,platform,title,collectionId,createdAt,updatedAt);
}

@override
String toString() {
    return 'MoveToCollectionSavedItemResponse(id: $id, url: $url, domain: $domain, platform: $platform, title: $title, collectionId: $collectionId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MoveToCollectionSavedItemResponseCopyWith<$Res> implements $MoveToCollectionSavedItemResponseCopyWith<$Res> {
  factory _$MoveToCollectionSavedItemResponseCopyWith(_MoveToCollectionSavedItemResponse value, $Res Function(_MoveToCollectionSavedItemResponse) _then) = __$MoveToCollectionSavedItemResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? domain, String? platform, String? title,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$MoveToCollectionSavedItemResponseCopyWithImpl<$Res>
    implements _$MoveToCollectionSavedItemResponseCopyWith<$Res> {
  __$MoveToCollectionSavedItemResponseCopyWithImpl(this._self, this._then);

  final _MoveToCollectionSavedItemResponse _self;
  final $Res Function(_MoveToCollectionSavedItemResponse) _then;

/// Create a copy of MoveToCollectionSavedItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? domain = freezed,Object? platform = freezed,Object? title = freezed,Object? collectionId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MoveToCollectionSavedItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: freezed == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MoveToCollectionDataResponse {

 MoveToCollectionCollectionResponse get collection;@JsonKey(name: 'saved_item') MoveToCollectionSavedItemResponse get savedItem;@JsonKey(name: 'collection_created') bool get collectionCreated;@JsonKey(name: 'already_in_collection') bool get alreadyInCollection;
/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToCollectionDataResponseCopyWith<MoveToCollectionDataResponse> get copyWith => _$MoveToCollectionDataResponseCopyWithImpl<MoveToCollectionDataResponse>(this as MoveToCollectionDataResponse, _$identity);

  /// Serializes this MoveToCollectionDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveToCollectionDataResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToCollectionDataResponse&&(identical(other.collection, _this.collection) || other.collection == _this.collection)&&(identical(other.savedItem, _this.savedItem) || other.savedItem == _this.savedItem)&&(identical(other.collectionCreated, _this.collectionCreated) || other.collectionCreated == _this.collectionCreated)&&(identical(other.alreadyInCollection, _this.alreadyInCollection) || other.alreadyInCollection == _this.alreadyInCollection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveToCollectionDataResponse;
  return Object.hash(runtimeType,_this.collection,_this.savedItem,_this.collectionCreated,_this.alreadyInCollection);
}

@override
String toString() {
  final _this = this as MoveToCollectionDataResponse;
  return 'MoveToCollectionDataResponse(collection: ${_this.collection}, savedItem: ${_this.savedItem}, collectionCreated: ${_this.collectionCreated}, alreadyInCollection: ${_this.alreadyInCollection})';
}


}

/// @nodoc
abstract mixin class $MoveToCollectionDataResponseCopyWith<$Res>  {
  factory $MoveToCollectionDataResponseCopyWith(MoveToCollectionDataResponse value, $Res Function(MoveToCollectionDataResponse) _then) = _$MoveToCollectionDataResponseCopyWithImpl;
@useResult
$Res call({
 MoveToCollectionCollectionResponse collection,@JsonKey(name: 'saved_item') MoveToCollectionSavedItemResponse savedItem,@JsonKey(name: 'collection_created') bool collectionCreated,@JsonKey(name: 'already_in_collection') bool alreadyInCollection
});


$MoveToCollectionCollectionResponseCopyWith<$Res> get collection;$MoveToCollectionSavedItemResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class _$MoveToCollectionDataResponseCopyWithImpl<$Res>
    implements $MoveToCollectionDataResponseCopyWith<$Res> {
  _$MoveToCollectionDataResponseCopyWithImpl(this._self, this._then);

  final MoveToCollectionDataResponse _self;
  final $Res Function(MoveToCollectionDataResponse) _then;

/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = null,Object? savedItem = null,Object? collectionCreated = null,Object? alreadyInCollection = null,}) {
  return _then(MoveToCollectionDataResponse(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as MoveToCollectionCollectionResponse,savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as MoveToCollectionSavedItemResponse,collectionCreated: null == collectionCreated ? _self.collectionCreated : collectionCreated // ignore: cast_nullable_to_non_nullable
as bool,alreadyInCollection: null == alreadyInCollection ? _self.alreadyInCollection : alreadyInCollection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionCollectionResponseCopyWith<$Res> get collection {
  
  return $MoveToCollectionCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionSavedItemResponseCopyWith<$Res> get savedItem {
  
  return $MoveToCollectionSavedItemResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [MoveToCollectionDataResponse].
extension MoveToCollectionDataResponsePatterns on MoveToCollectionDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveToCollectionDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveToCollectionDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveToCollectionDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoveToCollectionCollectionResponse collection, @JsonKey(name: 'saved_item')  MoveToCollectionSavedItemResponse savedItem, @JsonKey(name: 'collection_created')  bool collectionCreated, @JsonKey(name: 'already_in_collection')  bool alreadyInCollection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse() when $default != null:
return $default(_that.collection,_that.savedItem,_that.collectionCreated,_that.alreadyInCollection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoveToCollectionCollectionResponse collection, @JsonKey(name: 'saved_item')  MoveToCollectionSavedItemResponse savedItem, @JsonKey(name: 'collection_created')  bool collectionCreated, @JsonKey(name: 'already_in_collection')  bool alreadyInCollection)  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse():
return $default(_that.collection,_that.savedItem,_that.collectionCreated,_that.alreadyInCollection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoveToCollectionCollectionResponse collection, @JsonKey(name: 'saved_item')  MoveToCollectionSavedItemResponse savedItem, @JsonKey(name: 'collection_created')  bool collectionCreated, @JsonKey(name: 'already_in_collection')  bool alreadyInCollection)?  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionDataResponse() when $default != null:
return $default(_that.collection,_that.savedItem,_that.collectionCreated,_that.alreadyInCollection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveToCollectionDataResponse implements MoveToCollectionDataResponse {
  const _MoveToCollectionDataResponse({required this.collection, @JsonKey(name: 'saved_item') required this.savedItem, @JsonKey(name: 'collection_created') required this.collectionCreated, @JsonKey(name: 'already_in_collection') required this.alreadyInCollection});
  factory _MoveToCollectionDataResponse.fromJson(Map<String, dynamic> json) => _$MoveToCollectionDataResponseFromJson(json);

@override final  MoveToCollectionCollectionResponse collection;
@override@JsonKey(name: 'saved_item') final  MoveToCollectionSavedItemResponse savedItem;
@override@JsonKey(name: 'collection_created') final  bool collectionCreated;
@override@JsonKey(name: 'already_in_collection') final  bool alreadyInCollection;

/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveToCollectionDataResponseCopyWith<_MoveToCollectionDataResponse> get copyWith => __$MoveToCollectionDataResponseCopyWithImpl<_MoveToCollectionDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToCollectionDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveToCollectionDataResponse&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.savedItem, savedItem) || other.savedItem == savedItem)&&(identical(other.collectionCreated, collectionCreated) || other.collectionCreated == collectionCreated)&&(identical(other.alreadyInCollection, alreadyInCollection) || other.alreadyInCollection == alreadyInCollection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,collection,savedItem,collectionCreated,alreadyInCollection);
}

@override
String toString() {
    return 'MoveToCollectionDataResponse(collection: $collection, savedItem: $savedItem, collectionCreated: $collectionCreated, alreadyInCollection: $alreadyInCollection)';
}


}

/// @nodoc
abstract mixin class _$MoveToCollectionDataResponseCopyWith<$Res> implements $MoveToCollectionDataResponseCopyWith<$Res> {
  factory _$MoveToCollectionDataResponseCopyWith(_MoveToCollectionDataResponse value, $Res Function(_MoveToCollectionDataResponse) _then) = __$MoveToCollectionDataResponseCopyWithImpl;
@override @useResult
$Res call({
 MoveToCollectionCollectionResponse collection,@JsonKey(name: 'saved_item') MoveToCollectionSavedItemResponse savedItem,@JsonKey(name: 'collection_created') bool collectionCreated,@JsonKey(name: 'already_in_collection') bool alreadyInCollection
});


@override $MoveToCollectionCollectionResponseCopyWith<$Res> get collection;@override $MoveToCollectionSavedItemResponseCopyWith<$Res> get savedItem;

}
/// @nodoc
class __$MoveToCollectionDataResponseCopyWithImpl<$Res>
    implements _$MoveToCollectionDataResponseCopyWith<$Res> {
  __$MoveToCollectionDataResponseCopyWithImpl(this._self, this._then);

  final _MoveToCollectionDataResponse _self;
  final $Res Function(_MoveToCollectionDataResponse) _then;

/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? savedItem = null,Object? collectionCreated = null,Object? alreadyInCollection = null,}) {
  return _then(_MoveToCollectionDataResponse(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as MoveToCollectionCollectionResponse,savedItem: null == savedItem ? _self.savedItem : savedItem // ignore: cast_nullable_to_non_nullable
as MoveToCollectionSavedItemResponse,collectionCreated: null == collectionCreated ? _self.collectionCreated : collectionCreated // ignore: cast_nullable_to_non_nullable
as bool,alreadyInCollection: null == alreadyInCollection ? _self.alreadyInCollection : alreadyInCollection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionCollectionResponseCopyWith<$Res> get collection {
  
  return $MoveToCollectionCollectionResponseCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}/// Create a copy of MoveToCollectionDataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionSavedItemResponseCopyWith<$Res> get savedItem {
  
  return $MoveToCollectionSavedItemResponseCopyWith<$Res>(_self.savedItem, (value) {
    return _then(_self.copyWith(savedItem: value));
  });
}
}


/// @nodoc
mixin _$MoveToCollectionResponse {

 MoveToCollectionDataResponse get data; String? get message;
/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToCollectionResponseCopyWith<MoveToCollectionResponse> get copyWith => _$MoveToCollectionResponseCopyWithImpl<MoveToCollectionResponse>(this as MoveToCollectionResponse, _$identity);

  /// Serializes this MoveToCollectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoveToCollectionResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToCollectionResponse&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoveToCollectionResponse;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as MoveToCollectionResponse;
  return 'MoveToCollectionResponse(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $MoveToCollectionResponseCopyWith<$Res>  {
  factory $MoveToCollectionResponseCopyWith(MoveToCollectionResponse value, $Res Function(MoveToCollectionResponse) _then) = _$MoveToCollectionResponseCopyWithImpl;
@useResult
$Res call({
 MoveToCollectionDataResponse data, String? message
});


$MoveToCollectionDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class _$MoveToCollectionResponseCopyWithImpl<$Res>
    implements $MoveToCollectionResponseCopyWith<$Res> {
  _$MoveToCollectionResponseCopyWithImpl(this._self, this._then);

  final MoveToCollectionResponse _self;
  final $Res Function(MoveToCollectionResponse) _then;

/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(MoveToCollectionResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as MoveToCollectionDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionDataResponseCopyWith<$Res> get data {
  
  return $MoveToCollectionDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [MoveToCollectionResponse].
extension MoveToCollectionResponsePatterns on MoveToCollectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveToCollectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveToCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveToCollectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveToCollectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MoveToCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoveToCollectionDataResponse data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveToCollectionResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoveToCollectionDataResponse data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoveToCollectionDataResponse data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _MoveToCollectionResponse() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveToCollectionResponse implements MoveToCollectionResponse {
  const _MoveToCollectionResponse({required this.data, this.message});
  factory _MoveToCollectionResponse.fromJson(Map<String, dynamic> json) => _$MoveToCollectionResponseFromJson(json);

@override final  MoveToCollectionDataResponse data;
@override final  String? message;

/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveToCollectionResponseCopyWith<_MoveToCollectionResponse> get copyWith => __$MoveToCollectionResponseCopyWithImpl<_MoveToCollectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToCollectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveToCollectionResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'MoveToCollectionResponse(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MoveToCollectionResponseCopyWith<$Res> implements $MoveToCollectionResponseCopyWith<$Res> {
  factory _$MoveToCollectionResponseCopyWith(_MoveToCollectionResponse value, $Res Function(_MoveToCollectionResponse) _then) = __$MoveToCollectionResponseCopyWithImpl;
@override @useResult
$Res call({
 MoveToCollectionDataResponse data, String? message
});


@override $MoveToCollectionDataResponseCopyWith<$Res> get data;

}
/// @nodoc
class __$MoveToCollectionResponseCopyWithImpl<$Res>
    implements _$MoveToCollectionResponseCopyWith<$Res> {
  __$MoveToCollectionResponseCopyWithImpl(this._self, this._then);

  final _MoveToCollectionResponse _self;
  final $Res Function(_MoveToCollectionResponse) _then;

/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? message = freezed,}) {
  return _then(_MoveToCollectionResponse(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as MoveToCollectionDataResponse,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MoveToCollectionResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveToCollectionDataResponseCopyWith<$Res> get data {
  
  return $MoveToCollectionDataResponseCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
