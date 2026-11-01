import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';

part 'save_url_controller.g.dart';

/// Copy for a confirmed save.
///
/// Confirmation means only that the item was created. It does not imply that
/// enrichment has finished, metadata exists, or the item has been organized.
const String _savedCopy = 'Saved.';

/// Feedback for a value that does not have a URL shape.
///
/// No request was sent. The message explains the expected format and how to
/// correct the value, without implying that the server rejected it.
///
/// A constant instance also prevents repeated publication of identical
/// feedback while the same notice is still visible.
const AppFeedback _invalidUrlFeedback = AppFeedback(
  tone: FeedbackTone.danger,
  copy:
      "That doesn't look like a valid link. Enter a full http:// or https:// "
      'address.',
);

/// Handles one `POST /saved-items` request per explicit user action.
///
/// ## State
///
/// The boolean state indicates only whether a save is in flight. Outcomes are
/// published through the app-wide feedback channel rather than provider errors,
/// preventing a failed mutation from being retried automatically by Riverpod.
///
/// ## Lifecycle
///
/// The notifier stays alive while a save is in progress, even if the user leaves
/// the screen. This allows the operation to publish its outcome and refresh the
/// listing after the screen is closed.
///
/// ## Request behavior
///
/// Each submission sends at most one request. There is no automatic retry or
/// resubmission after an uncertain outcome. A second call while a request is in
/// flight is ignored rather than queued.
///
/// The authentication interceptor may replay a request after a `401` when
/// session renewal succeeds. That replay follows a request rejected before the
/// save operation ran; it is not a retry of a completed save.
///
/// [build] performs no I/O and cannot fail, so no provider retry override is
/// needed.
@Riverpod(keepAlive: true)
class SaveUrl extends _$SaveUrl {
  @override
  bool build() => false;

  /// Saves [rawUrl] and returns whether the server confirmed the creation.
  ///
  /// A `true` result allows the caller to clear the field. A `false` result
  /// means the value should remain available for correction or another attempt.
  /// Refusals are reported through the feedback channel rather than thrown.
  ///
  /// A submission made while another is in flight is ignored, not queued.
  /// This prevents multiple taps from creating duplicate items.
  ///
  /// The URL is trimmed and checked with [isSubmittableUrl] before submission.
  /// This local check rejects values that clearly cannot be URLs. Other
  /// constraints that the client cannot determine remain subject to server
  /// validation. A locally rejected value never reaches the repository.
  Future<bool> submit(String rawUrl) async {
    if (state) return false;

    final url = rawUrl.trim();
    if (url.isEmpty) return false;

    // Reject invalid URL shapes before setting the loading state or sending
    // a request.
    if (!isSubmittableUrl(url)) {
      _publish(_invalidUrlFeedback);
      return false;
    }

    state = true;

    try {
      await ref.read(savedItemsRepositoryProvider).create(url: url);

      // The notifier outlives the screen. This check protects against a
      // container that has already been disposed.
      if (!ref.mounted) return true;

      _publish(const AppFeedback(tone: FeedbackTone.success, copy: _savedCopy));

      // The save is confirmed, so the caller can clear the field immediately.
      // Refreshing the listing is a separate operation and must not change the
      // confirmed save result if the refresh fails.
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());

      return true;
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return false;

      final feedback = saveFeedbackFor(
        failure,
        sessionEnded: ref.read(authStateProvider).isSignedOut,
      );
      if (feedback != null) _publish(feedback);

      return false;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// Maps a failed save to client-owned feedback, or returns null when no
/// additional notice should be shown.
///
/// The mapping uses the typed [ApiFailure] variant rather than an error code
/// or server-provided message. The type of failure determines both the tone
/// and the certainty communicated to the user.
///
/// Known refusals are reported as unsuccessful saves. Transport failures and
/// unreadable responses are treated as uncertain because the save may have
/// succeeded even though its result could not be confirmed.
///
/// [sessionEnded] indicates whether the session layer has already taken over
/// the failure. When it has, the router and authentication screen provide
/// their own session-expiry feedback, so a second notice is unnecessary.
AppFeedback? saveFeedbackFor(ApiFailure failure, {required bool sessionEnded}) {
  return switch (failure) {
    // The server rejected the URL. The field still contains the value, so the
    // user can correct it and submit again.
    ApiFailureValidation() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: "That doesn't look like a valid link. Check the URL and try again.",
    ),

    // The request could not be processed because its format was invalid.
    // The message does not incorrectly suggest that the URL itself is invalid.
    ApiFailureMalformedRequest() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: 'Something went wrong sending that link. Try again.',
    ),

    // Uses the server-provided Retry-After duration when available. No
    // countdown is shown when the duration is missing or invalid.
    ApiFailureRateLimited(:final retryAfter) => AppFeedback(
      tone: FeedbackTone.warning,
      copy: retryAfter == null
          ? "You're saving too quickly. Try again shortly."
          : "You're saving too quickly. Try again in ${_waitPhrase(retryAfter)}.",
    ),

    // The save could not be completed. No retry duration is available.
    ApiFailureServerUnavailable() ||
    ApiFailureServerFault() ||
    ApiFailureNotFound() ||
    ApiFailureUserNotFound() ||
    ApiFailureCurrentPasswordInvalid() ||
    ApiFailureCurrentPasswordRequired() ||
    ApiFailureUnexpectedCurrentPassword() ||
    ApiFailurePasswordCredentialAlreadyExists() ||
    ApiFailurePasswordAlreadyChanged() ||
    ApiFailureCollectionNameAlreadyExists() ||
    ApiFailureCollectionNotEmpty() ||
    ApiFailureUnsortedCollectionProtected() ||
    ApiFailurePinEmailDeliveryFailed() ||
    ApiFailureRegistration() ||
    ApiFailureGoogleAuth() ||
    ApiFailurePasswordReset() ||
    ApiFailureCollectionDeleteTargetNotFound() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: "We couldn't save this link just now. Try again shortly.",
    ),

    // The response arrived but could not be read. The save may have succeeded,
    // so the message does not claim that it failed. The user should check the
    // Inbox before deciding whether to try again.
    ApiFailureUnreadableResponse() => const AppFeedback(
      tone: FeedbackTone.uncertain,
      copy:
          "We couldn't read the server's reply, so we can't confirm the save. "
          'Check your Inbox before trying again.',
    ),

    // No response arrived, so the save outcome cannot be confirmed. The user
    // should check the Inbox before deciding whether to submit again.
    ApiFailureTransport() => const AppFeedback(
      tone: FeedbackTone.uncertain,
      copy:
          "We couldn't confirm this save. It may or may not have gone through "
          '— check your Inbox before trying again.',
    ),

    // Session renewal failed, but the original save request was not replayed.
    // The save is known not to have been submitted; the session state is
    // uncertain, so the message does not claim that the session has ended.
    ApiFailureRefreshUncertain() => const AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          "We couldn't renew your session, so that link wasn't saved. "
          'Try again.',
    ),

    // The device could not access the stored credentials, so the save request
    // was not replayed. The session has not necessarily ended.
    ApiFailureCredentialStorage() => const AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          "This device couldn't refresh your session, so that link wasn't "
          'saved. Try again.',
    ),

    // Authentication is required. If the session layer has already handled
    // the expiry, its existing feedback is sufficient.
    ApiFailureAuthRequired() =>
      sessionEnded
          ? null
          : const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to save this link.',
            ),

    // Session-expiry feedback is handled by the session layer.
    ApiFailureSessionEnded() => null,
  };
}

/// Formats a server-provided wait duration using the coarsest unit that does
/// not understate the remaining time.
///
/// The duration is rounded up so the displayed wait does not suggest retrying
/// before the supplied interval has elapsed. No countdown is generated when
/// the server does not provide a duration.
///
/// This helper formats the English singular and plural forms used by this
/// message.
String _waitPhrase(Duration wait) {
  final seconds = wait.inSeconds;
  if (seconds <= 1) return 'a second';
  if (seconds < 60) return '$seconds seconds';

  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return _count(minutes, 'minute');

  return _count((minutes / 60).ceil(), 'hour');
}

String _count(int value, String unit) =>
    value == 1 ? '1 $unit' : '$value ${unit}s';
