import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the one non-sensitive appearance preference.
///
/// **Not in `SecureCredentialStore`.** That store is token-specific and exists
/// for credentials; a theme choice is neither secret nor part of a session. The
/// app therefore uses `shared_preferences`, which is the general-purpose store
/// this preference belongs in.
///
/// The stored value is a stable word (`light`, `dark`, `system`) rather than the
/// enum's index, so reordering [ThemeMode] cannot change what an existing
/// installation restores. Anything unrecognised — including a missing key or a
/// value written by a future version — resolves to [ThemeMode.system].
class ThemePreferenceStore {
  const ThemePreferenceStore(this._preferences);

  /// The namespaced key, shared with tests and future migrations.
  static const String storageKey = 'stash_it.settings.theme_mode';

  final SharedPreferences _preferences;

  /// Reads the persisted mode, falling back to [ThemeMode.system].
  ///
  /// Reading is synchronous because [SharedPreferences] has already loaded its
  /// cache when `bootstrap` constructed this store. That is what lets the first
  /// frame use the saved Light or Dark mode instead of briefly showing System.
  ThemeMode read() {
    // `get` rather than `getString`: a malformed non-string value must fall back
    // to System, not throw while the app is starting.
    return switch (_preferences.get(storageKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  /// Persists [mode] and reports whether the platform accepted the write.
  ///
  /// A false result or a platform exception is returned rather than thrown: the
  /// controller keeps the already-applied theme and tells the user that the
  /// preference could not be saved. No caller should claim persistence succeeded
  /// when this returns false.
  Future<bool> write(ThemeMode mode) async {
    try {
      return await _preferences.setString(storageKey, _valueFor(mode));
    } catch (_) {
      return false;
    }
  }

  static String _valueFor(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

/// The store supplied by `bootstrap`.
///
/// No default implementation is provided: constructing one would read a platform
/// channel during a provider build, which is exactly the asynchronous work
/// `bootstrap` performs before the first frame.
final Provider<ThemePreferenceStore> themePreferenceStoreProvider =
    Provider<ThemePreferenceStore>(
      (ref) => throw UnimplementedError(
        'themePreferenceStoreProvider must be overridden by bootstrap',
      ),
    );
