import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

part 'save_url_controller.g.dart';

String _savedMessage(AppLocalizations localizations) => localizations.saved;
String _invalidUrlMessage(AppLocalizations localizations) =>
    localizations.invalidUrlFull;
String _saveValidationMessage(AppLocalizations localizations) =>
    localizations.saveValidation;
String _saveMalformedMessage(AppLocalizations localizations) =>
    localizations.saveMalformed;
String _saveServerUnavailableMessage(AppLocalizations localizations) =>
    localizations.saveServerUnavailable;
String _saveUnreadableMessage(AppLocalizations localizations) =>
    localizations.saveUnreadable;
String _saveTransportMessage(AppLocalizations localizations) =>
    localizations.saveTransport;
String _saveRefreshUncertainMessage(AppLocalizations localizations) =>
    localizations.saveRefreshUncertain;
String _saveCredentialStorageMessage(AppLocalizations localizations) =>
    localizations.saveCredentialStorage;
String _saveAuthRequiredMessage(AppLocalizations localizations) =>
    localizations.saveAuthRequired;

/// Stable feedback instances preserve identity-based replacement behavior.
///
/// Repeated publications of the same static outcome remain one notice rather
/// than restarting its transition and dismissal timer.
const AppFeedback _savedFeedback = AppFeedback.localized(
  tone: FeedbackTone.success,
  message: _savedMessage,
);
const AppFeedback _invalidUrlFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: _invalidUrlMessage,
);
const AppFeedback _saveValidationFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: _saveValidationMessage,
);
const AppFeedback _saveMalformedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: _saveMalformedMessage,
);
const AppFeedback _saveServerUnavailableFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: _saveServerUnavailableMessage,
);
const AppFeedback _saveUnreadableFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: _saveUnreadableMessage,
);
const AppFeedback _saveTransportFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: _saveTransportMessage,
);
const AppFeedback _saveRefreshUncertainFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: _saveRefreshUncertainMessage,
);
const AppFeedback _saveCredentialStorageFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: _saveCredentialStorageMessage,
);
const AppFeedback _saveAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: _saveAuthRequiredMessage,
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

      _publish(_savedFeedback);

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
    ApiFailureValidation() => _saveValidationFeedback,

    // The request could not be processed because its format was invalid.
    // The message does not incorrectly suggest that the URL itself is invalid.
    ApiFailureMalformedRequest() => _saveMalformedFeedback,

    // Uses the server-provided Retry-After duration when available. No
    // countdown is shown when the duration is missing or invalid.
    ApiFailureRateLimited(:final retryAfter) => AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (localizations) {
        if (retryAfter == null) return localizations.saveRateLimitedNoWait;

        final seconds = retryAfter.inSeconds;
        if (seconds <= 1) {
          return localizations.saveRateLimitedWithWait(
            localizations.retryAfterSecond,
          );
        }
        if (seconds < 60) {
          return localizations.saveRateLimitedWithWait(
            localizations.retryAfterSeconds(seconds),
          );
        }

        final minutes = (seconds / 60).ceil();
        if (minutes < 60) {
          return localizations.saveRateLimitedWithWait(
            localizations.retryAfterMinutes(minutes),
          );
        }

        return localizations.saveRateLimitedWithWait(
          localizations.retryAfterHours((seconds / 3600).ceil()),
        );
      },
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
    ApiFailureCollectionDeleteTargetNotFound() =>
      _saveServerUnavailableFeedback,

    // The response arrived but could not be read. The save may have succeeded,
    // so the message does not claim that it failed. The user should check the
    // Inbox before deciding whether to try again.
    ApiFailureUnreadableResponse() => _saveUnreadableFeedback,

    // No response arrived, so the save outcome cannot be confirmed. The user
    // should check the Inbox before deciding whether to submit again.
    ApiFailureTransport() => _saveTransportFeedback,

    // Session renewal failed, but the original save request was not replayed.
    // The save is known not to have been submitted; the session state is
    // uncertain, so the message does not claim that the session has ended.
    ApiFailureRefreshUncertain() => _saveRefreshUncertainFeedback,

    // The device could not access the stored credentials, so the save request
    // was not replayed. The session has not necessarily ended.
    ApiFailureCredentialStorage() => _saveCredentialStorageFeedback,

    // Authentication is required. If the session layer has already handled
    // the expiry, its existing feedback is sufficient.
    ApiFailureAuthRequired() => sessionEnded ? null : _saveAuthRequiredFeedback,

    // Session-expiry feedback is handled by the session layer.
    ApiFailureSessionEnded() => null,
  };
}
