/// The outcome of handing a downloaded artifact to the platform.
sealed class ReleaseInstallResult {
  const ReleaseInstallResult();
}

/// The installer or file browser was opened. The user still finishes manually.
final class ReleaseInstallHandedOff extends ReleaseInstallResult {
  const ReleaseInstallHandedOff();
}

final class ReleaseInstallFailed extends ReleaseInstallResult {
  const ReleaseInstallFailed({this.code, this.message, this.details});

  /// The platform error code, kept for logging and diagnosis.
  final String? code;
  final String? message;
  final Object? details;
}

/// Android needs the user to allow installs from this package before the
/// package installer can be opened.
final class ReleaseInstallPermissionRequired extends ReleaseInstallResult {
  const ReleaseInstallPermissionRequired({this.code, this.message});

  final String? code;
  final String? message;
}

final class ReleaseInstallUnsupported extends ReleaseInstallResult {
  const ReleaseInstallUnsupported();
}

/// Opens a downloaded artifact with the platform's normal handler.
abstract interface class ReleaseInstaller {
  Future<ReleaseInstallResult> open({
    required String filePath,
    required String platform,
  });
}
