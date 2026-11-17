// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientMetadata {

@JsonKey(includeIfNull: false) String? get title;@JsonKey(includeIfNull: false) String? get description;@JsonKey(name: 'image_url', includeIfNull: false) String? get imageUrl;@JsonKey(includeIfNull: false) String? get platform;
/// Create a copy of ClientMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientMetadataCopyWith<ClientMetadata> get copyWith => _$ClientMetadataCopyWithImpl<ClientMetadata>(this as ClientMetadata, _$identity);

  /// Serializes this ClientMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientMetadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMetadata&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.platform, _this.platform) || other.platform == _this.platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientMetadata;
  return Object.hash(runtimeType,_this.title,_this.description,_this.imageUrl,_this.platform);
}

@override
String toString() {
  final _this = this as ClientMetadata;
  return 'ClientMetadata(title: ${_this.title}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, platform: ${_this.platform})';
}


}

/// @nodoc
abstract mixin class $ClientMetadataCopyWith<$Res>  {
  factory $ClientMetadataCopyWith(ClientMetadata value, $Res Function(ClientMetadata) _then) = _$ClientMetadataCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? title,@JsonKey(includeIfNull: false) String? description,@JsonKey(name: 'image_url', includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? platform
});




}
/// @nodoc
class _$ClientMetadataCopyWithImpl<$Res>
    implements $ClientMetadataCopyWith<$Res> {
  _$ClientMetadataCopyWithImpl(this._self, this._then);

  final ClientMetadata _self;
  final $Res Function(ClientMetadata) _then;

/// Create a copy of ClientMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? platform = freezed,}) {
  return _then(ClientMetadata(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientMetadata].
extension ClientMetadataPatterns on ClientMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientMetadata value)  $default,){
final _that = this;
switch (_that) {
case _ClientMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _ClientMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? title, @JsonKey(includeIfNull: false)  String? description, @JsonKey(name: 'image_url', includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? platform)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientMetadata() when $default != null:
return $default(_that.title,_that.description,_that.imageUrl,_that.platform);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? title, @JsonKey(includeIfNull: false)  String? description, @JsonKey(name: 'image_url', includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? platform)  $default,) {final _that = this;
switch (_that) {
case _ClientMetadata():
return $default(_that.title,_that.description,_that.imageUrl,_that.platform);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? title, @JsonKey(includeIfNull: false)  String? description, @JsonKey(name: 'image_url', includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? platform)?  $default,) {final _that = this;
switch (_that) {
case _ClientMetadata() when $default != null:
return $default(_that.title,_that.description,_that.imageUrl,_that.platform);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientMetadata implements ClientMetadata {
  const _ClientMetadata({@JsonKey(includeIfNull: false) this.title, @JsonKey(includeIfNull: false) this.description, @JsonKey(name: 'image_url', includeIfNull: false) this.imageUrl, @JsonKey(includeIfNull: false) this.platform});
  factory _ClientMetadata.fromJson(Map<String, dynamic> json) => _$ClientMetadataFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? title;
@override@JsonKey(includeIfNull: false) final  String? description;
@override@JsonKey(name: 'image_url', includeIfNull: false) final  String? imageUrl;
@override@JsonKey(includeIfNull: false) final  String? platform;

/// Create a copy of ClientMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientMetadataCopyWith<_ClientMetadata> get copyWith => __$ClientMetadataCopyWithImpl<_ClientMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientMetadata&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,description,imageUrl,platform);
}

@override
String toString() {
    return 'ClientMetadata(title: $title, description: $description, imageUrl: $imageUrl, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$ClientMetadataCopyWith<$Res> implements $ClientMetadataCopyWith<$Res> {
  factory _$ClientMetadataCopyWith(_ClientMetadata value, $Res Function(_ClientMetadata) _then) = __$ClientMetadataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? title,@JsonKey(includeIfNull: false) String? description,@JsonKey(name: 'image_url', includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? platform
});




}
/// @nodoc
class __$ClientMetadataCopyWithImpl<$Res>
    implements _$ClientMetadataCopyWith<$Res> {
  __$ClientMetadataCopyWithImpl(this._self, this._then);

  final _ClientMetadata _self;
  final $Res Function(_ClientMetadata) _then;

/// Create a copy of ClientMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? platform = freezed,}) {
  return _then(_ClientMetadata(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
