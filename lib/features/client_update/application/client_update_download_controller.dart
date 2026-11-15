import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/client_update_providers.dart';
import '../domain/client_update_release.dart';
import '../domain/release_download.dart';
import '../domain/release_install.dart';

part 'client_update_download_controller.g.dart';

/// Downloads the current release, verifies its checksum, and hands it to the
/// platform installer.
///
/// The controller never installs silently. Android opens the package installer
/// and Windows opens the ZIP; the user finishes the operation.
@Riverpod(keepAlive: true)
class ClientUpdateDownload extends _$ClientUpdateDownload {
  CancelToken? _cancelToken;

  /// Invalidates completions from an older attempt after a retry or dismissal.
  int _generation = 0;

  @override
  ClientUpdateDownloadState build() => const ClientUpdateDownloadState();

  /// Starts a fresh download for [prompt].
  Future<void> start(ClientUpdatePrompt prompt) async {
    if (state.busy) return;

    final generation = ++_generation;
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    state = ClientUpdateDownloadState(
      stage: ClientUpdateDownloadStage.downloading,
      totalBytes: prompt.release.fileSizeBytes,
    );

    final platform = ref.read(clientPlatformProvider);

    try {
      final result = await ref
          .read(releaseDownloadServiceProvider)
          .download(
            release: prompt.release,
            platform: platform,
            cancelToken: cancelToken,
            onProgress: (received, total) {
              if (!ref.mounted || generation != _generation) return;
              state = state.copyWith(
                stage: ClientUpdateDownloadStage.downloading,
                receivedBytes: received,
                totalBytes: total,
              );
            },
            onVerifying: () {
              if (!ref.mounted || generation != _generation) return;
              state = state.copyWith(
                stage: ClientUpdateDownloadStage.verifying,
              );
            },
          );

      if (!ref.mounted || generation != _generation) return;

      switch (result) {
        case ReleaseDownloadSuccess(:final filePath):
          await _handOff(filePath, generation: generation);

        case ReleaseDownloadCancelled():
          state = const ClientUpdateDownloadState();

        case ReleaseDownloadHostRejected():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.hostRejected,
          );

        case ReleaseDownloadUnsupportedPlatform():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.unsupportedPlatform,
          );

        case ReleaseDownloadChecksumMissing():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.checksumMissing,
          );

        case ReleaseDownloadChecksumMismatch():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.checksumMismatch,
          );

        case ReleaseDownloadFailed():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.network,
          );
      }
    } catch (_) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(
        stage: ClientUpdateDownloadStage.failed,
        error: ClientUpdateDownloadError.network,
      );
    } finally {
      if (generation == _generation) _cancelToken = null;
    }
  }

  /// Retries the current failure.
  ///
  /// A handoff failure reopens the already verified file instead of downloading
  /// it again.
  Future<void> retry(ClientUpdatePrompt prompt) async {
    final current = state;
    final installerFailure =
        current.error == ClientUpdateDownloadError.installerFailed ||
        current.error == ClientUpdateDownloadError.installPermission;
    if (installerFailure && current.filePath != null) {
      await _handOff(current.filePath!, generation: ++_generation);
      return;
    }
    await start(prompt);
  }

  /// Reopens an artifact that is already downloaded and verified.
  Future<void> openAgain() async {
    final path = state.filePath;
    if (path == null) return;
    await _handOff(path, generation: ++_generation);
  }

  /// Cancels any running download and returns to the initial state.
  void reset() {
    _generation++;
    _cancelToken?.cancel();
    _cancelToken = null;
    if (ref.mounted) state = const ClientUpdateDownloadState();
  }

  Future<void> _handOff(String filePath, {required int generation}) async {
    if (!ref.mounted || generation != _generation) return;

    state = state.copyWith(
      stage: ClientUpdateDownloadStage.opening,
      filePath: filePath,
      clearError: true,
    );

    final platform = ref.read(clientPlatformProvider);

    try {
      final result = await ref
          .read(releaseInstallerProvider)
          .open(filePath: filePath, platform: platform);

      if (!ref.mounted || generation != _generation) return;

      switch (result) {
        case ReleaseInstallHandedOff():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.opened,
            clearError: true,
          );

        case ReleaseInstallPermissionRequired():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.installPermission,
          );

        case ReleaseInstallUnsupported():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.unsupportedPlatform,
          );

        case ReleaseInstallFailed():
          state = state.copyWith(
            stage: ClientUpdateDownloadStage.failed,
            error: ClientUpdateDownloadError.installerFailed,
          );
      }
    } catch (_) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(
        stage: ClientUpdateDownloadStage.failed,
        error: ClientUpdateDownloadError.installerFailed,
      );
    }
  }
}
