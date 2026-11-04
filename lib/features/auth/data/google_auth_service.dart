import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/config/google_auth_config.dart';
import 'windows_google_auth_service.dart';

/// The Google credential the client needs for the backend.
///
/// Only [idToken] is sent. [email] and [displayName] are local display hints for
/// the intermediate social-registration flow; they are never treated as identity
/// proof.
class GoogleAuthCredential {
  const GoogleAuthCredential({
    required this.idToken,
    required this.email,
    this.displayName,
  });

  final String idToken;
  final String email;
  final String? displayName;
}

/// Client-side Google credential acquisition failures.
enum GoogleAuthFailure {
  /// The build has no Google client configuration for the active platform.
  notConfigured,

  /// The plugin/platform could not start or complete the flow.
  unavailable,

  /// The platform returned an account without an ID token.
  missingIdToken,

  /// The system browser could not be opened.
  browserLaunchFailed,

  /// No authorization callback arrived before the timeout.
  callbackTimeout,

  /// The OAuth callback did not carry the state this client generated.
  stateMismatch,

  /// The OAuth callback reported an error other than user cancellation.
  callbackError,

  /// The authorization code could not be exchanged for an ID token.
  tokenExchangeFailed,
}

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.failure, {this.statusCode, this.oauthError});

  final GoogleAuthFailure failure;

  /// HTTP status returned by the token endpoint, when one was received.
  final int? statusCode;

  /// Google's OAuth error code, such as `invalid_request`, when present.
  ///
  /// Retained for diagnostics. It is not a credential and is never displayed
  /// directly to the user.
  final String? oauthError;
}

/// Acquires a Google ID token for the active platform.
///
/// Android keeps using the `google_sign_in` plugin. Windows uses a browser-based
/// OAuth authorization code flow with PKCE.
abstract interface class GoogleAuthClient {
  /// Returns null only when the user cancels or the flow is interrupted.
  Future<GoogleAuthCredential?> signIn();
}

/// A Google client that can stop an in-flight sign-in.
///
/// Android's plugin service does not implement this interface. Windows does,
/// where the operation waits on an external browser callback.
abstract interface class GoogleAuthCancellation implements GoogleAuthClient {
  /// Stops the current operation and releases its callback resources.
  ///
  /// Safe to call when no operation is running or after it has completed.
  void cancel();
}

/// Acquires a Google ID token through `google_sign_in` 7.x.
///
/// The service deliberately exposes only the ID token path. The backend accepts
/// no Google access token, and the ID token must be requested for the configured
/// server client ID so its audience matches `GOOGLE_CLIENT_ID`.
///
/// A user cancellation returns null. Any other failure is a typed
/// [GoogleAuthException] with client-owned meaning; the plugin's exception text
/// is never shown to the user.
class GoogleAuthService implements GoogleAuthClient {
  GoogleAuthService();

  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    if (!GoogleAuthConfig.isConfigured) {
      throw const GoogleAuthException(GoogleAuthFailure.notConfigured);
    }

    return _initialization ??= GoogleSignIn.instance.initialize(
      serverClientId: GoogleAuthConfig.serverClientId,
    );
  }

  /// Starts the interactive Google account picker.
  ///
  /// Returns null only when the user cancels or the platform interrupts the
  /// picker. A missing ID token is a failure because the backend cannot use the
  /// session without it.
  @override
  Future<GoogleAuthCredential?> signIn() async {
    try {
      await _ensureInitialized();
    } on GoogleAuthException {
      rethrow;
    } catch (_) {
      throw const GoogleAuthException(GoogleAuthFailure.unavailable);
    }

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleAuthException(GoogleAuthFailure.unavailable);
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(GoogleAuthFailure.missingIdToken);
      }

      return GoogleAuthCredential(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
      );
    } on GoogleAuthException {
      rethrow;
    } on GoogleSignInException catch (error) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return null;
        default:
          throw const GoogleAuthException(GoogleAuthFailure.unavailable);
      }
    } catch (_) {
      throw const GoogleAuthException(GoogleAuthFailure.unavailable);
    }
  }
}

/// Overridable in tests with a fake that returns a credential or a cancellation.
///
/// Windows has no native Google Sign-In implementation, so it uses the browser
/// OAuth flow instead. Other platforms keep the existing plugin.
final Provider<GoogleAuthClient> googleAuthServiceProvider =
    Provider<GoogleAuthClient>((ref) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        return WindowsGoogleAuthService(
          clientId: GoogleAuthConfig.desktopClientId,
        );
      }
      return GoogleAuthService();
    });
