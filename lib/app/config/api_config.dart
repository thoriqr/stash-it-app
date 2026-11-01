/// Build-time configuration supplied through `--dart-define`.
///
/// Values are compiled into the binary; no runtime configuration file or
/// additional package is required.
abstract final class ApiConfig {
  /// Backend origin without a trailing slash or base path.
  ///
  /// The trailing slash is removed to avoid double slashes when Dio combines
  /// the base URL with Retrofit endpoint paths.
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    return configured.endsWith('/')
        ? configured.substring(0, configured.length - 1)
        : configured;
  }

  /// Whether the API base URL was provided.
  ///
  /// Checked during bootstrap to fail early when configuration is missing.
  static bool get isConfigured => baseUrl.isNotEmpty;
}
