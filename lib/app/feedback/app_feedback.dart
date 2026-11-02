import 'package:flutter/foundation.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Resolves feedback copy against the active localization.
typedef FeedbackMessage = String Function(AppLocalizations localizations);

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
  /// Feedback whose copy is already final and does not depend on the locale.
  const AppFeedback({required this.tone, required this.copy}) : message = null;

  /// Feedback whose copy is selected from the active localization when shown.
  const AppFeedback.localized({required this.tone, required this.message})
    : copy = '';

  /// Determines the visual treatment in `feedback_host.dart`.
  final FeedbackTone tone;

  /// The fixed user-facing message, or an empty string when [message] supplies
  /// the text at presentation time.
  final String copy;

  /// Selects the message from the localization active at presentation time.
  final FeedbackMessage? message;

  /// Resolves the message to display for [localizations].
  String resolve(AppLocalizations localizations) =>
      message?.call(localizations) ?? copy;

  @override
  String toString() =>
      'AppFeedback($tone, ${message == null ? copy : 'localized'})';
}
