import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_response.freezed.dart';
part 'user_profile_response.g.dart';

@freezed
abstract class UserIdentityResponse with _$UserIdentityResponse {
  const factory UserIdentityResponse({
    required String provider,
    @JsonKey(name: 'linked_at') required String linkedAt,
    @JsonKey(name: 'email_snapshot') String? emailSnapshot,
    @JsonKey(name: 'display_name_snapshot') String? displayNameSnapshot,
  }) = _UserIdentityResponse;

  factory UserIdentityResponse.fromJson(Map<String, dynamic> json) =>
      _$UserIdentityResponseFromJson(json);
}

@freezed
abstract class UserResponse with _$UserResponse {
  const factory UserResponse({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'has_password_credential')
    required bool hasPasswordCredential,
    @JsonKey(name: 'created_at') required String createdAt,
    required List<UserIdentityResponse> identities,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

@freezed
abstract class UserDataResponse with _$UserDataResponse {
  const factory UserDataResponse({required UserResponse user}) =
      _UserDataResponse;

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
}

@freezed
abstract class GetUserResponse with _$GetUserResponse {
  const factory GetUserResponse({
    required UserDataResponse data,
    String? message,
  }) = _GetUserResponse;

  factory GetUserResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserResponseFromJson(json);
}

/// The whole `200` body of `PATCH /users/me`.
///
/// Structurally identical to [GetUserResponse], and deliberately a separate type:
/// the endpoint's contract is that it returns the **complete profile as written**,
/// not a partial patch representation, so this response can replace the loaded
/// profile outright. Naming it after the operation keeps that guarantee visible at
/// the call site instead of relying on a reader to know that the GET envelope is
/// reused.
@freezed
abstract class UpdateUserResponse with _$UpdateUserResponse {
  const factory UpdateUserResponse({
    required UserDataResponse data,
    String? message,
  }) = _UpdateUserResponse;

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserResponseFromJson(json);
}
