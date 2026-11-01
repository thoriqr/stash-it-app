import 'api_error_codes.dart';

/// A field-level validation failure returned by the API.
///
/// The `fields` collection is always present in a coded error response.
/// It may be empty when the error does not contain field-level failures.
class ApiErrorField {
  const ApiErrorField({required this.field, required this.message});

  /// Name of the field rejected by the API.
  final String field;

  /// Backend-provided description of the validation failure.
  ///
  /// Never display this message directly. The client owns user-facing copy.
  final String message;

  @override
  String toString() => 'ApiErrorField($field)';
}

/// Decoded `error` object from an API failure response.
///
/// ```json
/// {
///   "error": {
///     "code": "...",
///     "message": "...",
///     "fields": []
///   }
/// }
/// ```
///
/// The backend-provided [message] is parsed to preserve the response shape
/// and detect malformed payloads, but it is never displayed to users.
/// User-facing error messages must be defined by the client.
///
/// [code] is nullable because not every failure response uses this JSON
/// envelope. Some framework-level errors may return a different response
/// format, so the client must not assume that a structured error code exists.
class ApiErrorBody {
  const ApiErrorBody({
    this.code,
    this.message,
    this.fields = const <ApiErrorField>[],
  });

  final String? code;
  final String? message;
  final List<ApiErrorField> fields;

  /// Whether the error specifically indicates an expired access token.
  ///
  /// This is the only condition that should trigger token renewal.
  /// HTTP status alone is insufficient because the same status can represent
  /// expired, invalid, or missing authentication credentials.
  bool get isAccessTokenExpired => code == ApiErrorCode.accessTokenExpired;

  /// Whether the refresh response indicates that the session is permanently
  /// unusable.
  ///
  /// Only use this classification for responses from `POST /auth/refresh`.
  bool get isTerminalSession => ApiErrorCode.terminalRefresh.contains(code);
}
