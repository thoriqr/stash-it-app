import '../../../../core/error/api_failure.dart';

/// Describes the outcome of a refused password-reset continuation.
enum PasswordResetContinuationOutcome {
  /// The continuation was consumed by a successful password reset.
  /// The password has changed, so the user should sign in with the new one.
  consumed,

  /// The continuation is no longer valid.
  /// The user must start a new password-reset flow.
  restartRequired,

  /// The outcome cannot be determined reliably.
  /// Keep the continuation token because the failure does not establish
  /// whether it is still valid or has already been consumed.
  unconfirmed,
}

/// Classifies failures from password-reset continuation and finalization requests.
///
/// Only explicitly recognized terminal outcomes allow the continuation token
/// to be discarded. All other failures remain unconfirmed, preserving the token
/// when a transient failure may have interrupted the request.
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
