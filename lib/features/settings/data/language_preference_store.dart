import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/language_preference.dart';

/// Persists the one non-sensitive language preference.
///
/// **Not in `SecureCredentialStore`** — mirrors [ThemePreferenceStore]: a
/// language choice is neither secret nor part of a session, so it uses
/// `shared_preferences`, the general-purpose store these preferences belong in.
///
/// The stored value is a stable word (`system`, `en`, `id`) rather than the
/// enum's index, so reordering [LanguagePreference] cannot change what an
/// existing installation restores. Anything unrecognised resolves to
/// [LanguagePreference.system].
class LanguagePreferenceStore {
  const LanguagePreferenceStore(this._preferences);

  /// The namespaced key, shared with tests and future migrations.
  static const String storageKey = 'stash_it.settings.language';

  final SharedPreferences _preferences;

  /// Reads the persisted preference, falling back to [LanguagePreference.system].
  ///
  /// Reading is synchronous because [SharedPreferences] has already loaded its
  /// cache when `bootstrap` constructed this store — the same rationale as
  /// [ThemePreferenceStore.read], which keeps the first frame from briefly
  /// flashing the wrong language.
  LanguagePreference read() {
    // `get` rather than `getString`: a malformed non-string value must fall back
    // to System, not throw while the app is starting.
    return LanguagePreference.fromStorage(_preferences.get(storageKey));
  }

  /// Persists [preference] and reports whether the platform accepted the write.
  ///
  /// A `false` result or platform exception is returned rather than thrown:
  /// the controller keeps the already-applied language and tells the user that
  /// the preference could not be saved. No caller should claim persistence
  /// succeeded when this returns `false`.
  Future<bool> write(LanguagePreference preference) async {
    try {
      return await _preferences.setString(storageKey, preference.storageValue);
    } catch (_) {
      return false;
    }
  }
}

/// The store supplied by `bootstrap`.
///
/// No default implementation is provided: constructing one would read a platform
/// channel during a provider build, which is exactly the asynchronous work
/// `bootstrap` performs before the first frame. Same rationale as
/// [themePreferenceStoreProvider].
final Provider<LanguagePreferenceStore> languagePreferenceStoreProvider =
    Provider<LanguagePreferenceStore>(
      (ref) => throw UnimplementedError(
        'languagePreferenceStoreProvider must be overridden by bootstrap',
      ),
    );
