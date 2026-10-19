// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_saved_item_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateSavedItemRequest {

 String get url;
/// Create a copy of CreateSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSavedItemRequestCopyWith<CreateSavedItemRequest> get copyWith => _$CreateSavedItemRequestCopyWithImpl<CreateSavedItemRequest>(this as CreateSavedItemRequest, _$identity);

  /// Serializes this CreateSavedItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateSavedItemRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSavedItemRequest&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateSavedItemRequest;
  return Object.hash(runtimeType,_this.url);
}

@override
String toString() {
  final _this = this as CreateSavedItemRequest;
  return 'CreateSavedItemRequest(url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $CreateSavedItemRequestCopyWith<$Res>  {
  factory $CreateSavedItemRequestCopyWith(CreateSavedItemRequest value, $Res Function(CreateSavedItemRequest) _then) = _$CreateSavedItemRequestCopyWithImpl;
@useResult
$Res call({
 String url
});




}
/// @nodoc
class _$CreateSavedItemRequestCopyWithImpl<$Res>
    implements $CreateSavedItemRequestCopyWith<$Res> {
  _$CreateSavedItemRequestCopyWithImpl(this._self, this._then);

  final CreateSavedItemRequest _self;
  final $Res Function(CreateSavedItemRequest) _then;

/// Create a copy of CreateSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,}) {
  return _then(CreateSavedItemRequest(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateSavedItemRequest].
extension CreateSavedItemRequestPatterns on CreateSavedItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSavedItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSavedItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSavedItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSavedItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSavedItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSavedItemRequest() when $default != null:
return $default(_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url)  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemRequest():
return $default(_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url)?  $default,) {final _that = this;
switch (_that) {
case _CreateSavedItemRequest() when $default != null:
return $default(_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSavedItemRequest implements CreateSavedItemRequest {
  const _CreateSavedItemRequest({required this.url});
  factory _CreateSavedItemRequest.fromJson(Map<String, dynamic> json) => _$CreateSavedItemRequestFromJson(json);

@override final  String url;

/// Create a copy of CreateSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSavedItemRequestCopyWith<_CreateSavedItemRequest> get copyWith => __$CreateSavedItemRequestCopyWithImpl<_CreateSavedItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSavedItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSavedItemRequest&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url);
}

@override
String toString() {
    return 'CreateSavedItemRequest(url: $url)';
}


}

/// @nodoc
abstract mixin class _$CreateSavedItemRequestCopyWith<$Res> implements $CreateSavedItemRequestCopyWith<$Res> {
  factory _$CreateSavedItemRequestCopyWith(_CreateSavedItemRequest value, $Res Function(_CreateSavedItemRequest) _then) = __$CreateSavedItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String url
});




}
/// @nodoc
class __$CreateSavedItemRequestCopyWithImpl<$Res>
    implements _$CreateSavedItemRequestCopyWith<$Res> {
  __$CreateSavedItemRequestCopyWithImpl(this._self, this._then);

  final _CreateSavedItemRequest _self;
  final $Res Function(_CreateSavedItemRequest) _then;

/// Create a copy of CreateSavedItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,}) {
  return _then(_CreateSavedItemRequest(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
