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
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_finalize_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_pin_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_request_screen.dart';

import '../../support/fake_http.dart';
import '../../support/saved_items_fixtures.dart';

/// The password-reset routes as the real router builds them.
void main() {
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
  const email = 'reader@example.com';

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
        passwordResetContinuationStoreProvider.overrideWithValue(
          PasswordResetContinuationStore(backend),
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

  testWidgets('the request route is reachable and starts the reset flow', (
    tester,
  ) async {
    final router = await pumpApp(tester);
    router.go(AppRoutes.forgotPassword);
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetRequestScreen), findsOneWidget);
  });

  testWidgets(
    'the email-selection mode opens the form with a saved token retained',
    (tester) async {
      await container
          .read(passwordResetContinuationStoreProvider)
          .write(email: email, token: 'saved-token');

      final router = await pumpApp(tester);
      router.go(
        AppRoutes.forgotPassword,
        extra: const PasswordResetEmailSelection(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PasswordResetRequestScreen), findsOneWidget);
      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Continue password reset'), findsNothing);
      expect(
        (await container.read(passwordResetContinuationStoreProvider).read())
            ?.token,
        'saved-token',
      );
    },
  );

  testWidgets('the PIN route receives the reset email as extra', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/password-reset/verification/$verificationId',
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
    router.go(AppRoutes.forgotPasswordVerifyFor(verificationId), extra: email);
    await tester.pumpAndSettle();

    final screen = tester.widget<PasswordResetPinScreen>(
      find.byType(PasswordResetPinScreen),
    );
    expect(screen.verificationId, verificationId);
    expect(screen.email, email);
  });

  testWidgets('the finalize route does not carry the token in the location', (
    tester,
  ) async {
    final router = await pumpApp(tester);
    router.go(AppRoutes.forgotPasswordFinalize);
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetFinalizeScreen), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.forgotPasswordFinalize,
    );
  });
}
