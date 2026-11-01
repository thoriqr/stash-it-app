import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_tokens.dart';

/// Persists the access and refresh token pair in platform secure storage.
///
/// Uses the iOS Keychain and Android Keystore-backed encryption. There is
/// intentionally no fallback to plain files or shared preferences.
///
/// Android backup is disabled because a restored encrypted value may no
/// longer be accessible when its original Keystore key is unavailable.
///
/// Reads return null when no usable credentials are stored. Being signed
/// in or signed out is represented by the returned value, not an exception.
class SecureCredentialStore {
  const SecureCredentialStore(this._storage);

  final FlutterSecureStorage _storage;

  /// Namespaced keys prevent collisions with unrelated stored values.
  ///
  /// This store is reserved for credentials and authentication-flow
  /// continuations. Device-local saved URLs are non-secret, account-independent
  /// data and are stored separately using shared preferences.
  static const String _accessTokenKey = 'stash_it.auth.access_token';
  static const String _refreshTokenKey = 'stash_it.auth.refresh_token';

  /// Returns the stored token pair, or null when no usable session exists.
  ///
  /// A partially stored pair is treated as absent. An access token without
  /// its refresh token cannot renew the session, so it must not be treated
  /// as a valid signed-in state.
  Future<AuthTokens?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || accessToken.isEmpty) return null;
    if (refreshToken == null || refreshToken.isEmpty) return null;

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Returns the stored access token, or null when it is absent or empty.
  ///
  /// Read by the authentication interceptor when preparing a request.
  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  /// Returns the stored refresh token, or null when it is absent or empty.
  ///
  /// Read when renewal begins rather than cached, so a concurrent or
  /// subsequent renewal uses the latest token written by the previous one.
  Future<String?> readRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  /// Writes both tokens, clearing the store if either write fails.
  ///
  /// Both tokens are rotated together on successful renewal. A partially
  /// persisted pair would leave credentials that cannot reliably renew the
  /// session and cannot be distinguished from a valid pair by a later read.
  ///
  /// If either write fails, clear whatever was persisted and rethrow the
  /// original error. This avoids retaining a partially updated session.
  ///
  /// The refresh token is written first, followed by the access token.
  /// Ordering alone does not make the operation atomic, so rollback is still
  /// required.
  Future<void> write(AuthTokens tokens) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    } catch (_) {
      await clear();
      rethrow;
    }
  }

  /// Removes both stored tokens.
  ///
  /// Deletes only the credential keys rather than calling `deleteAll`,
  /// which could remove values belonging to other features.
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
