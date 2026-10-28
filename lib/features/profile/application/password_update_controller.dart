import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

import '../data/profile_providers.dart';
import 'profile_controller.dart';

part 'password_update_controller.g.dart';

/// What one password create or change produced.
sealed class PasswordUpdateOutcome {
  const PasswordUpdateOutcome();
}

/// The `200` arrived and the loaded profile now records the credential.
final class PasswordUpdateSucceeded extends PasswordUpdateOutcome {
  const PasswordUpdateSucceeded();
}

/// `CURRENT_PASSWORD_INVALID`. The access token was accepted; the submitted
/// current password was not. Shown inline on the current-password field.
final class PasswordUpdateCurrentPasswordInvalid extends PasswordUpdateOutcome {
  const PasswordUpdateCurrentPasswordInvalid();
}

/// `VALIDATION_ERROR`. The new password is outside the backend's 8–128-rune
/// bound. Shown inline on the new-password field.
final class PasswordUpdateValidation extends PasswordUpdateOutcome {
  const PasswordUpdateValidation();
}

/// `PASSWORD_ALREADY_CHANGED`. Another request changed the credential first, so
/// the submitted current password no longer describes it. The form stays open and
/// clears the current-password field.
final class PasswordUpdateAlreadyChanged extends PasswordUpdateOutcome {
  const PasswordUpdateAlreadyChanged();
}

/// A **known not-set** refusal that is not tied to one field. Shown in a message
/// band; the form keeps every value.
final class PasswordUpdateRejected extends PasswordUpdateOutcome {
  const PasswordUpdateRejected(this.message, {this.tone = FeedbackTone.danger});

  /// Client-owned copy. Never a backend `message`.
  final String message;

  /// How the form paints the notice: [FeedbackTone.warning] for a budget or a
  /// session-layer problem, [FeedbackTone.danger] for a confirmed failure.
  final FeedbackTone tone;
}

/// The server's credential state differs from the form's mode. The screen closes,
/// the profile is refetched, and an app-wide notice explains what changed.
final class PasswordUpdateModeConflict extends PasswordUpdateOutcome {
  const PasswordUpdateModeConflict();
}

/// The account behind the token is gone. The screen closes and the profile is
/// refetched. **Never an automatic sign-out.**
final class PasswordUpdateAccountUnavailable extends PasswordUpdateOutcome {
  const PasswordUpdateAccountUnavailable();
}

/// The request may have committed. The screen closes, the profile is refetched,
/// and the notice says the outcome is unconfirmed rather than that the password
/// was unchanged.
final class PasswordUpdateUncertain extends PasswordUpdateOutcome {
  const PasswordUpdateUncertain();
}

/// The session layer refused the request. The screen closes; the router and
/// sign-in screen explain an ended session once.
final class PasswordUpdateSessionRefused extends PasswordUpdateOutcome {
  const PasswordUpdateSessionRefused();
}

/// A second submission arrived while one request was in flight. No request was
/// sent.
final class PasswordUpdateIgnored extends PasswordUpdateOutcome {
  const PasswordUpdateIgnored();
}

/// One `PUT /users/me/password` per explicit submission.
///
/// **The mode is captured by the screen for the whole visit and passed in.** This
/// controller does not read the profile to decide whether to send a current
/// password: the form the user is looking at is the form the request must match,
/// and re-deriving the mode mid-visit could send a body the visible form never
/// showed. The server remains authoritative and answers a mismatch with one of
/// the mode-conflict codes.
///
/// **No optimistic update.** `has_password_credential` is set only after a
/// confirmed `200`. An ambiguous outcome refetches the profile instead of assuming
/// either result, and no copy claims the password is unchanged when the client
/// cannot know.
///
/// **The caller's session is preserved by a change and no sign-out follows a
/// success.** The backend revokes the account's other sessions; already-issued
/// access tokens remain usable until their own expiry, which the change-mode note
/// states.
@Riverpod(keepAlive: true)
class PasswordUpdate extends _$PasswordUpdate {
  @override
  bool build() => false;

  /// Creates a first password when [change] is false, otherwise changes the
  /// existing one.
  ///
  /// In create mode [currentPassword] is ignored and the field is **omitted** from
  /// the body entirely. In change mode it is sent exactly as typed.
  Future<PasswordUpdateOutcome> submit({
    required bool change,
    required String newPassword,
    String? currentPassword,
  }) async {
    if (state) return const PasswordUpdateIgnored();
    state = true;

    // Captured before the request leaves. The profile may belong to a different
    // account by the time the `200` arrives, and this id is the only evidence
    // the completion carries about whose credential was written.
    final accountId = _loadedAccountId();

    try {
      await ref
          .read(profileRepositoryProvider)
          .setPassword(
            newPassword: newPassword,
            currentPassword: change ? currentPassword : null,
          );

      if (!ref.mounted) return const PasswordUpdateSucceeded();

      final applied =
          accountId != null &&
          ref
              .read(profileProvider.notifier)
              .markPasswordCredentialSet(accountId: accountId);

      // A success belonging to an account that is no longer loaded must not
      // announce itself during the next account's session.
      if (applied) {
        _publish(
          AppFeedback(
            tone: FeedbackTone.success,
            copy: change ? 'Password changed.' : 'Password created.',
          ),
        );
      }
      return const PasswordUpdateSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const PasswordUpdateUncertain();
      return _handle(failure, change: change);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// The id of the profile currently loaded, or null when there is none.
  ///
  /// `ref.exists` rather than a plain read: submitting with no loaded profile
  /// must not instantiate the provider and start a read as a side effect. The
  /// password screen cannot submit in that state, and this keeps the controller
  /// safe for any other caller.
  ///
  /// **Only `AsyncData` is a loaded account.** Riverpod carries the previous
  /// value inside an `AsyncLoading`, so `hasValue` would still name the account
  /// whose profile was cleared at a session boundary.
  String? _loadedAccountId() {
    if (!ref.exists(profileProvider)) return null;
    return switch (ref.read(profileProvider)) {
      AsyncData(:final value) => value.id,
      _ => null,
    };
  }

  PasswordUpdateOutcome _handle(ApiFailure failure, {required bool change}) {
    switch (failure) {
      case ApiFailureCurrentPasswordInvalid():
        return const PasswordUpdateCurrentPasswordInvalid();

      case ApiFailureValidation():
        return const PasswordUpdateValidation();

      // A concurrent change won. The submitted current password no longer
      // describes the stored credential, so it is cleared and the user is asked
      // for the current one again. Refetching the profile would not reveal the
      // new password, so this stays on the form rather than closing it.
      case ApiFailurePasswordAlreadyChanged():
        return const PasswordUpdateAlreadyChanged();

      // The credential state is the opposite of the form's mode. These are not
      // field errors: the correction is a fresh profile and the other form. The
      // profile is refetched so the next visit renders the right mode.
      case ApiFailurePasswordCredentialAlreadyExists():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                'A password was already created for this account. Open this '
                'screen again to change it.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const PasswordUpdateModeConflict();

      case ApiFailureCurrentPasswordRequired():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                'Your account already has a password. Open this screen again '
                'to change it.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const PasswordUpdateModeConflict();

      case ApiFailureUnexpectedCurrentPassword():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                'Your account has no password yet. Open this screen again to '
                'create one.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const PasswordUpdateModeConflict();

      // `PASSWORD_WORK_UNAVAILABLE` is mapped here too. The wording is
      // capacity-neutral on purpose: a spent budget and exhausted Argon2id
      // capacity are different causes with the same wait, and describing the
      // latter as too many attempts would blame the user for server load. The
      // countdown is shown only when `Retry-After` supplied one.
      case ApiFailureRateLimited(:final retryAfter):
        return PasswordUpdateRejected(
          retryAfter == null
              ? "We can't set a password right now. Try again shortly."
              : "We can't set a password right now. Try again in "
                    '${retryAfter.inSeconds} seconds.',
          tone: FeedbackTone.warning,
        );

      // The per-user limiter failed closed, or an upstream refused before the
      // handler. Nothing was written and no recovery time is known.
      case ApiFailureServerUnavailable():
        return const PasswordUpdateRejected(
          "We can't set a password right now. Try again shortly.",
        );

      // A commit error, a lost request, or a `2xx` whose body could not be read.
      // None of them establishes the outcome. The profile is refetched so a
      // create that landed is reflected, and the copy claims neither result.
      case ApiFailureServerFault() ||
          ApiFailureTransport() ||
          ApiFailureUnreadableResponse():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy:
                "We couldn't confirm whether your password was set. Open this "
                'screen again before trying again.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const PasswordUpdateUncertain();

      case ApiFailureUserNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This account is no longer available.',
          ),
        );
        ref.read(profileProvider.notifier).reconcile();
        return const PasswordUpdateAccountUnavailable();

      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to set your password.',
            ),
          );
        }
        return const PasswordUpdateSessionRefused();

      case ApiFailureSessionEnded():
        return const PasswordUpdateSessionRefused();

      // The renewal failed ambiguously and the PUT was never replayed. Known
      // not set; the session is the uncertain part, so the credentials are kept
      // and the form stays open for a manual retry.
      case ApiFailureRefreshUncertain():
        return PasswordUpdateRejected(
          "We couldn't renew your session, so your password wasn't "
          '${change ? 'changed' : 'set'}. Try again.',
          tone: FeedbackTone.warning,
        );

      case ApiFailureCredentialStorage():
        return PasswordUpdateRejected(
          "This device couldn't refresh your session, so your password wasn't "
          '${change ? 'changed' : 'set'}. Try again.',
          tone: FeedbackTone.warning,
        );

      // A well-formed client never produces these on this route. Known not set,
      // and nothing the user can correct from this screen.
      case ApiFailureMalformedRequest() ||
          ApiFailureNotFound() ||
          ApiFailureCollectionNameAlreadyExists() ||
          ApiFailureCollectionNotEmpty() ||
          ApiFailureUnsortedCollectionProtected() ||
          ApiFailurePinEmailDeliveryFailed() ||
          ApiFailureRegistration() ||
          ApiFailurePasswordReset() ||
          ApiFailureCollectionDeleteTargetNotFound():
        return const PasswordUpdateRejected(
          "We couldn't set your password. Try again.",
        );
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}
