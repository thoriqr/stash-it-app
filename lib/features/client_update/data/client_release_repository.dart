import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../app/config/download_config.dart';
import '../domain/client_update_release.dart';
import 'client_release_mapper.dart';
import 'datasources/client_release_api.dart';

/// Reads the release policy for the running build.
///
/// The check is best effort: non-2xx responses, timeouts, transport failures,
/// and undecodable bodies all produce [ClientUpdateUnavailable]. The app never
/// reports an update error to the user because of an automatic check, and it
/// remains fully usable.
class ClientReleaseRepository {
  const ClientReleaseRepository({required this.api});

  static const Duration _timeout = Duration(seconds: 8);

  final ClientReleaseApi api;

  Future<ClientUpdateCheckResult> check({
    required String platform,
    required int build,
  }) async {
    try {
      final response = await api.check(
        platform,
        build,
        RequestOptions(
          path: '',
          connectTimeout: _timeout,
          receiveTimeout: _timeout,
          sendTimeout: _timeout,
        ),
      );

      return clientUpdateFromResponse(
        response,
        allowedHost: DownloadConfig.host,
      );
    } catch (error) {
      developer.log(
        'client release check failed: ${error.runtimeType}',
        name: 'client_update',
      );
      return const ClientUpdateUnavailable();
    }
  }
}
