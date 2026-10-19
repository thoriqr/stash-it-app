// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the credential pair, and is the only provider the API client depends on.
///
/// Implements [TokenProvider], which is how `core/network` reaches the session
/// without importing anything from this feature (`AGENTS.md` §2, rule 1).
///
/// ## Why this provider must not depend on the auth repository
///
/// `appDio` reads this provider to obtain the bearer token, so anything this
/// provider depends on sits underneath `appDio` in the dependency graph. If
/// this provider also depended on `authRepositoryProvider` — which is built
/// from `appDio` — the graph would close into a loop:
///
/// ```text
/// appDio -> sessionController -> authRepository -> authApi -> appDio
/// ```
///
/// Riverpod rejects that: `_debugAssertCanDependOn` walks the reader's
/// *dependents* and throws `CircularDependencyError` if the target is among
/// them. The check is a static property of the graph and runs on **every**
/// `read`/`watch`, so deferring the lookup into a closure does not avoid it — it
/// only postpones the throw to the first request, where it surfaces as an
/// unexplained transport failure.
///
/// Depending only on [refreshApiProvider] makes renewal *structurally* unable to
/// recurse as a second-order effect: the refresh client is built from
/// `refreshDio`, which carries no auth interceptor and therefore no path back
/// into this provider.
///
/// ## Why renewal is serialized here
///
/// The backend rotates the refresh token on **every** use and treats a second
/// presentation of an already-rotated token as reuse: it revokes the entire
/// session and answers `SESSION_REVOKED`
/// (`documentation/auth-sessions.md`, "Reuse detection"). It cannot distinguish
/// a client retry from a replay, so two concurrent renewals cost the user their
/// session outright.
///
/// One [Future] shared by every caller is the whole mitigation. Concurrent
/// callers do not each submit the token; they await the same operation and
/// receive the same new token.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Owns the credential pair, and is the only provider the API client depends on.
///
/// Implements [TokenProvider], which is how `core/network` reaches the session
/// without importing anything from this feature (`AGENTS.md` §2, rule 1).
///
/// ## Why this provider must not depend on the auth repository
///
/// `appDio` reads this provider to obtain the bearer token, so anything this
/// provider depends on sits underneath `appDio` in the dependency graph. If
/// this provider also depended on `authRepositoryProvider` — which is built
/// from `appDio` — the graph would close into a loop:
///
/// ```text
/// appDio -> sessionController -> authRepository -> authApi -> appDio
/// ```
///
/// Riverpod rejects that: `_debugAssertCanDependOn` walks the reader's
/// *dependents* and throws `CircularDependencyError` if the target is among
/// them. The check is a static property of the graph and runs on **every**
/// `read`/`watch`, so deferring the lookup into a closure does not avoid it — it
/// only postpones the throw to the first request, where it surfaces as an
/// unexplained transport failure.
///
/// Depending only on [refreshApiProvider] makes renewal *structurally* unable to
/// recurse as a second-order effect: the refresh client is built from
/// `refreshDio`, which carries no auth interceptor and therefore no path back
/// into this provider.
///
/// ## Why renewal is serialized here
///
/// The backend rotates the refresh token on **every** use and treats a second
/// presentation of an already-rotated token as reuse: it revokes the entire
/// session and answers `SESSION_REVOKED`
/// (`documentation/auth-sessions.md`, "Reuse detection"). It cannot distinguish
/// a client retry from a replay, so two concurrent renewals cost the user their
/// session outright.
///
/// One [Future] shared by every caller is the whole mitigation. Concurrent
/// callers do not each submit the token; they await the same operation and
/// receive the same new token.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AuthTokens?> {
  /// Owns the credential pair, and is the only provider the API client depends on.
  ///
  /// Implements [TokenProvider], which is how `core/network` reaches the session
  /// without importing anything from this feature (`AGENTS.md` §2, rule 1).
  ///
  /// ## Why this provider must not depend on the auth repository
  ///
  /// `appDio` reads this provider to obtain the bearer token, so anything this
  /// provider depends on sits underneath `appDio` in the dependency graph. If
  /// this provider also depended on `authRepositoryProvider` — which is built
  /// from `appDio` — the graph would close into a loop:
  ///
  /// ```text
  /// appDio -> sessionController -> authRepository -> authApi -> appDio
  /// ```
  ///
  /// Riverpod rejects that: `_debugAssertCanDependOn` walks the reader's
  /// *dependents* and throws `CircularDependencyError` if the target is among
  /// them. The check is a static property of the graph and runs on **every**
  /// `read`/`watch`, so deferring the lookup into a closure does not avoid it — it
  /// only postpones the throw to the first request, where it surfaces as an
  /// unexplained transport failure.
  ///
  /// Depending only on [refreshApiProvider] makes renewal *structurally* unable to
  /// recurse as a second-order effect: the refresh client is built from
  /// `refreshDio`, which carries no auth interceptor and therefore no path back
  /// into this provider.
  ///
  /// ## Why renewal is serialized here
  ///
  /// The backend rotates the refresh token on **every** use and treats a second
  /// presentation of an already-rotated token as reuse: it revokes the entire
  /// session and answers `SESSION_REVOKED`
  /// (`documentation/auth-sessions.md`, "Reuse detection"). It cannot distinguish
  /// a client retry from a replay, so two concurrent renewals cost the user their
  /// session outright.
  ///
  /// One [Future] shared by every caller is the whole mitigation. Concurrent
  /// callers do not each submit the token; they await the same operation and
  /// receive the same new token.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokens? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokens?>(value),
    );
  }
}

String _$sessionControllerHash() => r'da07a9358d4588639710e0dcd686f7d3d0d84d44';

/// Owns the credential pair, and is the only provider the API client depends on.
///
/// Implements [TokenProvider], which is how `core/network` reaches the session
/// without importing anything from this feature (`AGENTS.md` §2, rule 1).
///
/// ## Why this provider must not depend on the auth repository
///
/// `appDio` reads this provider to obtain the bearer token, so anything this
/// provider depends on sits underneath `appDio` in the dependency graph. If
/// this provider also depended on `authRepositoryProvider` — which is built
/// from `appDio` — the graph would close into a loop:
///
/// ```text
/// appDio -> sessionController -> authRepository -> authApi -> appDio
/// ```
///
/// Riverpod rejects that: `_debugAssertCanDependOn` walks the reader's
/// *dependents* and throws `CircularDependencyError` if the target is among
/// them. The check is a static property of the graph and runs on **every**
/// `read`/`watch`, so deferring the lookup into a closure does not avoid it — it
/// only postpones the throw to the first request, where it surfaces as an
/// unexplained transport failure.
///
/// Depending only on [refreshApiProvider] makes renewal *structurally* unable to
/// recurse as a second-order effect: the refresh client is built from
/// `refreshDio`, which carries no auth interceptor and therefore no path back
/// into this provider.
///
/// ## Why renewal is serialized here
///
/// The backend rotates the refresh token on **every** use and treats a second
/// presentation of an already-rotated token as reuse: it revokes the entire
/// session and answers `SESSION_REVOKED`
/// (`documentation/auth-sessions.md`, "Reuse detection"). It cannot distinguish
/// a client retry from a replay, so two concurrent renewals cost the user their
/// session outright.
///
/// One [Future] shared by every caller is the whole mitigation. Concurrent
/// callers do not each submit the token; they await the same operation and
/// receive the same new token.

abstract class _$SessionController extends $Notifier<AuthTokens?> {
  AuthTokens? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthTokens?, AuthTokens?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthTokens?, AuthTokens?>,
              AuthTokens?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
