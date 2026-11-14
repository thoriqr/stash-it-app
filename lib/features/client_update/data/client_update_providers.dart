import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'client_release_repository.dart';
import 'datasources/client_release_api.dart';

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
