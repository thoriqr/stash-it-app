/// Build-time download host allowlist.
///
/// The backend supplies the full `download_url` for each release, and that URL
/// is the only one used. This value exists solely to decide whether a manifest
/// may be acted on: the URL must use HTTPS and name this host. It is compiled
/// into the binary and is never user-configurable at runtime.
abstract final class DownloadConfig {
  static const String host = String.fromEnvironment(
    'DOWNLOAD_HOST',
    defaultValue: 'downloads.stashit.thoriqr.my.id',
  );
}
