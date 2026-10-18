import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/storage/secure_credential_store.dart';
import '../features/auth/application/session_controller.dart';
import 'config/api_config.dart';

/// Prepares everything the app needs before the first frame is built.
///
/// Runs before `runApp` and returns the [ProviderScope] overrides the app needs,
/// for one reason: **credential restoration is asynchronous** and a provider's
/// `build` cannot be. Reading storage inside `bootstrap` is what lets
/// [AuthState] be synchronous, and therefore what lets the router decide on the
/// very first navigation whether to show the app or sign-in — with no flash of
/// the wrong one and no `restoring` state threaded through every screen.
///
/// Two things happen here and nowhere else:
///
/// - the platform binding is initialised, which any plugin channel requires;
/// - stored credentials are read exactly once.
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

  // Read directly rather than through a provider: `credentialStoreProvider` is
  // overridden only by the overrides returned below, so reading it from a fresh
  // container would hit the deliberate `UnimplementedError` its default carries.
  final restoredTokens = await credentialStore.read();

  return [
    credentialStoreProvider.overrideWithValue(credentialStore),
    restoredTokensProvider.overrideWithValue(restoredTokens),
  ];
}
