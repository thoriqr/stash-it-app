import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';

import '../../../support/fake_http.dart';

void main() {
  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;
  });

  Map<String, dynamic> authenticatedData() => {
    'outcome': 'authenticated',
    'access_token': 'access-google',
    'refresh_token': 'refresh-google',
    'user': {
      'id': '01a0f359-093b-737a-963a-80f7ca6768ed',
      'email': 'google@example.com',
      'display_name': 'Google User',
    },
  };

  Future<bool> hasStoredPair() async {
    final store = container.read(credentialStoreProvider);
    return (await store.readAccessToken()) != null &&
        (await store.readRefreshToken()) != null;
  }

  test('authenticated Google login persists and adopts the pair', () async {
    adapter.onMethod(
      'POST',
      '/auth/login/google',
      body: {'data': authenticatedData(), 'message': 'login successful'},
    );

    final result = await container
        .read(authStateProvider.notifier)
        .signInWithGoogle('google-id-token');

    expect(result, isA<GoogleSignInAuthenticated>());
    expect(container.read(authStateProvider), AuthStatus.signedIn);
    expect(await hasStoredPair(), isTrue);
    expect(
      await container.read(credentialStoreProvider).readAccessToken(),
      'access-google',
    );
  });

  test(
    'account-link-required never creates a session or stores a pair',
    () async {
      adapter.onMethod(
        'POST',
        '/auth/login/google',
        body: {
          'data': {
            'outcome': 'account_link_required',
            'provider': 'google',
            'confirmation_id': 'confirmation-1',
          },
          'message': 'account link required',
        },
      );

      final result = await container
          .read(authStateProvider.notifier)
          .signInWithGoogle('google-id-token');

      expect(result, isA<GoogleAccountLinkRequired>());
      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(await hasStoredPair(), isFalse);
    },
  );

  test(
    'registration-required never creates a session or stores a pair',
    () async {
      adapter.onMethod(
        'POST',
        '/auth/login/google',
        body: {
          'data': {
            'outcome': 'registration_required',
            'verification_id': 'verification-1',
          },
          'message': 'registration required',
        },
      );

      final result = await container
          .read(authStateProvider.notifier)
          .signInWithGoogle('google-id-token');

      expect(result, isA<GoogleRegistrationRequired>());
      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(await hasStoredPair(), isFalse);
    },
  );

  test('account-link confirmation persists and adopts the pair', () async {
    adapter.onMethod(
      'POST',
      '/auth/login/google/account-link/confirmation-1/confirm',
      body: {'data': authenticatedData(), 'message': 'account linked'},
    );

    await container
        .read(authStateProvider.notifier)
        .confirmGoogleAccountLink(
          confirmationId: 'confirmation-1',
          idToken: 'google-id-token',
        );

    expect(container.read(authStateProvider), AuthStatus.signedIn);
    expect(await hasStoredPair(), isTrue);
  });

  test('social finalization persists and adopts the pair', () async {
    adapter.onMethod(
      'POST',
      '/auth/register/finalize/social',
      body: {
        'data': {
          'access_token': 'access-social',
          'refresh_token': 'refresh-social',
          'user': {
            'id': '01a0f359-093b-737a-963a-80f7ca6768ed',
            'email': 'social@example.com',
            'display_name': 'Social User',
          },
        },
        'message': 'social registration completed',
      },
    );

    await container
        .read(authStateProvider.notifier)
        .finalizeSocialRegistration(
          continuationToken: 'social-token',
          displayName: 'Social User',
        );

    expect(container.read(authStateProvider), AuthStatus.signedIn);
    expect(
      await container.read(credentialStoreProvider).readAccessToken(),
      'access-social',
    );
  });
}
