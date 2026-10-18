import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/api_envelope.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/logout_data.dart';

part 'auth_api.g.dart';

/// The authenticated API surface, issued over `appDio`.
///
/// Returns API envelopes rather than bare models, so `data`, `message` and
/// `meta` are decoded once at the boundary and the mapper above them never has
/// to reach into a raw map.
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// `POST /auth/login`
  ///
  /// Unauthenticated, and bounded per client address and per email address
  /// (30/10min and 10/15min). A `429` here is a real budget, not a defect.
  @POST('/auth/login')
  Future<ApiEnvelope<LoginResponse>> login(@Body() LoginRequest request);

  /// `POST /auth/logout`
  ///
  /// **No request body.** The backend binds none: it revokes the session named
  /// by the verified token's `sid` claim, which the guard has already
  /// established, so a body would be ignored at best and misleading at worst.
  ///
  /// Returns `ApiEnvelope<LogoutData>` because the success body is
  /// `{"data": null, "message": "logout successful"}` — `httpx.OKMessage` writes
  /// a nil `Data` pointer. `ApiEnvelope.data` is nullable so that decodes; a
  /// dedicated payload type rather than `Object?` keeps the generated decoder
  /// meaningful instead of an identity cast.
  ///
  /// The call is idempotent server-side: a missing, already-revoked or
  /// foreign session all answer `200`, so a retry after a lost response is safe.
  @POST('/auth/logout')
  Future<ApiEnvelope<LogoutData>> logout();
}
