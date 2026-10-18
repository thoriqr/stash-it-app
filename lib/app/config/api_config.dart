/// Build-time configuration.
///
/// Read through `--dart-define`, which is compiled into the binary and needs no
/// runtime file, no asset bundle and no package:
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
/// ```
///
/// Android emulators reach the host loopback at `10.0.2.2`, not `localhost`.
abstract final class ApiConfig {
  /// The backend origin, with no trailing slash and no path.
  ///
  /// A trailing slash would produce a double slash in every request path: Dio
  /// joins `baseUrl + path`, and Retrofit paths begin with `/`
  /// (`dio/src/options.dart:662`).
  ///
  /// Deliberately unvalidated beyond emptiness. Resolving or rewriting a URL
  /// here would make the client second-guess what the operator asked for, and
  /// the backend has no base path to accommodate. A malformed value fails at
  /// the first request, where the error is honest.
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    return configured.endsWith('/')
        ? configured.substring(0, configured.length - 1)
        : configured;
  }

  /// Whether [baseUrl] was supplied.
  ///
  /// Checked by `bootstrap` so a missing `--dart-define` fails with an
  /// explanation at startup rather than as an opaque network error on the first
  /// screen the user opens.
  static bool get isConfigured => baseUrl.isNotEmpty;
}
