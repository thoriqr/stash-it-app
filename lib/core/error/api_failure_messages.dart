import 'api_failure.dart';

/// Feature-agnostic copy for a failed **read**.
///
/// These are the failures every read screen currently reports the same way: a
/// spent rate limit, a server fault, and the unreadable/malformed/validation
/// group. The wording names no feature, content, or session destination.
///
/// Returns null for failures that need screen-specific wording: the session
/// destination, the content that failed to load, a feature-specific
/// availability sentence, or the final fallback. Screens select those first and
/// use this helper only for the remainder.
///
/// **Do not use this for a write.** [ApiFailureUnreadableResponse] and
/// [ApiFailureTransport] do not establish a write's outcome ([D15], [D16]), so
/// mutation copy must say that rather than reuse a read's "could not read the
/// reply" wording.
String? genericReadFailureMessage(Object failure) => switch (failure) {
  ApiFailureRateLimited() => 'Too many attempts. Try again shortly.',
  ApiFailureServerFault() =>
    'We could not reach the server. Try again shortly.',
  ApiFailureUnreadableResponse() ||
  ApiFailureMalformedRequest() ||
  ApiFailureValidation() => "We couldn't read the server's reply. Try again.",
  _ => null,
};
