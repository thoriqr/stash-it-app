// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiEnvelope<T> {

 T? get data; String? get message; Map<String, dynamic>? get meta;
/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiEnvelopeCopyWith<T, ApiEnvelope<T>> get copyWith => _$ApiEnvelopeCopyWithImpl<T, ApiEnvelope<T>>(this as ApiEnvelope<T>, _$identity);

  /// Serializes this ApiEnvelope to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as ApiEnvelope<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiEnvelope<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.meta, _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiEnvelope<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.message,const DeepCollectionEquality().hash(_this.meta));
}

@override
String toString() {
  final _this = this as ApiEnvelope<T>;
  return 'ApiEnvelope<$T>(data: ${_this.data}, message: ${_this.message}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $ApiEnvelopeCopyWith<T,$Res>  {
  factory $ApiEnvelopeCopyWith(ApiEnvelope<T> value, $Res Function(ApiEnvelope<T>) _then) = _$ApiEnvelopeCopyWithImpl;
@useResult
$Res call({
 T? data, String? message, Map<String, dynamic>? meta
});




}
/// @nodoc
class _$ApiEnvelopeCopyWithImpl<T,$Res>
    implements $ApiEnvelopeCopyWith<T, $Res> {
  _$ApiEnvelopeCopyWithImpl(this._self, this._then);

  final ApiEnvelope<T> _self;
  final $Res Function(ApiEnvelope<T>) _then;

/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? message = freezed,Object? meta = freezed,}) {
  return _then(ApiEnvelope(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiEnvelope].
extension ApiEnvelopePatterns<T> on ApiEnvelope<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiEnvelope<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiEnvelope<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiEnvelope<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data,  String? message,  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data,  String? message,  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _ApiEnvelope():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data,  String? message,  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _ApiEnvelope() when $default != null:
return $default(_that.data,_that.message,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiEnvelope<T> implements ApiEnvelope<T> {
  const _ApiEnvelope({this.data, this.message,  Map<String, dynamic>? meta}): _meta = meta;
  factory _ApiEnvelope.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiEnvelopeFromJson(json,fromJsonT);

@override final  T? data;
@override final  String? message;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiEnvelopeCopyWith<T, _ApiEnvelope<T>> get copyWith => __$ApiEnvelopeCopyWithImpl<T, _ApiEnvelope<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiEnvelopeToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiEnvelope<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),message,const DeepCollectionEquality().hash(_meta));
}

@override
String toString() {
    return 'ApiEnvelope<$T>(data: $data, message: $message, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ApiEnvelopeCopyWith<T,$Res> implements $ApiEnvelopeCopyWith<T, $Res> {
  factory _$ApiEnvelopeCopyWith(_ApiEnvelope<T> value, $Res Function(_ApiEnvelope<T>) _then) = __$ApiEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 T? data, String? message, Map<String, dynamic>? meta
});




}
/// @nodoc
class __$ApiEnvelopeCopyWithImpl<T,$Res>
    implements _$ApiEnvelopeCopyWith<T, $Res> {
  __$ApiEnvelopeCopyWithImpl(this._self, this._then);

  final _ApiEnvelope<T> _self;
  final $Res Function(_ApiEnvelope<T>) _then;

/// Create a copy of ApiEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? message = freezed,Object? meta = freezed,}) {
  return _then(_ApiEnvelope<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
