import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Normalizes an email for local comparison and scoping.
String normalizePasswordResetEmail(String email) => email.trim().toLowerCase();

/// A password-reset continuation token and the address it belongs to.
///
/// [email] is always normalized. [token] is the raw continuation token,
/// which is returned only once and cannot be recovered if lost.
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
/// Separate from the session credential store and registration continuation
/// store:
///
/// - It is a single-purpose credential, not a session credential, and is
///   managed independently.
/// - Its dedicated key prevents session credential updates or changes to the
///   registration continuation from affecting it.
/// - It uses the existing [FlutterSecureStorage] instance.
///
/// **One slot, one key.** The value is a JSON object holding the normalized
/// email and raw token. A token for another address overwrites the record;
/// concurrent password resets on one device are not supported. No expiry is
/// stored because the continuation's expiry is not available to the client.
/// The server remains authoritative for its validity.
class PasswordResetContinuationStore {
  const PasswordResetContinuationStore(this._storage);

  /// Namespaced to avoid collisions with other stored values.
  static const String storageKey = 'stash_it.auth.password_reset_continuation';

  final FlutterSecureStorage _storage;

  /// Returns the stored record, or null when none is usable.
  ///
  /// Missing, empty, malformed, or structurally invalid values return null.
  /// Platform read failures propagate so the caller can decide whether to retry.
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
  /// Platform write failures propagate. The caller must not continue to the
  /// password form unless the token has been saved successfully.
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

  /// Removes the stored record without affecting other keys.
  Future<void> clear() async {
    await _storage.delete(key: storageKey);
  }

  /// Removes the record only when it holds [token].
  ///
  /// Prevents a stale screen from erasing a newer reset's record.
  Future<void> clearIfToken(String token) async {
    final stored = await read();
    if (stored != null && stored.token == token) {
      await clear();
    }
  }
}

/// Provides the password-reset continuation store.
///
/// Override this provider during app initialization and in tests. The default
/// throws to ensure a real or test implementation is supplied.
final Provider<PasswordResetContinuationStore>
passwordResetContinuationStoreProvider =
    Provider<PasswordResetContinuationStore>(
      (ref) => throw UnimplementedError(
        'passwordResetContinuationStoreProvider must be overridden with a '
        'real or fake store',
      ),
    );
