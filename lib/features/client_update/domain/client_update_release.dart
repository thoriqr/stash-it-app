import 'package:flutter/foundation.dart';

import 'client_update_status.dart';

/// A release the server reports as available for this platform.
@immutable
class ClientUpdateRelease {
  const ClientUpdateRelease({
    required this.version,
    required this.build,
    required this.downloadUrl,
    this.sha256,
    this.fileSizeBytes,
    this.releaseNotes,
    this.publishedAt,
  });

  final String version;
  final int build;

  /// The validated HTTPS URL on the allowed download host.
  final Uri downloadUrl;

  final String? sha256;
  final int? fileSizeBytes;
  final String? releaseNotes;
  final DateTime? publishedAt;
}

/// A pending update prompt.
@immutable
class ClientUpdatePrompt {
  const ClientUpdatePrompt({required this.status, required this.release});

  final ClientUpdateStatus status;
  final ClientUpdateRelease release;

  bool get isRequired => status == ClientUpdateStatus.required;
}

/// The outcome of one release check.
sealed class ClientUpdateCheckResult {
  const ClientUpdateCheckResult();
}

/// No update is needed, or the platform has no published release.
final class ClientUpdateNone extends ClientUpdateCheckResult {
  const ClientUpdateNone();
}

/// The server reported a release that passed client-side validation.
final class ClientUpdateAvailable extends ClientUpdateCheckResult {
  const ClientUpdateAvailable(this.prompt);

  final ClientUpdatePrompt prompt;
}

/// The response could not be used as a release manifest.
///
/// This includes an unknown status, a missing release, or a download URL that
/// is not HTTPS on the allowed host. No prompt is shown and no download is
/// offered.
final class ClientUpdateInvalidManifest extends ClientUpdateCheckResult {
  const ClientUpdateInvalidManifest();
}

/// The check could not be completed.
final class ClientUpdateUnavailable extends ClientUpdateCheckResult {
  const ClientUpdateUnavailable();
}
