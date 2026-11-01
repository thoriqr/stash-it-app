import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Normalizes an email for local comparison and scoping.
String normalizeRegistrationEmail(String email) => email.trim().toLowerCase();

/// A registration continuation token and the address it belongs to.
///
/// [email] is always normalized. [token] is the raw continuation token,
/// which is returned only once and cannot be recovered if lost.
class StoredRegistrationContinuation {
  const StoredRegistrationContinuation({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;
}

/// Persists the raw registration continuation token across app restarts.
///
/// Separate from the session credential store:
///
/// - This token belongs to the registration flow, not an authenticated
///   session. It must not be adopted as a session, refreshed, or cleared by
///   signing out.
/// - The session credential store manages the access/refresh token pair,
///   while this store manages an independent single value.
/// - Both stores use the same [FlutterSecureStorage] instance.
///
/// **One slot, one key.** The value is a JSON object holding the normalized
/// email and raw token. A token for a different email overwrites the record;
/// concurrent registrations on one device are not supported. No expiry is
/// stored because the continuation's expiry is not available to the client.
/// Its validity remains determined by the server.
class RegistrationContinuationStore {
  const RegistrationContinuationStore(this._storage);

  /// Namespaced to avoid collisions with other stored values.
  static const String storageKey = 'stash_it.auth.registration_continuation';

  final FlutterSecureStorage _storage;

  /// Returns the stored record, or null when none is usable.
  ///
  /// Missing, empty, malformed, or structurally invalid values return null.
  /// A corrupt record must not make registration unusable. Platform read
  /// failures propagate so the caller can decide how to proceed. Registration
  /// can continue without the stored token, but recovery across app restarts
  /// will not be available.
  Future<StoredRegistrationContinuation?> read() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final email = decoded['email'];
      final token = decoded['token'];
      if (email is! String || token is! String) return null;

      final normalizedEmail = normalizeRegistrationEmail(email);
      if (normalizedEmail.isEmpty || token.isEmpty) return null;

      return StoredRegistrationContinuation(
        email: normalizedEmail,
        token: token,
      );
    } on FormatException {
      return null;
    }
  }

  /// Stores [token] against [email], replacing any previous record.
  ///
  /// Platform write failures propagate. Registration can still continue, but
  /// recovery across an app restart will not be available.
  Future<void> write({required String email, required String token}) async {
    final normalizedEmail = normalizeRegistrationEmail(email);
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
  /// Prevents an outdated navigation event from deleting a newer registration
  /// continuation. A read failure propagates and nothing is cleared.
  Future<void> clearIfToken(String token) async {
    final stored = await read();
    if (stored != null && stored.token == token) {
      await clear();
    }
  }
}

/// Provides the registration continuation store.
///
/// Override this provider during app initialization and in tests. The default
/// throws to ensure a real or test implementation is supplied.
final Provider<RegistrationContinuationStore>
registrationContinuationStoreProvider = Provider<RegistrationContinuationStore>(
  (ref) => throw UnimplementedError(
    'registrationContinuationStoreProvider must be overridden with a '
    'real or fake store',
  ),
);
