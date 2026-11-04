import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/config/google_auth_config.dart';
import '../core/storage/secure_credential_store.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/data/password_reset_continuation_store.dart';
import '../features/auth/data/registration_continuation_store.dart';
import '../features/pending_urls/data/pending_url_store.dart';
import '../features/settings/application/language_preference_controller.dart';
import '../features/settings/application/theme_mode_controller.dart';
import '../features/settings/data/language_preference_store.dart';
import '../features/settings/data/theme_preference_store.dart';
import 'config/api_config.dart';

/// Initializes platform services and restores persisted state before the first
/// frame. Returns the provider overrides required by the application.
Future<List<Override>> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!ApiConfig.isConfigured) {
    throw StateError(
      'API_BASE_URL is not set. Run with '
      '--dart-define=API_BASE_URL=http://<host>:<port>.\n'
      'An Android emulator reaches the host loopback at 10.0.2.2, not localhost.',
    );
  }

  // The supported native desktop targets use a browser-based flow with a
  // Desktop OAuth client instead of the mobile Google Sign-In plugin, so each
  // platform validates the client ID its Google flow actually uses.
  final requiresDesktopClient =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS);

  if (requiresDesktopClient && !GoogleAuthConfig.isDesktopConfigured) {
    throw StateError(
      'GOOGLE_DESKTOP_CLIENT_ID is not set. Run with '
      '--dart-define=GOOGLE_DESKTOP_CLIENT_ID=<desktop-client-id>.',
    );
  }
  if (!requiresDesktopClient && !GoogleAuthConfig.isConfigured) {
    throw StateError(
      'GOOGLE_SERVER_CLIENT_ID is not set. Run with '
      '--dart-define=GOOGLE_SERVER_CLIENT_ID=<client-id>.',
    );
  }

  // macOS uses the legacy Keychain so an unsigned testing build does not need
  // the keychain-access-groups entitlement or a provisioning profile. Other
  // platforms keep their existing secure storage configuration.
  final secureStorage = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
      ? const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        )
      : const FlutterSecureStorage();
  final credentialStore = SecureCredentialStore(secureStorage);
  final registrationContinuationStore = RegistrationContinuationStore(
    secureStorage,
  );
  final passwordResetContinuationStore = PasswordResetContinuationStore(
    secureStorage,
  );

  // Read directly because credentialStoreProvider is not available until bootstrap completes.
  final restoredTokens = await credentialStore.read();

  // Restore the theme before the first frame to avoid a visual flash.
  final preferences = await SharedPreferences.getInstance();
  final themeStore = ThemePreferenceStore(preferences);

  final languageStore = LanguagePreferenceStore(preferences);

  // Pending URLs are device-local, non-sensitive data and must remain available
  // independently of authentication state.
  final pendingUrlStore = PendingUrlStore(preferences);

  return [
    credentialStoreProvider.overrideWithValue(credentialStore),
    registrationContinuationStoreProvider.overrideWithValue(
      registrationContinuationStore,
    ),
    passwordResetContinuationStoreProvider.overrideWithValue(
      passwordResetContinuationStore,
    ),
    restoredTokensProvider.overrideWithValue(restoredTokens),
    themePreferenceStoreProvider.overrideWithValue(themeStore),
    initialThemeModeProvider.overrideWithValue(themeStore.read()),
    languagePreferenceStoreProvider.overrideWithValue(languageStore),
    initialLanguagePreferenceProvider.overrideWithValue(languageStore.read()),
    pendingUrlStoreProvider.overrideWithValue(pendingUrlStore),
  ];
}
