import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_data.freezed.dart';
part 'logout_data.g.dart';

/// Represents the response data of a successful `POST /auth/logout`.
///
/// The endpoint returns `null` as its data payload. This concrete type keeps
/// the API response model explicit instead of using a generic `Object?`.
@freezed
abstract class LogoutData with _$LogoutData {
  const factory LogoutData() = _LogoutData;

  factory LogoutData.fromJson(Map<String, dynamic> json) =>
      _$LogoutDataFromJson(json);
}
