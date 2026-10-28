// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_link_confirmation_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountLinkConfirmationResponse {

 String get id; String get provider;@JsonKey(name: 'display_name_snapshot') String get displayNameSnapshot;@JsonKey(name: 'masked_user_email') String get maskedUserEmail;
/// Create a copy of AccountLinkConfirmationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountLinkConfirmationResponseCopyWith<AccountLinkConfirmationResponse> get copyWith => _$AccountLinkConfirmationResponseCopyWithImpl<AccountLinkConfirmationResponse>(this as AccountLinkConfirmationResponse, _$identity);

  /// Serializes this AccountLinkConfirmationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountLinkConfirmationResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountLinkConfirmationResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.displayNameSnapshot, _this.displayNameSnapshot) || other.displayNameSnapshot == _this.displayNameSnapshot)&&(identical(other.maskedUserEmail, _this.maskedUserEmail) || other.maskedUserEmail == _this.maskedUserEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountLinkConfirmationResponse;
  return Object.hash(runtimeType,_this.id,_this.provider,_this.displayNameSnapshot,_this.maskedUserEmail);
}

@override
String toString() {
  final _this = this as AccountLinkConfirmationResponse;
  return 'AccountLinkConfirmationResponse(id: ${_this.id}, provider: ${_this.provider}, displayNameSnapshot: ${_this.displayNameSnapshot}, maskedUserEmail: ${_this.maskedUserEmail})';
}


}

/// @nodoc
abstract mixin class $AccountLinkConfirmationResponseCopyWith<$Res>  {
  factory $AccountLinkConfirmationResponseCopyWith(AccountLinkConfirmationResponse value, $Res Function(AccountLinkConfirmationResponse) _then) = _$AccountLinkConfirmationResponseCopyWithImpl;
@useResult
$Res call({
 String id, String provider,@JsonKey(name: 'display_name_snapshot') String displayNameSnapshot,@JsonKey(name: 'masked_user_email') String maskedUserEmail
});




}
/// @nodoc
class _$AccountLinkConfirmationResponseCopyWithImpl<$Res>
    implements $AccountLinkConfirmationResponseCopyWith<$Res> {
  _$AccountLinkConfirmationResponseCopyWithImpl(this._self, this._then);

  final AccountLinkConfirmationResponse _self;
  final $Res Function(AccountLinkConfirmationResponse) _then;

/// Create a copy of AccountLinkConfirmationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? provider = null,Object? displayNameSnapshot = null,Object? maskedUserEmail = null,}) {
  return _then(AccountLinkConfirmationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,displayNameSnapshot: null == displayNameSnapshot ? _self.displayNameSnapshot : displayNameSnapshot // ignore: cast_nullable_to_non_nullable
as String,maskedUserEmail: null == maskedUserEmail ? _self.maskedUserEmail : maskedUserEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountLinkConfirmationResponse].
extension AccountLinkConfirmationResponsePatterns on AccountLinkConfirmationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountLinkConfirmationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountLinkConfirmationResponse value)  $default,){
final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountLinkConfirmationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String provider, @JsonKey(name: 'display_name_snapshot')  String displayNameSnapshot, @JsonKey(name: 'masked_user_email')  String maskedUserEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse() when $default != null:
return $default(_that.id,_that.provider,_that.displayNameSnapshot,_that.maskedUserEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String provider, @JsonKey(name: 'display_name_snapshot')  String displayNameSnapshot, @JsonKey(name: 'masked_user_email')  String maskedUserEmail)  $default,) {final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse():
return $default(_that.id,_that.provider,_that.displayNameSnapshot,_that.maskedUserEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String provider, @JsonKey(name: 'display_name_snapshot')  String displayNameSnapshot, @JsonKey(name: 'masked_user_email')  String maskedUserEmail)?  $default,) {final _that = this;
switch (_that) {
case _AccountLinkConfirmationResponse() when $default != null:
return $default(_that.id,_that.provider,_that.displayNameSnapshot,_that.maskedUserEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountLinkConfirmationResponse implements AccountLinkConfirmationResponse {
  const _AccountLinkConfirmationResponse({required this.id, required this.provider, @JsonKey(name: 'display_name_snapshot') required this.displayNameSnapshot, @JsonKey(name: 'masked_user_email') required this.maskedUserEmail});
  factory _AccountLinkConfirmationResponse.fromJson(Map<String, dynamic> json) => _$AccountLinkConfirmationResponseFromJson(json);

@override final  String id;
@override final  String provider;
@override@JsonKey(name: 'display_name_snapshot') final  String displayNameSnapshot;
@override@JsonKey(name: 'masked_user_email') final  String maskedUserEmail;

/// Create a copy of AccountLinkConfirmationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountLinkConfirmationResponseCopyWith<_AccountLinkConfirmationResponse> get copyWith => __$AccountLinkConfirmationResponseCopyWithImpl<_AccountLinkConfirmationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountLinkConfirmationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountLinkConfirmationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.displayNameSnapshot, displayNameSnapshot) || other.displayNameSnapshot == displayNameSnapshot)&&(identical(other.maskedUserEmail, maskedUserEmail) || other.maskedUserEmail == maskedUserEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,provider,displayNameSnapshot,maskedUserEmail);
}

@override
String toString() {
    return 'AccountLinkConfirmationResponse(id: $id, provider: $provider, displayNameSnapshot: $displayNameSnapshot, maskedUserEmail: $maskedUserEmail)';
}


}

/// @nodoc
abstract mixin class _$AccountLinkConfirmationResponseCopyWith<$Res> implements $AccountLinkConfirmationResponseCopyWith<$Res> {
  factory _$AccountLinkConfirmationResponseCopyWith(_AccountLinkConfirmationResponse value, $Res Function(_AccountLinkConfirmationResponse) _then) = __$AccountLinkConfirmationResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String provider,@JsonKey(name: 'display_name_snapshot') String displayNameSnapshot,@JsonKey(name: 'masked_user_email') String maskedUserEmail
});




}
/// @nodoc
class __$AccountLinkConfirmationResponseCopyWithImpl<$Res>
    implements _$AccountLinkConfirmationResponseCopyWith<$Res> {
  __$AccountLinkConfirmationResponseCopyWithImpl(this._self, this._then);

  final _AccountLinkConfirmationResponse _self;
  final $Res Function(_AccountLinkConfirmationResponse) _then;

/// Create a copy of AccountLinkConfirmationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? provider = null,Object? displayNameSnapshot = null,Object? maskedUserEmail = null,}) {
  return _then(_AccountLinkConfirmationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,displayNameSnapshot: null == displayNameSnapshot ? _self.displayNameSnapshot : displayNameSnapshot // ignore: cast_nullable_to_non_nullable
as String,maskedUserEmail: null == maskedUserEmail ? _self.maskedUserEmail : maskedUserEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
