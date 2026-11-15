import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/client_update/application/client_update_download_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/data/release_download_service.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_status.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';
import 'package:stash_it_app/features/client_update/domain/release_install.dart';

ClientUpdatePrompt _prompt({bool required = false}) {
  return ClientUpdatePrompt(
    status: required
        ? ClientUpdateStatus.required
        : ClientUpdateStatus.optional,
    release: ClientUpdateRelease(
      version: '1.1.1',
      build: 3,
      downloadUrl: Uri.parse(
        'https://downloads.stashit.thoriqr.my.id/android/stash-it-1.1.1-3.apk',
      ),
      sha256: List.filled(64, 'a').join(),
    ),
  );
}

class _FakeDownloadService implements ReleaseDownloadService {
  _FakeDownloadService(this.result);

  ReleaseDownloadResult result;
  int calls = 0;

  @override
  Future<ReleaseDownloadResult> download({
    required ClientUpdateRelease release,
    required String platform,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onProgress,
    void Function()? onVerifying,
  }) async {
    calls++;
    onProgress?.call(50, 100);
    onVerifying?.call();
    return result;
  }
}

class _ControlledDownloadService implements ReleaseDownloadService {
  final completer = Completer<ReleaseDownloadResult>();

  @override
  Future<ReleaseDownloadResult> download({
    required ClientUpdateRelease release,
    required String platform,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onProgress,
    void Function()? onVerifying,
  }) {
    completer.future.ignore();
    return completer.future;
  }
}

class _ProgressDownloadService implements ReleaseDownloadService {
  final completer = Completer<ReleaseDownloadResult>();

  @override
  Future<ReleaseDownloadResult> download({
    required ClientUpdateRelease release,
    required String platform,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onProgress,
    void Function()? onVerifying,
  }) {
    onProgress?.call(25, 100);
    onVerifying?.call();
    return completer.future;
  }
}

class _FakeInstaller implements ReleaseInstaller {
  _FakeInstaller(this.result);

  ReleaseInstallResult result;
  int calls = 0;
  String? lastPath;

  @override
  Future<ReleaseInstallResult> open({
    required String filePath,
    required String platform,
  }) async {
    calls++;
    lastPath = filePath;
    return result;
  }
}

ProviderContainer _container({
  required ReleaseDownloadService service,
  required ReleaseInstaller installer,
}) {
  final container = ProviderContainer(
    overrides: [
      clientPlatformProvider.overrideWithValue('android'),
      releaseDownloadServiceProvider.overrideWithValue(service),
      releaseInstallerProvider.overrideWithValue(installer),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ClientUpdateDownload', () {
    test('downloads, verifies, and hands the file to the installer', () async {
      final service = _FakeDownloadService(
        const ReleaseDownloadSuccess(filePath: '/cache/app.apk', bytes: 10),
      );
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);

      await container
          .read(clientUpdateDownloadProvider.notifier)
          .start(_prompt());

      final state = container.read(clientUpdateDownloadProvider);
      expect(state.stage, ClientUpdateDownloadStage.opened);
      expect(state.filePath, '/cache/app.apk');
      expect(installer.calls, 1);
      expect(installer.lastPath, '/cache/app.apk');
    });

    test('a network failure leaves a retryable error', () async {
      final service = _FakeDownloadService(const ReleaseDownloadFailed());
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);

      await container
          .read(clientUpdateDownloadProvider.notifier)
          .start(_prompt());

      final state = container.read(clientUpdateDownloadProvider);
      expect(state.stage, ClientUpdateDownloadStage.failed);
      expect(state.error, ClientUpdateDownloadError.network);
      expect(installer.calls, 0);
    });

    test('a checksum mismatch is distinct and never installs', () async {
      final service = _FakeDownloadService(
        const ReleaseDownloadChecksumMismatch(),
      );
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);

      await container
          .read(clientUpdateDownloadProvider.notifier)
          .start(_prompt());

      final state = container.read(clientUpdateDownloadProvider);
      expect(state.stage, ClientUpdateDownloadStage.failed);
      expect(state.error, ClientUpdateDownloadError.checksumMismatch);
      expect(installer.calls, 0);
    });

    test('a rejected host never installs', () async {
      final service = _FakeDownloadService(const ReleaseDownloadHostRejected());
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);

      await container
          .read(clientUpdateDownloadProvider.notifier)
          .start(_prompt());

      expect(
        container.read(clientUpdateDownloadProvider).error,
        ClientUpdateDownloadError.hostRejected,
      );
      expect(installer.calls, 0);
    });

    test(
      'an unsupported platform is reported without an installer call',
      () async {
        final service = _FakeDownloadService(
          const ReleaseDownloadUnsupportedPlatform(),
        );
        final installer = _FakeInstaller(const ReleaseInstallHandedOff());
        final container = _container(service: service, installer: installer);

        await container
            .read(clientUpdateDownloadProvider.notifier)
            .start(_prompt());

        expect(
          container.read(clientUpdateDownloadProvider).error,
          ClientUpdateDownloadError.unsupportedPlatform,
        );
        expect(installer.calls, 0);
      },
    );

    test(
      'retry after an installer failure reopens without redownloading',
      () async {
        final service = _FakeDownloadService(
          const ReleaseDownloadSuccess(filePath: '/cache/app.apk', bytes: 10),
        );
        final installer = _FakeInstaller(const ReleaseInstallFailed());
        final container = _container(service: service, installer: installer);
        final prompt = _prompt();

        await container
            .read(clientUpdateDownloadProvider.notifier)
            .start(prompt);

        var state = container.read(clientUpdateDownloadProvider);
        expect(state.stage, ClientUpdateDownloadStage.failed);
        expect(state.error, ClientUpdateDownloadError.installerFailed);
        expect(state.filePath, '/cache/app.apk');
        expect(service.calls, 1);

        installer.result = const ReleaseInstallHandedOff();
        await container
            .read(clientUpdateDownloadProvider.notifier)
            .retry(prompt);

        state = container.read(clientUpdateDownloadProvider);
        expect(state.stage, ClientUpdateDownloadStage.opened);
        expect(service.calls, 1);
        expect(installer.calls, 2);
      },
    );

    test(
      'install permission failure reopens after the user grants it',
      () async {
        final service = _FakeDownloadService(
          const ReleaseDownloadSuccess(filePath: '/cache/app.apk', bytes: 10),
        );
        final installer = _FakeInstaller(
          const ReleaseInstallPermissionRequired(),
        );
        final container = _container(service: service, installer: installer);
        final prompt = _prompt();

        await container
            .read(clientUpdateDownloadProvider.notifier)
            .start(prompt);

        var state = container.read(clientUpdateDownloadProvider);
        expect(state.stage, ClientUpdateDownloadStage.failed);
        expect(state.error, ClientUpdateDownloadError.installPermission);
        expect(state.filePath, '/cache/app.apk');
        expect(service.calls, 1);

        installer.result = const ReleaseInstallHandedOff();
        await container
            .read(clientUpdateDownloadProvider.notifier)
            .retry(prompt);

        state = container.read(clientUpdateDownloadProvider);
        expect(state.stage, ClientUpdateDownloadStage.opened);
        expect(service.calls, 1);
        expect(installer.calls, 2);
      },
    );

    test('retry after a download failure downloads again', () async {
      final service = _FakeDownloadService(const ReleaseDownloadFailed());
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);
      final prompt = _prompt();

      await container.read(clientUpdateDownloadProvider.notifier).start(prompt);
      service.result = const ReleaseDownloadSuccess(
        filePath: '/cache/app.apk',
        bytes: 10,
      );
      await container.read(clientUpdateDownloadProvider.notifier).retry(prompt);

      expect(service.calls, 2);
      expect(
        container.read(clientUpdateDownloadProvider).stage,
        ClientUpdateDownloadStage.opened,
      );
    });

    test('reset ignores a completion from the canceled attempt', () async {
      final service = _ControlledDownloadService();
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);
      final controller = container.read(clientUpdateDownloadProvider.notifier);

      final pending = controller.start(_prompt());
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(clientUpdateDownloadProvider).stage,
        ClientUpdateDownloadStage.downloading,
      );

      controller.reset();
      expect(
        container.read(clientUpdateDownloadProvider).stage,
        ClientUpdateDownloadStage.idle,
      );

      service.completer.complete(
        const ReleaseDownloadSuccess(filePath: '/cache/app.apk', bytes: 10),
      );
      await pending;

      expect(
        container.read(clientUpdateDownloadProvider).stage,
        ClientUpdateDownloadStage.idle,
      );
      expect(installer.calls, 0);
    });

    test('progress and verification are reflected before completion', () async {
      final service = _ProgressDownloadService();
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);
      final controller = container.read(clientUpdateDownloadProvider.notifier);

      final pending = controller.start(_prompt());
      await Future<void>.delayed(Duration.zero);

      final state = container.read(clientUpdateDownloadProvider);
      expect(state.stage, ClientUpdateDownloadStage.verifying);
      expect(state.receivedBytes, 25);
      expect(state.totalBytes, 100);

      service.completer.complete(const ReleaseDownloadCancelled());
      await pending;
    });

    test('openAgain reopens the downloaded file without downloading', () async {
      final service = _FakeDownloadService(
        const ReleaseDownloadSuccess(filePath: '/cache/app.apk', bytes: 10),
      );
      final installer = _FakeInstaller(const ReleaseInstallHandedOff());
      final container = _container(service: service, installer: installer);
      final controller = container.read(clientUpdateDownloadProvider.notifier);

      await controller.start(_prompt());
      await controller.openAgain();

      expect(service.calls, 1);
      expect(installer.calls, 2);
    });
  });
}
