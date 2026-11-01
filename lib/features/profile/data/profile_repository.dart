import 'package:dio/dio.dart';

import '../../../core/error/api_failure_mapper.dart';
import '../domain/user_profile.dart';
import 'datasources/profile_api.dart';
import 'models/set_password_request.dart';
import 'models/update_display_name_request.dart';
import 'profile_mapper.dart';

class ProfileRepository {
  const ProfileRepository({required this.api});

  final ProfileApi api;

  Future<UserProfile> getUser() async {
    try {
      final response = await api.getUser();
      return profileFrom(response.data.user);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Updates the authenticated user's display name and returns the resulting
  /// profile.
  ///
  /// The returned profile replaces the currently loaded profile; fields are
  /// not merged individually.
  ///
  /// [displayName] is sent exactly as provided. The client does not trim or
  /// change its casing, keeping this behavior consistent with registration.
  ///
  /// A `404 USER_NOT_FOUND` means the account no longer exists. A server error,
  /// transport failure, or unreadable success response does not necessarily
  /// mean the update failed. The name may already have been saved, so the caller
  /// should refetch the profile to establish the current state.
  ///
  /// Throws [ApiFailure] for non-2xx responses.
  Future<UserProfile> updateDisplayName(String displayName) async {
    try {
      final response = await api.updateDisplayName(
        UpdateDisplayNameRequest(displayName: displayName),
      );
      return profileFrom(response.data.user);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // Retrofit may fail to decode a successful response after Dio completes.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Sets the account's first password or changes its existing password.
  ///
  /// [currentPassword] is omitted when null. The client does not choose which
  /// operation runs; that depends on whether the account already has a password.
  ///
  /// A `200` confirms that the password operation succeeded. This method does
  /// not update local state; the caller handles the confirmed result.
  ///
  /// A server error, transport failure, or unreadable response may leave the
  /// outcome uncertain. The password may already have been changed, so the
  /// caller should reconcile the state rather than assume it is unchanged.
  ///
  /// Throws [ApiFailure] for non-2xx responses.
  Future<void> setPassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    try {
      await api.setPassword(
        SetPasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
