/// Build-time Google Sign-In configuration.
///
/// The Web/server OAuth client ID is public, not a secret. It must be the same
/// value the backend verifies as the Google ID token audience
/// (`GOOGLE_CLIENT_ID`). The default is the configured Stash-it Web client; a
/// build can override it with:
///
/// ```sh
/// flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=...
/// ```
abstract final class GoogleAuthConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '1011270119241-nd57rov2q3mv1cddqcit5jn5peon2c4r.apps.googleusercontent.com',
  );

  static bool get isConfigured => serverClientId.isNotEmpty;
}
