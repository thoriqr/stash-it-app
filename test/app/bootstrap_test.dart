import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/bootstrap.dart';
import 'package:stash_it_app/app/config/api_config.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/datasources/auth_api.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/features/settings/data/language_preference_store.dart';
import 'package:stash_it_app/features/settings/data/theme_preference_store.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';

import '../support/fake_http.dart';
import '../support/pending_urls.dart';

/// `bootstrap` is the one piece of wiring no other test reaches, because it runs
/// before the app exists. A mistake there — a provider read from an unoverridden
/// container, a missing override — is invisible until the app launches on a
/// device, so its behaviour is pinned here.
void main() {
  // `bootstrap` calls `WidgetsFlutterBinding.ensureInitialized`; initialize the
  // test binding first so the later `SharedPreferences` mock uses the same one.
  TestWidgetsFlutterBinding.ensureInitialized();

  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';

  group('base URL', () {
    test('is required and reported clearly when absent', () {
      // `API_BASE_URL` is compile-time, so it cannot vary per test. Whichever way
      // this environment resolves, the behaviour must be explicit rather than an
      // obscure failure on the first request.
      if (ApiConfig.isConfigured) {
        expect(ApiConfig.baseUrl, isNotEmpty);
        return;
      }

      expect(
        () => bootstrap(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('API_BASE_URL'),
          ),
        ),
      );
    });

    test('never keeps a trailing slash', () {
      // Dio joins `baseUrl + path` and Retrofit paths begin with `/`, so a
      // trailing slash would put a double slash in every request path.
      expect(ApiConfig.baseUrl.endsWith('/'), isFalse);
    });
  });

  group('the credential read bootstrap performs', () {
    test('a full pair is restored', () async {
      final storage = InMemorySecureStorage()
        ..values[accessKey] = 'access-1'
        ..values[refreshKey] = 'refresh-1';

      expect(
        await SecureCredentialStore(storage).read(),
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );
    });

    test('a half-present pair is not a session', () async {
      // A startup that reported this as a session would let the user into the
      // app with a token no request can renew.
      final storage = InMemorySecureStorage()..values[accessKey] = 'access-1';

      expect(await SecureCredentialStore(storage).read(), isNull);
    });

    test('an empty store is not a session', () async {
      expect(
        await SecureCredentialStore(InMemorySecureStorage()).read(),
        isNull,
      );
    });
  });

  group('the overrides bootstrap returns', () {
    late PendingUrlStore pendingStore;
    late LanguagePreferenceStore languageStore;
    late ThemePreferenceStore themeStore;

    setUp(() async {
      pendingStore = await testPendingUrlStore();
      final preferences = await SharedPreferences.getInstance();
      languageStore = LanguagePreferenceStore(preferences);
      themeStore = ThemePreferenceStore(preferences);
    });

    // Assembled the way `bootstrap` assembles them, which is the only way to
    // check that the three together make a working container: each on its own
    // proves nothing.
    ProviderContainer wiredContainer({
      AuthTokens? restored,
      InMemorySecureStorage? storage,
    }) {
      final sharedStorage = storage ?? InMemorySecureStorage();
      final container = ProviderContainer(
        overrides: [
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(sharedStorage),
          ),
          registrationContinuationStoreProvider.overrideWithValue(
            RegistrationContinuationStore(sharedStorage),
          ),
          passwordResetContinuationStoreProvider.overrideWithValue(
            PasswordResetContinuationStore(sharedStorage),
          ),
          restoredTokensProvider.overrideWithValue(restored),
          themePreferenceStoreProvider.overrideWithValue(themeStore),
          initialThemeModeProvider.overrideWithValue(themeStore.read()),
          languagePreferenceStoreProvider.overrideWithValue(languageStore),
          initialLanguagePreferenceProvider.overrideWithValue(
            languageStore.read(),
          ),
          pendingUrlStoreProvider.overrideWithValue(pendingStore),
          authRepositoryProvider.overrideWith(
            (ref) =>
                AuthRepository(authApi: AuthApi(ref.watch(appDioProvider))),
          ),
        ],
        // Stops Riverpod retrying a provider driven into an error state, which
        // would otherwise make error-path tests slow and add call-count noise.
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      return container;
    }

    test('a restored pair makes the app start signed in', () {
      final container = wiredContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );

      expect(container.read(authStateProvider), AuthStatus.signedIn);
    });

    test('no restored pair makes the app start signed out', () {
      final container = wiredContainer();

      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });

    test('the repository and its two Dio instances resolve', () {
      // Exercises the lazy construction that keeps the auth interceptor's
      // dependency on the session controller from becoming a cycle.
      final container = wiredContainer();

      expect(container.read(authRepositoryProvider), isA<AuthRepository>());
      expect(container.read(appDioProvider), isNotNull);
      expect(container.read(refreshDioProvider), isNotNull);
    });

    test('the registration continuation store resolves', () {
      // Its default throws deliberately, so a missing bootstrap override would
      // only surface when the user submitted the sign-up form.
      final container = wiredContainer();

      expect(
        container.read(registrationContinuationStoreProvider),
        isA<RegistrationContinuationStore>(),
      );
    });

    test('the password reset continuation store resolves', () {
      final container = wiredContainer();

      expect(
        container.read(passwordResetContinuationStoreProvider),
        isA<PasswordResetContinuationStore>(),
      );
    });

    test('the device-local URL store resolves', () {
      final container = wiredContainer();

      expect(container.read(pendingUrlStoreProvider), isA<PendingUrlStore>());
    });

    test('the theme preference store resolves', () {
      final container = wiredContainer();

      expect(
        container.read(themePreferenceStoreProvider),
        isA<ThemePreferenceStore>(),
      );
    });

    test('the language preference store resolves', () {
      final container = wiredContainer();

      expect(
        container.read(languagePreferenceStoreProvider),
        isA<LanguagePreferenceStore>(),
      );
    });

    test('the initial language preference defaults to system', () {
      final container = wiredContainer();

      expect(
        container.read(initialLanguagePreferenceProvider),
        LanguagePreference.system,
      );
    });

    test('the initial theme mode defaults to system', () {
      final container = wiredContainer();

      expect(container.read(initialThemeModeProvider), ThemeMode.system);
    });

    test(
      'a stored language preference is restored during bootstrap assembly',
      () async {
        // `testPendingUrlStore` already created the SharedPreferences singleton
        // with empty values; reset it so a fresh instance picks up the stored 'id'.
        SharedPreferences.resetStatic();
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceStore.storageKey: 'id',
        });
        final preferences = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            credentialStoreProvider.overrideWithValue(
              SecureCredentialStore(InMemorySecureStorage()),
            ),
            languagePreferenceStoreProvider.overrideWithValue(
              LanguagePreferenceStore(preferences),
            ),
            initialLanguagePreferenceProvider.overrideWithValue(
              LanguagePreferenceStore(preferences).read(),
            ),
            pendingUrlStoreProvider.overrideWithValue(pendingStore),
          ],
          retry: (_, _) => null,
        );
        addTearDown(container.dispose);

        expect(
          container.read(initialLanguagePreferenceProvider),
          LanguagePreference.indonesian,
        );
      },
    );

    test('refreshDio carries no auth interceptor, so renewal cannot recurse', () {
      // The structural guarantee behind single-flight: a renewal response cannot
      // reach the interceptor, because the interceptor is not on this instance.
      final container = wiredContainer();

      final interceptorTypes = container
          .read(refreshDioProvider)
          .interceptors
          .map((i) => i.runtimeType.toString())
          .toList();

      expect(
        interceptorTypes.any((t) => t.contains('AuthInterceptor')),
        isFalse,
        reason: 'a refresh response must never re-enter the auth interceptor',
      );
    });

    test('appDio does carry the auth interceptor', () {
      final container = wiredContainer();

      final interceptorTypes = container
          .read(appDioProvider)
          .interceptors
          .map((i) => i.runtimeType.toString())
          .toList();

      expect(
        interceptorTypes.any((t) => t.contains('AuthInterceptor')),
        isTrue,
      );
    });
  });
}
