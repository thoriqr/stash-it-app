import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../../../core/network/token_provider.dart';
import '../../../core/storage/secure_credential_store.dart';
import '../data/auth_api_providers.dart';
import '../data/datasources/refresh_api.dart';
import '../data/models/auth_tokens.dart';
import '../data/models/refresh_request.dart';

part 'session_controller.g.dart';

/// Provides secure credential storage.
///
/// Uses a plain [Provider] so tests can substitute a fake store without
/// accessing platform storage.
final Provider<SecureCredentialStore> credentialStoreProvider =
    Provider<SecureCredentialStore>(
      (ref) => throw UnimplementedError(
        'credentialStoreProvider must be overridden with a real or fake store',
      ),
    );

/// Credentials restored from secure storage during startup, if available.
///
/// Initialized by bootstrap before `runApp` so the session is available
/// synchronously on the first frame without introducing a loading state.
final Provider<AuthTokens?> restoredTokensProvider = Provider<AuthTokens?>(
  (ref) => null,
);

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
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController implements TokenProvider {
  @override
  AuthTokens? build() {
    // Only dependencies that do not use the authenticated API client.
    _refreshApi = ref.watch(refreshApiProvider);
    _store = ref.watch(credentialStoreProvider);

    // Use the credentials already restored during bootstrap.
    // Keeping this synchronous avoids an unnecessary loading state.
    return ref.watch(restoredTokensProvider);
  }

  late final RefreshApi _refreshApi;
  late final SecureCredentialStore _store;

  /// The in-flight renewal, or null when no renewal is running.
  ///
  /// The provider is kept alive so concurrent requests share the same future
  /// instead of starting separate renewal operations.
  Future<String>? _inFlight;

  /// The credential pair currently adopted by the app.
  ///
  /// Null means no session is held locally. [AuthState] derives its
  /// authentication status from this value.
  AuthTokens? get current => state;

  /// Whether a session ended without its one-time notice being consumed.
  ///
  /// Set by [_endSession] and cleared when [consumeSessionEnded] returns true.
  bool _endedWithoutNotice = false;

  /// Whether this controller has processed the end of the current session.
  ///
  /// Unlike a null [state], this marker distinguishes an ended session from
  /// the initial state, where credentials may exist in storage but have not
  /// yet been adopted.
  bool _sessionEnded = false;

  /// Returns whether a session has ended, consuming the notice in the process.
  ///
  /// Returns true only once per ended session. Clearing the flag before
  /// returning prevents rebuilds or later visits from showing the same notice
  /// again.
  bool consumeSessionEnded() {
    if (!_endedWithoutNotice) return false;
    _endedWithoutNotice = false;
    return true;
  }

  /// Adopts a newly obtained credential pair after it has been persisted.
  ///
  /// Persistence is handled by the caller so the controller only updates
  /// session state after credentials have been stored successfully.
  void adopt(AuthTokens tokens) {
    if (!ref.mounted) return;
    _sessionEnded = false;
    state = tokens;
  }

  /// Clears the locally adopted session.
  ///
  /// The caller is responsible for clearing stored credentials.
  void discard() {
    if (!ref.mounted) return;
    _sessionEnded = true;
    state = null;
  }

  @override
  Future<String?> readAccessToken() => _store.readAccessToken();

  @override
  Future<String> refreshAccessToken() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    // Compare future identity before clearing the handle so an older
    // operation cannot clear a newer in-flight renewal.
    late final Future<String> future;
    future = _renew().whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    _inFlight = future;

    return future;
  }

  Future<String> _renew() async {
    // Read the latest refresh token when renewal starts. A previous renewal
    // may have already replaced the token held by an earlier request.
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) {
      // Without a refresh token, the current session cannot be renewed.
      await _endSession();
      throw const SessionExpiredException('NO_REFRESH_TOKEN');
    }

    final AuthTokens tokens;
    try {
      final response = await _refreshApi.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );
      final data = response.data;

      if (data == null) {
        // The response body is unreadable, so the renewal outcome is unknown.
        // Keep the credentials and do not retry automatically.
        throw _uncertain(const ApiFailureUnreadableResponse());
      }

      tokens = AuthTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      );
    } on DioException catch (error) {
      final failure = mapApiFailure(error);

      if (failure is ApiFailureSessionEnded) {
        // The session is definitively no longer valid.
        await _endSession();
        throw SessionExpiredException(failure.code);
      }

      // The failure does not establish whether renewal succeeded.
      // Preserve the credentials and report an uncertain outcome rather than
      // treating a temporary failure as a definitive session termination.
      throw _uncertain(failure);
    }

    // Persist the rotated pair before allowing callers to use the new token.
    await _persist(tokens);
    adopt(tokens);

    return tokens.accessToken;
  }

  /// Stores a rotated credential pair as a single operation.
  ///
  /// If persistence fails, the session is ended rather than continuing with
  /// credentials that may no longer form a valid pair.
  Future<void> _persist(AuthTokens tokens) async {
    try {
      await _store.write(tokens);
    } catch (error) {
      // A partially persisted pair cannot be used safely.
      await _endSession();
      throw ApiFailureCredentialStorage(cause: error);
    }
  }

  /// Clears stored credentials and records that the session has ended.
  ///
  /// The [ref.mounted] check protects against updating provider state after an
  /// asynchronous operation completes while the provider is being disposed.
  ///
  /// Authentication status is derived from this controller's state, so this
  /// method does not update [AuthState] directly.
  Future<void> _endSession() async {
    // Ignore repeated end requests for the same session. This also prevents
    // a late request from showing the one-time notice again after it was read.
    //
    // The marker distinguishes an ended session from the initial null state,
    // where credentials may still need to be cleared.
    if (_sessionEnded) return;
    _sessionEnded = true;

    try {
      await _store.clear();
    } catch (_) {
      // Storage still holds the credentials, so do not claim the session
      // ended successfully. Allow a later cleanup attempt.
      _sessionEnded = false;
      rethrow;
    }

    // Record the notice before discarding the session, because the state
    // change may immediately cause the app to navigate to the sign-in screen.
    // Only successful credential cleanup can trigger this notice.
    _endedWithoutNotice = true;
    discard();
  }
}

/// Wraps an uncertain renewal failure in a [DioException].
///
/// Preserves the typed failure so the existing network error handling can
/// process it without losing the original failure classification.
DioException _uncertain(ApiFailure cause) {
  return DioException(
    requestOptions: RequestOptions(path: '/auth/refresh'),
    type: DioExceptionType.badResponse,
    error: ApiFailureRefreshUncertain(cause: cause),
  );
}
