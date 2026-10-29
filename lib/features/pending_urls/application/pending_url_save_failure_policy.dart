import 'package:stash_it_app/core/error/api_failure.dart';

/// What a sequential save run should do after one `POST /saved-items` refused.
///
/// The run moves to the next URL only after a confirmed create. Every refusal
/// therefore stops it:
///
/// - [stop] is a known refusal. The entry stays and the queue stops. This
///   includes [ApiFailureValidation]: a URL the server refuses is a failed save,
///   not a reason to continue with a later one.
/// - [uncertain] is an outcome the client could not establish. The entry stays,
///   is marked uncertain, and the queue stops; the request is never replayed.
///
/// The distinction is only how the stopped entry is recorded. No disposition
/// continues the run.
enum PendingUrlSaveDisposition { stop, uncertain }

/// Resolves one [ApiFailure] into the run's next move.
///
/// The switch is exhaustive over the closed taxonomy. That is the guard: a new
/// [ApiFailure] variant cannot be added without deciding how a bulk save records
/// it.
PendingUrlSaveDisposition pendingUrlSaveDisposition(ApiFailure failure) {
  return switch (failure) {
    // No answer, or a reply this client could not read. For a write neither is
    // proof that the server did not commit. Keep the entry, mark it uncertain,
    // and stop so the run does not accumulate more unconfirmed writes.
    ApiFailureTransport() ||
    ApiFailureUnreadableResponse() => PendingUrlSaveDisposition.uncertain,

    // Every other refusal, including a validation refusal for this URL. The
    // failed entry and everything after it stay local for a later explicit run.
    ApiFailureValidation() ||
    ApiFailureRateLimited() ||
    ApiFailureServerUnavailable() ||
    ApiFailureServerFault() ||
    ApiFailurePinEmailDeliveryFailed() ||
    ApiFailureMalformedRequest() ||
    ApiFailureRegistration() ||
    ApiFailureGoogleAuth() ||
    ApiFailurePasswordReset() ||
    ApiFailureCollectionNameAlreadyExists() ||
    ApiFailureCollectionNotEmpty() ||
    ApiFailureUnsortedCollectionProtected() ||
    ApiFailureCollectionDeleteTargetNotFound() ||
    ApiFailureNotFound() ||
    ApiFailureUserNotFound() ||
    ApiFailureCurrentPasswordInvalid() ||
    ApiFailureCurrentPasswordRequired() ||
    ApiFailureUnexpectedCurrentPassword() ||
    ApiFailurePasswordCredentialAlreadyExists() ||
    ApiFailurePasswordAlreadyChanged() ||
    ApiFailureAuthRequired() ||
    ApiFailureSessionEnded() ||
    ApiFailureRefreshUncertain() ||
    ApiFailureCredentialStorage() => PendingUrlSaveDisposition.stop,
  };
}
