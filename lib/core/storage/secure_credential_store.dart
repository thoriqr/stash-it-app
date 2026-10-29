import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_tokens.dart';

/// Persists the access/refresh pair in platform secure storage.
///
/// Keychain on iOS, Keystore-backed on Android — `decisions.md` §7.12 and V5
/// rule out plain files and shared preferences, so there is deliberately no
/// fallback to either. `flutter_secure_storage` 11.x uses RSA-OAEP key
/// wrapping with AES-GCM on Android and the iOS Keychain; `android:allowBackup`
/// is disabled in the manifest because a restored Keystore key cannot unwrap the
/// value it encrypted.
///
/// Reads return null rather than throwing when nothing is stored, so "not signed
/// in" and "signed in" are both ordinary values and neither is an exceptional
/// path.
class SecureCredentialStore {
  const SecureCredentialStore(this._storage);

  final FlutterSecureStorage _storage;

  /// Namespaced so a future credential value written here cannot collide with
  /// an unrelated key added later.
  ///
  /// The device-local URL fallback deliberately does **not** use this store:
  /// those entries are non-secret application data and are account-independent,
  /// so they live in `shared_preferences`. Credentials and auth-flow
  /// continuations remain here.
  static const String _accessTokenKey = 'stash_it.auth.access_token';
  static const String _refreshTokenKey = 'stash_it.auth.refresh_token';

  /// The stored pair, or null when the store holds no usable session.
  ///
  /// **A half-present pair reads as null, not as a partial session.** An
  /// access token without its refresh token cannot be renewed, and treating it
  /// as a session would produce a `401` on the user's first request and an
  /// unrecoverable loop rather than a clean signed-out state.
  Future<AuthTokens?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || accessToken.isEmpty) return null;
    if (refreshToken == null || refreshToken.isEmpty) return null;

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// The stored access token alone, or null. Used per request by the
  /// interceptor.
  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  /// The stored refresh token alone, or null. Read at the moment a renewal
  /// begins rather than cached, so a renewal triggered by a late `401` uses the
  /// token the previous renewal produced.
  Future<String?> readRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  /// Writes a pair, or writes nothing.
  ///
  /// The backend rotates **both** tokens on every successful renewal
  /// (`session/repository.go:238-254`), so the pair is only ever valid together.
  /// A write that succeeded for one and failed for the other would leave an
  /// access token that cannot be renewed beside a refresh token that does not
  /// match it — indistinguishable, once persisted, from a genuine session, and
  /// not something a later read can detect.
  ///
  /// So a failure partway through discards whatever landed: the store is cleared
  /// and the error is rethrown. The session is then simply gone rather than
  /// subtly wrong, which is the recoverable outcome — the user signs in again.
  ///
  /// Ordering is refresh-then-access so the most sensitive value is written
  /// first; that ordering alone cannot make the operation atomic, which is why
  /// the rollback exists.
  Future<void> write(AuthTokens tokens) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    } catch (_) {
      await clear();
      rethrow;
    }
  }

  /// Removes both tokens.
  ///
  /// Key-scoped rather than `deleteAll`, which would also remove any value added
  /// for another purpose later.
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
