import 'api_error_body.dart';

/// Represents what the client can conclude about a failed API call.
///
/// This is a closed set of outcomes. Presentation code selects behavior from
/// the failure type and must not re-derive it from HTTP status codes or raw
/// API error codes.
///
/// Hand-written because this type never crosses a serialization boundary.
/// Unlike [ApiErrorBody], it does not need generated serialization or
/// value-object methods.
///
/// Backend error messages are intentionally excluded. They are not part of
/// the client-facing contract; all displayed copy is owned by the client.
///
/// The distinction between [ApiFailureServerUnavailable],
/// [ApiFailureServerFault], and [ApiFailureTransport] is important:
/// unavailable and server-fault responses are known outcomes, while a
/// transport failure leaves the outcome uncertain.
sealed class ApiFailure {
  const ApiFailure();
}

/// A request was refused because a rate or usage budget was exhausted.
///
/// [retryAfter] is populated only when the server supplies a valid
/// `Retry-After` header. The client must not calculate a countdown from a
/// configured rate-limit window.
final class ApiFailureRateLimited extends ApiFailure {
  const ApiFailureRateLimited({required this.code, this.retryAfter});

  /// The API error code, retained for logging and tests.
  final String code;

  /// The server-provided wait duration, or null when none was supplied.
  final Duration? retryAfter;
}

/// The server is reachable but temporarily refusing work.
///
/// No recovery duration is known, so presentation must not invent a
/// countdown. Recovery is through a manual retry.
final class ApiFailureServerUnavailable extends ApiFailure {
  const ApiFailureServerUnavailable({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// A registration PIN was persisted, but its email could not be handed
/// off for delivery.
///
/// This is separate from [ApiFailureServerUnavailable] because the server
/// has already changed state and supplies the cooldown before another PIN
/// can be requested.
final class ApiFailurePinEmailDeliveryFailed extends ApiFailure {
  const ApiFailurePinEmailDeliveryFailed({this.retryAfter});

  final Duration? retryAfter;
}

/// The server returned an internal error (`500`).
///
/// For a refresh request, the outcome may still be ambiguous. The session
/// controller handles that case separately and retains the credentials.
final class ApiFailureServerFault extends ApiFailure {
  const ApiFailureServerFault();
}

/// A request was rejected because its body was invalid or could not be parsed.
sealed class ApiFailureRequest extends ApiFailure {
  const ApiFailureRequest();
}

/// A refusal from the manual registration lifecycle.
///
/// These failures share an HTTP status but have different recovery actions.
/// Presentation selects on the concrete variant, not [code].
///
/// This type is sealed so callers can handle the complete registration group
/// in one switch arm while preserving exhaustive matching.
sealed class ApiFailureRegistration extends ApiFailure {
  const ApiFailureRegistration({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `REGISTRATION_ALREADY_COMPLETED` — this address already has a completed
/// registration.
///
/// The user must sign in instead. Retrying registration cannot succeed.
final class ApiFailureRegistrationAlreadyCompleted
    extends ApiFailureRegistration {
  const ApiFailureRegistrationAlreadyCompleted({required super.code});
}

/// `REGISTRATION_ALREADY_PENDING` — normal registration verification is
/// still pending.
///
/// This is neither a restart nor a generic retry. The existing registration
/// is still usable. Continue through `POST /auth/register/manual` with the
/// same email to retrieve its existing verification ID, then resume the
/// normal PIN flow.
///
/// This differs from [ApiFailureRegistrationRetryable], which represents a
/// concurrent insert race, and [ApiFailureRegistrationRestartRequired],
/// which means the registration lifecycle has ended.
final class ApiFailureRegistrationAlreadyPending
    extends ApiFailureRegistration {
  const ApiFailureRegistrationAlreadyPending({required super.code});
}

/// `REGISTRATION_ALREADY_EXISTS` or `ACTIVE_VERIFICATION_CODE_EXISTS` —
/// another concurrent request created the record first.
///
/// The request and address are valid. Retrying the same request is the
/// appropriate correction; the user does not need to change their email.
final class ApiFailureRegistrationRetryable extends ApiFailureRegistration {
  const ApiFailureRegistrationRetryable({required super.code});
}

/// The registration or verification lifecycle has ended.
///
/// Repeating the same request cannot succeed. The user must start a new
/// registration.
final class ApiFailureRegistrationRestartRequired
    extends ApiFailureRegistration {
  const ApiFailureRegistrationRestartRequired({required super.code});
}

/// `VERIFICATION_RESEND_COOLDOWN` — another PIN was sent too recently.
///
/// The server does not provide the remaining cooldown duration, so this
/// variant carries no countdown. The existing PIN remains valid because
/// the refusal happens before another code is reserved or written.
final class ApiFailureVerificationResendCooldown
    extends ApiFailureRegistration {
  const ApiFailureVerificationResendCooldown({required super.code});
}

/// `INVALID_VERIFICATION_CODE` — the submitted PIN did not match.
final class ApiFailureInvalidVerificationCode extends ApiFailureRegistration {
  const ApiFailureInvalidVerificationCode({required super.code});
}

/// `VERIFICATION_CODE_ATTEMPTS_EXCEEDED` — too many incorrect PIN attempts.
final class ApiFailureVerificationCodeAttemptsExceeded
    extends ApiFailureRegistration {
  const ApiFailureVerificationCodeAttemptsExceeded({required super.code});
}

/// `REGISTRATION_CONTINUATION_REQUIRED` — no continuation token was supplied.
final class ApiFailureRegistrationContinuationRequired
    extends ApiFailureRegistration {
  const ApiFailureRegistrationContinuationRequired({required super.code});
}

/// `REGISTRATION_CONTINUATION_CONSUMED` — the token has already been used.
final class ApiFailureRegistrationContinuationConsumed
    extends ApiFailureRegistration {
  const ApiFailureRegistrationContinuationConsumed({required super.code});
}

/// `REGISTRATION_CONTINUATION_EXPIRED` — the token has expired.
final class ApiFailureRegistrationContinuationExpired
    extends ApiFailureRegistration {
  const ApiFailureRegistrationContinuationExpired({required super.code});
}

/// `INVALID_REGISTRATION_TYPE` — the registration is not manual.
final class ApiFailureInvalidRegistrationType extends ApiFailureRegistration {
  const ApiFailureInvalidRegistrationType({required super.code});
}

/// `REGISTRATION_IDENTITY_MISMATCH` — a social registration for this address
/// is already open under a different provider identity.
///
/// The current Google identity cannot take over the existing registration.
/// This is neither a concurrent insert race nor an expired registration.
final class ApiFailureRegistrationIdentityMismatch
    extends ApiFailureRegistration {
  const ApiFailureRegistrationIdentityMismatch({required super.code});
}

/// A refusal from the Google authentication lifecycle.
///
/// These failures are separate from bearer-session and registration failures.
/// The sealed group allows a screen to handle the Google flow as a whole.
sealed class ApiFailureGoogleAuth extends ApiFailure {
  const ApiFailureGoogleAuth({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `INVALID_GOOGLE_TOKEN` — the token failed Google verification.
final class ApiFailureInvalidGoogleToken extends ApiFailureGoogleAuth {
  const ApiFailureInvalidGoogleToken({required super.code});
}

/// `ACCOUNT_LINK_CONFIRMATION_INVALID` — the confirmation is expired,
/// unknown, or already consumed.
///
/// A new Google login is required.
final class ApiFailureAccountLinkConfirmationInvalid
    extends ApiFailureGoogleAuth {
  const ApiFailureAccountLinkConfirmationInvalid({required super.code});
}

/// `ACCOUNT_LINK_IDENTITY_MISMATCH` — the token belongs to a different
/// Google identity than the one associated with the confirmation.
///
/// Retrying with the same token cannot succeed. The correct Google identity
/// can still complete the confirmation.
final class ApiFailureAccountLinkIdentityMismatch extends ApiFailureGoogleAuth {
  const ApiFailureAccountLinkIdentityMismatch({required super.code});
}

/// `ACCOUNT_LINK_SESSION_FAILED` — the account link was committed and the
/// confirmation consumed, but session creation failed.
///
/// Recovery requires a fresh Google login, not another confirmation attempt.
final class ApiFailureAccountLinkSessionFailed extends ApiFailureGoogleAuth {
  const ApiFailureAccountLinkSessionFailed({required super.code});
}

/// A refusal from the password-reset lifecycle.
///
/// These failures have distinct recovery actions and remain separate from
/// [ApiFailureRegistration] so password-reset screens cannot accidentally
/// display registration copy.
///
/// Most use `409`; [ApiFailurePasswordResetContinuationRequired] is a `401`
/// because the required capability header was missing.
sealed class ApiFailurePasswordReset extends ApiFailure {
  const ApiFailurePasswordReset({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `PASSWORD_RESET_ALREADY_PENDING` — another request opened the reset first,
/// and the service's retry also lost the race.
///
/// The existing reset remains active. Repeating the request should return
/// its existing verification ID.
final class ApiFailurePasswordResetAlreadyPending
    extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetAlreadyPending({required super.code});
}

/// `PASSWORD_RESET_NOT_PENDING` — the reset is no longer pending.
///
/// It may have been completed, expired, or replaced. A new reset is required.
final class ApiFailurePasswordResetNotPending extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetNotPending({required super.code});
}

/// `PASSWORD_RESET_EXPIRED` — the reset has passed its 15-minute lifetime.
///
/// A new reset creates a replacement. The previous verification ID and any
/// continuation token it produced can no longer advance the flow.
final class ApiFailurePasswordResetExpired extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetExpired({required super.code});
}

/// `PASSWORD_RESET_CONTINUATION_CONSUMED` — the continuation was used by a
/// successful finalization.
///
/// The password has already been changed. The user must sign in with the
/// new password rather than retry finalization.
final class ApiFailurePasswordResetContinuationConsumed
    extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetContinuationConsumed({required super.code});
}

/// `PASSWORD_RESET_CONTINUATION_REQUIRED` — the continuation header was absent.
///
/// Although this is a `401`, it is a capability-header refusal, not a
/// bearer-session failure. It must not trigger token refresh or be presented
/// as a request to sign in again.
final class ApiFailurePasswordResetContinuationRequired
    extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetContinuationRequired({required super.code});
}

/// `PASSWORD_RESET_CONTINUATION_EXPIRED` — the continuation token has passed
/// its 15-minute lifetime.
///
/// The reset itself may still be pending, but this token can no longer
/// finalize it. A new reset is required.
final class ApiFailurePasswordResetContinuationExpired
    extends ApiFailurePasswordReset {
  const ApiFailurePasswordResetContinuationExpired({required super.code});
}

/// An input failed validation or exceeded a documented constraint.
///
/// [fields] contains field-level details for diagnosis. These messages are
/// not rendered verbatim by the client.
final class ApiFailureValidation extends ApiFailureRequest {
  const ApiFailureValidation(this.fields);

  final List<ApiErrorField> fields;
}

/// `COLLECTION_NAME_ALREADY_EXISTS` — the requested collection name is
/// already used by one of the caller's collections.
///
/// The name is valid, but the user must choose another one. The client
/// cannot determine whether the existing collection is a system or user
/// collection, so presentation must not claim either.
final class ApiFailureCollectionNameAlreadyExists extends ApiFailure {
  const ApiFailureCollectionNameAlreadyExists({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `COLLECTION_NOT_EMPTY` — the collection deletion transaction was rolled
/// back because a saved item was added during the operation.
///
/// The collection and its items remain unchanged. This is a concurrency
/// outcome; the backend remains the authority on collection contents.
final class ApiFailureCollectionNotEmpty extends ApiFailure {
  const ApiFailureCollectionNotEmpty({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `UNSORTED_COLLECTION_PROTECTED` — the delete request targeted Unsorted.
///
/// The server identifies this collection by its system key. Client-side
/// checks are not an authorization boundary, and the request writes nothing.
final class ApiFailureUnsortedCollectionProtected extends ApiFailure {
  const ApiFailureUnsortedCollectionProtected({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `COLLECTION_DELETE_TARGET_NOT_FOUND` — a delete action using `move`
/// specified a destination that is missing or inaccessible.
///
/// The source collection remains intact because the backend validates the
/// destination before moving or deleting anything. The user can choose
/// another destination.
///
/// This is separate from [ApiFailureNotFound], which describes the resource
/// currently being displayed.
final class ApiFailureCollectionDeleteTargetNotFound extends ApiFailure {
  const ApiFailureCollectionDeleteTargetNotFound({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// The request body was malformed or did not specify a supported operation.
///
/// For example, an invalid collection intent does not identify whether the
/// client wants to move items into an existing collection or create a new
/// one. There is no user-correctable name in this case, and it must not be
/// presented as a duplicate-name conflict.
final class ApiFailureMalformedRequest extends ApiFailureRequest {
  const ApiFailureMalformedRequest();
}

/// A response arrived, but its body could not be interpreted as a known
/// API error or decoded into the expected success response shape.
///
/// For reads, the response arrival establishes that the request received a
/// determinate outcome, even though the client cannot use the response.
///
/// For writes, this variant does not establish whether the operation
/// succeeded. It can represent either a non-2xx response the client could
/// not read, or a successful response whose body failed to decode. Those
/// cases have different server-side outcomes, but this variant does not
/// distinguish them. Mutation handling must therefore avoid claiming that
/// the write definitely failed or succeeded.
final class ApiFailureUnreadableResponse extends ApiFailure {
  const ApiFailureUnreadableResponse({this.code});

  /// An unrecognised API error code, when one was present.
  /// Retained for logging only.
  final String? code;
}

/// No response arrived at all.
///
/// The request may or may not have been processed by the server. This is
/// the only failure variant that represents an uncertain transport outcome;
/// presentation must not claim that the item was not saved.
final class ApiFailureTransport extends ApiFailure {
  const ApiFailureTransport();
}

/// The requested resource does not exist or is not visible to this caller.
///
/// This variant is produced only from recognised API error codes, never
/// from a bare `404`. A non-JSON `404`, for example, remains an
/// [ApiFailureUnreadableResponse].
///
/// Different endpoints use different codes for this outcome:
/// - `RESOURCE_NOT_FOUND` from `GET /saved-items/{id}`
/// - `SAVED_ITEM_NOT_FOUND` from `PUT /saved-items/{id}/collection`
/// - `COLLECTION_NOT_FOUND` from the collection's saved-items listing
///
/// The backend intentionally uses the same response for resources owned by
/// another user. Presentation must not claim whether the resource is missing
/// or belongs to someone else.
///
/// For reads, the resource is known to be unavailable. For the move operation,
/// the item is known not to have been moved.
final class ApiFailureNotFound extends ApiFailure {
  const ApiFailureNotFound({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `USER_NOT_FOUND` — the account identified by the access token no longer
/// exists.
///
/// This is distinct from [ApiFailureNotFound], which describes a resource
/// displayed by a screen. The account is unavailable, not the current
/// screen's resource.
///
/// This is not a session expiry and must not cause an automatic sign-out.
/// The access token was valid, and signing in again cannot recreate the
/// missing account.
final class ApiFailureUserNotFound extends ApiFailure {
  const ApiFailureUserNotFound({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `CURRENT_PASSWORD_INVALID` — the submitted current password does not
/// match the stored credential.
///
/// Although the server returns `401`, the access token was accepted.
/// This is not a bearer-token failure and must not trigger token refresh.
/// The user needs to enter the correct current password.
final class ApiFailureCurrentPasswordInvalid extends ApiFailure {
  const ApiFailureCurrentPasswordInvalid({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `CURRENT_PASSWORD_REQUIRED` — the account has a password credential,
/// but the request omitted the current password.
///
/// This is a credential-state mismatch, not a field validation error.
/// The client should reload the profile and display the password-change
/// form instead of asking the user to fill a field that was not shown.
final class ApiFailureCurrentPasswordRequired extends ApiFailure {
  const ApiFailureCurrentPasswordRequired({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `UNEXPECTED_CURRENT_PASSWORD` — the account has no password credential,
/// but the request supplied a current password.
///
/// This is the opposite credential-state mismatch. The client should
/// reload the profile and display the create-password form.
final class ApiFailureUnexpectedCurrentPassword extends ApiFailure {
  const ApiFailureUnexpectedCurrentPassword({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `PASSWORD_CREDENTIAL_ALREADY_EXISTS` — another request created the
/// account's first password before this request.
///
/// This request created nothing. The client should reload the profile and
/// derive the form from the updated credential state.
final class ApiFailurePasswordCredentialAlreadyExists extends ApiFailure {
  const ApiFailurePasswordCredentialAlreadyExists({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// `PASSWORD_ALREADY_CHANGED` — another request changed the credential
/// after this request verified against the previous one.
///
/// The current request's update and session revocation were part of one
/// transaction, which rolled back. Nothing from this request was committed,
/// and the submitted current password is no longer valid for the stored
/// credential.
final class ApiFailurePasswordAlreadyChanged extends ApiFailure {
  const ApiFailurePasswordAlreadyChanged({required this.code});

  /// The API error code, retained for logging and tests.
  final String code;
}

/// The bearer guard refused the request after the interceptor completed
/// any applicable refresh attempt.
///
/// Covers invalid authorization headers, invalid access tokens, and expired
/// access tokens. The remaining user action is to sign in.
///
/// This is a known refusal: the protected operation was not performed.
final class ApiFailureAuthRequired extends ApiFailure {
  const ApiFailureAuthRequired({this.code});

  /// The bearer-guard code, retained for logging and tests.
  final String? code;
}

/// The refresh endpoint refused the request with a terminal session error.
///
/// Only codes classified as terminal refresh failures produce this variant.
/// The backend has already committed the corresponding session state, so
/// the session cannot be recovered by retrying the same refresh token.
final class ApiFailureSessionEnded extends ApiFailure {
  const ApiFailureSessionEnded({required this.code});

  /// The terminal refresh code.
  final String code;
}

/// A refresh failed, but the client cannot determine whether the backend
/// committed the token rotation.
///
/// This can happen when the refresh request loses its response or the
/// server returns an internal error. Retrying the previous refresh token
/// may trigger reuse detection and revoke the session.
///
/// The current policy is to retain the credentials and avoid automatic
/// retries. A later user action may attempt recovery, but retaining the
/// credentials does not guarantee that the session is recoverable.
final class ApiFailureRefreshUncertain extends ApiFailure {
  const ApiFailureRefreshUncertain({required this.cause});

  /// The underlying failure, retained for diagnosis.
  final ApiFailure cause;
}

/// The local credential layer could not persist or provide usable credentials.
///
/// This includes a partially failed token rotation, an unreadable refresh
/// token before a request, or a failure to clear credentials after a
/// terminal session result. In each case, the client cannot safely use the
/// stored session.
///
/// This does not establish that the server-side session has ended.
/// [cause] is retained for diagnosis and must never be displayed.
final class ApiFailureCredentialStorage extends ApiFailure {
  const ApiFailureCredentialStorage({required this.cause});

  /// The underlying platform or storage error.
  final Object cause;
}
