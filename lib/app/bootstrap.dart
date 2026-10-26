import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/secure_credential_store.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/data/registration_continuation_store.dart';
import '../features/settings/application/theme_mode_controller.dart';
import '../features/settings/data/theme_preference_store.dart';
import 'config/api_config.dart';

/// Prepares everything the app needs before the first frame is built.
///
/// Runs before `runApp` and returns the [ProviderScope] overrides the app needs,
/// for one reason: **storage reads are asynchronous** and a provider's `build`
/// cannot be. Reading them inside `bootstrap` is what lets [AuthState] and the
/// theme choice be synchronous, and therefore what lets the router decide on the
/// very first navigation whether to show the app or the auth entry screen — with
/// no flash of the wrong one and no `restoring` state threaded through every
/// screen.
///
/// Three things happen here and nowhere else:
///
/// - the platform binding is initialised, which any plugin channel requires;
/// - stored credentials are read exactly once;
/// - the theme preference is read exactly once, before the first frame, so a
///   saved Light or Dark choice is never briefly replaced by System.
///
/// **No network request and no token validation.** The access token is a
/// self-contained JWT whose expiry this client deliberately does not decode: a
/// local expiry guess would make the client its own authority on a credential
/// only the backend can judge. A stored pair means "signed in until proven
/// otherwise", and the first protected request is that proof. This also costs
/// no rotation on a cold start.
Future<List<Override>> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!ApiConfig.isConfigured) {
    throw StateError(
      'API_BASE_URL is not set. Run with '
      '--dart-define=API_BASE_URL=http://<host>:<port>.\n'
      'An Android emulator reaches the host loopback at 10.0.2.2, not localhost.',
    );
  }

  const secureStorage = FlutterSecureStorage();
  const credentialStore = SecureCredentialStore(secureStorage);
  const registrationContinuationStore = RegistrationContinuationStore(
    secureStorage,
  );

  // Read directly rather than through a provider: `credentialStoreProvider` is
  // overridden only by the overrides returned below, so reading it from a fresh
  // container would hit the deliberate `UnimplementedError` its default carries.
  final restoredTokens = await credentialStore.read();

  // The registration continuation is deliberately not read here. It is only
  // needed when the user submits the sign-up form, and an unfinished
  // registration is not resumed automatically on launch.

  // A non-sensitive UI preference lives in shared preferences, not in the
  // credential store. Reading it here, rather than inside a provider build,
  // keeps the first frame synchronous and already themed.
  final preferences = await SharedPreferences.getInstance();
  final themeStore = ThemePreferenceStore(preferences);

  return [
    credentialStoreProvider.overrideWithValue(credentialStore),
    registrationContinuationStoreProvider.overrideWithValue(
      registrationContinuationStore,
    ),
    restoredTokensProvider.overrideWithValue(restoredTokens),
    themePreferenceStoreProvider.overrideWithValue(themeStore),
    initialThemeModeProvider.overrideWithValue(themeStore.read()),
  ];
}
