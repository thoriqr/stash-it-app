// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_account_link_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfirmAccountLinkRequest {

@JsonKey(name: 'id_token') String get idToken;
/// Create a copy of ConfirmAccountLinkRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmAccountLinkRequestCopyWith<ConfirmAccountLinkRequest> get copyWith => _$ConfirmAccountLinkRequestCopyWithImpl<ConfirmAccountLinkRequest>(this as ConfirmAccountLinkRequest, _$identity);

  /// Serializes this ConfirmAccountLinkRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfirmAccountLinkRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmAccountLinkRequest&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmAccountLinkRequest;
  return Object.hash(runtimeType,_this.idToken);
}

@override
String toString() {
  final _this = this as ConfirmAccountLinkRequest;
  return 'ConfirmAccountLinkRequest(idToken: ${_this.idToken})';
}


}

/// @nodoc
abstract mixin class $ConfirmAccountLinkRequestCopyWith<$Res>  {
  factory $ConfirmAccountLinkRequestCopyWith(ConfirmAccountLinkRequest value, $Res Function(ConfirmAccountLinkRequest) _then) = _$ConfirmAccountLinkRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class _$ConfirmAccountLinkRequestCopyWithImpl<$Res>
    implements $ConfirmAccountLinkRequestCopyWith<$Res> {
  _$ConfirmAccountLinkRequestCopyWithImpl(this._self, this._then);

  final ConfirmAccountLinkRequest _self;
  final $Res Function(ConfirmAccountLinkRequest) _then;

/// Create a copy of ConfirmAccountLinkRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,}) {
  return _then(ConfirmAccountLinkRequest(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmAccountLinkRequest].
extension ConfirmAccountLinkRequestPatterns on ConfirmAccountLinkRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmAccountLinkRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmAccountLinkRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmAccountLinkRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest() when $default != null:
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)  $default,) {final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest():
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_token')  String idToken)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmAccountLinkRequest() when $default != null:
return $default(_that.idToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmAccountLinkRequest implements ConfirmAccountLinkRequest {
  const _ConfirmAccountLinkRequest({@JsonKey(name: 'id_token') required this.idToken});
  factory _ConfirmAccountLinkRequest.fromJson(Map<String, dynamic> json) => _$ConfirmAccountLinkRequestFromJson(json);

@override@JsonKey(name: 'id_token') final  String idToken;

/// Create a copy of ConfirmAccountLinkRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmAccountLinkRequestCopyWith<_ConfirmAccountLinkRequest> get copyWith => __$ConfirmAccountLinkRequestCopyWithImpl<_ConfirmAccountLinkRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmAccountLinkRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmAccountLinkRequest&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idToken);
}

@override
String toString() {
    return 'ConfirmAccountLinkRequest(idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class _$ConfirmAccountLinkRequestCopyWith<$Res> implements $ConfirmAccountLinkRequestCopyWith<$Res> {
  factory _$ConfirmAccountLinkRequestCopyWith(_ConfirmAccountLinkRequest value, $Res Function(_ConfirmAccountLinkRequest) _then) = __$ConfirmAccountLinkRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class __$ConfirmAccountLinkRequestCopyWithImpl<$Res>
    implements _$ConfirmAccountLinkRequestCopyWith<$Res> {
  __$ConfirmAccountLinkRequestCopyWithImpl(this._self, this._then);

  final _ConfirmAccountLinkRequest _self;
  final $Res Function(_ConfirmAccountLinkRequest) _then;

/// Create a copy of ConfirmAccountLinkRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,}) {
  return _then(_ConfirmAccountLinkRequest(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
