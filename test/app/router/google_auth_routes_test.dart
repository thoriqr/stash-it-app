import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/google_auth_service.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/finalize_social_registration_screen.dart';
import 'package:stash_it_app/features/auth/presentation/google_account_link_screen.dart';
import 'package:stash_it_app/features/auth/presentation/pin_entry_screen.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../support/fake_http.dart';
import '../../support/pending_urls.dart';
import '../../support/saved_items_fixtures.dart';

class _FakeGoogleAuthService extends GoogleAuthService {
  Future<GoogleAuthCredential?> Function()? result;

  @override
  Future<GoogleAuthCredential?> signIn() async {
    final handler = result;
    if (handler == null) return null;
    return handler();
  }
}

void main() {
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
  const maskedEmail = 'g***@example.com';

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;
  late _FakeGoogleAuthService google;
  late PendingUrlStore pendingStore;

  setUp(() async {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
    google = _FakeGoogleAuthService();
    pendingStore = await testPendingUrlStore();
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        registrationContinuationStoreProvider.overrideWithValue(
          RegistrationContinuationStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(null),
        googleAuthServiceProvider.overrideWithValue(google),
        pendingUrlStoreProvider.overrideWithValue(pendingStore),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
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

  Future<void> pumpApp(
    WidgetTester tester, {
    String location = AppRoutes.auth,
    Object? extra,
  }) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    adapter.onMethod(
      'GET',
      '/saved-items',
      status: 200,
      body: SavedItemsFixtures.emptyPage(),
    );

    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);
    router.go(location, extra: extra);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  void scriptAuthenticatedGoogleLogin() {
    adapter.onMethod(
      'POST',
      '/auth/login/google',
      body: {'data': authenticatedData(), 'message': 'login successful'},
    );
  }

  testWidgets('direct Google sign-in enters the app and stores the pair', (
    tester,
  ) async {
    google.result = () async => const GoogleAuthCredential(
      idToken: 'google-id-token',
      email: 'google@example.com',
      displayName: 'Google User',
    );
    scriptAuthenticatedGoogleLogin();

    await pumpApp(tester, location: AppRoutes.signIn);
    await tester.tap(find.widgetWithText(AppButton, 'Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.text('A place for things you find on the internet.'),
      findsNothing,
    );
    expect(container.read(authStateProvider), AuthStatus.signedIn);

    final sent = adapter.lastRequestTo('/auth/login/google')!;
    expect(sent.jsonField('id_token'), 'google-id-token');
    expect((sent.body as Map).keys, {'id_token'});
    expect(
      await container.read(credentialStoreProvider).readAccessToken(),
      'access-google',
    );
  });

  testWidgets(
    'account-link-required opens the masked confirmation without a session',
    (tester) async {
      google.result = () async => const GoogleAuthCredential(
        idToken: 'google-id-token',
        email: 'google@example.com',
        displayName: 'Google User',
      );
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
      adapter.onMethod(
        'GET',
        '/auth/login/google/account-link/confirmation-1',
        body: {
          'data': {
            'id': 'confirmation-1',
            'provider': 'google',
            'display_name_snapshot': 'Google User',
            'masked_user_email': maskedEmail,
          },
          'message': 'confirmation retrieved',
        },
      );

      await pumpApp(tester, location: AppRoutes.signIn);
      await tester.tap(find.widgetWithText(AppButton, 'Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.byType(GoogleAccountLinkScreen), findsOneWidget);
      expect(find.text('Link your Google account'), findsOneWidget);
      expect(find.textContaining(maskedEmail), findsOneWidget);
      expect(find.text('Google profile: Google User'), findsOneWidget);
      expect(container.read(authStateProvider), AuthStatus.signedOut);

      final router = container.read(appRouterProvider);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/sign-in/google/account-link/confirmation-1',
      );
      expect(
        router.routeInformationProvider.value.uri.path,
        isNot(contains('google-id-token')),
      );
    },
  );

  testWidgets('confirming the link adopts the session', (tester) async {
    adapter.onMethod(
      'GET',
      '/auth/login/google/account-link/confirmation-1',
      body: {
        'data': {
          'id': 'confirmation-1',
          'provider': 'google',
          'display_name_snapshot': 'Google User',
          'masked_user_email': maskedEmail,
        },
        'message': 'confirmation retrieved',
      },
    );
    adapter.onMethod(
      'POST',
      '/auth/login/google/account-link/confirmation-1/confirm',
      body: {'data': authenticatedData(), 'message': 'account linked'},
    );

    await pumpApp(
      tester,
      location: AppRoutes.googleAccountLinkFor('confirmation-1'),
      extra: const GoogleAccountLinkArgs(idToken: 'google-id-token'),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Link account'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(container.read(authStateProvider), AuthStatus.signedIn);

    final sent = adapter.lastRequestTo('/confirm')!;
    expect(sent.jsonField('id_token'), 'google-id-token');
    expect(
      await container.read(credentialStoreProvider).readAccessToken(),
      'access-google',
    );
  });

  testWidgets(
    'a committed link without a session is not presented as signed in',
    (tester) async {
      adapter.onMethod(
        'GET',
        '/auth/login/google/account-link/confirmation-1',
        body: {
          'data': {
            'id': 'confirmation-1',
            'provider': 'google',
            'display_name_snapshot': 'Google User',
            'masked_user_email': maskedEmail,
          },
          'message': 'confirmation retrieved',
        },
      );
      adapter.onMethod(
        'POST',
        '/auth/login/google/account-link/confirmation-1/confirm',
        status: 503,
        body: errorBody(ApiErrorCode.accountLinkSessionFailed),
      );

      await pumpApp(
        tester,
        location: AppRoutes.googleAccountLinkFor('confirmation-1'),
        extra: const GoogleAccountLinkArgs(idToken: 'google-id-token'),
      );
      await tester.tap(find.widgetWithText(AppButton, 'Link account'));
      await tester.pumpAndSettle();

      expect(find.text('Accounts linked'), findsOneWidget);
      expect(find.textContaining('Continue with Google'), findsOneWidget);
      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(
        await container.read(credentialStoreProvider).readAccessToken(),
        isNull,
      );
    },
  );

  testWidgets(
    'registration-required uses the PIN route and finalizes socially',
    (tester) async {
      google.result = () async => const GoogleAuthCredential(
        idToken: 'google-id-token',
        email: 'google@example.com',
        displayName: 'Google User',
      );
      adapter.onMethod(
        'POST',
        '/auth/login/google',
        body: {
          'data': {
            'outcome': 'registration_required',
            'verification_id': verificationId,
          },
          'message': 'registration required',
        },
      );
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/pin',
        status: 201,
        body: {
          'data': {'verification_id': verificationId},
          'message': 'verification code sent',
        },
      );
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        body: {
          'data': {
            'verification_id': verificationId,
            'status': 'pending',
            'pin_issued': true,
            'resend_in_seconds': 0,
          },
          'message': 'verification retrieved',
        },
      );
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        body: {
          'data': {'registration_continuation_token': 'social-token'},
          'message': 'registration verified',
        },
      );
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        body: {
          'data': {
            'email': 'google@example.com',
            'registration_type': 'social',
            'requires_password': false,
          },
          'message': 'continuation retrieved',
        },
      );
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/social',
        body: {
          'data': {
            'access_token': 'access-social',
            'refresh_token': 'refresh-social',
            'user': {
              'id': '01a0f359-093b-737a-963a-80f7ca6768ed',
              'email': 'google@example.com',
              'display_name': 'Google User',
            },
          },
          'message': 'social registration completed',
        },
      );

      await pumpApp(tester, location: AppRoutes.signIn);
      await tester.tap(find.widgetWithText(AppButton, 'Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.byType(PinEntryScreen), findsOneWidget);
      expect(find.text('Enter your PIN'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.widgetWithText(AppButton, 'Verify PIN'));
      await tester.pumpAndSettle();

      expect(find.byType(FinalizeSocialRegistrationScreen), findsOneWidget);
      final nameField = tester.widget<TextField>(find.byType(TextField));
      expect(nameField.controller?.text, 'Google User');

      await tester.tap(find.widgetWithText(AppButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(container.read(authStateProvider), AuthStatus.signedIn);
      expect(
        await container.read(credentialStoreProvider).readAccessToken(),
        'access-social',
      );
      expect(
        await container.read(registrationContinuationStoreProvider).read(),
        isNull,
      );
    },
  );

  testWidgets('social finalize without an in-memory token is refused', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.finalizeSocialRegistration);

    expect(
      find.text('A place for things you find on the internet.'),
      findsOneWidget,
    );
    expect(find.byType(FinalizeSocialRegistrationScreen), findsNothing);
  });

  testWidgets(
    'a consumed social continuation is terminal and clears the token',
    (tester) async {
      await container
          .read(registrationContinuationStoreProvider)
          .write(email: 'google@example.com', token: 'consumed-token');
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationConsumed),
      );

      await pumpApp(
        tester,
        location: AppRoutes.finalizeSocialRegistration,
        extra: const FinalizeSocialRegistrationArgs(
          continuationToken: 'consumed-token',
        ),
      );

      expect(find.text('Account already created'), findsOneWidget);
      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(
        await container.read(registrationContinuationStoreProvider).read(),
        isNull,
      );
    },
  );

  testWidgets('a non-social continuation is refused and cleared', (
    tester,
  ) async {
    await container
        .read(registrationContinuationStoreProvider)
        .write(email: 'manual@example.com', token: 'manual-token');
    adapter.onMethod(
      'GET',
      '/auth/register/continuation',
      body: {
        'data': {
          'email': 'manual@example.com',
          'registration_type': 'manual',
          'requires_password': true,
        },
        'message': 'continuation retrieved',
      },
    );

    await pumpApp(
      tester,
      location: AppRoutes.finalizeSocialRegistration,
      extra: const FinalizeSocialRegistrationArgs(
        continuationToken: 'manual-token',
      ),
    );

    expect(find.text('Registration unavailable'), findsOneWidget);
    expect(
      await container.read(registrationContinuationStoreProvider).read(),
      isNull,
    );
  });

  testWidgets('an invalid account-link confirmation is terminal', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/login/google/account-link/confirmation-1',
      status: 409,
      body: errorBody(ApiErrorCode.accountLinkConfirmationInvalid),
    );

    await pumpApp(
      tester,
      location: AppRoutes.googleAccountLinkFor('confirmation-1'),
      extra: const GoogleAccountLinkArgs(idToken: 'google-id-token'),
    );

    expect(find.text('Link unavailable'), findsOneWidget);
    expect(container.read(authStateProvider), AuthStatus.signedOut);
    expect(adapter.countFor('/account-link/confirmation-1/confirm'), 0);
  });

  testWidgets('a mismatched Google identity is terminal', (tester) async {
    adapter.onMethod(
      'GET',
      '/auth/login/google/account-link/confirmation-1',
      body: {
        'data': {
          'id': 'confirmation-1',
          'provider': 'google',
          'display_name_snapshot': 'Google User',
          'masked_user_email': maskedEmail,
        },
        'message': 'confirmation retrieved',
      },
    );
    adapter.onMethod(
      'POST',
      '/auth/login/google/account-link/confirmation-1/confirm',
      status: 409,
      body: errorBody(ApiErrorCode.accountLinkIdentityMismatch),
    );

    await pumpApp(
      tester,
      location: AppRoutes.googleAccountLinkFor('confirmation-1'),
      extra: const GoogleAccountLinkArgs(idToken: 'google-id-token'),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Link account'));
    await tester.pumpAndSettle();

    expect(find.text('Different Google account'), findsOneWidget);
    expect(container.read(authStateProvider), AuthStatus.signedOut);
  });

  testWidgets('social finalize validates the display name before sending', (
    tester,
  ) async {
    await container
        .read(registrationContinuationStoreProvider)
        .write(email: 'google@example.com', token: 'social-token');
    adapter.onMethod(
      'GET',
      '/auth/register/continuation',
      body: {
        'data': {
          'email': 'google@example.com',
          'registration_type': 'social',
          'requires_password': false,
        },
        'message': 'continuation retrieved',
      },
    );

    await pumpApp(
      tester,
      location: AppRoutes.finalizeSocialRegistration,
      extra: const FinalizeSocialRegistrationArgs(
        continuationToken: 'social-token',
      ),
    );

    await tester.ensureVisible(
      find.widgetWithText(AppButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a display name.'), findsOneWidget);
    expect(adapter.countFor('/auth/register/finalize/social'), 0);
  });

  testWidgets('an uncertain social finalization keeps the continuation', (
    tester,
  ) async {
    await container
        .read(registrationContinuationStoreProvider)
        .write(email: 'google@example.com', token: 'social-token');
    adapter.onMethod(
      'GET',
      '/auth/register/continuation',
      body: {
        'data': {
          'email': 'google@example.com',
          'registration_type': 'social',
          'requires_password': false,
        },
        'message': 'continuation retrieved',
      },
    );
    adapter.onOffline('/auth/register/finalize/social', method: 'POST');

    await pumpApp(
      tester,
      location: AppRoutes.finalizeSocialRegistration,
      extra: const FinalizeSocialRegistrationArgs(
        continuationToken: 'social-token',
        suggestedDisplayName: 'Google User',
      ),
    );

    await tester.ensureVisible(
      find.widgetWithText(AppButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('could not confirm whether registration completed'),
      findsOneWidget,
    );
    expect(container.read(authStateProvider), AuthStatus.signedOut);
    expect(
      (await container.read(registrationContinuationStoreProvider).read())
          ?.token,
      'social-token',
    );
  });
}
