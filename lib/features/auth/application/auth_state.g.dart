// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthState)
final authStateProvider = AuthStateProvider._();

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
final class AuthStateProvider extends $NotifierProvider<AuthState, AuthStatus> {
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
