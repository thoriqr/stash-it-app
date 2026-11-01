import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/api_envelope.dart';
import '../models/auth_tokens_response.dart';
import '../models/refresh_request.dart';

part 'refresh_api.g.dart';

/// Defines the token renewal API used by the client.
///
/// Uses a separate Dio instance without the authentication interceptor.
/// This prevents refresh requests from triggering another refresh cycle.
///
/// The endpoint does not require a bearer token. The refresh token is sent
/// in the request body as the credential for renewal.
@RestApi()
abstract class RefreshApi {
  factory RefreshApi(Dio dio, {String? baseUrl}) = _RefreshApi;

  /// `POST /auth/refresh`
  ///
  /// Exchanges the submitted refresh token for a new access and refresh token
  /// pair.
  @POST('/auth/refresh')
  Future<ApiEnvelope<AuthTokensResponse>> refresh(
    @Body() RefreshRequest request,
  );
}
