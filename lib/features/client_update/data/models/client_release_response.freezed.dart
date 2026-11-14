// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_release_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientReleaseEnvelope {

 ClientReleaseCheck? get data; String? get message;
/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientReleaseEnvelopeCopyWith<ClientReleaseEnvelope> get copyWith => _$ClientReleaseEnvelopeCopyWithImpl<ClientReleaseEnvelope>(this as ClientReleaseEnvelope, _$identity);

  /// Serializes this ClientReleaseEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientReleaseEnvelope;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientReleaseEnvelope&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientReleaseEnvelope;
  return Object.hash(runtimeType,_this.data,_this.message);
}

@override
String toString() {
  final _this = this as ClientReleaseEnvelope;
  return 'ClientReleaseEnvelope(data: ${_this.data}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ClientReleaseEnvelopeCopyWith<$Res>  {
  factory $ClientReleaseEnvelopeCopyWith(ClientReleaseEnvelope value, $Res Function(ClientReleaseEnvelope) _then) = _$ClientReleaseEnvelopeCopyWithImpl;
@useResult
$Res call({
 ClientReleaseCheck? data, String? message
});


$ClientReleaseCheckCopyWith<$Res>? get data;

}
/// @nodoc
class _$ClientReleaseEnvelopeCopyWithImpl<$Res>
    implements $ClientReleaseEnvelopeCopyWith<$Res> {
  _$ClientReleaseEnvelopeCopyWithImpl(this._self, this._then);

  final ClientReleaseEnvelope _self;
  final $Res Function(ClientReleaseEnvelope) _then;

/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? message = freezed,}) {
  return _then(ClientReleaseEnvelope(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ClientReleaseCheck?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientReleaseCheckCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $ClientReleaseCheckCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientReleaseEnvelope].
extension ClientReleaseEnvelopePatterns on ClientReleaseEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientReleaseEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientReleaseEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientReleaseEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientReleaseEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ClientReleaseCheck? data,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientReleaseEnvelope() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ClientReleaseCheck? data,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseEnvelope():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ClientReleaseCheck? data,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseEnvelope() when $default != null:
return $default(_that.data,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientReleaseEnvelope implements ClientReleaseEnvelope {
  const _ClientReleaseEnvelope({this.data, this.message});
  factory _ClientReleaseEnvelope.fromJson(Map<String, dynamic> json) => _$ClientReleaseEnvelopeFromJson(json);

@override final  ClientReleaseCheck? data;
@override final  String? message;

/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientReleaseEnvelopeCopyWith<_ClientReleaseEnvelope> get copyWith => __$ClientReleaseEnvelopeCopyWithImpl<_ClientReleaseEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientReleaseEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientReleaseEnvelope&&(identical(other.data, data) || other.data == data)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,message);
}

@override
String toString() {
    return 'ClientReleaseEnvelope(data: $data, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ClientReleaseEnvelopeCopyWith<$Res> implements $ClientReleaseEnvelopeCopyWith<$Res> {
  factory _$ClientReleaseEnvelopeCopyWith(_ClientReleaseEnvelope value, $Res Function(_ClientReleaseEnvelope) _then) = __$ClientReleaseEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 ClientReleaseCheck? data, String? message
});


@override $ClientReleaseCheckCopyWith<$Res>? get data;

}
/// @nodoc
class __$ClientReleaseEnvelopeCopyWithImpl<$Res>
    implements _$ClientReleaseEnvelopeCopyWith<$Res> {
  __$ClientReleaseEnvelopeCopyWithImpl(this._self, this._then);

  final _ClientReleaseEnvelope _self;
  final $Res Function(_ClientReleaseEnvelope) _then;

/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? message = freezed,}) {
  return _then(_ClientReleaseEnvelope(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ClientReleaseCheck?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ClientReleaseEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientReleaseCheckCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $ClientReleaseCheckCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$ClientReleaseCheck {

 String? get status; ClientReleaseDto? get latest;
/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientReleaseCheckCopyWith<ClientReleaseCheck> get copyWith => _$ClientReleaseCheckCopyWithImpl<ClientReleaseCheck>(this as ClientReleaseCheck, _$identity);

  /// Serializes this ClientReleaseCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientReleaseCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientReleaseCheck&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.latest, _this.latest) || other.latest == _this.latest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientReleaseCheck;
  return Object.hash(runtimeType,_this.status,_this.latest);
}

@override
String toString() {
  final _this = this as ClientReleaseCheck;
  return 'ClientReleaseCheck(status: ${_this.status}, latest: ${_this.latest})';
}


}

/// @nodoc
abstract mixin class $ClientReleaseCheckCopyWith<$Res>  {
  factory $ClientReleaseCheckCopyWith(ClientReleaseCheck value, $Res Function(ClientReleaseCheck) _then) = _$ClientReleaseCheckCopyWithImpl;
@useResult
$Res call({
 String? status, ClientReleaseDto? latest
});


$ClientReleaseDtoCopyWith<$Res>? get latest;

}
/// @nodoc
class _$ClientReleaseCheckCopyWithImpl<$Res>
    implements $ClientReleaseCheckCopyWith<$Res> {
  _$ClientReleaseCheckCopyWithImpl(this._self, this._then);

  final ClientReleaseCheck _self;
  final $Res Function(ClientReleaseCheck) _then;

/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? latest = freezed,}) {
  return _then(ClientReleaseCheck(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as ClientReleaseDto?,
  ));
}
/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientReleaseDtoCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $ClientReleaseDtoCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientReleaseCheck].
extension ClientReleaseCheckPatterns on ClientReleaseCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientReleaseCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientReleaseCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientReleaseCheck value)  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientReleaseCheck value)?  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  ClientReleaseDto? latest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientReleaseCheck() when $default != null:
return $default(_that.status,_that.latest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  ClientReleaseDto? latest)  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseCheck():
return $default(_that.status,_that.latest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  ClientReleaseDto? latest)?  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseCheck() when $default != null:
return $default(_that.status,_that.latest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientReleaseCheck implements ClientReleaseCheck {
  const _ClientReleaseCheck({this.status, this.latest});
  factory _ClientReleaseCheck.fromJson(Map<String, dynamic> json) => _$ClientReleaseCheckFromJson(json);

@override final  String? status;
@override final  ClientReleaseDto? latest;

/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientReleaseCheckCopyWith<_ClientReleaseCheck> get copyWith => __$ClientReleaseCheckCopyWithImpl<_ClientReleaseCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientReleaseCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientReleaseCheck&&(identical(other.status, status) || other.status == status)&&(identical(other.latest, latest) || other.latest == latest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,latest);
}

@override
String toString() {
    return 'ClientReleaseCheck(status: $status, latest: $latest)';
}


}

/// @nodoc
abstract mixin class _$ClientReleaseCheckCopyWith<$Res> implements $ClientReleaseCheckCopyWith<$Res> {
  factory _$ClientReleaseCheckCopyWith(_ClientReleaseCheck value, $Res Function(_ClientReleaseCheck) _then) = __$ClientReleaseCheckCopyWithImpl;
@override @useResult
$Res call({
 String? status, ClientReleaseDto? latest
});


@override $ClientReleaseDtoCopyWith<$Res>? get latest;

}
/// @nodoc
class __$ClientReleaseCheckCopyWithImpl<$Res>
    implements _$ClientReleaseCheckCopyWith<$Res> {
  __$ClientReleaseCheckCopyWithImpl(this._self, this._then);

  final _ClientReleaseCheck _self;
  final $Res Function(_ClientReleaseCheck) _then;

/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? latest = freezed,}) {
  return _then(_ClientReleaseCheck(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as ClientReleaseDto?,
  ));
}

/// Create a copy of ClientReleaseCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientReleaseDtoCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $ClientReleaseDtoCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// @nodoc
mixin _$ClientReleaseDto {

 String? get version; int? get build;@JsonKey(name: 'download_url') String? get downloadUrl; String? get sha256;@JsonKey(name: 'file_size_bytes') int? get fileSizeBytes;@JsonKey(name: 'release_notes') String? get releaseNotes;@JsonKey(name: 'published_at') String? get publishedAt;
/// Create a copy of ClientReleaseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientReleaseDtoCopyWith<ClientReleaseDto> get copyWith => _$ClientReleaseDtoCopyWithImpl<ClientReleaseDto>(this as ClientReleaseDto, _$identity);

  /// Serializes this ClientReleaseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientReleaseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientReleaseDto&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.build, _this.build) || other.build == _this.build)&&(identical(other.downloadUrl, _this.downloadUrl) || other.downloadUrl == _this.downloadUrl)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256)&&(identical(other.fileSizeBytes, _this.fileSizeBytes) || other.fileSizeBytes == _this.fileSizeBytes)&&(identical(other.releaseNotes, _this.releaseNotes) || other.releaseNotes == _this.releaseNotes)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientReleaseDto;
  return Object.hash(runtimeType,_this.version,_this.build,_this.downloadUrl,_this.sha256,_this.fileSizeBytes,_this.releaseNotes,_this.publishedAt);
}

@override
String toString() {
  final _this = this as ClientReleaseDto;
  return 'ClientReleaseDto(version: ${_this.version}, build: ${_this.build}, downloadUrl: ${_this.downloadUrl}, sha256: ${_this.sha256}, fileSizeBytes: ${_this.fileSizeBytes}, releaseNotes: ${_this.releaseNotes}, publishedAt: ${_this.publishedAt})';
}


}

/// @nodoc
abstract mixin class $ClientReleaseDtoCopyWith<$Res>  {
  factory $ClientReleaseDtoCopyWith(ClientReleaseDto value, $Res Function(ClientReleaseDto) _then) = _$ClientReleaseDtoCopyWithImpl;
@useResult
$Res call({
 String? version, int? build,@JsonKey(name: 'download_url') String? downloadUrl, String? sha256,@JsonKey(name: 'file_size_bytes') int? fileSizeBytes,@JsonKey(name: 'release_notes') String? releaseNotes,@JsonKey(name: 'published_at') String? publishedAt
});




}
/// @nodoc
class _$ClientReleaseDtoCopyWithImpl<$Res>
    implements $ClientReleaseDtoCopyWith<$Res> {
  _$ClientReleaseDtoCopyWithImpl(this._self, this._then);

  final ClientReleaseDto _self;
  final $Res Function(ClientReleaseDto) _then;

/// Create a copy of ClientReleaseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = freezed,Object? build = freezed,Object? downloadUrl = freezed,Object? sha256 = freezed,Object? fileSizeBytes = freezed,Object? releaseNotes = freezed,Object? publishedAt = freezed,}) {
  return _then(ClientReleaseDto(
version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,build: freezed == build ? _self.build : build // ignore: cast_nullable_to_non_nullable
as int?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientReleaseDto].
extension ClientReleaseDtoPatterns on ClientReleaseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientReleaseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientReleaseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientReleaseDto value)  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientReleaseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClientReleaseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? version,  int? build, @JsonKey(name: 'download_url')  String? downloadUrl,  String? sha256, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes, @JsonKey(name: 'release_notes')  String? releaseNotes, @JsonKey(name: 'published_at')  String? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientReleaseDto() when $default != null:
return $default(_that.version,_that.build,_that.downloadUrl,_that.sha256,_that.fileSizeBytes,_that.releaseNotes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? version,  int? build, @JsonKey(name: 'download_url')  String? downloadUrl,  String? sha256, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes, @JsonKey(name: 'release_notes')  String? releaseNotes, @JsonKey(name: 'published_at')  String? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseDto():
return $default(_that.version,_that.build,_that.downloadUrl,_that.sha256,_that.fileSizeBytes,_that.releaseNotes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? version,  int? build, @JsonKey(name: 'download_url')  String? downloadUrl,  String? sha256, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes, @JsonKey(name: 'release_notes')  String? releaseNotes, @JsonKey(name: 'published_at')  String? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientReleaseDto() when $default != null:
return $default(_that.version,_that.build,_that.downloadUrl,_that.sha256,_that.fileSizeBytes,_that.releaseNotes,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientReleaseDto implements ClientReleaseDto {
  const _ClientReleaseDto({this.version, this.build, @JsonKey(name: 'download_url') this.downloadUrl, this.sha256, @JsonKey(name: 'file_size_bytes') this.fileSizeBytes, @JsonKey(name: 'release_notes') this.releaseNotes, @JsonKey(name: 'published_at') this.publishedAt});
  factory _ClientReleaseDto.fromJson(Map<String, dynamic> json) => _$ClientReleaseDtoFromJson(json);

@override final  String? version;
@override final  int? build;
@override@JsonKey(name: 'download_url') final  String? downloadUrl;
@override final  String? sha256;
@override@JsonKey(name: 'file_size_bytes') final  int? fileSizeBytes;
@override@JsonKey(name: 'release_notes') final  String? releaseNotes;
@override@JsonKey(name: 'published_at') final  String? publishedAt;

/// Create a copy of ClientReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientReleaseDtoCopyWith<_ClientReleaseDto> get copyWith => __$ClientReleaseDtoCopyWithImpl<_ClientReleaseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientReleaseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientReleaseDto&&(identical(other.version, version) || other.version == version)&&(identical(other.build, build) || other.build == build)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,build,downloadUrl,sha256,fileSizeBytes,releaseNotes,publishedAt);
}

@override
String toString() {
    return 'ClientReleaseDto(version: $version, build: $build, downloadUrl: $downloadUrl, sha256: $sha256, fileSizeBytes: $fileSizeBytes, releaseNotes: $releaseNotes, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ClientReleaseDtoCopyWith<$Res> implements $ClientReleaseDtoCopyWith<$Res> {
  factory _$ClientReleaseDtoCopyWith(_ClientReleaseDto value, $Res Function(_ClientReleaseDto) _then) = __$ClientReleaseDtoCopyWithImpl;
@override @useResult
$Res call({
 String? version, int? build,@JsonKey(name: 'download_url') String? downloadUrl, String? sha256,@JsonKey(name: 'file_size_bytes') int? fileSizeBytes,@JsonKey(name: 'release_notes') String? releaseNotes,@JsonKey(name: 'published_at') String? publishedAt
});




}
/// @nodoc
class __$ClientReleaseDtoCopyWithImpl<$Res>
    implements _$ClientReleaseDtoCopyWith<$Res> {
  __$ClientReleaseDtoCopyWithImpl(this._self, this._then);

  final _ClientReleaseDto _self;
  final $Res Function(_ClientReleaseDto) _then;

/// Create a copy of ClientReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = freezed,Object? build = freezed,Object? downloadUrl = freezed,Object? sha256 = freezed,Object? fileSizeBytes = freezed,Object? releaseNotes = freezed,Object? publishedAt = freezed,}) {
  return _then(_ClientReleaseDto(
version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,build: freezed == build ? _self.build : build // ignore: cast_nullable_to_non_nullable
as int?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
