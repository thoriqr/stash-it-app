import 'package:flutter/foundation.dart';

/// Semantic tone used to distinguish feedback outcomes.
enum FeedbackTone {
  /// A save or operation confirmed as successful.
  success,

  /// A known warning, such as an exhausted budget or an expired item.
  ///
  /// Use [uncertain] when the client cannot establish the outcome.
  warning,

  /// The outcome could not be established.
  ///
  /// Used when the client receives no reliable confirmation, including
  /// responses whose bodies cannot be decoded. The hollow mark distinguishes
  /// this state from a known failure.
  uncertain,

  /// An operation confirmed as failed.
  danger,
}

/// Feedback presented to the user, using copy owned by the client.
///
/// Server error messages are intentionally excluded. Callers select the
/// appropriate user-facing copy based on the outcome.
@immutable
class AppFeedback {
  const AppFeedback({required this.tone, required this.copy});

  /// Determines the visual treatment in `feedback_host.dart`.
  final FeedbackTone tone;

  /// The user-facing message.
  final String copy;

  @override
  String toString() => 'AppFeedback($tone, $copy)';
}
