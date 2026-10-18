import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_data.freezed.dart';
part 'logout_data.g.dart';

/// The `data` of a successful `POST /auth/logout`, which is always `null`.
///
/// Exists so the endpoint's return type is concrete. `ApiEnvelope.data` is
/// already nullable and would decode `null` fine, but typing it as `Object?`
/// makes the generated decoder an identity cast — a value passed to a decoder
/// that returns the same value, which reads as though something were being
/// checked when nothing is.
///
/// Declaring the type keeps the envelope honest: this endpoint carries no
/// payload, and a type named for that is easier to notice than `Object?` when
/// someone later adds a field.
@freezed
abstract class LogoutData with _$LogoutData {
  const factory LogoutData() = _LogoutData;

  factory LogoutData.fromJson(Map<String, dynamic> json) =>
      _$LogoutDataFromJson(json);
}
