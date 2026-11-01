// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the locally adopted credential pair and provides tokens to the API client.
///
/// Implements [TokenProvider] to expose session credentials to the network
/// layer without coupling that layer to authentication feature internals.
///
/// ## Dependency isolation
///
/// This provider must not depend on the authentication repository because the
/// repository uses the authenticated API client, which already depends on this
/// provider. Such a dependency would create a circular dependency.
///
/// Renewal uses [refreshApiProvider], which is backed by a separate client
/// without the authentication interceptor. This keeps the refresh operation
/// independent of the session renewal process.
///
/// ## Concurrent renewal
///
/// Refresh requests are serialized through a shared future. Every concurrent
/// caller waits for the same renewal operation and receives the same new access
/// token. This prevents multiple requests from submitting the same refresh
/// token simultaneously.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Owns the locally adopted credential pair and provides tokens to the API client.
///
/// Implements [TokenProvider] to expose session credentials to the network
/// layer without coupling that layer to authentication feature internals.
///
/// ## Dependency isolation
///
/// This provider must not depend on the authentication repository because the
/// repository uses the authenticated API client, which already depends on this
/// provider. Such a dependency would create a circular dependency.
///
/// Renewal uses [refreshApiProvider], which is backed by a separate client
/// without the authentication interceptor. This keeps the refresh operation
/// independent of the session renewal process.
///
/// ## Concurrent renewal
///
/// Refresh requests are serialized through a shared future. Every concurrent
/// caller waits for the same renewal operation and receives the same new access
/// token. This prevents multiple requests from submitting the same refresh
/// token simultaneously.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AuthTokens?> {
  /// Owns the locally adopted credential pair and provides tokens to the API client.
  ///
  /// Implements [TokenProvider] to expose session credentials to the network
  /// layer without coupling that layer to authentication feature internals.
  ///
  /// ## Dependency isolation
  ///
  /// This provider must not depend on the authentication repository because the
  /// repository uses the authenticated API client, which already depends on this
  /// provider. Such a dependency would create a circular dependency.
  ///
  /// Renewal uses [refreshApiProvider], which is backed by a separate client
  /// without the authentication interceptor. This keeps the refresh operation
  /// independent of the session renewal process.
  ///
  /// ## Concurrent renewal
  ///
  /// Refresh requests are serialized through a shared future. Every concurrent
  /// caller waits for the same renewal operation and receives the same new access
  /// token. This prevents multiple requests from submitting the same refresh
  /// token simultaneously.
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

String _$sessionControllerHash() => r'fb1250844b164733e2be360f0cf5ad2266e0fb86';

/// Owns the locally adopted credential pair and provides tokens to the API client.
///
/// Implements [TokenProvider] to expose session credentials to the network
/// layer without coupling that layer to authentication feature internals.
///
/// ## Dependency isolation
///
/// This provider must not depend on the authentication repository because the
/// repository uses the authenticated API client, which already depends on this
/// provider. Such a dependency would create a circular dependency.
///
/// Renewal uses [refreshApiProvider], which is backed by a separate client
/// without the authentication interceptor. This keeps the refresh operation
/// independent of the session renewal process.
///
/// ## Concurrent renewal
///
/// Refresh requests are serialized through a shared future. Every concurrent
/// caller waits for the same renewal operation and receives the same new access
/// token. This prevents multiple requests from submitting the same refresh
/// token simultaneously.

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
