import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Client-owned copy for a sign-in failure.
///
/// Messages are selected from typed [ApiFailure] values rather than
/// server-provided error text. Rate limits, server unavailability, and
/// connection failures retain distinct messages because they represent
/// different outcomes.
String authSignInMessageFor(
  ApiFailure failure,
  AppLocalizations localizations,
) {
  return switch (failure) {
    // Use the same message for an incorrect password and an unknown email.
    // This prevents the sign-in screen from revealing whether an account exists.
    ApiFailureAuthRequired() => localizations.authSignInInvalidCredentials,

    ApiFailureValidation() => localizations.authSignInValidation,

    ApiFailureRateLimited(:final retryAfter) =>
      retryAfter != null
          ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
          : localizations.genericReadRateLimited,

    ApiFailureServerUnavailable() => localizations.authSignInUnavailable,

    // The server returned a failure response, so the request is known to have
    // failed. Reserve unconfirmed wording for requests with an unknown outcome.
    ApiFailureServerFault() => localizations.genericReadServerFault,

    // These failures belong to other operations and are not expected during
    // sign-in. Keep the mapping exhaustive and use the unreadable-reply fallback.
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
    ApiFailureCollectionDeleteTargetNotFound() ||
    ApiFailureMalformedRequest() ||
    ApiFailurePinEmailDeliveryFailed() ||
    ApiFailureRegistration() ||
    ApiFailureGoogleAuth() ||
    ApiFailurePasswordReset() ||
    ApiFailureUnreadableResponse() => localizations.genericReadUnreadable,

    // The request may have been applied even though no response arrived.
    // Do not imply that the account was left unchanged.
    ApiFailureTransport() => localizations.authSignInUnconfirmed,

    ApiFailureSessionEnded() => localizations.sessionEnded,

    ApiFailureRefreshUncertain() => localizations.authSessionUnconfirmed,

    ApiFailureCredentialStorage() => localizations.authSignInStorageFailed,
  };
}

/// Client-owned messages for registration failures and incomplete outcomes.
///
/// Messages are selected from typed [ApiFailure] values. Each failure retains
/// its own correction, and uncertain outcomes are not presented as confirmed
/// failures. In particular, an unreadable PIN response does not prove that the
/// PIN was not issued or emailed.
String authRegistrationMessageFor(
  ApiFailure failure,
  AppLocalizations localizations,
) {
  return switch (failure) {
    // Registration is complete; direct the user to sign in instead.
    ApiFailureRegistrationAlreadyCompleted() =>
      localizations.authRegistrationAlreadyCompleted,

    // The normal verification is still pending; continue with that flow.
    ApiFailureRegistrationAlreadyPending() =>
      localizations.authRegistrationAlreadyPending,

    // Another registration attempt is already in progress; retry without changing
    // the email address.
    ApiFailureRegistrationRetryable() =>
      localizations.authRegistrationRetryable,

    // This email is already being registered with a different Google account.
    ApiFailureRegistrationIdentityMismatch() =>
      localizations.authRegistrationIdentityMismatch,

    ApiFailureRegistrationRestartRequired() =>
      localizations.authRegistrationRestartRequired,

    // This response provides no countdown, so show a short cooldown message.
    ApiFailureVerificationResendCooldown() => localizations.authPinRecentlySent,

    // PIN creation succeeded, but email delivery could not be confirmed.
    ApiFailurePinEmailDeliveryFailed() => localizations.authPinEmailUnconfirmed,

    ApiFailureRateLimited(:final retryAfter) =>
      retryAfter != null
          ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
          : localizations.genericReadRateLimited,

    ApiFailureServerUnavailable() =>
      localizations.authRegistrationUnavailableShort,

    ApiFailureServerFault() => localizations.authRegistrationServerFault,

    // The request may have been applied even though no response arrived.
    ApiFailureTransport() => localizations.authRegistrationStartUnconfirmed,

    // An unreadable response does not establish whether registration started or
    // a PIN was sent. Ask the user to check the inbox before retrying.
    ApiFailureUnreadableResponse() =>
      localizations.authRegistrationStartUnreadable,

    ApiFailureValidation() => localizations.authCheckEmailThenTryAgain,

    // These outcomes mean the saved continuation cannot be used; start a new flow.
    ApiFailureRegistrationContinuationExpired() ||
    ApiFailureRegistrationContinuationRequired() ||
    ApiFailureInvalidRegistrationType() =>
      localizations.authRegistrationRestartRequired,

    // A consumed continuation means registration is complete; direct the user to
    // sign in.
    ApiFailureRegistrationContinuationConsumed() =>
      localizations.authRegistrationAlreadyCompletedSignIn,

    // These failures are not expected during registration start. Keep the mapping
    // exhaustive and use the general registration error message.
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
    ApiFailureCollectionDeleteTargetNotFound() ||
    ApiFailureMalformedRequest() ||
    ApiFailureAuthRequired() ||
    ApiFailureInvalidVerificationCode() ||
    ApiFailureVerificationCodeAttemptsExceeded() ||
    ApiFailureSessionEnded() ||
    ApiFailureRefreshUncertain() ||
    ApiFailureCredentialStorage() ||
    ApiFailurePasswordReset() ||
    ApiFailureGoogleAuth() => localizations.authRegistrationStartGeneric,
  };
}
