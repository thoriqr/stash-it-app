import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/api_envelope.dart';
import '../models/auth_tokens_response.dart';
import '../models/refresh_request.dart';

part 'refresh_api.g.dart';

/// The renewal surface, issued over `refreshDio`.
///
/// A **separate Dio instance with no auth interceptor**, which is what makes
/// recursive refresh structurally impossible rather than merely guarded against.
/// A refresh response cannot reach [AuthInterceptor] because the interceptor is
/// not on this instance, so no flag, path comparison or depth counter is needed
/// to prevent it — and none can be forgotten.
///
/// That separation also means this client never sends an `Authorization` header
/// on renewal, which is correct: the route has no bearer guard and the token in
/// the body is the whole credential.
@RestApi()
abstract class RefreshApi {
  factory RefreshApi(Dio dio, {String? baseUrl}) = _RefreshApi;

  /// `POST /auth/refresh`
  ///
  /// Bounded per client address at 60 per 10 minutes, and **failing closed**:
  /// during a Redis outage it answers `503 IP_RATE_LIMIT_UNAVAILABLE` before the
  /// handler runs, so no rotation happens and no token is consumed. The refresh
  /// token remains usable once the counter recovers — which is exactly why a
  /// `503` here must not clear credentials.
  @POST('/auth/refresh')
  Future<ApiEnvelope<AuthTokensResponse>> refresh(
    @Body() RefreshRequest request,
  );
}
