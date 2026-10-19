import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_api_providers.dart';
import '../data/auth_repository.dart';
import 'session_controller.dart';

part 'auth_state.g.dart';

/// Whether the app holds a usable session.
///
/// Three states, not two, because "we have not finished looking" and "we looked
/// and there is nothing" must not be the same answer: a router redirect built on
/// a two-state model would bounce a signed-in user to sign-in during startup.
enum AuthStatus {
  /// Startup has not finished reading storage. Redirects must wait rather than
  /// assume.
  restoring,

  /// No usable session in storage.
  signedOut,

  /// A credential pair is held. **Not proof the server still accepts it** — the
  /// access token is stateless, and `middleware.Auth` never consults the
  /// database, so the only evidence is a request that uses it
  /// (`auth-sessions.md`, "Revocation, and what it does not do").
  ///
  /// No validation happens at startup: decoding the JWT locally would make the
  /// client its own token authority, and a probe request would spend a
  /// rotation. The first real request is the test.
  signedIn,
}

/// The auth data layer.
///
/// Plain [Provider] rather than `@Riverpod`, because `riverpod_generator` cannot
/// convert a Retrofit `@RestApi` type to code. See `auth_api_providers.dart`.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => AuthRepository(authApi: ref.watch(authApiProvider)),
    );

/// The authentication state, and the operations that change it.
///
/// ## Why the status is derived rather than assigned
///
/// This provider reads [sessionControllerProvider], which is the single owner of
/// "does a session exist". Deriving the status means a session that ends
/// server-side — a renewal that comes back `SESSION_REVOKED` — updates the UI
/// with no notification path of its own.
///
/// The alternative, having [SessionController] push into this provider, is not
/// available: the API client depends on the session controller, so any edge from
/// the session controller back to here closes a dependency cycle Riverpod
/// rejects at runtime.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  AuthStatus build() {
    // Watched, not read: a session that ends must be reflected without anyone
    // having to say so.
    final session = ref.watch(sessionControllerProvider);

    return session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
  }

  /// Signs in and stores the resulting credentials.
  ///
  /// The pair is written **before** the session is adopted, so a `signedIn`
  /// state never describes credentials that failed to persist. The all-or-nothing
  /// guarantee lives in [SecureCredentialStore.write]: a failure partway through
  /// discards what landed and rethrows, so the store is left empty and this
  /// provider keeps reporting signed out.
  Future<void> signIn(String email, String password) async {
    final outcome = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    await ref.read(credentialStoreProvider).write(outcome.tokens);

    // Adopting updates the watched session, which rebuilds this provider into
    // `signedIn`. Nothing assigns the status directly.
    ref.read(sessionControllerProvider.notifier).adopt(outcome.tokens);
  }

  /// Signs out, clearing local credentials whether or not the server call
  /// worked.
  ///
  /// The local clear runs in a `finally`: a user who asked to sign out is signed
  /// out on this device regardless, and leaving the app apparently signed in
  /// after a failed logout would be worse than a server-side session outliving
  /// its revocation by up to 90 days.
  ///
  /// A server-side failure is deliberately not rethrown. The user's intent is
  /// satisfied either way, and surfacing an error would imply it was not.
  ///
  /// **No manual renew-then-retry here.** `logout` is issued through `appDio`,
  /// so an expired access token is handled by the auth interceptor: it sees
  /// `ACCESS_TOKEN_EXPIRED`, renews, and replays the request once. Doing it a
  /// second time here would be duplicate machinery on a second code path.
  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // The server session may survive. That is accepted, not ignored: it is
      // recorded rather than hidden, and local credentials are cleared below.
    } finally {
      await ref.read(credentialStoreProvider).clear();
      ref.read(sessionControllerProvider.notifier).discard();
    }
  }
}

/// Convenience predicates for the status enum.
///
/// Named rather than inlined so a router or a screen never re-derives "is this
/// signed in" with its own comparison.
extension AuthStatusX on AuthStatus {
  bool get isSignedIn => this == AuthStatus.signedIn;
  bool get isSignedOut => this == AuthStatus.signedOut;

  /// True once startup has settled, whichever way it went.
  bool get isResolved => this != AuthStatus.restoring;
}
