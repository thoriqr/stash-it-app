import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/finalize_registration_screen.dart';
import 'package:stash_it_app/features/auth/presentation/pin_entry_screen.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart';

import '../../support/fake_http.dart';
import '../../support/saved_items_fixtures.dart';

/// The registration routes as the real router builds them.
///
/// The email is not part of the PIN location, so the only way to establish that
/// it reached the screen is to read the widget the builder produced. The same
/// applies to the continuation token on the finalize route.
void main() {
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
  const email = 'reader@example.com';
  const token = 'raw-continuation-token';

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
        registrationContinuationStoreProvider.overrideWithValue(
          RegistrationContinuationStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    // The router opens on the Inbox, and the shell builds its listing before the
    // test navigates away.
    adapter.onMethod(
      'GET',
      '/saved-items',
      status: 200,
      body: SavedItemsFixtures.emptyPage(),
    );

    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('the PIN route receives the registration email as extra', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/register/verification/$verificationId',
      status: 200,
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

    final router = await pumpApp(tester);
    router.go(AppRoutes.signUpVerifyFor(verificationId), extra: email);
    await tester.pumpAndSettle();

    final screen = tester.widget<PinEntryScreen>(find.byType(PinEntryScreen));
    expect(screen.verificationId, verificationId);
    expect(screen.email, email);
  });

  testWidgets('the finalize route receives the raw continuation token', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/register/continuation',
      status: 200,
      body: {
        'data': {
          'email': email,
          'registration_type': 'manual',
          'requires_password': true,
        },
        'message': 'registration continuation is valid',
      },
    );

    final router = await pumpApp(tester);
    router.go(AppRoutes.finalizeRegistration, extra: token);
    await tester.pumpAndSettle();

    final screen = tester.widget<FinalizeRegistrationScreen>(
      find.byType(FinalizeRegistrationScreen),
    );
    expect(screen.continuationToken, token);
  });

  testWidgets('the finalize route without a token falls back to sign-up', (
    tester,
  ) async {
    final router = await pumpApp(tester);
    router.go(AppRoutes.finalizeRegistration);
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.byType(FinalizeRegistrationScreen), findsNothing);
  });
}
