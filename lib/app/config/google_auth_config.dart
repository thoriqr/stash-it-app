/// Build-time Google Sign-In configuration.
///
/// The server OAuth client ID is public and must match the backend's
/// `GOOGLE_CLIENT_ID` configuration.
abstract final class GoogleAuthConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// Desktop OAuth client ID used by the Windows browser-based flow.
  ///
  /// A desktop client is a distinct Google OAuth client type from the server
  /// client used by the mobile Google Sign-In plugin. Its secret is never
  /// embedded because the flow uses PKCE instead.
  static const String desktopClientId = String.fromEnvironment(
    'GOOGLE_DESKTOP_CLIENT_ID',
  );

  static bool get isConfigured => serverClientId.isNotEmpty;

  static bool get isDesktopConfigured => desktopClientId.isNotEmpty;
}
