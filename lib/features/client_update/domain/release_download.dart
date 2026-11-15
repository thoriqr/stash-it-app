import 'package:flutter/foundation.dart';

/// The phases of downloading and handing off a release artifact.
enum ClientUpdateDownloadStage {
  idle,
  downloading,
  verifying,
  opening,
  opened,
  failed,
}

/// A reason the download or handoff could not finish.
enum ClientUpdateDownloadError {
  /// The artifact could not be downloaded or saved.
  network,

  /// The saved bytes do not match the release checksum.
  checksumMismatch,

  /// The release did not include a usable checksum.
  checksumMissing,

  /// The URL was not HTTPS on the configured download host.
  hostRejected,

  /// This platform has no supported install handoff.
  unsupportedPlatform,

  /// The downloaded file exists, but the installer could not be opened.
  installerFailed,

  /// Android needs the user to allow installs from this app.
  installPermission,
}

/// Download progress and handoff state for the current prompt.
@immutable
class ClientUpdateDownloadState {
  const ClientUpdateDownloadState({
    this.stage = ClientUpdateDownloadStage.idle,
    this.receivedBytes = 0,
    this.totalBytes,
    this.filePath,
    this.error,
  });

  final ClientUpdateDownloadStage stage;
  final int receivedBytes;
  final int? totalBytes;
  final String? filePath;
  final ClientUpdateDownloadError? error;

  /// Whether the download or handoff is still running.
  bool get busy =>
      stage == ClientUpdateDownloadStage.downloading ||
      stage == ClientUpdateDownloadStage.verifying ||
      stage == ClientUpdateDownloadStage.opening;

  /// Download fraction from 0 to 1, or null when the total is unknown.
  double? get progress {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (receivedBytes / total).clamp(0.0, 1.0);
  }

  ClientUpdateDownloadState copyWith({
    ClientUpdateDownloadStage? stage,
    int? receivedBytes,
    int? totalBytes,
    String? filePath,
    ClientUpdateDownloadError? error,
    bool clearError = false,
  }) {
    return ClientUpdateDownloadState(
      stage: stage ?? this.stage,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      filePath: filePath ?? this.filePath,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// The outcome of downloading and verifying one release artifact.
sealed class ReleaseDownloadResult {
  const ReleaseDownloadResult();
}

final class ReleaseDownloadSuccess extends ReleaseDownloadResult {
  const ReleaseDownloadSuccess({required this.filePath, required this.bytes});

  final String filePath;
  final int bytes;
}

final class ReleaseDownloadHostRejected extends ReleaseDownloadResult {
  const ReleaseDownloadHostRejected();
}

final class ReleaseDownloadUnsupportedPlatform extends ReleaseDownloadResult {
  const ReleaseDownloadUnsupportedPlatform();
}

final class ReleaseDownloadChecksumMissing extends ReleaseDownloadResult {
  const ReleaseDownloadChecksumMissing();
}

final class ReleaseDownloadChecksumMismatch extends ReleaseDownloadResult {
  const ReleaseDownloadChecksumMismatch();
}

final class ReleaseDownloadFailed extends ReleaseDownloadResult {
  const ReleaseDownloadFailed();
}

final class ReleaseDownloadCancelled extends ReleaseDownloadResult {
  const ReleaseDownloadCancelled();
}
