import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Normalizes an email the same way the backend's `NormalizeEmail` does.
///
/// Used only for local scoping — deciding whether a stored continuation belongs
/// to the address the user just entered. The wire value is unaffected; the
/// backend normalizes what it receives.
String normalizeRegistrationEmail(String email) => email.trim().toLowerCase();

/// A registration continuation token, together with the address it belongs to.
///
/// [email] is always normalized. [token] is the raw token returned once by
/// `POST /auth/register/verification/{id}/verify`; the backend stores only its
/// hash and cannot reconstruct it.
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
/// This is deliberately separate from `SecureCredentialStore`:
///
/// - The token is registration-flow state, not a session credential. It must not
///   be adopted as a session, refreshed, or cleared by signing out.
/// - The credential store owns exactly the access/refresh pair, and its
///   all-or-nothing write exists because those two values rotate together. This
///   value has no partner and is written with a single key.
/// - Both classes share one [FlutterSecureStorage], so no new dependency is
///   introduced and the existing in-memory test double works unchanged.
///
/// **One slot, one key.** The value is a JSON object holding the normalized
/// email and the raw token. A token for a different email overwrites the record;
/// concurrent registrations on one device are not a supported flow. No expiry is
/// stored: no response exposes the continuation's expiry, and a device-clock
/// deadline would make the client its own authority over a server-owned
/// lifetime.
class RegistrationContinuationStore {
  const RegistrationContinuationStore(this._storage);

  /// Namespaced so clearing or adding other values cannot collide with it.
  static const String storageKey = 'stash_it.auth.registration_continuation';

  final FlutterSecureStorage _storage;

  /// The stored record, or null when none is usable.
  ///
  /// A missing, empty, malformed or structurally invalid value reads as null:
  /// the record is a convenience, and a corrupt one must not make sign-up
  /// unusable. Platform read failures propagate, matching
  /// `SecureCredentialStore`, so a caller can decide whether the registration
  /// can still proceed (it can — without recovery).
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
  /// A platform failure propagates: the caller decides whether to continue (it
  /// can) and whether to tell the user that recovery across a restart is not
  /// available.
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

  /// Removes the stored record, leaving every other key alone.
  Future<void> clear() async {
    await _storage.delete(key: storageKey);
  }

  /// Removes the record only when it holds [token].
  ///
  /// A route extra can carry a token different from the newest stored one (for
  /// example an old navigation replayed after a newer registration verified).
  /// Clearing unconditionally would discard the newer capability, so the match
  /// is checked first. A read failure propagates and nothing is cleared.
  Future<void> clearIfToken(String token) async {
    final stored = await read();
    if (stored != null && stored.token == token) {
      await clear();
    }
  }
}

/// The registration continuation store, overridden in `bootstrap` and in tests.
///
/// A plain [Provider] for the same reason as `credentialStoreProvider`: the
/// value never changes, and the deliberate default keeps a platform channel out
/// of any test that has not substituted a store.
final Provider<RegistrationContinuationStore>
registrationContinuationStoreProvider = Provider<RegistrationContinuationStore>(
  (ref) => throw UnimplementedError(
    'registrationContinuationStoreProvider must be overridden with a '
    'real or fake store',
  ),
);
