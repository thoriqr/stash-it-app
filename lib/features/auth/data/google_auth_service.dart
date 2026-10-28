import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/config/google_auth_config.dart';

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
  /// The build has no Google server client ID.
  notConfigured,

  /// The plugin/platform could not start or complete the flow.
  unavailable,

  /// The platform returned an account without an ID token.
  missingIdToken,
}

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.failure);

  final GoogleAuthFailure failure;
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
class GoogleAuthService {
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
final Provider<GoogleAuthService> googleAuthServiceProvider =
    Provider<GoogleAuthService>((ref) => GoogleAuthService());
