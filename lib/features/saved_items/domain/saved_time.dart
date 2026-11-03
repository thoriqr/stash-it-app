import 'package:flutter/foundation.dart';

/// The time bucket used to describe when an item was saved.
enum SavedTimeKind {
  /// Less than one minute has elapsed.
  justNow,

  /// Less than one hour has elapsed.
  minutes,

  /// Less than one day has elapsed.
  hours,

  /// At least one day and less than two days have elapsed.
  yesterday,

  /// At least two whole days have elapsed.
  days,
}

/// A locale-independent representation of elapsed saved time.
///
/// The presentation layer converts this value into a localized message. The
/// value carries the bucket and its dynamic count, never display copy.
@immutable
class SavedTime {
  const SavedTime.justNow() : kind = SavedTimeKind.justNow, value = 0;

  const SavedTime.minutes(this.value)
    : assert(value > 0),
      kind = SavedTimeKind.minutes;

  const SavedTime.hours(this.value)
    : assert(value > 0),
      kind = SavedTimeKind.hours;

  const SavedTime.yesterday() : kind = SavedTimeKind.yesterday, value = 0;

  const SavedTime.days(this.value)
    : assert(value >= 2),
      kind = SavedTimeKind.days;

  final SavedTimeKind kind;

  /// Whole minutes, hours or days for the corresponding bucket.
  ///
  /// Zero for [SavedTimeKind.justNow] and [SavedTimeKind.yesterday], which do
  /// not carry a displayed count.
  final int value;

  @override
  bool operator ==(Object other) =>
      other is SavedTime && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'SavedTime(${kind.name}, $value)';
}
