/// The backend `error.code` values this client recognises.
///
/// Every constant here is verified against the backend implementation, not
/// against its Swagger annotations — the two disagree in places, and the Go
/// source is authoritative (`AGENTS.md` §1, "Hierarchy when sources conflict").
///
/// Each constant records where it comes from, because a code that drifts out of
/// the verified list must be *removed* rather than left to accumulate. A code
/// this client has never seen is not an error case; it is
/// [ApiErrorCode.unmapped], and the client owns the copy for it.
abstract final class ApiErrorCode {
  // ---------------------------------------------------------------------------
  // Bearer guard — `internal/middleware/auth.go`. The only source of all three,
  // mounted per route and never via `router.Use`.
  // ---------------------------------------------------------------------------

  /// 401. The `Authorization` header is absent, is not `Bearer `-prefixed, or is
  /// empty after the prefix. `auth.go:29`, `auth.go:38`.
  ///
  /// No token reached the server, so there is nothing to refresh.
  static const String invalidAuthorizationHeader =
      'INVALID_AUTHORIZATION_HEADER';

  /// 401. JWT verification failed for any reason other than expiry — bad
  /// signature, wrong algorithm, missing `sub` or `sid`. `auth.go:55`.
  ///
  /// No token reached the server, so there is nothing to refresh.
  static const String invalidAccessToken = 'INVALID_ACCESS_TOKEN';

  /// 401. `jwt.ErrTokenExpired`. `auth.go:48`.
  ///
  /// **This is the only code that authorises a refresh attempt.** The distinction
  /// from the two above is load-bearing: `decisions.md` D15 group A requires a
  /// single-flight refresh and one retry for this code, and requires going
  /// straight to sign-in for the other two. A refresh for a token the server
  /// refused as unusable cannot succeed.
  static const String accessTokenExpired = 'ACCESS_TOKEN_EXPIRED';

  // ---------------------------------------------------------------------------
  // Refresh — `internal/api/auth/session/error_codes.go`.
  //
  // Emitted only by `POST /auth/refresh`. No protected endpoint can return them:
  // access tokens are stateless and `middleware.Auth` never consults the
  // database, so a revoked session's access token keeps working until its own
  // 15-minute expiry (`documentation/auth-sessions.md`, "Revocation, and what it
  // does not do").
  // ---------------------------------------------------------------------------

  /// 401. No token row matched the hash. `session/repository.go:170`.
  ///
  /// Terminal. It is also what a revoked session answers once maintenance has
  /// reclaimed its token chain (`auth-sessions.md`, "What the response does and
  // does not say"), so it carries no more information than `SESSION_REVOKED`
  /// does. Both are treated identically.
  static const String refreshTokenInvalid = 'REFRESH_TOKEN_INVALID';

  /// 401. The session is revoked, or the presented token was already rotated and
  /// reuse detection has just revoked the session. `repository.go:181`, `:197`.
  ///
  /// Terminal, and always committed before the response is written.
  static const String sessionRevoked = 'SESSION_REVOKED';

  /// 401. Past the session's 90-day absolute lifetime or its 30-day idle
  /// window. `repository.go:215`, `:231`.
  ///
  /// Terminal.
  static const String sessionExpired = 'SESSION_EXPIRED';

  // ---------------------------------------------------------------------------
  // Login — `internal/api/auth/login/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 401. Wrong password, or an address with no account. Identical for both
  /// (`login/repository.go:77`, `login/service.go:159`) so the endpoint cannot
  /// be used to enumerate registered addresses.
  static const String invalidCredentials = 'INVALID_CREDENTIALS';

  // ---------------------------------------------------------------------------
  // Manual registration — `internal/api/auth/registration/error_codes.go`.
  //
  // Only codes reachable from `POST /auth/register/manual`,
  // `POST /auth/register/recovery/manual`, or
  // `POST /auth/register/verification/{id}/pin` belong here. Later registration
  // stages have their own contracts and must not acquire client branches early.
  // ---------------------------------------------------------------------------

  /// 409. This address already has a completed manual registration.
  static const String registrationAlreadyCompleted =
      'REGISTRATION_ALREADY_COMPLETED';

  /// 409. Recovery was requested while the normal registration verification is
  /// still `pending`.
  ///
  /// The recovery route refuses this state without creating a recovery request
  /// or returning a verification id. The correction is the normal
  /// `POST /auth/register/manual` + PIN flow, which returns the existing
  /// verification id with `verification_status: "pending"`.
  static const String registrationAlreadyPending =
      'REGISTRATION_ALREADY_PENDING';

  /// 409. A concurrent registration insert could not be reconciled.
  static const String registrationAlreadyExists = 'REGISTRATION_ALREADY_EXISTS';

  /// 409. Another issuance left an active code for this verification.
  static const String activeVerificationCodeExists =
      'ACTIVE_VERIFICATION_CODE_EXISTS';

  /// 409. The verification request can no longer accept a PIN.
  static const String verificationNotPending = 'VERIFICATION_NOT_PENDING';

  /// 409. The registration behind the verification is no longer pending.
  static const String registrationNotPending = 'REGISTRATION_NOT_PENDING';

  /// 409. The registration expired before a PIN could be issued.
  static const String registrationExpired = 'REGISTRATION_EXPIRED';

  /// 409. A PIN was already issued and its server-owned resend cooldown remains.
  static const String verificationResendCooldown =
      'VERIFICATION_RESEND_COOLDOWN';

  /// 429, `Retry-After` present. The client address's PIN budget is spent.
  static const String pinRateLimitExceeded = 'PIN_RATE_LIMIT_EXCEEDED';

  /// 503, no `Retry-After`. The client address's PIN budget was unavailable.
  static const String pinRateLimitUnavailable = 'PIN_RATE_LIMIT_UNAVAILABLE';

  /// 429, `Retry-After` present. The deployment-wide PIN email budget is spent.
  static const String pinEmailBudgetExceeded = 'PIN_EMAIL_BUDGET_EXCEEDED';

  /// 503, no `Retry-After`. The deployment-wide PIN email budget was unavailable.
  static const String pinEmailBudgetUnavailable =
      'PIN_EMAIL_BUDGET_UNAVAILABLE';

  /// 503, **`Retry-After` present**. The PIN was persisted but handing the
  /// message to the email sender failed. This is distinct from an unavailable
  /// limiter: its cooldown is the server-owned recovery time for a code that
  /// already exists.
  static const String pinEmailDeliveryFailed = 'PIN_EMAIL_DELIVERY_FAILED';

  /// 409. The submitted PIN does not match the issued code.
  static const String invalidVerificationCode = 'INVALID_VERIFICATION_CODE';

  /// 409. Too many incorrect PIN attempts.
  static const String verificationCodeAttemptsExceeded =
      'VERIFICATION_CODE_ATTEMPTS_EXCEEDED';

  /// 401. The continuation token is required.
  static const String registrationContinuationRequired =
      'REGISTRATION_CONTINUATION_REQUIRED';

  /// 409. The continuation token has already been used.
  static const String registrationContinuationConsumed =
      'REGISTRATION_CONTINUATION_CONSUMED';

  /// 409. The continuation token has expired.
  static const String registrationContinuationExpired =
      'REGISTRATION_CONTINUATION_EXPIRED';

  /// 409. The registration is not a manual registration.
  static const String invalidRegistrationType = 'INVALID_REGISTRATION_TYPE';

  /// 409. The account already exists.
  static const String userAlreadyExists = 'USER_ALREADY_EXISTS';

  /// 409. The auth identity already exists.
  static const String authIdentityAlreadyExists =
      'AUTH_IDENTITY_ALREADY_EXISTS';

  // ---------------------------------------------------------------------------
  // Password reset — `internal/api/auth/password_reset/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 409. A concurrent request created a pending reset for the address first.
  ///
  /// The service normally resolves this race internally by returning the existing
  /// verification id; reaching the client means the single retry also lost. The
  /// correction is to repeat the request, not to treat the reset as invalid.
  static const String passwordResetAlreadyPending =
      'PASSWORD_RESET_ALREADY_PENDING';

  /// 409. The pending reset is no longer pending: it completed, expired, or was
  /// replaced. Recovery is to request a new reset.
  static const String passwordResetNotPending = 'PASSWORD_RESET_NOT_PENDING';

  /// 409. The reset is past its 15-minute lifetime. Requesting a new reset opens
  /// a new one; the old id cannot continue.
  static const String passwordResetExpired = 'PASSWORD_RESET_EXPIRED';

  /// 409. The continuation was already used by a successful finalization.
  static const String passwordResetContinuationConsumed =
      'PASSWORD_RESET_CONTINUATION_CONSUMED';

  /// 401. The `X-Password-Reset-Continuation` header was absent or empty.
  ///
  /// A capability-header refusal, not a session event: the mapper must not turn
  /// this into an auth-required failure.
  static const String passwordResetContinuationRequired =
      'PASSWORD_RESET_CONTINUATION_REQUIRED';

  /// 409. The continuation's own 15-minute lifetime elapsed. The reset may still
  /// be pending, but this token can no longer finalize it.
  static const String passwordResetContinuationExpired =
      'PASSWORD_RESET_CONTINUATION_EXPIRED';

  // ---------------------------------------------------------------------------
  // Generic — `internal/apperror/error.go`.
  // ---------------------------------------------------------------------------

  /// 400. A body that could not be parsed at all. `httpx/bind.go:29`.
  ///
  /// A well-formed client never produces this; it indicates a client defect.
  static const String badRequest = 'BAD_REQUEST';

  /// 400. Field-level validation failed. `httpx/bind.go:26`. Carries `fields[]`.
  static const String validationError = 'VALIDATION_ERROR';

  /// 404. `apperror.NotFound`'s default code. `saved_item/repository.go`
  /// (`GetSavedItemByIDForUser`) uses it for a saved item that does not exist or
  /// is owned by another user, so the two are deliberately indistinguishable and
  /// the response cannot be used to enumerate IDs.
  ///
  /// **Never inferred from the status alone.** A `404` whose body is not a coded
  /// error is an unreadable response, not a resource that is known to be gone.
  static const String resourceNotFound = 'RESOURCE_NOT_FOUND';

  // ---------------------------------------------------------------------------
  // Saved items — `internal/api/saved_item/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 400. The submitted `url` parsed but is unusable: no host after parsing, or
  /// an empty one after lowercasing. `saved_item/service.go` (`deriveDomain`).
  ///
  /// Raised **after** the body passed validation, so it is a sibling of
  /// [validationError] rather than a replacement for it: the request was
  /// well-formed and the value is still not an address anything can be saved
  /// from. Emitted before the insert, so it is a known-not-saved outcome.
  static const String invalidUrl = 'INVALID_URL';

  /// 500. `apperror.Internal`.
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';

  /// 503. `apperror.ServiceUnavailable` used as its default code.
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';

  // ---------------------------------------------------------------------------
  // Collections — `internal/api/collection/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 400. The submitted collection name was blank after trimming, or longer
  /// than 100 runes. `collection/service.go` (`normalizeCollectionName`).
  ///
  /// Emitted by `PUT /saved-items/{id}/collection`. The route owns this name
  /// rule, so it is a sibling of [validationError] and is mapped to the same
  /// failure variant: the input has to change.
  static const String invalidCollectionName = 'INVALID_COLLECTION_NAME';

  /// 400. `collection_intent` was absent, or was neither `existing` nor
  /// `create`. `collection/service.go` (`PutSavedItem`).
  ///
  /// Nothing is defaulted because the two intents have opposite outcomes for a
  /// name that is already taken. A well-formed client never produces this, so it
  /// is a client defect with no name for the user to correct; it maps to the
  /// standard malformed-request handling, never to a duplicate-name conflict.
  static const String invalidCollectionIntent = 'INVALID_COLLECTION_INTENT';

  /// 409. The caller asked to create a collection and the submitted name is
  /// already held by one of the user's collections. `collection/repository.go`
  /// (`createNewUserCollection`), decided by the same unique index that enforces
  /// case-insensitive, whitespace-trimmed uniqueness.
  ///
  /// Only the `create` intent can produce it. Under `existing` the name is a
  /// destination and is reused instead. The backend reports it before creating
  /// or moving anything, so this is a known-not-moved refusal.
  static const String collectionNameAlreadyExists =
      'COLLECTION_NAME_ALREADY_EXISTS';

  /// 404. The saved item does not exist or belongs to another user.
  /// `collection/repository.go` (`PutSavedItemIntoUserCollection`).
  ///
  /// **The move endpoint's own not-found code**, distinct from
  /// [resourceNotFound] used by the reads. Both deliberately make an item that
  /// does not exist and one owned by another user indistinguishable.
  static const String savedItemNotFound = 'SAVED_ITEM_NOT_FOUND';

  /// 404. The collection does not exist or belongs to another user.
  /// `collection/error_codes.go` (`CodeCollectionNotFound`), raised by
  /// `GetCollectionByIDForUser` and reported by `DELETE /collections/{id}` and by
  /// the collection's saved-items listing.
  ///
  /// Both cases share this one code and message on purpose, so the response never
  /// discloses whether an id exists. It is what lets the collection detail screen
  /// tell **an empty collection** (a `200` whose `saved_items` is `[]`) apart from
  /// **a collection this caller cannot read** — a distinction that cannot be made
  /// from the status alone.
  static const String collectionNotFound = 'COLLECTION_NOT_FOUND';

  /// 409. `DELETE /collections/{id}` found a saved item in the collection after
  /// the operation had already dealt with the items it saw.
  /// `collection/error_codes.go` (`CodeCollectionNotEmpty`).
  ///
  /// The database's `ON DELETE RESTRICT` constraint detects it, the whole
  /// transaction rolls back, and the collection and its items are unchanged.
  /// This is a known not-deleted outcome, not an emptiness precondition the
  /// client can check.
  static const String collectionNotEmpty = 'COLLECTION_NOT_EMPTY';

  /// 409. `DELETE /collections/{id}` named the Unsorted collection.
  /// `collection/error_codes.go` (`CodeUnsortedCollectionProtected`).
  ///
  /// Unsorted is identified by its system key, never by display name or type.
  /// It is the only protected collection and the transaction writes nothing.
  static const String unsortedCollectionProtected =
      'UNSORTED_COLLECTION_PROTECTED';

  /// 400. `DELETE /collections/{id}` received no `saved_items_action`, or one
  /// that is neither `delete` nor `move`. Nothing is defaulted.
  ///
  /// A well-formed client never produces it; it maps to the standard malformed
  /// request handling.
  static const String invalidCollectionDeleteAction =
      'INVALID_COLLECTION_DELETE_ACTION';

  /// 400. `DELETE /collections/{id}` received a `target_collection_id` that does
  /// not match the action: absent for `move`, or present for `delete`.
  ///
  /// A well-formed client never produces it; it maps to the standard malformed
  /// request handling.
  static const String invalidCollectionDeleteTarget =
      'INVALID_COLLECTION_DELETE_TARGET';

  /// 404. The `target_collection_id` of a `move` does not exist or belongs to
  /// another user. `collection/error_codes.go`
  /// (`CodeCollectionDeleteTargetNotFound`).
  ///
  /// Deliberately distinct from [collectionNotFound]: that code describes the
  /// collection being deleted, while this one names the destination. The backend
  /// validates the target before moving or deleting anything, so the source and
  /// its items are unchanged and the user can choose another destination.
  static const String collectionDeleteTargetNotFound =
      'COLLECTION_DELETE_TARGET_NOT_FOUND';

  // ---------------------------------------------------------------------------
  // Search — `internal/api/search/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 400. The submitted `q` was blank after trimming, shorter than 2 runes, or
  /// longer than 128 runes. `search/service.go` (`normalizeQuery`).
  ///
  /// **Search's own validation code, not `VALIDATION_ERROR`.** The request type
  /// carries no `validate` tag on purpose, so the service owns these rules and
  /// reports them under this code. It means exactly what `VALIDATION_ERROR`
  /// means to a caller — the input has to change — and is mapped to the same
  /// failure variant rather than falling into the unreadable-response bucket.
  static const String invalidSearchQuery = 'INVALID_SEARCH_QUERY';

  // ---------------------------------------------------------------------------
  // Rate limiting — `internal/middleware/ratelimit.go`,
  // `internal/middleware/user_ratelimit.go`, and the login feature's own codes.
  // ---------------------------------------------------------------------------

  /// 429, `Retry-After` present. Namespace `login-ip`, 30 per 10 minutes.
  static const String ipRateLimitExceeded = 'IP_RATE_LIMIT_EXCEEDED';

  /// 503, **no** `Retry-After`. The limiter failed closed, so the request was
  /// refused without being attempted.
  static const String ipRateLimitUnavailable = 'IP_RATE_LIMIT_UNAVAILABLE';

  /// 503, no `Retry-After`. The peer address could not be resolved at all.
  static const String clientIpUnavailable = 'CLIENT_IP_UNAVAILABLE';

  /// 429, `Retry-After` present. Namespace `login-email`, 10 per 15 minutes.
  static const String loginRateLimitExceeded = 'LOGIN_RATE_LIMIT_EXCEEDED';

  /// 503, no `Retry-After`. Login's per-email counter could not be evaluated.
  static const String loginRateLimitUnavailable =
      'LOGIN_RATE_LIMIT_UNAVAILABLE';

  /// 429, **`Retry-After` present**. This authenticated user's budget for the
  /// route is spent. Mounted on `POST /saved-items` (namespace
  /// `saved-item-create-user`, 60 per 10 minutes), on
  /// `POST /saved-items/:id/enrich`, and on `GET /search` (namespace
  /// `search-user`, 30 per minute). `middleware/user_ratelimit.go`.
  static const String userRateLimitExceeded = 'USER_RATE_LIMIT_EXCEEDED';

  /// 503, no `Retry-After`. The per-user limiter failed closed.
  static const String userRateLimitUnavailable = 'USER_RATE_LIMIT_UNAVAILABLE';

  /// 503, `Retry-After` present. The shared Argon2id capacity was exhausted, so
  /// **the password was never checked**. Deliberately neither a rate-limit code
  /// nor `INVALID_CREDENTIALS`, because both would be lies the caller acts on
  /// (`login/service.go:266`).
  static const String passwordWorkUnavailable = 'PASSWORD_WORK_UNAVAILABLE';

  // ---------------------------------------------------------------------------
  // User profile and password — `internal/api/user/error_codes.go`.
  // ---------------------------------------------------------------------------

  /// 404. No user row holds the authenticated user's id.
  /// `user/repository.go` (`GetUserProfile`, `UpdateUserDisplayName`).
  ///
  /// Reachable because access tokens are stateless and outlive the session they
  /// name: a token minted before its account was deleted still verifies. Unknown
  /// and deleted are deliberately the same answer. **This is not a session
  /// expiry** — the token is valid, the account is gone — so it must not be
  /// treated like a bearer-guard refusal or used to justify an automatic sign-out.
  static const String userNotFound = 'USER_NOT_FOUND';

  /// 401. The `current_password` submitted with a password change did not match
  /// the stored credential. `user/service.go` (`changePassword`).
  ///
  /// **401 because the credential failed, not the access token.** It is not one of
  /// the bearer-guard codes and must never trigger a refresh: renewing the access
  /// token cannot make a wrong current password right. The distinct code exists so
  /// a client can say "try a different password" instead of "sign in again".
  static const String currentPasswordInvalid = 'CURRENT_PASSWORD_INVALID';

  /// 400. A password change omitted `current_password` for an account that holds
  /// a credential. `user/service.go` (`changePassword`).
  ///
  /// The credential state differs from the mode the client rendered. Nothing was
  /// written.
  static const String currentPasswordRequired = 'CURRENT_PASSWORD_REQUIRED';

  /// 400. A first-password request supplied `current_password` for an account
  /// that holds no credential. `user/service.go` (`createPasswordCredential`).
  ///
  /// Refused rather than ignored, so the caller is never told a secret it sent was
  /// checked when it was not. Nothing was written.
  static const String unexpectedCurrentPassword = 'UNEXPECTED_CURRENT_PASSWORD';

  /// 409. A concurrent request created the account's first password before this
  /// one could. `user/repository.go` (`CreatePasswordCredential`).
  ///
  /// The winner's hash is kept; this request wrote nothing. The credential state
  /// has changed, so a create form is no longer the correct shape.
  static const String passwordCredentialAlreadyExists =
      'PASSWORD_CREDENTIAL_ALREADY_EXISTS';

  /// 409. A concurrent request changed the password after this request read and
  /// verified against the previous one. `user/repository.go`
  /// (`SetPasswordAndRevokeOtherSessions`).
  ///
  /// The whole transaction — the update and the revocation — rolled back, so this
  /// request wrote nothing. Its `current_password` no longer describes the stored
  /// credential.
  static const String passwordAlreadyChanged = 'PASSWORD_ALREADY_CHANGED';

  // `PASSWORD_CREDENTIAL_NOT_FOUND` is deliberately absent. The code exists in
  // `user/error_codes.go`, but `Service.SetPassword` consumes it internally to
  // select the create branch; it is not a reachable HTTP response. Adding it here
  // without an endpoint that can emit it would invite a branch that never runs.

  /// The codes that mean "this session can never be used again", as returned by
  /// `POST /auth/refresh`.
  ///
  /// A definitive refusal from the server: the token is spent, the session is
  /// revoked, or the session is past a lifetime. In every case the backend has
  /// already committed the revocation before answering, so nothing is gained by
  /// keeping the credentials and retrying.
  ///
  /// Nothing else belongs here. In particular a bare `401` is not evidence of
  /// anything: `INVALID_ACCESS_TOKEN` means the token is unusable,
  /// `INVALID_AUTHORIZATION_HEADER` means none was sent, and a network failure
  /// or a `500` leaves the rotation outcome unknown. Treating those as terminal
  /// signs a user out over a network blip.
  static const Set<String> terminalRefresh = {
    refreshTokenInvalid,
    sessionRevoked,
    sessionExpired,
  };
}
