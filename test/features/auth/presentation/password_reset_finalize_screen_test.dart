import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_finalize_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_request_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

void main() {
  const email = 'reader@example.com';
  const token = 'raw-password-reset-token';

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;
  late PasswordResetContinuationStore continuationStore;

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
    continuationStore = PasswordResetContinuationStore(backend);
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        passwordResetContinuationStoreProvider.overrideWithValue(
          continuationStore,
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  Map<String, dynamic> continuationEnvelope() => {
    'data': {'email': email, 'has_password_credential': true},
    'message': 'password reset continuation is valid',
  };

  void scriptContinuation({int httpStatus = 200, Object? body}) {
    adapter.onMethod(
      'GET',
      '/auth/password-reset/continuation',
      status: httpStatus,
      body: body ?? continuationEnvelope(),
    );
  }

  void scriptFinalize({
    int httpStatus = 200,
    Object? body,
    Map<String, List<String>> headers = const {},
  }) {
    adapter.onMethod(
      'POST',
      '/auth/password-reset/finalize',
      status: httpStatus,
      body:
          body ??
          {'data': null, 'message': 'password reset completed successfully'},
      headers: headers,
    );
  }

  Future<void> pumpBare(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const PasswordResetFinalizeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpRouted(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = GoRouter(
      initialLocation: AppRoutes.forgotPasswordFinalize,
      routes: [
        GoRoute(
          path: AppRoutes.forgotPasswordFinalize,
          builder: (_, _) => const PasswordResetFinalizeScreen(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (_, state) =>
              Scaffold(body: Text('SIGNIN ${state.extra ?? 'none'}')),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, state) => PasswordResetRequestScreen(
            startWithEmailForm: state.extra is PasswordResetEmailSelection,
          ),
        ),
      ],
    );
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
  }

  Future<void> fillAndSubmit(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'password123');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.widgetWithText(AppButton, 'Reset password'));
    await tester.pumpAndSettle();
  }

  testWidgets('no stored token shows the no-reset state and sends nothing', (
    tester,
  ) async {
    await pumpBare(tester);

    expect(find.text('No reset in progress'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Start a new reset'), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });

  testWidgets('a valid token loads the form with the account address', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();

    await pumpBare(tester);

    expect(find.text('Choose a new password'), findsOneWidget);
    expect(find.textContaining(email), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Reset password'), findsOneWidget);
    expect((await continuationStore.read())?.token, token);
  });

  testWidgets(
    'the form returns to email entry without clearing the saved token',
    (tester) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();

      await pumpRouted(tester);

      final action = find.widgetWithText(AppButton, 'Use a different email');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byType(PasswordResetRequestScreen), findsOneWidget);
      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Continue password reset'), findsNothing);
      expect((await continuationStore.read())?.token, token);
    },
  );

  testWidgets(
    'a successful finalization clears the token and carries success',
    (tester) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      scriptFinalize();

      await pumpRouted(tester);
      await fillAndSubmit(tester);

      expect(find.text('SIGNIN password-reset-success'), findsOneWidget);
      expect(await continuationStore.read(), isNull);
      final sent = adapter.lastRequestTo('/auth/password-reset/finalize')!;
      expect(sent.method, 'POST');
      expect(sent.headers['X-Password-Reset-Continuation'], token);
      expect(sent.jsonField('password'), 'password123');
    },
  );

  testWidgets('a consumed continuation on load is completed, not a retry', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation(
      httpStatus: 409,
      body: errorBody(ApiErrorCode.passwordResetContinuationConsumed),
    );

    await pumpBare(tester);

    expect(find.text('Password reset completed'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
    expect(await continuationStore.read(), isNull);
  });

  testWidgets(
    'an expired continuation on load clears and asks for a new reset',
    (tester) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation(
        httpStatus: 409,
        body: errorBody(ApiErrorCode.passwordResetContinuationExpired),
      );

      await pumpBare(tester);

      expect(find.text('Reset unavailable'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Start a new reset'),
        findsOneWidget,
      );
      expect(await continuationStore.read(), isNull);
    },
  );

  testWidgets('an unconfirmed load keeps the token and retries on demand', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    adapter.onOffline('/auth/password-reset/continuation');

    await pumpBare(tester);

    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
    expect((await continuationStore.read())?.token, token);
    expect(adapter.countFor('/auth/password-reset/continuation'), 1);
    expect(find.textContaining('could not check this reset'), findsOneWidget);
  });

  testWidgets('a secure-storage read failure is named and retryable', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    backend.failingReads.add(PasswordResetContinuationStore.storageKey);

    await pumpBare(tester);

    expect(
      find.textContaining('could not read the saved password reset'),
      findsOneWidget,
    );
    expect(adapter.requests, isEmpty);

    backend.failingReads.clear();
    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a new password'), findsOneWidget);
    expect(adapter.countFor('/auth/password-reset/continuation'), 1);
  });

  testWidgets('a finalize consumed outcome is already completed', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    scriptFinalize(
      httpStatus: 409,
      body: errorBody(ApiErrorCode.passwordResetContinuationConsumed),
    );

    await pumpBare(tester);
    await fillAndSubmit(tester);

    expect(find.text('Password reset completed'), findsOneWidget);
    expect(await continuationStore.read(), isNull);
  });

  testWidgets('an ambiguous finalize keeps the token and claims nothing', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    adapter.onOffline('/auth/password-reset/finalize');

    await pumpBare(tester);
    await fillAndSubmit(tester);

    expect(
      find.textContaining('could not confirm whether the password reset'),
      findsOneWidget,
    );
    expect((await continuationStore.read())?.token, token);
    expect(
      adapter.countFor('/auth/password-reset/finalize'),
      1,
      reason: 'no automatic retry',
    );
  });

  testWidgets('password-work capacity keeps the form and the server wait', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    scriptFinalize(
      httpStatus: 503,
      body: errorBody(ApiErrorCode.passwordWorkUnavailable),
      headers: {
        'retry-after': ['5'],
      },
    );

    await pumpBare(tester);
    await fillAndSubmit(tester);

    expect(
      find.text(
        "We can't reset your password right now. Try again in 5 seconds.",
      ),
      findsOneWidget,
    );
    expect(find.text('Choose a new password'), findsOneWidget);
    expect((await continuationStore.read())?.token, token);
  });

  testWidgets('a validation refusal keeps the form and the token', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    scriptFinalize(
      httpStatus: 400,
      body: errorBody(ApiErrorCode.validationError),
    );

    await pumpBare(tester);
    await fillAndSubmit(tester);

    expect(find.text('Use between 8 and 128 characters.'), findsOneWidget);
    expect(find.text('Choose a new password'), findsOneWidget);
    expect((await continuationStore.read())?.token, token);
  });

  testWidgets('duplicate submits issue one finalize request', (tester) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    adapter.onBlocking(
      '/auth/password-reset/finalize',
      FakeReply(200, {
        'data': null,
        'message': 'password reset completed successfully',
      }),
    );

    await pumpBare(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'password123');
    await tester.enterText(fields.at(1), 'password123');

    final reset = find.widgetWithText(AppButton, 'Reset password');
    await tester.tap(reset);
    await tester.pump();

    final primary = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.primary,
    );
    expect(tester.widget<AppButton>(primary).busy, isTrue);

    await tester.tap(primary, warnIfMissed: false);
    adapter.releaseBlocked();
    await tester.pumpAndSettle();

    expect(adapter.countFor('/auth/password-reset/finalize'), 1);
  });

  testWidgets('leaving before submitting claims no uncertainty', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();

    await pumpRouted(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Back to sign in'));
    await tester.pumpAndSettle();

    expect(find.text('SIGNIN none'), findsOneWidget);
    expect(find.textContaining('password-reset-uncertain'), findsNothing);
  });

  testWidgets('leaving after an ambiguous submit carries uncertainty', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: token);
    scriptContinuation();
    adapter.onOffline('/auth/password-reset/finalize');

    await pumpRouted(tester);
    await fillAndSubmit(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Back to sign in'));
    await tester.pumpAndSettle();

    expect(find.text('SIGNIN password-reset-uncertain'), findsOneWidget);
  });
}
