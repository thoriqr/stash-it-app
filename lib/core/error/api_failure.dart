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

/// `VALIDATION_ERROR`. The fields carry field-level detail for diagnosis; they
/// are not rendered verbatim.
final class ApiFailureValidation extends ApiFailureRequest {
  const ApiFailureValidation(this.fields);

  final List<ApiErrorField> fields;
}

/// `BAD_REQUEST`. The body was unparseable.
final class ApiFailureMalformedRequest extends ApiFailureRequest {
  const ApiFailureMalformedRequest();
}

/// A non-2xx response arrived but its body could not be read as a coded error:
/// not JSON, no `error` key, or a code this client does not recognise.
///
/// **[D15] group F. Known not saved** — a response did arrive, so the outcome is
/// determinate. The body is never surfaced.
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
final class ApiFailureCredentialStorage extends ApiFailure {
  const ApiFailureCredentialStorage({required this.cause});

  final Object cause;
}
