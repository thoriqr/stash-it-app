import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

import '../data/profile_providers.dart';
import 'profile_controller.dart';

part 'display_name_update_controller.g.dart';

/// What one display-name update produced.
sealed class DisplayNameUpdateOutcome {
  const DisplayNameUpdateOutcome();
}

/// The rename committed and the loaded profile now holds the response.
final class DisplayNameUpdateSucceeded extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateSucceeded();
}

/// `VALIDATION_ERROR`. The submitted name is outside the backend's 2–100-rune
/// bound. Shown as the field's own error, because the correction is the value.
final class DisplayNameUpdateValidation extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateValidation();
}

/// A **known not-changed** refusal that is not about the name's shape. The sheet
/// stays open and shows [message] in a notice band, so the typed name survives.
final class DisplayNameUpdateRejected extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateRejected(
    this.message, {
    this.tone = FeedbackTone.danger,
  });

  /// Client-owned copy for the inline message. Never a backend `message`.
  final String message;

  /// How the sheet paints the notice: [FeedbackTone.warning] for a budget or a
  /// session-layer problem, [FeedbackTone.danger] for a confirmed failure.
  final FeedbackTone tone;
}

/// The account behind the token is gone. The sheet closes, the profile is
/// refetched, and an app-wide notice explains the account state.
///
/// **Not a session expiry, and never an automatic sign-out.** The token is valid;
/// the account it names is not.
final class DisplayNameUpdateAccountUnavailable
    extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateAccountUnavailable();
}

/// The request may have committed. The sheet closes, the profile is refetched,
/// and the notice says the outcome is unconfirmed rather than that the name was
/// not saved.
final class DisplayNameUpdateUncertain extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateUncertain();
}

/// The session layer refused the request. The sheet closes; the router and
/// sign-in screen explain an ended session once.
final class DisplayNameUpdateSessionRefused extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateSessionRefused();
}

/// A second save arrived while one request was in flight. No request was sent.
final class DisplayNameUpdateIgnored extends DisplayNameUpdateOutcome {
  const DisplayNameUpdateIgnored();
}

/// One `PATCH /users/me` per explicit Save.
///
/// **The status is a plain `bool`, set synchronously before the first `await`**, so
/// a double tap cannot issue two writes. Keep-alive so a request already sent is
/// not abandoned when the sheet or route rebuilds.
///
/// The success response is the complete profile, so the loaded profile is replaced
/// with it rather than merged. An ambiguous outcome — a `500`, a transport failure,
/// or an unreadable success body — is reconciled by refetching; the name is never
/// reported as unsaved when the client cannot establish that.
@Riverpod(keepAlive: true)
class DisplayNameUpdate extends _$DisplayNameUpdate {
  @override
  bool build() => false;

  /// Renames the account to [displayName] exactly as given.
  ///
  /// [displayName] is not trimmed here. The screen is responsible for the
  /// 2–100-rune check, which mirrors the backend's own bound.
  Future<DisplayNameUpdateOutcome> save(String displayName) async {
    if (state) return const DisplayNameUpdateIgnored();
    state = true;

    try {
      final updated = await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(displayName);

      if (!ref.mounted) return const DisplayNameUpdateSucceeded();

      ref.read(profileProvider.notifier).applyUpdatedProfile(updated);
      _publish(
        const AppFeedback(
          tone: FeedbackTone.success,
          copy: 'Display name updated.',
        ),
      );
      return const DisplayNameUpdateSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const DisplayNameUpdateUncertain();
      return _handle(failure);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  DisplayNameUpdateOutcome _handle(ApiFailure failure) {
    switch (failure) {
      case ApiFailureValidation():
        return const DisplayNameUpdateValidation();

      case ApiFailureRateLimited(:final retryAfter):
        return DisplayNameUpdateRejected(
          retryAfter == null
              ? 'Too many attempts. Try again shortly.'
              : 'Too many attempts. Try again in ${retryAfter.inSeconds} '
                    'seconds.',
          tone: FeedbackTone.warning,
        );

      // The limiter or an upstream refused before the handler ran. No write
      // happened and there is no recovery time, so the sheet stays open.
      case ApiFailureServerUnavailable():
        return const DisplayNameUpdateRejected(
          'Display name changes are temporarily unavailable. Try again '
          'shortly.',
        );

      // A `500` is **not** proof the rename failed: the handler commits the name
      // before reading identities, and a later identity-read failure is reported
      // as a server fault. A transport failure or an unreadable body is equally
      // unestablished. Refetch and say so.
      case ApiFailureServerFault() ||
          ApiFailureTransport() ||
          ApiFailureUnreadableResponse():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy:
                "We couldn't confirm whether your display name was updated. "
                'Check your profile before trying again.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const DisplayNameUpdateUncertain();

      // The account is gone. Refetch so the screen stops showing a stale profile,
      // and do not sign out: the token is valid and signing in cannot recreate
      // the account.
      case ApiFailureUserNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This account is no longer available.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const DisplayNameUpdateAccountUnavailable();

      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to change your display name.',
            ),
          );
        }
        return const DisplayNameUpdateSessionRefused();

      // Only the refresh endpoint emits terminal codes, and the interceptor
      // turns a terminal renewal into the original 401.
      case ApiFailureSessionEnded():
        return const DisplayNameUpdateSessionRefused();

      // The renewal failed ambiguously and the PATCH was never replayed: the 401
      // came from the guard, before the handler. The rename is known not saved,
      // while the session is the uncertain part. Keeping the sheet open keeps
      // the typed name; a retry is manual, never automatic.
      case ApiFailureRefreshUncertain():
        return const DisplayNameUpdateRejected(
          "We couldn't renew your session, so your display name wasn't "
          'changed. Try again.',
          tone: FeedbackTone.warning,
        );

      case ApiFailureCredentialStorage():
        return const DisplayNameUpdateRejected(
          "This device couldn't refresh your session, so your display name "
          "wasn't changed. Try again.",
          tone: FeedbackTone.warning,
        );

      // A well-formed client never produces these on this route. Known
      // not-changed, and nothing in the sheet can correct them.
      case ApiFailureMalformedRequest() ||
          ApiFailureNotFound() ||
          ApiFailureCurrentPasswordInvalid() ||
          ApiFailureCurrentPasswordRequired() ||
          ApiFailureUnexpectedCurrentPassword() ||
          ApiFailurePasswordCredentialAlreadyExists() ||
          ApiFailurePasswordAlreadyChanged() ||
          ApiFailureCollectionNameAlreadyExists() ||
          ApiFailureCollectionNotEmpty() ||
          ApiFailureUnsortedCollectionProtected() ||
          ApiFailureCollectionDeleteTargetNotFound():
        return const DisplayNameUpdateRejected(
          "We couldn't change your display name. Try again.",
        );
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}
