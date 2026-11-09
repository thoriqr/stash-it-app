// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_saved_item_note_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateSavedItemNoteRequest {

 String get note;
/// Create a copy of UpdateSavedItemNoteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSavedItemNoteRequestCopyWith<UpdateSavedItemNoteRequest> get copyWith => _$UpdateSavedItemNoteRequestCopyWithImpl<UpdateSavedItemNoteRequest>(this as UpdateSavedItemNoteRequest, _$identity);

  /// Serializes this UpdateSavedItemNoteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateSavedItemNoteRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSavedItemNoteRequest&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateSavedItemNoteRequest;
  return Object.hash(runtimeType,_this.note);
}

@override
String toString() {
  final _this = this as UpdateSavedItemNoteRequest;
  return 'UpdateSavedItemNoteRequest(note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $UpdateSavedItemNoteRequestCopyWith<$Res>  {
  factory $UpdateSavedItemNoteRequestCopyWith(UpdateSavedItemNoteRequest value, $Res Function(UpdateSavedItemNoteRequest) _then) = _$UpdateSavedItemNoteRequestCopyWithImpl;
@useResult
$Res call({
 String note
});




}
/// @nodoc
class _$UpdateSavedItemNoteRequestCopyWithImpl<$Res>
    implements $UpdateSavedItemNoteRequestCopyWith<$Res> {
  _$UpdateSavedItemNoteRequestCopyWithImpl(this._self, this._then);

  final UpdateSavedItemNoteRequest _self;
  final $Res Function(UpdateSavedItemNoteRequest) _then;

/// Create a copy of UpdateSavedItemNoteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = null,}) {
  return _then(UpdateSavedItemNoteRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateSavedItemNoteRequest].
extension UpdateSavedItemNoteRequestPatterns on UpdateSavedItemNoteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSavedItemNoteRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSavedItemNoteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest() when $default != null:
return $default(_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String note)  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest():
return $default(_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String note)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSavedItemNoteRequest() when $default != null:
return $default(_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateSavedItemNoteRequest implements UpdateSavedItemNoteRequest {
  const _UpdateSavedItemNoteRequest({required this.note});
  factory _UpdateSavedItemNoteRequest.fromJson(Map<String, dynamic> json) => _$UpdateSavedItemNoteRequestFromJson(json);

@override final  String note;

/// Create a copy of UpdateSavedItemNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSavedItemNoteRequestCopyWith<_UpdateSavedItemNoteRequest> get copyWith => __$UpdateSavedItemNoteRequestCopyWithImpl<_UpdateSavedItemNoteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSavedItemNoteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSavedItemNoteRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,note);
}

@override
String toString() {
    return 'UpdateSavedItemNoteRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateSavedItemNoteRequestCopyWith<$Res> implements $UpdateSavedItemNoteRequestCopyWith<$Res> {
  factory _$UpdateSavedItemNoteRequestCopyWith(_UpdateSavedItemNoteRequest value, $Res Function(_UpdateSavedItemNoteRequest) _then) = __$UpdateSavedItemNoteRequestCopyWithImpl;
@override @useResult
$Res call({
 String note
});




}
/// @nodoc
class __$UpdateSavedItemNoteRequestCopyWithImpl<$Res>
    implements _$UpdateSavedItemNoteRequestCopyWith<$Res> {
  __$UpdateSavedItemNoteRequestCopyWithImpl(this._self, this._then);

  final _UpdateSavedItemNoteRequest _self;
  final $Res Function(_UpdateSavedItemNoteRequest) _then;

/// Create a copy of UpdateSavedItemNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = null,}) {
  return _then(_UpdateSavedItemNoteRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
