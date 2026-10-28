import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Normalizes an email the same way the backend's `NormalizeEmail` does.
///
/// Used only for local scoping — deciding whether a stored password-reset
/// continuation belongs to the address being displayed. The wire value is
/// unaffected; the backend normalizes what it receives.
String normalizePasswordResetEmail(String email) => email.trim().toLowerCase();

/// A password-reset continuation token and the address it belongs to.
///
/// [email] is always normalized. [token] is the raw token returned once by
/// `POST /auth/password-reset/verification/{id}/verify`; the backend stores only
/// its hash and cannot reconstruct it.
class StoredPasswordResetContinuation {
  const StoredPasswordResetContinuation({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;
}

/// Persists the raw password-reset continuation token across navigation and app
/// restarts.
///
/// Separate from `SecureCredentialStore` and from the registration continuation
/// store:
///
/// - It is a single-purpose capability, not a session credential, and it is
///   cleared only by this store.
/// - A different key means clearing or rotating an access/refresh pair or an
///   unrelated registration continuation cannot remove it.
/// - It uses the same `FlutterSecureStorage` as both, so no new dependency or
///   storage mechanism is introduced.
///
/// **One slot, one key.** The value is a JSON object holding the normalized
/// email and the raw token. A token for another address overwrites the record;
/// concurrent password resets on one device are not a supported flow. No expiry
/// is stored: no response exposes the continuation's expiry, and a device-clock
/// deadline would make the client its own authority over a server-owned
/// lifetime.
class PasswordResetContinuationStore {
  const PasswordResetContinuationStore(this._storage);

  /// Namespaced so clearing or adding other values cannot collide with it.
  static const String storageKey = 'stash_it.auth.password_reset_continuation';

  final FlutterSecureStorage _storage;

  /// The stored record, or null when none is usable.
  ///
  /// A missing, empty, malformed or structurally invalid value reads as null: a
  /// corrupt record must not make the reset flow unusable. Platform read
  /// failures propagate, so a caller can decide whether to retry rather than
  /// silently starting over.
  Future<StoredPasswordResetContinuation?> read() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final email = decoded['email'];
      final token = decoded['token'];
      if (email is! String || token is! String) return null;

      final normalizedEmail = normalizePasswordResetEmail(email);
      if (normalizedEmail.isEmpty || token.isEmpty) return null;

      return StoredPasswordResetContinuation(
        email: normalizedEmail,
        token: token,
      );
    } on FormatException {
      return null;
    }
  }

  /// Stores [token] against [email], replacing any previous record.
  ///
  /// A platform failure propagates: the verification screen decides whether the
  /// reset can continue. It does not navigate to the password form when the
  /// token could not be saved, because that form reads the token back from this
  /// store.
  Future<void> write({required String email, required String token}) async {
    final normalizedEmail = normalizePasswordResetEmail(email);
    if (normalizedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'must not be empty');
    }
    if (token.isEmpty) {
      throw ArgumentError.value(token, 'token', 'must not be empty');
    }

    await _storage.write(
      key: storageKey,
      value: jsonEncode({'email': normalizedEmail, 'token': token}),
    );
  }

  /// Removes the stored record, leaving every other key alone.
  Future<void> clear() async {
    await _storage.delete(key: storageKey);
  }

  /// Removes the record only when it holds [token].
  ///
  /// A stale screen must not erase a newer reset's record.
  Future<void> clearIfToken(String token) async {
    final stored = await read();
    if (stored != null && stored.token == token) {
      await clear();
    }
  }
}

/// The password-reset continuation store, overridden in `bootstrap` and tests.
///
/// A plain [Provider] for the same reason as `credentialStoreProvider`: the
/// value never changes, and the deliberate default keeps a platform channel out
/// of any test that has not substituted a store.
final Provider<PasswordResetContinuationStore>
passwordResetContinuationStoreProvider =
    Provider<PasswordResetContinuationStore>(
      (ref) => throw UnimplementedError(
        'passwordResetContinuationStoreProvider must be overridden with a '
        'real or fake store',
      ),
    );
