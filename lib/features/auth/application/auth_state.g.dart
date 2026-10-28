// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthState)
final authStateProvider = AuthStateProvider._();

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
final class AuthStateProvider extends $NotifierProvider<AuthState, AuthStatus> {
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
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  AuthState create() => AuthState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authStateHash() => r'0c7a2b19fda92765641ddcecd8e33780ce1cf527';

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

abstract class _$AuthState extends $Notifier<AuthStatus> {
  AuthStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthStatus, AuthStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStatus, AuthStatus>,
              AuthStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
