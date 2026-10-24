import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/set_password_request.dart';
import '../models/set_password_response.dart';
import '../models/update_display_name_request.dart';
import '../models/user_profile_response.dart';

part 'profile_api.g.dart';

/// The profile API surface, issued over `appDio`.
///
/// Returns the envelope, not a bare model, so `data` and `message` are decoded
/// once at the boundary.
@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String? baseUrl}) = _ProfileApi;

  /// `GET /users/me` — the authenticated user's profile and linked identities.
  @GET('/users/me')
  Future<GetUserResponse> getUser();

  /// `PATCH /users/me` — renames the authenticated user.
  ///
  /// **Mounted as `Auth` only**: the route has no rate limiter, so a `401` comes
  /// from the guard before the handler runs and the write is known not to have
  /// happened. A `404 USER_NOT_FOUND` means the account behind a still-valid token
  /// is gone.
  ///
  /// The `200` carries the complete profile as the request wrote it. A later
  /// identity read can fail after the rename committed and answer `500`, so a
  /// server fault does not prove the name is unchanged.
  ///
  /// The route accepts only `display_name`; see [UpdateDisplayNameRequest] for why
  /// the value is not trimmed.
  @PATCH('/users/me')
  Future<UpdateUserResponse> updateDisplayName(
    @Body() UpdateDisplayNameRequest request,
  );

  /// `PUT /users/me/password` — creates the account's first password or replaces
  /// an existing one.
  ///
  /// **Mounted as `Auth` → per-user rate limit → handler.** A `429` or `503` from
  /// the limiter is refused before the handler and writes nothing. The budget is
  /// five requests per fifteen minutes per user, and a failed attempt spends it.
  ///
  /// Which operation runs is decided by the stored credential, not by the body.
  /// `current_password` is required only when one already exists; sending it for
  /// an account with none is refused rather than ignored.
  ///
  /// A successful change revokes every other session of the account but preserves
  /// the caller's. That revocation does **not** invalidate an access token already
  /// issued: those are stateless and keep working until their own expiry.
  ///
  /// The `200` carries `data: null`; see [SetPasswordResponse] for why only the
  /// envelope is modelled.
  @PUT('/users/me/password')
  Future<SetPasswordResponse> setPassword(@Body() SetPasswordRequest request);
}
