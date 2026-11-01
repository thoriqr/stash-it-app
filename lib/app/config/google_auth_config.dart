/// Build-time Google Sign-In configuration.
///
/// The server OAuth client ID is public and must match the backend's
/// `GOOGLE_CLIENT_ID` configuration.
abstract final class GoogleAuthConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static bool get isConfigured => serverClientId.isNotEmpty;
}
