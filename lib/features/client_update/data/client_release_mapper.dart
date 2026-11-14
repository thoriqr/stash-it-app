import '../domain/client_update_release.dart';
import '../domain/client_update_status.dart';
import '../domain/download_url.dart';
import 'models/client_release_response.dart';

/// Converts a release-check response into an action the client may take.
///
/// Every field the prompt needs is validated here. When the response cannot be
/// used, the result is [ClientUpdateInvalidManifest]: no prompt is shown and no
/// download is offered, which keeps the app usable.
ClientUpdateCheckResult clientUpdateFromResponse(
  ClientReleaseEnvelope response, {
  required String allowedHost,
}) {
  final data = response.data;
  if (data == null) return const ClientUpdateInvalidManifest();

  final status = ClientUpdateStatus.fromApi(data.status);
  if (status == null) return const ClientUpdateInvalidManifest();
  if (status == ClientUpdateStatus.none) return const ClientUpdateNone();

  final latest = data.latest;
  if (latest == null) return const ClientUpdateInvalidManifest();

  final version = latest.version?.trim() ?? '';
  final build = latest.build;
  if (version.isEmpty || build == null || build < 1) {
    return const ClientUpdateInvalidManifest();
  }

  final downloadUrl = validatedDownloadUrl(
    latest.downloadUrl,
    allowedHost: allowedHost,
  );
  if (downloadUrl == null) return const ClientUpdateInvalidManifest();

  final releaseNotes = latest.releaseNotes?.trim();
  final fileSize = latest.fileSizeBytes;

  return ClientUpdateAvailable(
    ClientUpdatePrompt(
      status: status,
      release: ClientUpdateRelease(
        version: version,
        build: build,
        downloadUrl: downloadUrl,
        sha256: latest.sha256,
        fileSizeBytes: fileSize != null && fileSize > 0 ? fileSize : null,
        releaseNotes: releaseNotes == null || releaseNotes.isEmpty
            ? null
            : releaseNotes,
        publishedAt: DateTime.tryParse(latest.publishedAt ?? ''),
      ),
    ),
  );
}
