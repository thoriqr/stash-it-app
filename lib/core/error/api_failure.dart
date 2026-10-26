import 'api_error_body.dart';

/// Everything this client can conclude about a failed API call.
///
/// A closed set. Each variant is a decision the client has already made about
/// what it may do next, so presentation code selects on the variant and never
/// re-derives the outcome from an HTTP status or an `error.code`
/// (`AGENTS.md` §2, presentation boundaries).
///
/// Hand-written rather than generated: this type never crosses a serialization
/// boundary, so `copyWith`, `==` and `fromJson` would be generated and never
/// called. `ApiErrorBody` is the DTO and *is* generated.
///
/// **[D22] No variant carries a backend `message`.** Messages are English
/// human-facing prose that is not part of any contract, and every string this
/// app renders is owned by the client. Copy is selected per variant, later, in
/// `en` and `id`.
///
/// **[D15] The distinction between [serverUnavailable], [serverFault] and
/// [transport] is load-bearing, not cosmetic.** The first two are *known not
/// saved*; [transport] is *uncertain*, and only it may tell the user the outcome
/// is unconfirmed. Collapsing them would produce a claim the client cannot make.
sealed class ApiFailure {
  const ApiFailure();
}

/// A budget was spent. [retryAfter] is non-null only when the server actually
/// sent a `Retry-After` header.
///
/// A countdown is presented only from this value. It is never computed from a
/// configured window or invented: a `429` from a limit that knows its own TTL
/// reports it, and nothing else does.
///
/// **[D15] group B. Known not saved.** A refused request writes nothing.
final class ApiFailureRateLimited extends ApiFailure {
  const ApiFailureRateLimited({required this.code, this.retryAfter});

  /// The backend code, e.g. `USER_RATE_LIMIT_EXCEEDED`. Retained for logging
  /// and tests, never for display.
  final String code;

  /// The server's stated wait, or null when it sent none.
  final Duration? retryAfter;
}

/// The server is reachable and refusing work.
///
/// **[D15] group C. Known not saved. No countdown** — no recovery time is known,
/// and a fabricated one would be a guess presented as a fact (`decisions.md`
/// §2.11). Manual retry only ([D23]).
final class ApiFailureServerUnavailable extends ApiFailure {
  const ApiFailureServerUnavailable({required this.code});

  /// The backend code, e.g. `IP_RATE_LIMIT_UNAVAILABLE`.
  final String code;
}

/// A registration PIN was persisted, but the server could not hand its email to
/// the sender.
///
/// This stays separate from [ApiFailureServerUnavailable]: `CreatePIN` has
/// already changed server state and the server supplies the cooldown before a
/// replacement may be requested. The failure carries no backend prose.
final class ApiFailurePinEmailDeliveryFailed extends ApiFailure {
  const ApiFailurePinEmailDeliveryFailed({this.retryAfter});

  final Duration? retryAfter;
}

/// The server failed in a way it reports as its own fault (`500`).
///
/// **[D15] group C. Known not saved.** For a refresh specifically this outcome is
/// *ambiguous* rather than known — see `SessionController`, which keeps the
/// credentials rather than clearing them.
final class ApiFailureServerFault extends ApiFailure {
  const ApiFailureServerFault();
}

/// The request body failed field-level validation, or could not be parsed.
///
/// **[D15] groups D and E. Known not saved.** A well-formed client never produces
/// [ApiFailureMalformedRequest]; reaching it indicates a client defect worth
/// logging.
sealed class ApiFailureRequest extends ApiFailure {
  const ApiFailureRequest();
}

/// A refusal from the manual registration lifecycle.
///
/// The backend answers all of these with `409`, but they do not share a
/// correction, so each is mapped to its own typed variant. Presentation selects
/// on the variant and never on [code]; the code is retained for logging and
/// tests only (`AGENTS.md` §2, presentation boundaries).
///
/// Sealed so a route that cannot reach registration can still cover the whole
/// group in one arm, and so an exhaustive switch over [ApiFailure] stays
/// exhaustive through this hierarchy.
sealed class ApiFailureRegistration extends ApiFailure {
  const ApiFailureRegistration({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `REGISTRATION_ALREADY_COMPLETED` — this address already has a completed
/// registration, so there is no sign-up to start.
///
/// The only correction is to sign in. Retrying registration cannot succeed, and
/// no copy derived from this variant may describe it as a transient conflict.
/// Nothing was created by this request.
final class ApiFailureRegistrationAlreadyCompleted
    extends ApiFailureRegistration {
  const ApiFailureRegistrationAlreadyCompleted({required super.code});
}

/// `REGISTRATION_ALREADY_EXISTS` or `ACTIVE_VERIFICATION_CODE_EXISTS` — a
/// concurrent request won a unique-constraint race this one lost.
///
/// Nothing is wrong with the request or the address: the other request's row is
/// what remains, which is why the same call is expected to succeed if repeated.
/// No copy derived from this variant may ask the user to change the email
/// address. Nothing was written by this request.
final class ApiFailureRegistrationRetryable extends ApiFailureRegistration {
  const ApiFailureRegistrationRetryable({required super.code});
}

/// `VERIFICATION_NOT_PENDING`, `REGISTRATION_NOT_PENDING`, or
/// `REGISTRATION_EXPIRED` — the registration or its verification can no longer
/// accept work.
///
/// The lifecycle is over, so repeating the same request returns the same
/// refusal. The correction is to start a new registration, which may reuse the
/// address once the abandoned one is no longer pending. Nothing was written by
/// this request.
final class ApiFailureRegistrationRestartRequired
    extends ApiFailureRegistration {
  const ApiFailureRegistrationRestartRequired({required super.code});
}

/// `VERIFICATION_RESEND_COOLDOWN` — a PIN was sent too recently to send
/// another.
///
/// **No duration is carried, because the server sends none.** This refusal is a
/// `409` without a `Retry-After` header, and the backend does not report the
/// remaining cooldown on this response. A countdown would therefore be invented,
/// which `decisions.md` §2.11 forbids: presentation may say a code was sent
/// recently and to try again shortly, and may not say how long remains.
///
/// Known not sent: the cooldown is checked before a code is reserved or written,
/// so the code the user already holds is the one that still applies.
final class ApiFailureVerificationResendCooldown
    extends ApiFailureRegistration {
  const ApiFailureVerificationResendCooldown({required super.code});
}

/// `VALIDATION_ERROR`, `INVALID_URL`, `INVALID_SEARCH_QUERY`, and
/// `INVALID_COLLECTION_NAME` — an input that parses but names nothing usable,
/// or is outside its documented bounds.
///
/// The fields carry field-level detail for diagnosis; they are not rendered
/// verbatim.
final class ApiFailureValidation extends ApiFailureRequest {
  const ApiFailureValidation(this.fields);

  final List<ApiErrorField> fields;
}

/// `COLLECTION_NAME_ALREADY_EXISTS` — the caller asked to create a collection
/// and the submitted name is already held by one of their collections.
///
/// Kept distinct from [ApiFailureValidation] because the name's shape is valid;
/// the conflict is ownership, and the only correction is a different name. The
/// client does not know whether the owner is a system or user collection, and no
/// copy derived from this variant may claim one.
///
/// **[D15] Known not moved.** The backend refuses before creating or moving
/// anything, so there is nothing to reconcile.
final class ApiFailureCollectionNameAlreadyExists extends ApiFailure {
  const ApiFailureCollectionNameAlreadyExists({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `COLLECTION_NOT_EMPTY` — the collection delete transaction was rolled back
/// because a saved item was filed into the collection after the operation had
/// already dealt with the items it found.
///
/// **Known not deleted.** The collection and its items are unchanged. This is a
/// concurrency outcome, not evidence that the client should have checked
/// emptiness first; the backend is the only authority on the collection's
/// contents at commit time.
final class ApiFailureCollectionNotEmpty extends ApiFailure {
  const ApiFailureCollectionNotEmpty({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `UNSORTED_COLLECTION_PROTECTED` — the collection delete named Unsorted.
///
/// **Known not deleted.** Unsorted is identified by its system key on the
/// server, and no client-side check is authorization. The request writes
/// nothing.
final class ApiFailureUnsortedCollectionProtected extends ApiFailure {
  const ApiFailureUnsortedCollectionProtected({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `COLLECTION_DELETE_TARGET_NOT_FOUND` — a collection delete's `move` action
/// named a destination that is gone or is not this caller's.
///
/// **Known not deleted, and the source is intact.** The backend validates the
/// target before moving or deleting anything, so nothing changed and the only
/// correction is another destination.
///
/// Deliberately distinct from [ApiFailureNotFound]. That variant describes the
/// resource a screen is showing, and treating a missing destination as it would
/// push the collection screen into its not-found state even though the
/// collection being deleted is still there.
final class ApiFailureCollectionDeleteTargetNotFound extends ApiFailure {
  const ApiFailureCollectionDeleteTargetNotFound({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `BAD_REQUEST`, or `INVALID_COLLECTION_INTENT`. The body was unparseable, or
/// parsed without stating a supported operation.
///
/// `INVALID_COLLECTION_INTENT` belongs here rather than with the name failures:
/// the request did not say whether it selected a destination or asked for a new
/// collection, so there is no name for the user to correct and the client is at
/// fault. It must never be presented as a duplicate-name conflict.
final class ApiFailureMalformedRequest extends ApiFailureRequest {
  const ApiFailureMalformedRequest();
}

/// A reply arrived but its body could not be read as a coded error: not JSON, no
/// `error` key, or a code this client does not recognise — **or** a reply whose
/// status is `2xx` and whose body does not decode into the documented shape.
///
/// **[D15] group F. Known not saved for a read** — a response did arrive, so the
/// outcome is determinate: the page is not shown. The body is never surfaced.
///
/// **For a write, this variant does not establish the outcome.** The two shapes
/// it collapses mean opposite things: a non-2xx body the client could not read is
/// a known-not-saved refusal (**D16**), while a `2xx` whose body failed to decode
/// — Dio only decodes a status that passed `validateStatus`, and the create
/// handler answers `201` only after the row committed — means the write landed
/// and only its representation is unreadable. Nothing in the variant separates
/// them, so a mutation must treat it as *unestablished* rather than as a failure
/// to save. Adding a variant for the second case would be the honest fix; it is
/// deliberately not done here, because nothing in this client yet distinguishes
/// them and a guessed distinction would be worse than a stated one.
final class ApiFailureUnreadableResponse extends ApiFailure {
  const ApiFailureUnreadableResponse({this.code});

  /// The unrecognised code when one was present, for logging only.
  final String? code;
}

/// No response arrived at all.
///
/// **[D15] groups G and H. UNCERTAIN — the only category that may say so.** The
/// request may or may not have been applied. The client must not state that the
/// item was not saved.
final class ApiFailureTransport extends ApiFailure {
  const ApiFailureTransport();
}

/// The named resource does not exist, or is not visible to this caller.
///
/// Produced **only** from the backend's verified not-found codes, never from a
/// bare `404`: a non-JSON `404` is [ApiFailureUnreadableResponse], because "the
/// server answered 404" and "the server told us this resource is gone" are
/// different claims.
///
/// Three routes use different codes for the same conclusion:
/// `RESOURCE_NOT_FOUND` from `GET /saved-items/{id}`, `SAVED_ITEM_NOT_FOUND`
/// from `PUT /saved-items/{id}/collection`, and `COLLECTION_NOT_FOUND` from the
/// collection's saved-items listing.
///
/// **The backend deliberately uses the same response for a resource owned by
/// another user.** This variant therefore carries no reason, and no copy derived
/// from it may say which of the two happened.
///
/// For a read this is *known not shown*: a reply arrived and the resource is not
/// available to this caller. For the move write it is *known not moved*.
final class ApiFailureNotFound extends ApiFailure {
  const ApiFailureNotFound({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `USER_NOT_FOUND` — the account this access token names no longer exists.
///
/// Deliberately distinct from [ApiFailureNotFound]. That variant is about the
/// resource a screen is showing; this one says the authenticated **account** is
/// unavailable, which is why the profile and password screens need their own
/// sentence for it.
///
/// **[D15] Known not written.** The handler reaches no write when the row is
/// missing.
///
/// **This is not a session expiry and must not cause an automatic sign-out.** The
/// access token is valid; the account behind it is gone. Signing in again cannot
/// recreate it, and inventing a sign-out here would discard the very session that
/// is the only way the server could say so.
final class ApiFailureUserNotFound extends ApiFailure {
  const ApiFailureUserNotFound({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `CURRENT_PASSWORD_INVALID` — a password change submitted a current password
/// that does not match the stored credential.
///
/// **401, but not an authentication failure.** This is deliberately its own
/// variant rather than [ApiFailureAuthRequired]: the access token was accepted and
/// the user is signed in. Renewing the token cannot fix a wrong password, so this
/// must never trigger the refresh path. It is a known-not-changed refusal with one
/// correction — enter the current password again.
final class ApiFailureCurrentPasswordInvalid extends ApiFailure {
  const ApiFailureCurrentPasswordInvalid({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `CURRENT_PASSWORD_REQUIRED` — a password change omitted the current password
/// for an account that holds a credential.
///
/// A **mode conflict**, not bad input: the server's credential state differs from
/// the form the client rendered. Nothing was written. The correction is to refetch
/// the profile and show the change form, not to ask the user to add a field the
/// form did not have.
final class ApiFailureCurrentPasswordRequired extends ApiFailure {
  const ApiFailureCurrentPasswordRequired({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `UNEXPECTED_CURRENT_PASSWORD` — a first-password request supplied a current
/// password for an account that holds no credential.
///
/// A **mode conflict** in the other direction: the server says the account has no
/// credential, while the client rendered the change form. Nothing was written. The
/// correction is to refetch the profile and show the create form.
final class ApiFailureUnexpectedCurrentPassword extends ApiFailure {
  const ApiFailureUnexpectedCurrentPassword({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `PASSWORD_CREDENTIAL_ALREADY_EXISTS` — a concurrent request created the
/// account's first password before this one did.
///
/// **Known not created.** The winner's credential is what remains; this request
/// wrote nothing. The state the create form was based on has changed, so the form
/// must be re-derived from a fresh profile rather than submitted again unchanged.
final class ApiFailurePasswordCredentialAlreadyExists extends ApiFailure {
  const ApiFailurePasswordCredentialAlreadyExists({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// `PASSWORD_ALREADY_CHANGED` — a concurrent request changed the credential after
/// this request read and verified against the previous one.
///
/// **Known not changed by this request.** The update and the revocation shared one
/// transaction and it rolled back, so nothing this request did survives. The
/// submitted current password no longer describes the stored credential.
final class ApiFailurePasswordAlreadyChanged extends ApiFailure {
  const ApiFailurePasswordAlreadyChanged({required this.code});

  /// The backend code, retained for logging and tests, never for display.
  final String code;
}

/// The bearer guard refused the request, and any refresh that might have been
/// possible has already been attempted.
///
/// Covers all three guard codes ([ApiErrorCode.invalidAuthorizationHeader],
/// [ApiErrorCode.invalidAccessToken], [ApiErrorCode.accessTokenExpired]) after
/// the interceptor has acted. A `401` reaches the user as this and as nothing
/// more specific: the distinction has been used, and what remains is the same
/// action — sign in.
///
/// **[D15] group A. Known not saved.**
final class ApiFailureAuthRequired extends ApiFailure {
  const ApiFailureAuthRequired({this.code});

  /// The guard code that produced this, for logging and tests.
  final String? code;
}

/// The refresh endpoint refused in a way that ends the session permanently.
///
/// Only [ApiErrorCode.terminalRefresh] produces this. The backend has already
/// committed the revocation before answering, so there is nothing to keep and
/// nothing to retry.
final class ApiFailureSessionEnded extends ApiFailure {
  const ApiFailureSessionEnded({required this.code});

  /// `REFRESH_TOKEN_INVALID`, `SESSION_REVOKED` or `SESSION_EXPIRED`.
  final String code;
}

/// A refresh failed where the outcome is genuinely unknown: a transport failure
/// or a `500` from `POST /auth/refresh`.
///
/// **[Open] — the client cannot know whether the backend committed the
/// rotation.** `auth-sessions.md` records both halves: a failed commit yields
/// `500` rather than a false "you were revoked", and "a lost refresh response
/// costs the session". Presenting the stored refresh token again may therefore
/// trip reuse detection and revoke the session.
///
/// The chosen policy — keep the credentials, do not retry automatically, let a
/// subsequent user action attempt recovery — is recorded in `PROGRESS.md`.
/// Retaining the credentials is **not** a guarantee that the session is
/// recoverable, and no copy may imply that it is.
final class ApiFailureRefreshUncertain extends ApiFailure {
  const ApiFailureRefreshUncertain({required this.cause});

  /// What actually happened, retained for diagnosis only.
  final ApiFailure cause;
}

/// The credentials could not be persisted, so no session can be used.
///
/// Raised when a rotation's write fails partway. The alternative — carrying on
/// with a half-written pair — would leave the client holding an access token it
/// cannot refresh and a refresh token that does not match it.
///
/// **Also the classification for a renewal that fails inside the local
/// credential layer and arrives unclassified**: a refresh token that cannot be
/// read before the request is even attempted, or credentials that cannot be
/// cleared once a session has ended. All three are the same thing to a caller —
/// this device could not produce a usable session — and none of them says the
/// session ended, so none of them may be read as terminal. [cause] keeps the
/// underlying error for diagnosis; it is never displayed ([D22]).
final class ApiFailureCredentialStorage extends ApiFailure {
  const ApiFailureCredentialStorage({required this.cause});

  /// The platform error that made the credential layer unusable.
  final Object cause;
}
