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

  /// 409. The submitted collection name is already held by a **system**
  /// collection, including Unsorted. `collection/repository.go`
  /// (`createOrGetUserCollection`).
  ///
  /// The move endpoint only ever files into a user collection, so a name held by
  /// a system collection cannot be used as a destination. The client must not
  /// guess which system collection caused the refusal.
  static const String collectionNameReserved = 'COLLECTION_NAME_RESERVED';

  /// 404. The saved item does not exist or belongs to another user.
  /// `collection/repository.go` (`PutSavedItemIntoUserCollection`).
  ///
  /// **The move endpoint's own not-found code**, distinct from
  /// [resourceNotFound] used by the reads. Both deliberately make an item that
  /// does not exist and one owned by another user indistinguishable.
  static const String savedItemNotFound = 'SAVED_ITEM_NOT_FOUND';

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
