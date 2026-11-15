import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/network/network_providers.dart';
import '../domain/release_install.dart';
import 'client_release_repository.dart';
import 'datasources/client_release_api.dart';
import 'release_download_service.dart';
import 'release_installer.dart';

final Provider<ClientReleaseApi> clientReleaseApiProvider =
    Provider<ClientReleaseApi>(
      (ref) => ClientReleaseApi(ref.watch(appDioProvider)),
    );

final Provider<ClientReleaseRepository> clientReleaseRepositoryProvider =
    Provider<ClientReleaseRepository>(
      (ref) =>
          ClientReleaseRepository(api: ref.watch(clientReleaseApiProvider)),
    );

/// The platform identifier sent to the release endpoint.
///
/// Uses the operating system name (for example `android`, `windows`, or
/// `macos`). Overridden in tests so the check never depends on the host
/// running the test.
final Provider<String> clientPlatformProvider = Provider<String>(
  (ref) => Platform.operatingSystem,
);

/// Dio client used only for release artifacts.
///
/// It has no authentication or client-metadata interceptors, so the API bearer
/// token is never sent to the download host. Redirects are disabled so a
/// response cannot move the request to a host outside the allowlist.
final Provider<Dio> clientUpdateDownloadDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
});

final Provider<ReleaseDownloadService> releaseDownloadServiceProvider =
    Provider<ReleaseDownloadService>((ref) {
      return DioReleaseDownloadService(
        dio: ref.watch(clientUpdateDownloadDioProvider),
        tempDirectory: getTemporaryDirectory,
      );
    });

final Provider<ReleaseInstaller> releaseInstallerProvider =
    Provider<ReleaseInstaller>((ref) => const PlatformReleaseInstaller());
