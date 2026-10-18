import 'api_error_codes.dart';

/// One field-level validation failure.
///
/// `error.fields` is always present on a coded error and is `[]` when empty
/// (`httpx/error_handler.go:75`), so a client must tolerate an empty list rather
/// than treating its absence as meaningful.
///
/// Hand-written rather than generated: it never crosses a boundary on its own,
/// only inside [ApiErrorBody], so a generated `fromJson` for it would be dead
/// code.
class ApiErrorField {
  const ApiErrorField({required this.field, required this.message});

  /// The rejected field's name.
  final String field;

  /// The backend's description of the failure. Never displayed ([D22]).
  final String message;

  @override
  String toString() => 'ApiErrorField($field)';
}

/// The decoded `error` object from a backend failure response.
///
/// ```json
/// { "error": { "code": "...", "message": "...", "fields": [ ... ] } }
/// ```
///
/// **[D22] `message` is never displayed to a user.** It is human-facing prose in
/// English and is not part of any contract. It is parsed so the shape is honest
/// and so a malformed payload can be *detected*, never so it can be shown. The
/// client owns every string it renders; see `ApiFailure`.
///
/// `code` is nullable on purpose. The envelope is not guaranteed:
/// `httpx.NewErrorHandler` delegates to `fiber.DefaultErrorHandler` for any
/// `*fiber.Error`, checked before the `AppError` branch, and Fiber's default
/// handler answers with `text/plain` and a bare message rather than JSON
/// (`decisions.md` D15, group F).
class ApiErrorBody {
  const ApiErrorBody({
    this.code,
    this.message,
    this.fields = const <ApiErrorField>[],
  });

  final String? code;
  final String? message;
  final List<ApiErrorField> fields;

  /// Whether this body's code means the access token expired and nothing else.
  ///
  /// The single place the refresh trigger is decided. Every caller about to
  /// refresh asks this rather than testing the HTTP status: a `401` on its own
  /// covers expired, unusable and never-sent alike, and renewing for the latter
  /// two cannot succeed.
  bool get isAccessTokenExpired => code == ApiErrorCode.accessTokenExpired;

  /// Whether this body's code means the session is permanently unusable.
  ///
  /// Only ever true for a response from `POST /auth/refresh`. See
  /// [ApiErrorCode.terminalRefresh].
  bool get isTerminalSession => ApiErrorCode.terminalRefresh.contains(code);
}
