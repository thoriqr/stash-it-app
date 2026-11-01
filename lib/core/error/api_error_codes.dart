/// Error codes recognized by the client.
///
/// These codes represent failure conditions returned by the backend API.
/// Keep this list limited to codes that can actually reach an HTTP response.
///
/// Each code documents the condition that triggers it and any client behavior
/// that depends on that distinction. Unknown codes must be handled through
/// the client's generic error handling rather than assumed to be known cases.
abstract final class ApiErrorCode {
  // ---------------------------------------------------------------------------
  // Bearer authentication
  // ---------------------------------------------------------------------------

  /// 401. The Authorization header is missing, is not Bearer-prefixed, or
  /// contains an empty token.
  ///
  /// No usable access token reached the server. Do not attempt token refresh.
  static const String invalidAuthorizationHeader =
      'INVALID_AUTHORIZATION_HEADER';

  /// 401. JWT verification failed for a reason other than expiration, such as
  /// an invalid signature, unsupported algorithm, or missing required claims.
  ///
  /// This token cannot be recovered through refresh.
  static const String invalidAccessToken = 'INVALID_ACCESS_TOKEN';

  /// 401. The access token has expired.
  ///
  /// This is the only error code that authorizes an automatic token refresh.
  /// Other authentication failures must not trigger refresh attempts.
  static const String accessTokenExpired = 'ACCESS_TOKEN_EXPIRED';

  // ---------------------------------------------------------------------------
  // Session refresh
  // ---------------------------------------------------------------------------

  /// 401. No refresh-token record matches the presented token.
  ///
  /// This is a terminal session failure. Treat it the same as
  /// [sessionRevoked].
  static const String refreshTokenInvalid = 'REFRESH_TOKEN_INVALID';

  /// 401. The session has been revoked, or refresh-token reuse was detected
  /// and the session was revoked.
  ///
  /// This is a terminal session failure. The client must not retry using the
  /// same credentials.
  static const String sessionRevoked = 'SESSION_REVOKED';

  /// 401. The session exceeded its absolute lifetime or idle-time limit.
  ///
  /// This is a terminal session failure.
  static const String sessionExpired = 'SESSION_EXPIRED';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// 401. The supplied password is incorrect, or no account exists for the
  /// submitted address.
  ///
  /// Both conditions intentionally return the same code to prevent account
  /// enumeration.
  static const String invalidCredentials = 'INVALID_CREDENTIALS';

  // ---------------------------------------------------------------------------
  // Manual registration
  // ---------------------------------------------------------------------------

  /// 409. The address already belongs to a completed manual registration.
  static const String registrationAlreadyCompleted =
      'REGISTRATION_ALREADY_COMPLETED';

  /// 409. Registration recovery was requested while the normal verification
  /// process is still pending.
  ///
  /// The recovery request is not created. Continue through the normal
  /// registration verification flow, which can return the existing
  /// verification ID.
  static const String registrationAlreadyPending =
      'REGISTRATION_ALREADY_PENDING';

  /// 409. A concurrent registration operation could not be reconciled.
  static const String registrationAlreadyExists = 'REGISTRATION_ALREADY_EXISTS';

  /// 409. An active verification code already exists for this verification.
  static const String activeVerificationCodeExists =
      'ACTIVE_VERIFICATION_CODE_EXISTS';

  /// 409. The verification request can no longer accept a PIN.
  static const String verificationNotPending = 'VERIFICATION_NOT_PENDING';

  /// 409. The registration associated with the verification is no longer
  /// pending.
  static const String registrationNotPending = 'REGISTRATION_NOT_PENDING';

  /// 409. The registration expired before a PIN could be issued.
  static const String registrationExpired = 'REGISTRATION_EXPIRED';

  /// 409. A PIN was already issued and its server-managed resend cooldown
  /// has not elapsed.
  static const String verificationResendCooldown =
      'VERIFICATION_RESEND_COOLDOWN';

  /// 429. The client address's PIN request budget is exhausted.
  ///
  /// The response includes Retry-After.
  static const String pinRateLimitExceeded = 'PIN_RATE_LIMIT_EXCEEDED';

  /// 503. The client address's PIN request budget could not be evaluated.
  ///
  /// The response does not include Retry-After.
  static const String pinRateLimitUnavailable = 'PIN_RATE_LIMIT_UNAVAILABLE';

  /// 429. The deployment-wide PIN email budget is exhausted.
  ///
  /// The response includes Retry-After.
  static const String pinEmailBudgetExceeded = 'PIN_EMAIL_BUDGET_EXCEEDED';

  /// 503. The deployment-wide PIN email budget could not be evaluated.
  ///
  /// The response does not include Retry-After.
  static const String pinEmailBudgetUnavailable =
      'PIN_EMAIL_BUDGET_UNAVAILABLE';

  /// 503. The PIN was persisted, but delivery to the email sender failed.
  ///
  /// The response includes Retry-After. Unlike an unavailable rate limiter,
  /// the verification code already exists, so the cooldown represents the
  /// server-managed recovery period for that code.
  static const String pinEmailDeliveryFailed = 'PIN_EMAIL_DELIVERY_FAILED';

  /// 409. The submitted PIN does not match the issued verification code.
  static const String invalidVerificationCode = 'INVALID_VERIFICATION_CODE';

  /// 409. The maximum number of incorrect PIN attempts has been reached.
  static const String verificationCodeAttemptsExceeded =
      'VERIFICATION_CODE_ATTEMPTS_EXCEEDED';

  /// 401. The registration continuation token is missing.
  static const String registrationContinuationRequired =
      'REGISTRATION_CONTINUATION_REQUIRED';

  /// 409. The registration continuation token has already been used.
  static const String registrationContinuationConsumed =
      'REGISTRATION_CONTINUATION_CONSUMED';

  /// 409. The registration continuation token has expired.
  static const String registrationContinuationExpired =
      'REGISTRATION_CONTINUATION_EXPIRED';

  /// 409. The registration is not a manual registration.
  static const String invalidRegistrationType = 'INVALID_REGISTRATION_TYPE';

  /// 409. The account already exists.
  static const String userAlreadyExists = 'USER_ALREADY_EXISTS';

  /// 409. The authentication identity already exists.
  static const String authIdentityAlreadyExists =
      'AUTH_IDENTITY_ALREADY_EXISTS';

  /// 409. A social registration for this address is already pending under
  /// a different provider identity.
  static const String registrationIdentityMismatch =
      'REGISTRATION_IDENTITY_MISMATCH';

  // ---------------------------------------------------------------------------
  // Google authentication
  // ---------------------------------------------------------------------------

  /// 401. The Google ID token failed signature, audience, claim, or
  /// email-verification checks.
  static const String invalidGoogleToken = 'INVALID_GOOGLE_TOKEN';

  /// 409. The account-link confirmation is expired, unknown, or already used.
  static const String accountLinkConfirmationInvalid =
      'ACCOUNT_LINK_CONFIRMATION_INVALID';

  /// 409. The Google identity submitted for confirmation does not match the
  /// identity associated with the pending confirmation.
  ///
  /// The confirmation remains usable by the correct identity.
  static const String accountLinkIdentityMismatch =
      'ACCOUNT_LINK_IDENTITY_MISMATCH';

  /// 503. The account link was committed and its confirmation consumed, but
  /// session creation failed.
  ///
  /// Retrying the same confirmation cannot help. A new Google login can
  /// establish a session because the identity is already linked.
  static const String accountLinkSessionFailed = 'ACCOUNT_LINK_SESSION_FAILED';

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  /// 409. Another request created a pending password reset for this address
  /// before the current request could complete.
  ///
  /// The backend normally resolves this race by returning the existing
  /// verification ID. If this error reaches the client, repeat the request
  /// rather than treating the reset as invalid.
  static const String passwordResetAlreadyPending =
      'PASSWORD_RESET_ALREADY_PENDING';

  /// 409. The pending password reset is no longer pending because it
  /// completed, expired, or was replaced.
  ///
  /// Request a new password reset to continue.
  static const String passwordResetNotPending = 'PASSWORD_RESET_NOT_PENDING';

  /// 409. The password reset exceeded its 15-minute lifetime.
  ///
  /// Request a new reset. The expired verification ID cannot be reused.
  static const String passwordResetExpired = 'PASSWORD_RESET_EXPIRED';

  /// 409. The password-reset continuation was already used by a successful
  /// finalization.
  static const String passwordResetContinuationConsumed =
      'PASSWORD_RESET_CONTINUATION_CONSUMED';

  /// 401. The password-reset continuation header is missing or empty.
  ///
  /// This is a password-reset authorization failure, not an authentication
  /// session failure. It must not be treated as a reason to sign out.
  static const String passwordResetContinuationRequired =
      'PASSWORD_RESET_CONTINUATION_REQUIRED';

  /// 409. The password-reset continuation exceeded its own 15-minute
  /// lifetime.
  ///
  /// The reset request itself may still be pending, but this continuation
  /// can no longer be used to finalize it.
  static const String passwordResetContinuationExpired =
      'PASSWORD_RESET_CONTINUATION_EXPIRED';

  // ---------------------------------------------------------------------------
  // Generic errors
  // ---------------------------------------------------------------------------

  /// 400. The request body could not be parsed.
  ///
  /// A correctly formed client request should not produce this error.
  static const String badRequest = 'BAD_REQUEST';

  /// 400. Field-level request validation failed.
  ///
  /// The response includes field-level details in `fields`.
  static const String validationError = 'VALIDATION_ERROR';

  /// 404. The requested resource does not exist or is not accessible to the
  /// authenticated user.
  ///
  /// Both conditions intentionally use the same response to avoid exposing
  /// resource ownership.
  ///
  /// Never infer this condition from HTTP status alone. A response without
  /// a recognized error code does not establish that the resource is missing.
  static const String resourceNotFound = 'RESOURCE_NOT_FOUND';

  // ---------------------------------------------------------------------------
  // Saved items
  // ---------------------------------------------------------------------------

  /// 400. The submitted URL was parsed but does not contain a usable host.
  ///
  /// This is distinct from [validationError]: the request body passed
  /// structural validation, but the URL itself cannot be used.
  ///
  /// The error is returned before insertion, so the item is known not to
  /// have been saved.
  static const String invalidUrl = 'INVALID_URL';

  /// 500. An unexpected internal server error occurred.
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';

  /// 503. The requested service is unavailable.
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';

  // ---------------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------------

  /// 400. The submitted collection name is blank after trimming or exceeds
  /// the allowed length of 100 runes.
  ///
  /// This is a collection-specific validation failure and requires the
  /// submitted name to be changed.
  static const String invalidCollectionName = 'INVALID_COLLECTION_NAME';

  /// 400. The collection intent is missing or is neither `existing` nor
  /// `create`.
  ///
  /// The intent is not defaulted because the two values have different
  /// outcomes when a collection name already exists. A well-formed client
  /// should not produce this error. It is handled as a malformed request,
  /// not as a duplicate-name conflict.
  static const String invalidCollectionIntent = 'INVALID_COLLECTION_INTENT';

  /// 409. A collection creation was requested with a name already used by
  /// one of the user's collections.
  ///
  /// This applies to the `create` intent. With the `existing` intent, the
  /// matching collection is used as the destination instead.
  ///
  /// The backend rejects the operation before creating or moving anything,
  /// so no changes have been made.
  static const String collectionNameAlreadyExists =
      'COLLECTION_NAME_ALREADY_EXISTS';

  /// 404. The saved item does not exist or belongs to another user.
  ///
  /// This is the not-found code used specifically by the collection move
  /// operation. Both ownership cases intentionally remain indistinguishable.
  static const String savedItemNotFound = 'SAVED_ITEM_NOT_FOUND';

  /// 404. The collection does not exist or belongs to another user.
  ///
  /// Both cases intentionally use the same code to avoid disclosing whether
  /// a collection ID exists.
  ///
  /// This also distinguishes an empty collection from a collection the
  /// caller cannot access: an empty collection returns a successful response
  /// with an empty saved-items list.
  static const String collectionNotFound = 'COLLECTION_NOT_FOUND';

  /// 409. A collection deletion was rejected because saved items remained
  /// in the collection during the operation.
  ///
  /// The database constraint causes the transaction to roll back, leaving
  /// the collection and its items unchanged. This is a known unsuccessful
  /// deletion outcome.
  static const String collectionNotEmpty = 'COLLECTION_NOT_EMPTY';

  /// 409. The requested collection deletion targeted the protected Unsorted
  /// collection.
  ///
  /// The collection is identified by its system key, not by its display name
  /// or type. The operation does not modify any data.
  static const String unsortedCollectionProtected =
      'UNSORTED_COLLECTION_PROTECTED';

  /// 400. The collection deletion request omitted `saved_items_action` or
  /// supplied a value other than `delete` or `move`.
  ///
  /// The action is not defaulted. A well-formed client should not produce this
  /// error; it is handled as a malformed request.
  static const String invalidCollectionDeleteAction =
      'INVALID_COLLECTION_DELETE_ACTION';

  /// 400. The supplied `target_collection_id` does not match the selected
  /// deletion action: it is missing for `move` or present for `delete`.
  ///
  /// A well-formed client should not produce this error; it is handled as a
  /// malformed request.
  static const String invalidCollectionDeleteTarget =
      'INVALID_COLLECTION_DELETE_TARGET';

  /// 404. The destination collection specified by `target_collection_id`
  /// does not exist or belongs to another user.
  ///
  /// This is distinct from [collectionNotFound], which refers to the source
  /// collection being deleted. The destination is validated before any items
  /// are moved or deleted, so the source collection remains unchanged.
  static const String collectionDeleteTargetNotFound =
      'COLLECTION_DELETE_TARGET_NOT_FOUND';

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// 400. The search query is blank after trimming, shorter than 2 runes,
  /// or longer than 128 runes.
  ///
  /// This is the search endpoint's own validation code rather than
  /// [validationError]. Both represent invalid user input and are mapped to
  /// the same client failure category.
  static const String invalidSearchQuery = 'INVALID_SEARCH_QUERY';

  // ---------------------------------------------------------------------------
  // Rate limiting
  // ---------------------------------------------------------------------------

  /// 429. The request exceeded the IP-based login rate limit.
  ///
  /// The response includes Retry-After.
  static const String ipRateLimitExceeded = 'IP_RATE_LIMIT_EXCEEDED';

  /// 503. The IP-based rate limiter is unavailable and refused the request.
  ///
  /// The response does not include Retry-After.
  static const String ipRateLimitUnavailable = 'IP_RATE_LIMIT_UNAVAILABLE';

  /// 503. The client IP address could not be resolved.
  ///
  /// The request could not proceed because the rate-limit identity was
  /// unavailable.
  static const String clientIpUnavailable = 'CLIENT_IP_UNAVAILABLE';

  /// 429. The request exceeded the email-based login rate limit.
  ///
  /// The response includes Retry-After.
  static const String loginRateLimitExceeded = 'LOGIN_RATE_LIMIT_EXCEEDED';

  /// 503. The login email-based rate limiter could not evaluate the request.
  ///
  /// The response does not include Retry-After.
  static const String loginRateLimitUnavailable =
      'LOGIN_RATE_LIMIT_UNAVAILABLE';

  /// 429. The authenticated user's request budget for the endpoint is
  /// exhausted.
  ///
  /// The response includes Retry-After. This limit applies to saved-item
  /// creation, saved-item enrichment, and search requests.
  static const String userRateLimitExceeded = 'USER_RATE_LIMIT_EXCEEDED';

  /// 503. The per-user rate limiter is unavailable and refused the request.
  ///
  /// The response does not include Retry-After.
  static const String userRateLimitUnavailable = 'USER_RATE_LIMIT_UNAVAILABLE';

  /// 503. Password verification capacity is unavailable.
  ///
  /// The response includes Retry-After. The password was never checked, so
  /// this must not be classified as invalid credentials or a rate-limit
  /// rejection.
  static const String passwordWorkUnavailable = 'PASSWORD_WORK_UNAVAILABLE';

  // ---------------------------------------------------------------------------
  // User profile and password
  // ---------------------------------------------------------------------------

  /// 404. No user record exists for the authenticated user's ID.
  ///
  /// An access token can remain valid after its associated account is deleted
  /// because access-token verification does not depend on a live user record.
  /// This is not a session-expiration error and must not automatically trigger
  /// sign-out.
  static const String userNotFound = 'USER_NOT_FOUND';

  /// 401. The submitted current password does not match the stored credential.
  ///
  /// This is a password-verification failure, not an access-token failure.
  /// Refreshing the access token cannot resolve it.
  static const String currentPasswordInvalid = 'CURRENT_PASSWORD_INVALID';

  /// 400. The current password is missing when changing the password for an
  /// account that already has a password credential.
  ///
  /// The request is rejected because the submitted credential state does not
  /// match the account's current state. Nothing is written.
  static const String currentPasswordRequired = 'CURRENT_PASSWORD_REQUIRED';

  /// 400. A current password was supplied when creating the first password
  /// for an account that does not yet have a password credential.
  ///
  /// The unexpected value is rejected rather than silently ignored.
  /// Nothing is written.
  static const String unexpectedCurrentPassword = 'UNEXPECTED_CURRENT_PASSWORD';

  /// 409. Another request created the account's first password before this
  /// request could complete.
  ///
  /// The existing credential is preserved, and this request writes nothing.
  /// The account's credential state has changed, so a first-password form is
  /// no longer appropriate.
  static const String passwordCredentialAlreadyExists =
      'PASSWORD_CREDENTIAL_ALREADY_EXISTS';

  /// 409. Another request changed the password after this request verified
  /// the previous credential.
  ///
  /// The password update and session revocation are performed in one
  /// transaction. If this conflict occurs, the transaction rolls back and
  /// this request writes nothing.
  static const String passwordAlreadyChanged = 'PASSWORD_ALREADY_CHANGED';

  // PASSWORD_CREDENTIAL_NOT_FOUND is intentionally not included. It is used
  // internally to select the first-password creation path and is not returned
  // as an HTTP error response.

  /// Error codes that indicate a refresh session is permanently unusable.
  ///
  /// These responses are definitive terminal failures. The client should
  /// clear stored credentials instead of retrying with the same refresh token.
  ///
  /// Other failures must not be classified as terminal. In particular, a
  /// generic 401, an invalid access token, or a network failure does not
  /// establish that the refresh session has ended. Signing out in those cases
  /// could terminate a valid session after a temporary failure.
  static const Set<String> terminalRefresh = {
    refreshTokenInvalid,
    sessionRevoked,
    sessionExpired,
  };
}
