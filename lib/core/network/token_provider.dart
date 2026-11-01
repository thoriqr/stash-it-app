/// Authentication credential contract required by `core/network`.
///
/// Keeps the network layer independent of authentication implementation
/// details. The interceptor can read an access token and request renewal
/// without knowing how credentials are stored, how renewal is performed,
/// or which state management solution is used.
///
/// Implemented by `features/auth`.
///
/// The contract intentionally exposes only two operations. Token storage,
/// session state, and credential lifecycle remain responsibilities of the
/// authentication feature.
abstract interface class TokenProvider {
  /// Returns the access token to attach as a bearer token.
  ///
  /// Returns null when no local session exists. Called for each request rather
  /// than cached, so requests issued after a renewal use the latest token.
  Future<String?> readAccessToken();

  /// Returns a usable access token, renewing the session when necessary.
  ///
  /// Implementations must share one in-flight renewal operation across
  /// concurrent callers. Reusing the same refresh token in multiple concurrent
  /// requests can be treated as token reuse and revoke the session. Requests
  /// that encounter an expired access token together must therefore result
  /// in only one renewal operation.
  ///
  /// Throws [SessionExpiredException] when the session is permanently
  /// unusable, and [DioException] for other renewal failures. This distinction
  /// allows the caller to handle terminal session failures separately from
  /// temporary or recoverable failures.
  Future<String> refreshAccessToken();
}

/// Indicates that a refresh attempt ended the current session.
///
/// Thrown only when the refresh failure is classified as terminal. This
/// distinction allows the caller to clear stored credentials when the
/// session is no longer usable without treating every renewal failure as
/// a reason to sign the user out.
class SessionExpiredException implements Exception {
  const SessionExpiredException(this.code);

  /// Error code identifying the terminal refresh failure.
  ///
  /// Retained for logging and tests. Never displayed to the user.
  final String code;

  @override
  String toString() => 'SessionExpiredException($code)';
}
