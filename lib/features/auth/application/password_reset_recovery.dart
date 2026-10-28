import '../../../../core/error/api_failure.dart';

/// What a refused password-reset continuation means for the stored token.
enum PasswordResetContinuationOutcome {
  /// The token was consumed by a successful finalization. The password was
  /// changed; the correction is to sign in with it.
  consumed,

  /// The token can never be used again (expired, absent, or the reset is no
  /// longer pending). A new reset is the only recovery.
  restartRequired,

  /// The refusal cannot be established — transport, an unreadable reply, a
  /// budget refusal or a server fault. Keep the token; nothing may be claimed.
  unconfirmed,
}

/// Classifies a failure from `GET /auth/password-reset/continuation` or
/// `POST /auth/password-reset/finalize`.
///
/// Deliberately total: anything not known to be terminal stays unconfirmed, so a
/// transient failure can never discard a valid capability.
PasswordResetContinuationOutcome passwordResetContinuationOutcomeFor(
  ApiFailure failure,
) {
  return switch (failure) {
    ApiFailurePasswordResetContinuationConsumed() =>
      PasswordResetContinuationOutcome.consumed,

    ApiFailurePasswordResetContinuationExpired() ||
    ApiFailurePasswordResetContinuationRequired() ||
    ApiFailurePasswordResetNotPending() ||
    ApiFailurePasswordResetExpired() =>
      PasswordResetContinuationOutcome.restartRequired,

    _ => PasswordResetContinuationOutcome.unconfirmed,
  };
}
