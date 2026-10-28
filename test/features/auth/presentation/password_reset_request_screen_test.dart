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
import 'package:stash_it_app/features/auth/presentation/password_reset_request_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

void main() {
  const email = 'reader@example.com';
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
  const continuationToken = 'raw-password-reset-token';

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

  /// Counts only requests whose path is exactly [path].
  ///
  /// `/auth/password-reset` is a prefix of every other route in this flow, so the
  /// fragment-based helper would count children as well.
  int exactCount(String method, String path) {
    return adapter.requests.where((request) {
      return request.method == method && Uri.parse(request.path).path == path;
    }).length;
  }

  Map<String, dynamic> resetEnvelope({String id = verificationId}) => {
    'data': {'verification_id': id},
    'message': 'password reset requested',
  };

  Map<String, dynamic> statusEnvelope({
    String id = verificationId,
    bool pinIssued = false,
    int resendInSeconds = 0,
  }) => {
    'data': {
      'verification_id': id,
      'status': 'pending',
      'pin_issued': pinIssued,
      'resend_in_seconds': resendInSeconds,
    },
    'message': 'verification retrieved',
  };

  Map<String, dynamic> continuationEnvelope() => {
    'data': {'email': email, 'has_password_credential': true},
    'message': 'password reset continuation is valid',
  };

  void scriptReset({
    String id = verificationId,
    int httpStatus = 201,
    Object? body,
  }) {
    // Registered after any POST child route: the fake matches fragments in
    // insertion order and this path is a prefix of the children.
    adapter.onMethod(
      'POST',
      '/auth/password-reset',
      status: httpStatus,
      body: body ?? resetEnvelope(id: id),
    );
  }

  void scriptStatus({
    String id = verificationId,
    bool pinIssued = false,
    int resendInSeconds = 0,
    int httpStatus = 200,
    Object? body,
  }) {
    adapter.onMethod(
      'GET',
      '/auth/password-reset/verification/$id',
      status: httpStatus,
      body:
          body ??
          statusEnvelope(
            id: id,
            pinIssued: pinIssued,
            resendInSeconds: resendInSeconds,
          ),
    );
  }

  void scriptPin({String id = verificationId}) {
    adapter.onMethod(
      'POST',
      '/auth/password-reset/verification/$id/pin',
      status: 201,
      body: {
        'data': {'verification_id': id},
        'message': 'verification code created',
      },
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
          home: const PasswordResetRequestScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpRouted(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = GoRouter(
      initialLocation: AppRoutes.forgotPassword,
      routes: [
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _) => const PasswordResetRequestScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPasswordVerify,
          builder: (_, state) => Scaffold(
            body: Text(
              'PIN ${state.pathParameters['verificationId']} '
              'email=${state.extra ?? ''}',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPasswordFinalize,
          builder: (_, _) => const Scaffold(body: Text('FINALIZE')),
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

  Future<void> submit(WidgetTester tester, {String value = email}) async {
    await tester.enterText(find.byType(TextFormField), value);
    final button = find.widgetWithText(AppButton, 'Send reset PIN');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'with nothing stored it shows the email form and sends no request',
    (tester) async {
      await pumpBare(tester);

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Send reset PIN'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    },
  );

  testWidgets(
    'submits, reads the status, requests the first PIN and navigates',
    (tester) async {
      await pumpRouted(tester);
      scriptPin();
      scriptStatus();
      scriptReset();

      await submit(tester);

      expect(exactCount('POST', '/auth/password-reset'), 1);
      expect(
        exactCount('GET', '/auth/password-reset/verification/$verificationId'),
        1,
      );
      expect(
        exactCount(
          'POST',
          '/auth/password-reset/verification/$verificationId/pin',
        ),
        1,
      );
      expect(find.text('PIN $verificationId email=$email'), findsOneWidget);
    },
  );

  testWidgets('an already-issued PIN is not requested again', (tester) async {
    await pumpRouted(tester);
    scriptStatus(pinIssued: true, resendInSeconds: 30);
    scriptReset();

    await submit(tester);

    expect(
      exactCount(
        'POST',
        '/auth/password-reset/verification/$verificationId/pin',
      ),
      0,
    );
    expect(find.text('PIN $verificationId email=$email'), findsOneWidget);
  });

  testWidgets('an already-verified reset shows a bounded wait state', (
    tester,
  ) async {
    await pumpBare(tester);
    scriptStatus(
      httpStatus: 409,
      body: errorBody(ApiErrorCode.verificationNotPending),
    );
    scriptReset();

    await submit(tester);

    expect(find.text('Reset already verified'), findsOneWidget);
    expect(find.textContaining('15 minutes'), findsOneWidget);
    expect(
      find.textContaining('does not have a usable saved reset for this email'),
      findsOneWidget,
    );
    expect(
      exactCount(
        'POST',
        '/auth/password-reset/verification/$verificationId/pin',
      ),
      0,
    );
    expect(exactCount('POST', '/auth/password-reset'), 1);

    // A rebuild must not retry the request.
    await tester.pump();
    expect(exactCount('POST', '/auth/password-reset'), 1);
    expect(
      find.widgetWithText(AppButton, 'Try again'),
      findsOneWidget,
      reason: 'a retry is available only as a new user action',
    );
  });

  testWidgets('a placeholder id gets the neutral non-enumerating answer', (
    tester,
  ) async {
    await pumpRouted(tester);
    scriptStatus(
      httpStatus: 404,
      body: errorBody(ApiErrorCode.resourceNotFound),
    );
    scriptReset();

    await submit(tester);

    expect(find.text('Check your email'), findsOneWidget);
    expect(
      find.textContaining('If an account exists for that address'),
      findsOneWidget,
    );
    expect(find.textContaining('no account'), findsNothing);
    expect(
      exactCount(
        'POST',
        '/auth/password-reset/verification/$verificationId/pin',
      ),
      0,
    );
    expect(find.text('SIGNIN'), findsNothing);
  });

  testWidgets('an ended reset returns to the form with start-over copy', (
    tester,
  ) async {
    await pumpBare(tester);
    scriptStatus(
      httpStatus: 409,
      body: errorBody(ApiErrorCode.passwordResetExpired),
    );
    scriptReset();

    await submit(tester);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(
      find.text('This password reset is no longer active. Request a new one.'),
      findsOneWidget,
    );
    expect(
      exactCount(
        'POST',
        '/auth/password-reset/verification/$verificationId/pin',
      ),
      0,
    );
  });

  testWidgets(
    'a PIN delivery failure keeps the form and a later submit resumes',
    (tester) async {
      await pumpRouted(tester);
      adapter.onMethod(
        'POST',
        '/auth/password-reset/verification/$verificationId/pin',
        status: 503,
        body: errorBody(ApiErrorCode.pinEmailDeliveryFailed),
        headers: {
          'retry-after': ['30'],
        },
      );
      adapter.onSequence('/auth/password-reset/verification/$verificationId', [
        FakeReply(200, statusEnvelope(pinIssued: false)),
        FakeReply(200, statusEnvelope(pinIssued: true, resendInSeconds: 30)),
      ]);
      scriptReset();

      await submit(tester);

      expect(
        find.text(
          'We could not confirm the PIN email was sent. Check your inbox before '
          'trying again.',
        ),
        findsOneWidget,
      );
      expect(find.text('PIN $verificationId email=$email'), findsNothing);

      await submit(tester);

      expect(
        find.text('PIN $verificationId email=$email'),
        findsOneWidget,
        reason: 'the status now says a PIN was already issued',
      );
      expect(
        exactCount(
          'POST',
          '/auth/password-reset/verification/$verificationId/pin',
        ),
        1,
      );
    },
  );

  testWidgets(
    'a stored continuation offers Continue and resumes without a reset',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 200,
        body: continuationEnvelope(),
      );

      await pumpRouted(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(find.textContaining(email), findsOneWidget);
      expect(adapter.requests, isEmpty);

      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('FINALIZE'), findsOneWidget);
      expect(exactCount('GET', '/auth/password-reset/continuation'), 1);
      expect(exactCount('POST', '/auth/password-reset'), 0);
      expect((await continuationStore.read())?.token, continuationToken);
    },
  );

  testWidgets(
    'a valid stored continuation can switch to email entry without clearing it',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      await pumpRouted(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Use a different email'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect((await continuationStore.read())?.token, continuationToken);
      expect(adapter.requests, isEmpty);
    },
  );

  testWidgets(
    'starting another reset from the switch leaves the saved token in place',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      await pumpRouted(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();

      scriptPin();
      scriptStatus();
      scriptReset();

      await submit(tester, value: 'other@example.com');

      expect(
        find.text('PIN $verificationId email=other@example.com'),
        findsOneWidget,
      );
      final stored = await continuationStore.read();
      expect(stored?.email, email);
      expect(stored?.token, continuationToken);
    },
  );

  testWidgets(
    'submitting the saved email offers Continue without a reset request',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 200,
        body: continuationEnvelope(),
      );
      await pumpRouted(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();

      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(
        find.textContaining(
          'A saved password reset for $email is available on this device.',
        ),
        findsOneWidget,
      );
      expect(exactCount('POST', '/auth/password-reset'), 0);
      expect(
        exactCount('GET', '/auth/password-reset/verification/$verificationId'),
        0,
      );
      expect(find.text('Reset already verified'), findsNothing);
      expect((await continuationStore.read())?.token, continuationToken);

      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('FINALIZE'), findsOneWidget);
      expect(exactCount('GET', '/auth/password-reset/continuation'), 1);
      expect(exactCount('POST', '/auth/password-reset'), 0);
    },
  );

  testWidgets('the saved email match is case-insensitive and normalized', (
    tester,
  ) async {
    await continuationStore.write(
      email: 'reader@example.com',
      token: continuationToken,
    );
    await pumpRouted(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
    await tester.pumpAndSettle();

    await submit(tester, value: ' Reader@Example.COM ');

    expect(find.text('Continue password reset'), findsOneWidget);
    expect(
      find.textContaining(
        'A saved password reset for reader@example.com is available',
      ),
      findsOneWidget,
    );
    expect(exactCount('POST', '/auth/password-reset'), 0);
    expect(adapter.requests, isEmpty);
    expect((await continuationStore.read())?.token, continuationToken);
  });

  testWidgets(
    'an unconfirmed match check returns to the same offer without a reset request',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onOffline('/auth/password-reset/continuation');
      await pumpRouted(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();
      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('We could not check your saved password reset'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(AppButton, 'Continue'),
        findsOneWidget,
        reason: 'Continue remains the retry action',
      );
      expect(
        find.widgetWithText(AppButton, 'Use a different email'),
        findsOneWidget,
      );
      expect((await continuationStore.read())?.token, continuationToken);
      expect(exactCount('POST', '/auth/password-reset'), 0);

      final switchButton = find.widgetWithText(
        AppButton,
        'Use a different email',
      );
      await tester.ensureVisible(switchButton);
      await tester.tap(switchButton);
      await tester.pumpAndSettle();

      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(
        find.textContaining(
          'A saved password reset for $email is available on this device.',
        ),
        findsOneWidget,
      );
      expect(exactCount('POST', '/auth/password-reset'), 0);
      expect((await continuationStore.read())?.token, continuationToken);
    },
  );

  testWidgets(
    'an expired saved continuation from the match clears and permits a new request',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.passwordResetContinuationExpired),
      );
      await pumpRouted(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();
      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(
        find.text(
          'Your previous password reset is no longer active. Request a new one.',
        ),
        findsOneWidget,
      );
      expect(await continuationStore.read(), isNull);
      expect(exactCount('POST', '/auth/password-reset'), 0);

      scriptPin();
      scriptStatus();
      scriptReset();
      await submit(tester);

      expect(find.text('PIN $verificationId email=$email'), findsOneWidget);
      expect(exactCount('POST', '/auth/password-reset'), 1);
    },
  );

  testWidgets(
    'a consumed saved continuation from the match preserves completed messaging',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.passwordResetContinuationConsumed),
      );
      await pumpRouted(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();
      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This password reset was already completed.'),
        findsOneWidget,
      );
      expect(await continuationStore.read(), isNull);
      expect(exactCount('POST', '/auth/password-reset'), 0);
    },
  );

  testWidgets(
    'a saved token written after load is offered on a verified response',
    (tester) async {
      await pumpRouted(tester);
      await continuationStore.write(email: email, token: continuationToken);

      scriptStatus(
        httpStatus: 409,
        body: errorBody(ApiErrorCode.verificationNotPending),
      );
      scriptReset();

      await submit(tester);

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(
        find.textContaining(
          'A saved password reset for $email is available on this device.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reset already verified'), findsNothing);
      expect(exactCount('POST', '/auth/password-reset'), 1);
      expect((await continuationStore.read())?.token, continuationToken);
    },
  );

  testWidgets(
    'an expired stored continuation is cleared and returns to the form',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.passwordResetContinuationExpired),
      );

      await pumpBare(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(
        find.text(
          'Your previous password reset is no longer active. Request a new one.',
        ),
        findsOneWidget,
      );
      expect(await continuationStore.read(), isNull);
    },
  );

  testWidgets(
    'a consumed stored continuation is cleared and explains completion',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onMethod(
        'GET',
        '/auth/password-reset/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.passwordResetContinuationConsumed),
      );

      await pumpBare(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This password reset was already completed.'),
        findsOneWidget,
      );
      expect(await continuationStore.read(), isNull);
    },
  );

  testWidgets(
    'an unconfirmed continuation check keeps the token and offers retry',
    (tester) async {
      await continuationStore.write(email: email, token: continuationToken);
      adapter.onOffline('/auth/password-reset/continuation');

      await pumpBare(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Continue password reset'), findsOneWidget);
      expect(
        find.textContaining('We could not check your saved password reset'),
        findsOneWidget,
      );
      expect((await continuationStore.read())?.token, continuationToken);
      expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Use a different email'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(AppButton, 'Use a different email'));
      await tester.pumpAndSettle();

      expect(find.text('Continue password reset'), findsNothing);
      expect(find.byType(TextFormField), findsOneWidget);
      expect((await continuationStore.read())?.token, continuationToken);
    },
  );

  testWidgets('duplicate submits send one reset request', (tester) async {
    await pumpBare(tester);
    scriptPin();
    scriptStatus();
    adapter.onBlocking('/auth/password-reset', FakeReply(201, resetEnvelope()));

    await tester.enterText(find.byType(TextFormField), email);
    await tester.tap(find.widgetWithText(AppButton, 'Send reset PIN'));
    await tester.pump();

    final primary = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.primary,
    );
    expect(tester.widget<AppButton>(primary).busy, isTrue);

    await tester.tap(primary, warnIfMissed: false);
    adapter.releaseBlocked();
    await tester.pumpAndSettle();

    expect(exactCount('POST', '/auth/password-reset'), 1);
  });
}
