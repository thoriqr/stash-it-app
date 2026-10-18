/// The authentication credential contract `core/network` depends on.
///
/// This is the seam that keeps the dependency direction honest
/// (`AGENTS.md` §2, rule 1): the auth interceptor lives in `core` and needs to
/// read a token and occasionally trigger a renewal, but it must not know that
/// those tokens live in secure storage, that renewal is an HTTP call, or that
/// anything about Riverpod exists. The implementation is provided by
/// `features/auth`.
///
/// Two methods is the whole contract. Anything richer — a token *pair*, a
/// session, an expiry — would put a decision in `core` that belongs to the
/// feature, and would make the interceptor testable only by standing up the
/// thing it exists to isolate.
abstract interface class TokenProvider {
  /// The access token to attach as `Authorization: Bearer <token>`.
  ///
  /// Returns null when there is no local session. Called per request rather
  /// than cached: a value read once would go stale the moment a refresh
  /// completes, and a stale token is a second round trip to the same 401.
  Future<String?> readAccessToken();

  /// Obtains a usable access token, renewing the session if required.
  ///
  /// Implementations **must** share one in-flight operation across concurrent
  /// callers. Presenting the same refresh token twice is not a harmless retry:
  /// the backend treats the second presentation as reuse, revokes the whole
  /// session, and answers `SESSION_REVOKED` (`auth-sessions.md`, accepted
  /// trade-offs). Two expired requests arriving together must produce one
  /// renewal, not two.
  ///
  /// Throws [SessionExpiredException] when the session is permanently unusable,
  /// and [DioException] for every other failure. The distinction is what lets
  /// the caller clear credentials in one case and keep them in the other.
  Future<String> refreshAccessToken();
}

/// The refresh endpoint refused in a way that ends the session.
///
/// Thrown only for [ApiErrorCode.terminalRefresh]. It is a distinct type rather
/// than a message or a flag because it is the one condition under which the
/// client may destroy credentials it otherwise cannot replace.
class SessionExpiredException implements Exception {
  const SessionExpiredException(this.code);

  /// `REFRESH_TOKEN_INVALID`, `SESSION_REVOKED` or `SESSION_EXPIRED`.
  ///
  /// Retained for logging and tests. Never displayed.
  final String code;

  @override
  String toString() => 'SessionExpiredException($code)';
}
