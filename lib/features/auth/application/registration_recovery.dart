import '../../../../core/error/api_failure.dart';
import '../data/models/register_manual_response.dart';
import '../data/registration_continuation_store.dart';

/// What a sign-up submission must do next.
///
/// A pure rule, separate from the screen, so the decision can be tested without
/// pumping a widget or scripting a transport.
enum RegistrationStart {
  /// Request a PIN and enter the verification flow. This covers a brand-new
  /// registration, a reused pending verification, an expired-registration
  /// replacement, and any response whose status the client does not recognise.
  requestPin,

  /// PIN verification has already completed and this device holds the raw
  /// continuation for the entered address. Go straight to finalization; do not
  /// request or submit another PIN.
  openFinalize,

  /// PIN verification has already completed but this device has no usable
  /// continuation for the entered address. The raw token is never reissued, so
  /// the screen must not enter the PIN flow for this id. The supported recovery
  /// is an explicit `POST /auth/register/recovery/manual` followed by the normal
  /// PIN verification and a new continuation token.
  verifiedWithoutToken,
}

/// Decides what to do with one `POST /auth/register/manual` response.
///
/// `verified` is the only status that suppresses the PIN step. A null status
/// (older backend) and an unknown future status both take the PIN path, which is
/// the behaviour this client shipped before `verification_status` existed.
///
/// A token is applied only when it belongs to the address the user entered. The
/// comparison uses the same normalization the backend applies, so case and
/// surrounding whitespace cannot make a token look like another registration's.
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

/// What a refused continuation read or finalization means for the stored token.
enum ContinuationOutcome {
  /// The token has already been consumed. Finalization is the only consumer, so
  /// the registration completed; the correction is to sign in, not to restart.
  consumed,

  /// The token can never be used again (expired, absent, or the registration is
  /// no longer pending). A replacement can be requested.
  restartRequired,

  /// The refusal cannot be established — a transport failure, an unreadable
  /// reply (including the backend's generic `CONFLICT` for an unknown token),
  /// a budget refusal or a server fault. Keep the token; nothing may be claimed.
  unconfirmed,
}

/// Classifies a failure from `GET /auth/register/continuation` or
/// `POST /auth/register/finalize/manual`.
///
/// Deliberately total: anything not known to be terminal stays unconfirmed, so
/// a transient failure can never cause a valid capability to be discarded.
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
