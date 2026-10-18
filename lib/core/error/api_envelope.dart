import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// The backend's success envelope: `{"data": ..., "message": "...", "meta": ...}`.
///
/// `meta` is omitted entirely by endpoints that do not paginate
/// (`httpx/response.go`), so it is absent rather than null and stays nullable.
///
/// `data` is nullable because `POST /auth/logout` answers `{"data": null, ...}`
/// — `httpx.OKMessage` writes a nil `Data` pointer — while every other endpoint
/// in this milestone returns an object. A non-nullable `T` would fail to decode
/// a successful logout.
///
/// [genericArgumentFactories] is what makes the generic decode: `json_serializable`
/// cannot generate a `fromJson` for a bare type parameter without it.
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
