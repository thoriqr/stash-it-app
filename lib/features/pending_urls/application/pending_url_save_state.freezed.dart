// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_url_save_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PendingUrlSaveState {

 bool get isRunning; int get processed; int get total; PendingUrlSaveSummary? get lastSummary;
/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingUrlSaveStateCopyWith<PendingUrlSaveState> get copyWith => _$PendingUrlSaveStateCopyWithImpl<PendingUrlSaveState>(this as PendingUrlSaveState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PendingUrlSaveState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingUrlSaveState&&(identical(other.isRunning, _this.isRunning) || other.isRunning == _this.isRunning)&&(identical(other.processed, _this.processed) || other.processed == _this.processed)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.lastSummary, _this.lastSummary) || other.lastSummary == _this.lastSummary));
}


@override
int get hashCode {
  final _this = this as PendingUrlSaveState;
  return Object.hash(runtimeType,_this.isRunning,_this.processed,_this.total,_this.lastSummary);
}

@override
String toString() {
  final _this = this as PendingUrlSaveState;
  return 'PendingUrlSaveState(isRunning: ${_this.isRunning}, processed: ${_this.processed}, total: ${_this.total}, lastSummary: ${_this.lastSummary})';
}


}

/// @nodoc
abstract mixin class $PendingUrlSaveStateCopyWith<$Res>  {
  factory $PendingUrlSaveStateCopyWith(PendingUrlSaveState value, $Res Function(PendingUrlSaveState) _then) = _$PendingUrlSaveStateCopyWithImpl;
@useResult
$Res call({
 bool isRunning, int processed, int total, PendingUrlSaveSummary? lastSummary
});


$PendingUrlSaveSummaryCopyWith<$Res>? get lastSummary;

}
/// @nodoc
class _$PendingUrlSaveStateCopyWithImpl<$Res>
    implements $PendingUrlSaveStateCopyWith<$Res> {
  _$PendingUrlSaveStateCopyWithImpl(this._self, this._then);

  final PendingUrlSaveState _self;
  final $Res Function(PendingUrlSaveState) _then;

/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRunning = null,Object? processed = null,Object? total = null,Object? lastSummary = freezed,}) {
  return _then(PendingUrlSaveState(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,lastSummary: freezed == lastSummary ? _self.lastSummary : lastSummary // ignore: cast_nullable_to_non_nullable
as PendingUrlSaveSummary?,
  ));
}
/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingUrlSaveSummaryCopyWith<$Res>? get lastSummary {
    if (_self.lastSummary == null) {
    return null;
  }

  return $PendingUrlSaveSummaryCopyWith<$Res>(_self.lastSummary!, (value) {
    return _then(_self.copyWith(lastSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [PendingUrlSaveState].
extension PendingUrlSaveStatePatterns on PendingUrlSaveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingUrlSaveState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingUrlSaveState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingUrlSaveState value)  $default,){
final _that = this;
switch (_that) {
case _PendingUrlSaveState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingUrlSaveState value)?  $default,){
final _that = this;
switch (_that) {
case _PendingUrlSaveState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRunning,  int processed,  int total,  PendingUrlSaveSummary? lastSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingUrlSaveState() when $default != null:
return $default(_that.isRunning,_that.processed,_that.total,_that.lastSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRunning,  int processed,  int total,  PendingUrlSaveSummary? lastSummary)  $default,) {final _that = this;
switch (_that) {
case _PendingUrlSaveState():
return $default(_that.isRunning,_that.processed,_that.total,_that.lastSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRunning,  int processed,  int total,  PendingUrlSaveSummary? lastSummary)?  $default,) {final _that = this;
switch (_that) {
case _PendingUrlSaveState() when $default != null:
return $default(_that.isRunning,_that.processed,_that.total,_that.lastSummary);case _:
  return null;

}
}

}

/// @nodoc


class _PendingUrlSaveState implements PendingUrlSaveState {
  const _PendingUrlSaveState({this.isRunning = false, this.processed = 0, this.total = 0, this.lastSummary});
  

@override@JsonKey() final  bool isRunning;
@override@JsonKey() final  int processed;
@override@JsonKey() final  int total;
@override final  PendingUrlSaveSummary? lastSummary;

/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingUrlSaveStateCopyWith<_PendingUrlSaveState> get copyWith => __$PendingUrlSaveStateCopyWithImpl<_PendingUrlSaveState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingUrlSaveState&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total)&&(identical(other.lastSummary, lastSummary) || other.lastSummary == lastSummary));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isRunning,processed,total,lastSummary);
}

@override
String toString() {
    return 'PendingUrlSaveState(isRunning: $isRunning, processed: $processed, total: $total, lastSummary: $lastSummary)';
}


}

/// @nodoc
abstract mixin class _$PendingUrlSaveStateCopyWith<$Res> implements $PendingUrlSaveStateCopyWith<$Res> {
  factory _$PendingUrlSaveStateCopyWith(_PendingUrlSaveState value, $Res Function(_PendingUrlSaveState) _then) = __$PendingUrlSaveStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRunning, int processed, int total, PendingUrlSaveSummary? lastSummary
});


@override $PendingUrlSaveSummaryCopyWith<$Res>? get lastSummary;

}
/// @nodoc
class __$PendingUrlSaveStateCopyWithImpl<$Res>
    implements _$PendingUrlSaveStateCopyWith<$Res> {
  __$PendingUrlSaveStateCopyWithImpl(this._self, this._then);

  final _PendingUrlSaveState _self;
  final $Res Function(_PendingUrlSaveState) _then;

/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRunning = null,Object? processed = null,Object? total = null,Object? lastSummary = freezed,}) {
  return _then(_PendingUrlSaveState(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,lastSummary: freezed == lastSummary ? _self.lastSummary : lastSummary // ignore: cast_nullable_to_non_nullable
as PendingUrlSaveSummary?,
  ));
}

/// Create a copy of PendingUrlSaveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingUrlSaveSummaryCopyWith<$Res>? get lastSummary {
    if (_self.lastSummary == null) {
    return null;
  }

  return $PendingUrlSaveSummaryCopyWith<$Res>(_self.lastSummary!, (value) {
    return _then(_self.copyWith(lastSummary: value));
  });
}
}

/// @nodoc
mixin _$PendingUrlSaveSummary {

 int get total; int get saved; int get knownFailed; int get uncertain; int get notAttempted; int? get remaining; PendingUrlSaveStop get stoppedBy; Duration? get retryAfter;
/// Create a copy of PendingUrlSaveSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingUrlSaveSummaryCopyWith<PendingUrlSaveSummary> get copyWith => _$PendingUrlSaveSummaryCopyWithImpl<PendingUrlSaveSummary>(this as PendingUrlSaveSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PendingUrlSaveSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingUrlSaveSummary&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.knownFailed, _this.knownFailed) || other.knownFailed == _this.knownFailed)&&(identical(other.uncertain, _this.uncertain) || other.uncertain == _this.uncertain)&&(identical(other.notAttempted, _this.notAttempted) || other.notAttempted == _this.notAttempted)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.stoppedBy, _this.stoppedBy) || other.stoppedBy == _this.stoppedBy)&&(identical(other.retryAfter, _this.retryAfter) || other.retryAfter == _this.retryAfter));
}


@override
int get hashCode {
  final _this = this as PendingUrlSaveSummary;
  return Object.hash(runtimeType,_this.total,_this.saved,_this.knownFailed,_this.uncertain,_this.notAttempted,_this.remaining,_this.stoppedBy,_this.retryAfter);
}

@override
String toString() {
  final _this = this as PendingUrlSaveSummary;
  return 'PendingUrlSaveSummary(total: ${_this.total}, saved: ${_this.saved}, knownFailed: ${_this.knownFailed}, uncertain: ${_this.uncertain}, notAttempted: ${_this.notAttempted}, remaining: ${_this.remaining}, stoppedBy: ${_this.stoppedBy}, retryAfter: ${_this.retryAfter})';
}


}

/// @nodoc
abstract mixin class $PendingUrlSaveSummaryCopyWith<$Res>  {
  factory $PendingUrlSaveSummaryCopyWith(PendingUrlSaveSummary value, $Res Function(PendingUrlSaveSummary) _then) = _$PendingUrlSaveSummaryCopyWithImpl;
@useResult
$Res call({
 int total, int saved, int knownFailed, int uncertain, int notAttempted, int? remaining, PendingUrlSaveStop stoppedBy, Duration? retryAfter
});




}
/// @nodoc
class _$PendingUrlSaveSummaryCopyWithImpl<$Res>
    implements $PendingUrlSaveSummaryCopyWith<$Res> {
  _$PendingUrlSaveSummaryCopyWithImpl(this._self, this._then);

  final PendingUrlSaveSummary _self;
  final $Res Function(PendingUrlSaveSummary) _then;

/// Create a copy of PendingUrlSaveSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? saved = null,Object? knownFailed = null,Object? uncertain = null,Object? notAttempted = null,Object? remaining = freezed,Object? stoppedBy = null,Object? retryAfter = freezed,}) {
  return _then(PendingUrlSaveSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as int,knownFailed: null == knownFailed ? _self.knownFailed : knownFailed // ignore: cast_nullable_to_non_nullable
as int,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as int,notAttempted: null == notAttempted ? _self.notAttempted : notAttempted // ignore: cast_nullable_to_non_nullable
as int,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,stoppedBy: null == stoppedBy ? _self.stoppedBy : stoppedBy // ignore: cast_nullable_to_non_nullable
as PendingUrlSaveStop,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingUrlSaveSummary].
extension PendingUrlSaveSummaryPatterns on PendingUrlSaveSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingUrlSaveSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingUrlSaveSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingUrlSaveSummary value)  $default,){
final _that = this;
switch (_that) {
case _PendingUrlSaveSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingUrlSaveSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PendingUrlSaveSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int saved,  int knownFailed,  int uncertain,  int notAttempted,  int? remaining,  PendingUrlSaveStop stoppedBy,  Duration? retryAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingUrlSaveSummary() when $default != null:
return $default(_that.total,_that.saved,_that.knownFailed,_that.uncertain,_that.notAttempted,_that.remaining,_that.stoppedBy,_that.retryAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int saved,  int knownFailed,  int uncertain,  int notAttempted,  int? remaining,  PendingUrlSaveStop stoppedBy,  Duration? retryAfter)  $default,) {final _that = this;
switch (_that) {
case _PendingUrlSaveSummary():
return $default(_that.total,_that.saved,_that.knownFailed,_that.uncertain,_that.notAttempted,_that.remaining,_that.stoppedBy,_that.retryAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int saved,  int knownFailed,  int uncertain,  int notAttempted,  int? remaining,  PendingUrlSaveStop stoppedBy,  Duration? retryAfter)?  $default,) {final _that = this;
switch (_that) {
case _PendingUrlSaveSummary() when $default != null:
return $default(_that.total,_that.saved,_that.knownFailed,_that.uncertain,_that.notAttempted,_that.remaining,_that.stoppedBy,_that.retryAfter);case _:
  return null;

}
}

}

/// @nodoc


class _PendingUrlSaveSummary implements PendingUrlSaveSummary {
  const _PendingUrlSaveSummary({this.total = 0, this.saved = 0, this.knownFailed = 0, this.uncertain = 0, this.notAttempted = 0, this.remaining, this.stoppedBy = PendingUrlSaveStop.none, this.retryAfter});
  

@override@JsonKey() final  int total;
@override@JsonKey() final  int saved;
@override@JsonKey() final  int knownFailed;
@override@JsonKey() final  int uncertain;
@override@JsonKey() final  int notAttempted;
@override final  int? remaining;
@override@JsonKey() final  PendingUrlSaveStop stoppedBy;
@override final  Duration? retryAfter;

/// Create a copy of PendingUrlSaveSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingUrlSaveSummaryCopyWith<_PendingUrlSaveSummary> get copyWith => __$PendingUrlSaveSummaryCopyWithImpl<_PendingUrlSaveSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingUrlSaveSummary&&(identical(other.total, total) || other.total == total)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.knownFailed, knownFailed) || other.knownFailed == knownFailed)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.notAttempted, notAttempted) || other.notAttempted == notAttempted)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.stoppedBy, stoppedBy) || other.stoppedBy == stoppedBy)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,total,saved,knownFailed,uncertain,notAttempted,remaining,stoppedBy,retryAfter);
}

@override
String toString() {
    return 'PendingUrlSaveSummary(total: $total, saved: $saved, knownFailed: $knownFailed, uncertain: $uncertain, notAttempted: $notAttempted, remaining: $remaining, stoppedBy: $stoppedBy, retryAfter: $retryAfter)';
}


}

/// @nodoc
abstract mixin class _$PendingUrlSaveSummaryCopyWith<$Res> implements $PendingUrlSaveSummaryCopyWith<$Res> {
  factory _$PendingUrlSaveSummaryCopyWith(_PendingUrlSaveSummary value, $Res Function(_PendingUrlSaveSummary) _then) = __$PendingUrlSaveSummaryCopyWithImpl;
@override @useResult
$Res call({
 int total, int saved, int knownFailed, int uncertain, int notAttempted, int? remaining, PendingUrlSaveStop stoppedBy, Duration? retryAfter
});




}
/// @nodoc
class __$PendingUrlSaveSummaryCopyWithImpl<$Res>
    implements _$PendingUrlSaveSummaryCopyWith<$Res> {
  __$PendingUrlSaveSummaryCopyWithImpl(this._self, this._then);

  final _PendingUrlSaveSummary _self;
  final $Res Function(_PendingUrlSaveSummary) _then;

/// Create a copy of PendingUrlSaveSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? saved = null,Object? knownFailed = null,Object? uncertain = null,Object? notAttempted = null,Object? remaining = freezed,Object? stoppedBy = null,Object? retryAfter = freezed,}) {
  return _then(_PendingUrlSaveSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as int,knownFailed: null == knownFailed ? _self.knownFailed : knownFailed // ignore: cast_nullable_to_non_nullable
as int,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as int,notAttempted: null == notAttempted ? _self.notAttempted : notAttempted // ignore: cast_nullable_to_non_nullable
as int,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,stoppedBy: null == stoppedBy ? _self.stoppedBy : stoppedBy // ignore: cast_nullable_to_non_nullable
as PendingUrlSaveStop,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
