import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// Standard success response envelope returned by the backend.
///
/// The response contains `data` and may include `message` and `meta`.
///
/// `meta` is nullable because endpoints that do not paginate omit it from
/// the response entirely.
///
/// `data` is nullable because some successful operations, such as
/// `POST /auth/logout`, return `{"data": null, ...}`. Other endpoints may
/// return an object, depending on the requested response type.
///
/// Generic argument factories allow `json_serializable` to decode [T] using
/// the type-specific [fromJsonT] function supplied by the caller.
@Freezed(genericArgumentFactories: true)
abstract class ApiEnvelope<T> with _$ApiEnvelope<T> {
  const factory ApiEnvelope({
    T? data,
    String? message,
    Map<String, dynamic>? meta,
  }) = _ApiEnvelope<T>;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? fromJsonT) fromJsonT,
  ) => _$ApiEnvelopeFromJson(json, fromJsonT);
}
