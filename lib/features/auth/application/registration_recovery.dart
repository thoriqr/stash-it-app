import '../../../../core/error/api_failure.dart';
import '../data/models/register_manual_response.dart';
import '../data/registration_continuation_store.dart';

/// Determines the next step after a sign-up submission.
///
/// Kept separate from the screen so the decision can be tested independently
/// of widget rendering and network interactions.
enum RegistrationStart {
  /// Request a PIN and continue to verification.
  ///
  /// Used for new registrations, reused pending verifications, expired
  /// registration replacements, and unrecognized response statuses.
  requestPin,

  /// Verification is already complete and this device has a continuation
  /// token for the entered email address.
  ///
  /// Proceed directly to finalization without requesting or submitting
  /// another PIN.
  openFinalize,

  /// Verification is complete, but this device has no usable continuation
  /// token for the entered email address.
  ///
  /// The existing verification cannot be continued without its token.
  /// The user must explicitly request registration recovery, complete PIN
  /// verification, and obtain a new continuation token.
  verifiedWithoutToken,
}

/// Determines the next step from a manual registration response.
///
/// Only the `verified` status skips PIN verification. Missing or unrecognized
/// statuses follow the PIN flow to preserve compatibility with responses that
/// do not provide a recognized verification status.
///
/// A stored continuation is used only when its email matches the entered
/// address after applying the same normalization used for registration.
RegistrationStart registrationStartFor({
  required RegisterManualResponse response,
  required StoredRegistrationContinuation? stored,
  required String email,
}) {
  if (!response.isVerified) return RegistrationStart.requestPin;

  if (stored != null && stored.email == normalizeRegistrationEmail(email)) {
    return RegistrationStart.openFinalize;
  }

  return RegistrationStart.verifiedWithoutToken;
}

/// Describes the outcome of a refused continuation read or finalization.
enum ContinuationOutcome {
  /// The continuation has already been consumed and registration is complete.
  /// The user should sign in rather than restart registration.
  consumed,

  /// The continuation is no longer valid or the registration cannot continue.
  /// The user must request a replacement and complete verification again.
  restartRequired,

  /// The outcome cannot be determined reliably.
  ///
  /// Keep the stored token because the failure does not establish whether it
  /// is still valid or has already been consumed.
  unconfirmed,
}

/// Classifies failures from registration continuation and finalization requests.
///
/// Only explicitly recognized terminal outcomes allow the stored token to be
/// discarded. All other failures remain unconfirmed, preventing a transient
/// failure from causing a potentially valid continuation to be lost.
ContinuationOutcome continuationOutcomeFor(ApiFailure failure) {
  return switch (failure) {
    ApiFailureRegistrationContinuationConsumed() =>
      ContinuationOutcome.consumed,

    ApiFailureRegistrationContinuationExpired() ||
    ApiFailureRegistrationContinuationRequired() ||
    ApiFailureRegistrationRestartRequired() ||
    ApiFailureInvalidRegistrationType() => ContinuationOutcome.restartRequired,

    _ => ContinuationOutcome.unconfirmed,
  };
}
