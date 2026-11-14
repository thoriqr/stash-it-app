import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/client_release_response.dart';

part 'client_release_api.g.dart';

/// Client release API, issued over `appDio`.
///
/// `GET /client-releases/latest` reports whether this build should update.
/// The server decides using its own release policy; the client must not
/// compare version strings.
@RestApi()
abstract class ClientReleaseApi {
  factory ClientReleaseApi(Dio dio, {String? baseUrl}) = _ClientReleaseApi;

  /// Checks the release status for [platform] and [build].
  ///
  /// The check uses a shorter timeout than ordinary API requests because the
  /// app remains usable while it runs and failure is handled by doing nothing.
  @GET('/client-releases/latest')
  Future<ClientReleaseEnvelope> check(
    @Query('platform') String platform,
    @Query('build') int build,
    @DioOptions() RequestOptions options,
  );
}
