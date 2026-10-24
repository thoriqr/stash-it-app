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

  /// Renames the authenticated user and returns the complete profile the server
  /// wrote.
  ///
  /// **The response replaces the loaded profile; it is never merged field by
  /// field.** The backend returns the row its own `UPDATE` produced, in the same
  /// shape as `GET /users/me`, so there is no second representation to reconcile.
  ///
  /// **[displayName] is sent exactly as given.** The endpoint does not trim or
  /// case-fold, and doing either here would make this path disagree with
  /// registration, which stores the same column verbatim.
  ///
  /// A `404 USER_NOT_FOUND` means the account behind the token is gone. A `500`
  /// does **not** prove the rename did not happen: the handler commits the name
  /// before reading identities, and a later identity-read failure is reported as a
  /// server fault. A transport failure or an unreadable success body does not
  /// establish the outcome either. The caller must treat those as ambiguous and
  /// reconcile by refetching.
  ///
  /// Throws [ApiFailure] for every non-2xx refusal.
  Future<UserProfile> updateDisplayName(String displayName) async {
    try {
      final response = await api.updateDisplayName(
        UpdateDisplayNameRequest(displayName: displayName),
      );
      return profileFrom(response.data.user);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A `2xx` whose body does not match the documented shape. Retrofit decodes
      // after Dio's transformer returns, so this never passes through Dio.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Creates the account's first password, or changes the existing one.
  ///
  /// **[currentPassword] is omitted entirely when null.** The backend treats an
  /// absent field and `""` the same, and the create operation is stated by sending
  /// only `new_password`. The client never decides which operation runs; the
  /// stored credential does.
  ///
  /// **A `200` is the only confirmation this method gives.** It means the create
  /// inserted, or the change's update-and-revoke transaction committed. Nothing is
  /// changed locally here; the caller applies the confirmed outcome.
  ///
  /// A `500`, a transport failure or an unreadable body is ambiguous for the
  /// password write: a commit error can be raised after the transaction may have
  /// committed, and an unreadable `2xx` body is still a successful status. The
  /// caller must reconcile rather than claim the password is unchanged.
  ///
  /// Throws [ApiFailure] for every non-2xx refusal.
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
