import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_failure.dart';
import '../data/auth_api_providers.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_tokens.dart';
import 'session_controller.dart';

part 'auth_state.g.dart';

/// Whether the app holds a usable session.
///
/// Three states distinguish an unfinished startup restoration from a completed
/// restoration with no session. The router must wait while the status is
/// unresolved rather than redirecting a potentially signed-in user prematurely.
enum AuthStatus {
  /// Startup has not finished restoring credentials. Redirects must wait.
  restoring,

  /// No usable session is available locally.
  signedOut,

  /// A credential pair is available locally.
  ///
  /// This does not guarantee that the server still accepts the credentials.
  /// The session is considered signed in locally until a request establishes
  /// otherwise. Startup does not validate tokens or make a separate probe
  /// request, avoiding unnecessary network traffic and token rotation.
  signedIn,
}

/// Provides the authentication repository.
///
/// Uses a plain [Provider] because the Retrofit API type is not supported by
/// the current Riverpod code generation setup.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => AuthRepository(authApi: ref.watch(authApiProvider)),
    );

/// Owns authentication operations and exposes the current authentication state.
///
/// ## Derived status
///
/// The status is derived from [sessionControllerProvider], which is the single
/// owner of the locally adopted session. This keeps authentication state
/// synchronized when a session ends, including after a terminal refresh failure.
///
/// Watching the session controller also avoids a dependency cycle: the API
/// client already depends on the session controller, so the session controller
/// must not depend on this provider in return.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  AuthStatus build() {
    // Watch the session so changes are reflected automatically.
    final session = ref.watch(sessionControllerProvider);

    return session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
  }

  /// Signs in and stores the resulting credentials.
  ///
  /// Credentials are persisted before the session is adopted. If persistence
  /// fails, the session is not adopted and the app remains signed out.
  Future<void> signIn(String email, String password) async {
    final outcome = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    await _persistAndAdopt(outcome.tokens);
  }

  /// Signs in with a Google ID token.
  ///
  /// Only an authenticated result is persisted. Account-link and registration
  /// results are returned to the caller so their respective flows can continue
  /// without creating an authenticated session prematurely.
  Future<GoogleSignInResult> signInWithGoogle(String idToken) async {
    final result = await ref
        .read(authRepositoryProvider)
        .loginGoogle(idToken: idToken);

    if (result is GoogleSignInAuthenticated) {
      await _persistAndAdopt(result.session.tokens);
    }

    return result;
  }

  /// Confirms a pending Google account link and adopts the returned session.
  Future<void> confirmGoogleAccountLink({
    required String confirmationId,
    required String idToken,
  }) async {
    final outcome = await ref
        .read(authRepositoryProvider)
        .confirmGoogleAccountLink(
          confirmationId: confirmationId,
          idToken: idToken,
        );

    await _persistAndAdopt(outcome.tokens);
  }

  /// Completes a social registration and adopts the returned session.
  Future<void> finalizeSocialRegistration({
    required String continuationToken,
    required String displayName,
  }) async {
    final outcome = await ref
        .read(authRepositoryProvider)
        .finalizeSocialRegistration(
          continuationToken: continuationToken,
          displayName: displayName,
        );

    await _persistAndAdopt(outcome.tokens);
  }

  /// Persists credentials before adopting the session.
  ///
  /// This ensures that the app never reports a signed-in state when the
  /// credentials could not be stored.
  Future<void> _persistAndAdopt(AuthTokens tokens) async {
    try {
      await ref.read(credentialStoreProvider).write(tokens);
    } catch (error) {
      // A storage failure is not an unknown sign-in outcome. The backend
      // authenticated the caller, but this device could not retain the session,
      // so callers receive the existing typed credential-storage failure rather
      // than an indistinguishable generic error.
      throw ApiFailureCredentialStorage(cause: error);
    }

    ref.read(sessionControllerProvider.notifier).adopt(tokens);
  }

  /// Signs out and clears local credentials regardless of the server result.
  ///
  /// The local cleanup runs in `finally`, ensuring the user is signed out on
  /// this device even if the logout request fails. A failed request may leave
  /// the server-side session active, but local credentials are still discarded.
  ///
  /// The request uses `appDio`, whose auth interceptor handles an expired access
  /// token by refreshing and replaying the request once. No separate retry
  /// mechanism is needed here.
  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Local sign-out still proceeds if the server request fails.
    } finally {
      await ref.read(credentialStoreProvider).clear();
      ref.read(sessionControllerProvider.notifier).discard();
    }
  }
}

/// Convenience predicates for [AuthStatus].
///
/// Centralizes status checks so callers do not need to repeat enum comparisons.
extension AuthStatusX on AuthStatus {
  bool get isSignedIn => this == AuthStatus.signedIn;
  bool get isSignedOut => this == AuthStatus.signedOut;

  /// Whether startup restoration has finished.
  bool get isResolved => this != AuthStatus.restoring;
}
