import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_pin_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

void main() {
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
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

  Map<String, dynamic> statusEnvelope({
    bool pinIssued = true,
    int resendInSeconds = 0,
  }) => {
    'data': {
      'verification_id': verificationId,
      'status': 'pending',
      'pin_issued': pinIssued,
      'resend_in_seconds': resendInSeconds,
    },
    'message': 'verification retrieved',
  };

  Map<String, dynamic> verifyEnvelope() => {
    'data': {'password_reset_continuation_token': token},
    'message': 'password reset verified',
  };

  Map<String, dynamic> continuationEnvelope() => {
    'data': {'email': email, 'has_password_credential': true},
    'message': 'password reset continuation is valid',
  };

  void scriptStatus({
    bool pinIssued = true,
    int resendInSeconds = 0,
    int httpStatus = 200,
    Object? body,
  }) {
    adapter.onMethod(
      'GET',
      '/auth/password-reset/verification/$verificationId',
      status: httpStatus,
      body:
          body ??
          statusEnvelope(
            pinIssued: pinIssued,
            resendInSeconds: resendInSeconds,
          ),
    );
  }

  void scriptVerify({int httpStatus = 200, Object? body}) {
    adapter.onMethod(
      'POST',
      '/auth/password-reset/verification/$verificationId/verify',
      status: httpStatus,
      body: body ?? verifyEnvelope(),
    );
  }

  Future<void> pumpBare(WidgetTester tester, {String? carriedEmail}) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: PasswordResetPinScreen(
            verificationId: verificationId,
            email: carriedEmail,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpRouted(WidgetTester tester, {String? carriedEmail}) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = GoRouter(
      initialLocation: AppRoutes.forgotPasswordVerifyFor(verificationId),
      routes: [
        GoRoute(
          path: AppRoutes.forgotPasswordVerify,
          builder: (_, _) => PasswordResetPinScreen(
            verificationId: verificationId,
            email: carriedEmail,
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPasswordFinalize,
          builder: (_, _) => const Scaffold(body: Text('FINALIZE')),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _) => const Scaffold(body: Text('RESET START')),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (_, _) => const Scaffold(body: Text('SIGNIN')),
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

  Future<void> enterPinAndVerify(
    WidgetTester tester, {
    String pin = '123456',
  }) async {
    await tester.enterText(find.byType(TextField), pin);
    await tester.tap(find.widgetWithText(AppButton, 'Verify PIN'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the pending PIN state', (tester) async {
    scriptStatus();
    await pumpBare(tester, carriedEmail: email);

    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.textContaining(email), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Verify PIN'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Resend PIN'), findsOneWidget);
  });

  testWidgets('a successful verification persists the token and navigates', (
    tester,
  ) async {
    scriptStatus();
    scriptVerify();
    await pumpRouted(tester, carriedEmail: email);

    await enterPinAndVerify(tester);

    expect(find.text('FINALIZE'), findsOneWidget);
    final stored = await continuationStore.read();
    expect(stored, isNotNull);
    expect(stored!.email, email);
    expect(stored.token, token);
    final sent = adapter.lastRequestTo('/verify')!;
    expect(sent.method, 'POST');
    expect(sent.jsonField('pin'), '123456');
  });

  testWidgets('a direct entry recovers the email before persisting', (
    tester,
  ) async {
    scriptStatus();
    scriptVerify();
    adapter.onMethod(
      'GET',
      '/auth/password-reset/continuation',
      status: 200,
      body: continuationEnvelope(),
    );
    await pumpRouted(tester);

    await enterPinAndVerify(tester);

    expect(find.text('FINALIZE'), findsOneWidget);
    expect((await continuationStore.read())?.email, email);
  });

  testWidgets('a wrong PIN and exhausted attempts keep their copy', (
    tester,
  ) async {
    scriptStatus();
    adapter.onSequence(
      '/auth/password-reset/verification/$verificationId/verify',
      [
        FakeReply(409, errorBody(ApiErrorCode.invalidVerificationCode)),
        FakeReply(
          409,
          errorBody(ApiErrorCode.verificationCodeAttemptsExceeded),
        ),
      ],
    );
    await pumpBare(tester, carriedEmail: email);

    await enterPinAndVerify(tester);

    expect(find.text('That PIN is not correct. Try again.'), findsOneWidget);

    await enterPinAndVerify(tester);

    expect(
      find.text('Too many incorrect PINs. Request a new reset.'),
      findsOneWidget,
    );
    expect(await continuationStore.read(), isNull);
  });

  testWidgets('a resend cooldown disables resend', (tester) async {
    scriptStatus(resendInSeconds: 30);
    await pumpBare(tester, carriedEmail: email);

    final resend = find.widgetWithText(AppButton, 'Resend PIN in 30 s');
    expect(resend, findsOneWidget);
    expect(tester.widget<AppButton>(resend).onPressed, isNull);
  });

  testWidgets('a resend success publishes feedback and refreshes the status', (
    tester,
  ) async {
    adapter.onSequence('/auth/password-reset/verification/$verificationId', [
      FakeReply(200, statusEnvelope(resendInSeconds: 0)),
      FakeReply(200, statusEnvelope(resendInSeconds: 60)),
    ]);
    adapter.onMethod(
      'POST',
      '/auth/password-reset/verification/$verificationId/resend',
      status: 200,
      body: {
        'data': {'verification_id': verificationId},
        'message': 'verification code resent',
      },
    );
    await pumpBare(tester, carriedEmail: email);

    await tester.tap(find.widgetWithText(AppButton, 'Resend PIN'));
    await tester.pumpAndSettle();

    final feedback = container.read(feedbackProvider);
    expect(feedback, isNotNull);
    expect(feedback!.tone, FeedbackTone.success);
    expect(feedback.copy, 'A new PIN has been sent.');
    expect(
      find.widgetWithText(AppButton, 'Resend PIN in 60 s'),
      findsOneWidget,
    );
  });

  testWidgets('a terminal verification never shows a PIN field', (
    tester,
  ) async {
    scriptStatus(
      httpStatus: 409,
      body: errorBody(ApiErrorCode.verificationNotPending),
    );

    await pumpBare(tester, carriedEmail: email);

    expect(find.text('Reset already verified'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.widgetWithText(AppButton, 'Verify PIN'), findsNothing);
    expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
  });

  testWidgets('an unknown verification is neutral, not an account claim', (
    tester,
  ) async {
    scriptStatus(
      httpStatus: 404,
      body: errorBody(ApiErrorCode.resourceNotFound),
    );

    await pumpBare(tester, carriedEmail: email);

    expect(find.text('Reset not available'), findsOneWidget);
    expect(
      find.textContaining('could not find that password reset'),
      findsOneWidget,
    );
    expect(find.textContaining('account'), findsNothing);
  });

  testWidgets('a storage failure after verification does not navigate', (
    tester,
  ) async {
    scriptStatus();
    scriptVerify();
    backend.failingWrites.add(PasswordResetContinuationStore.storageKey);

    await pumpRouted(tester, carriedEmail: email);
    await enterPinAndVerify(tester);

    expect(find.text('Reset verified, but not saved'), findsOneWidget);
    expect(find.text('FINALIZE'), findsNothing);
    expect(await continuationStore.read(), isNull);
  });

  testWidgets(
    'verifying another email discloses replacement and cancel keeps the old token',
    (tester) async {
      await continuationStore.write(
        email: 'saved@example.com',
        token: 'saved-token',
      );
      scriptStatus();
      scriptVerify();

      await pumpBare(tester, carriedEmail: email);
      await enterPinAndVerify(tester);

      expect(find.text('Replace saved password reset?'), findsOneWidget);
      expect(find.textContaining('saved@example.com'), findsOneWidget);
      expect(
        find.textContaining(
          'If this PIN verifies for $email, it will replace it',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('This does not cancel it on the server.'),
        findsOneWidget,
      );
      expect(
        adapter.countFor(
          '/auth/password-reset/verification/$verificationId/verify',
        ),
        0,
        reason: 'the disclosure must precede the verify request',
      );

      await tester.tap(find.widgetWithText(AppButton, 'Keep saved reset'));
      await tester.pumpAndSettle();

      final stored = await continuationStore.read();
      expect(stored?.email, 'saved@example.com');
      expect(stored?.token, 'saved-token');
      expect(
        adapter.countFor(
          '/auth/password-reset/verification/$verificationId/verify',
        ),
        0,
      );
      expect(find.text('Enter your PIN'), findsOneWidget);
    },
  );

  testWidgets(
    'confirming replacement verifies and only then stores the new token',
    (tester) async {
      await continuationStore.write(
        email: 'saved@example.com',
        token: 'saved-token',
      );
      scriptStatus();
      scriptVerify();

      await pumpRouted(tester, carriedEmail: email);
      await enterPinAndVerify(tester);

      expect(find.text('Replace saved password reset?'), findsOneWidget);
      expect(
        adapter.countFor(
          '/auth/password-reset/verification/$verificationId/verify',
        ),
        0,
      );

      await tester.tap(find.widgetWithText(AppButton, 'Replace and verify'));
      await tester.pumpAndSettle();

      expect(find.text('FINALIZE'), findsOneWidget);
      expect(
        adapter.countFor(
          '/auth/password-reset/verification/$verificationId/verify',
        ),
        1,
      );
      final stored = await continuationStore.read();
      expect(stored?.email, email);
      expect(stored?.token, token);
    },
  );

  testWidgets('verifying the same saved email does not ask for replacement', (
    tester,
  ) async {
    await continuationStore.write(email: email, token: 'old-token');
    scriptStatus();
    scriptVerify();

    await pumpRouted(tester, carriedEmail: email);
    await enterPinAndVerify(tester);

    expect(find.text('Replace saved password reset?'), findsNothing);
    expect(find.text('FINALIZE'), findsOneWidget);
    final stored = await continuationStore.read();
    expect(stored?.email, email);
    expect(stored?.token, token);
  });

  testWidgets(
    'an unreadable saved record blocks verification without clearing it',
    (tester) async {
      await continuationStore.write(
        email: 'saved@example.com',
        token: 'saved-token',
      );
      backend.failingReads.add(PasswordResetContinuationStore.storageKey);
      scriptStatus();

      await pumpBare(tester, carriedEmail: email);
      await enterPinAndVerify(tester);

      expect(
        find.text(
          'We could not check the saved reset on this device. Try again.',
        ),
        findsOneWidget,
      );
      expect(
        adapter.countFor(
          '/auth/password-reset/verification/$verificationId/verify',
        ),
        0,
      );

      backend.failingReads.clear();
      expect((await continuationStore.read())?.token, 'saved-token');
    },
  );

  testWidgets('duplicate verifies issue one request', (tester) async {
    scriptStatus();
    adapter.onBlocking(
      '/auth/password-reset/verification/$verificationId/verify',
      FakeReply(200, verifyEnvelope()),
    );

    await pumpBare(tester, carriedEmail: email);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(AppButton, 'Verify PIN'));
    await tester.pump();

    final primary = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.primary,
    );
    expect(tester.widget<AppButton>(primary).busy, isTrue);

    await tester.tap(primary, warnIfMissed: false);
    adapter.releaseBlocked();
    await tester.pumpAndSettle();

    expect(
      adapter.countFor(
        '/auth/password-reset/verification/$verificationId/verify',
      ),
      1,
    );
  });
}
