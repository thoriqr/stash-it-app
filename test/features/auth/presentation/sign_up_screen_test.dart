import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import '../../../support/fake_http.dart';

/// The first two steps of manual registration.
///
/// Covers the sequence the contract requires — start the registration, then use
/// its id to request the PIN — and the typed outcomes that stop it. No socket is
/// opened: the transport is scripted, so the interceptor and the response mapping
/// run exactly as they do in production.
void main() {
  const email = 'reader@example.com';
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';

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
  });

  /// Pumps the screen with the app's real themes, so the styling under test is
  /// the one that ships.
  Future<void> pumpSignUp(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const SignUpScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The documented success envelope of `POST /auth/register/manual`.
  Map<String, dynamic> registrationEnvelope({String id = verificationId}) => {
    'data': {'verification_id': id},
    'message': 'registration requested',
  };

  /// The documented success envelope of the PIN request.
  Map<String, dynamic> pinEnvelope({String id = verificationId}) => {
    'data': {'verification_id': id},
    'message': 'verification code created',
  };

  void scriptRegistration({
    String id = verificationId,
    int status = 201,
    Object? body,
  }) {
    adapter.onMethod(
      'POST',
      '/auth/register/manual',
      status: status,
      body: body ?? registrationEnvelope(id: id),
    );
  }

  void scriptPinFailure(
    String code, {
    int status = 409,
    Map<String, List<String>> headers = const {},
  }) {
    adapter.onMethod(
      'POST',
      '/verification/$verificationId/pin',
      status: status,
      body: errorBody(code),
      headers: headers,
    );
  }

  /// Enters an address and taps the primary action.
  Future<void> submit(
    WidgetTester tester, {
    String value = email,
    bool settle = true,
  }) async {
    await tester.enterText(find.byType(TextFormField), value);
    await tester.tap(find.widgetWithText(AppButton, 'Send PIN'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('layout', () {
    testWidgets(
      'shows the heading, one labelled email field and a sign-in route',
      (tester) async {
        await pumpSignUp(tester);

        expect(find.text('Create your account'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);

        // The label sits above the field, per the specification.
        final labelY = tester.getTopLeft(find.text('Email')).dy;
        final fieldY = tester.getTopLeft(find.byType(TextFormField)).dy;
        expect(labelY, lessThan(fieldY));

        expect(find.widgetWithText(AppButton, 'Send PIN'), findsOneWidget);
        expect(find.widgetWithText(AppButton, 'Sign in'), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.textContaining('Google'), findsNothing);
      },
    );

    testWidgets('the email field uses the email keyboard, autofill and submit '
        'action', (tester) async {
      await pumpSignUp(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.emailAddress);
      expect(field.autofillHints, contains(AutofillHints.email));
      expect(field.textInputAction, TextInputAction.done);
    });

    testWidgets('reads the tokens of the theme in force', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpSignUp(tester);

      final context = tester.element(find.text('Create your account'));
      expect(
        AppTheme.tokensOf(context).accent,
        AppTokens.dark.accent,
        reason: 'a dark platform must not render light-token colours',
      );
    });
  });

  group('client-side validation', () {
    testWidgets('an empty form does not reach the network', (tester) async {
      await pumpSignUp(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Send PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a malformed address is caught before the network', (
      tester,
    ) async {
      await pumpSignUp(tester);

      await submit(tester, value: 'not-an-email');

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('editing clears the message without relaxing validation', (
      tester,
    ) async {
      await pumpSignUp(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Send PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your email address.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'still-not-an-email');
      await tester.pumpAndSettle();
      expect(find.text('Enter your email address.'), findsNothing);

      await tester.tap(find.widgetWithText(AppButton, 'Send PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });
  });

  group('registration sequence', () {
    testWidgets('starts the registration and then requests its PIN, in that '
        'order', (tester) async {
      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        status: 201,
        body: pinEnvelope(),
      );

      await submit(tester);

      final paths = adapter.requests.map((request) => request.path).toList();
      expect(paths, hasLength(2));
      expect(paths[0], contains('/auth/register/manual'));
      expect(paths[1], contains('/verification/$verificationId/pin'));
      expect(
        adapter.requests.every((request) => request.method == 'POST'),
        isTrue,
      );

      final registration = adapter.lastRequestTo('/auth/register/manual')!;
      expect(registration.jsonField('email'), email);
      expect(
        adapter.lastRequestTo('/pin')!.body,
        isNull,
        reason: 'the PIN request is identified by its path, not a body',
      );
    });

    testWidgets('passes the id the registration returned, not a client-made '
        'one', (tester) async {
      await pumpSignUp(tester);
      const returnedId = 'server-issued-verification-id';
      scriptRegistration(id: returnedId);
      adapter.onMethod(
        'POST',
        '/verification/$returnedId/pin',
        status: 201,
        body: pinEnvelope(id: returnedId),
      );

      await submit(tester);

      expect(
        adapter.lastRequestTo('/pin')!.path,
        contains('/verification/$returnedId/pin'),
      );
    });

    testWidgets('reports a PIN was sent without claiming the account exists', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        status: 201,
        body: pinEnvelope(),
      );

      await submit(tester);

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining(email), findsOneWidget);
      expect(
        find.text('PIN verification is not available in this version yet.'),
        findsOneWidget,
      );
      expect(find.text('Back to sign in'), findsOneWidget);

      // Both calls only start the lifecycle: no session is created and no
      // account exists until the later verification and finalization steps.
      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(backend.values, isEmpty);
      expect(find.textContaining('has been created'), findsNothing);
    });

    testWidgets('trims the entered address before sending it', (tester) async {
      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        body: pinEnvelope(),
      );

      await submit(tester, value: '  $email  ');

      expect(
        adapter.lastRequestTo('/auth/register/manual')!.jsonField('email'),
        email,
      );
    });

    testWidgets('a registration failure never requests a PIN', (tester) async {
      await pumpSignUp(tester);
      scriptRegistration(
        status: 409,
        body: errorBody(ApiErrorCode.registrationAlreadyCompleted),
      );

      await submit(tester);

      expect(
        find.text('An account already exists for this email. Sign in instead.'),
        findsOneWidget,
      );
      expect(
        adapter.requests.any((request) => request.path.contains('/pin')),
        isFalse,
        reason: 'without a verification id the second call is impossible',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        email,
        reason: 'a recoverable failure must preserve the entered address',
      );
      expect(find.widgetWithText(AppButton, 'Sign in'), findsOneWidget);
    });

    testWidgets('a second submission is refused while the first is in flight', (
      tester,
    ) async {
      await pumpSignUp(tester);

      // Held open so the duplicate tap lands while the first call is genuinely
      // in flight, rather than after it has completed.
      adapter.onBlocking(
        '/auth/register/manual',
        FakeReply(201, registrationEnvelope()),
      );
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        status: 201,
        body: pinEnvelope(),
      );

      await submit(tester, settle: false);

      // Found by type, not by label: a busy button replaces its label with a
      // spinner.
      final primary = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.variant == AppButtonVariant.primary,
      );
      expect(tester.widget<AppButton>(primary).busy, isTrue);
      expect(
        tester.widget<AppField>(find.byType(AppField)).enabled,
        isFalse,
        reason: 'the address cannot be edited mid-flight',
      );

      await tester.tap(primary, warnIfMissed: false);
      final inFlightDeadline = DateTime.now().add(const Duration(seconds: 5));
      while (adapter.countFor('/auth/register/manual') < 1) {
        if (DateTime.now().isAfter(inFlightDeadline)) break;
        await tester.pump(const Duration(milliseconds: 1));
      }

      expect(adapter.countFor('/auth/register/manual'), 1);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(adapter.countFor('/auth/register/manual'), 1);
      expect(adapter.countFor('/pin'), 1);
      expect(find.text('Check your email'), findsOneWidget);
    });
  });

  group('registration-start failures', () {
    final cases = <({String name, String code, int status, String message})>[
      (
        name: 'an already completed registration points at sign-in',
        code: ApiErrorCode.registrationAlreadyCompleted,
        status: 409,
        message: 'An account already exists for this email. Sign in instead.',
      ),
      (
        name: 'a concurrent insert is retryable',
        code: ApiErrorCode.registrationAlreadyExists,
        status: 409,
        message: 'Another sign-up attempt was already in progress. Try again.',
      ),
      (
        name: 'a competing active verification is retryable',
        code: ApiErrorCode.activeVerificationCodeExists,
        status: 409,
        message: 'Another sign-up attempt was already in progress. Try again.',
      ),
      (
        name: 'an ended lifecycle asks for a new registration',
        code: ApiErrorCode.registrationExpired,
        status: 409,
        message: 'That registration can no longer continue. Start a new one.',
      ),
      (
        name: 'a rejected address asks for a correction',
        code: ApiErrorCode.validationError,
        status: 400,
        message: 'Check your email address, then try again.',
      ),
      (
        name: 'an unavailable limiter is not a spent budget',
        code: ApiErrorCode.pinRateLimitUnavailable,
        status: 503,
        message: 'Sign-up is temporarily unavailable. Try again shortly.',
      ),
      (
        name: 'a server fault is its own outcome',
        code: ApiErrorCode.internalServerError,
        status: 500,
        message:
            'The server could not start your registration. Try again '
            'shortly.',
      ),
    ];

    for (final testCase in cases) {
      testWidgets('${testCase.name}, and keeps the address', (tester) async {
        await pumpSignUp(tester);
        scriptRegistration(
          status: testCase.status,
          body: errorBody(testCase.code),
        );

        await submit(tester);

        expect(find.text(testCase.message), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          email,
        );
        expect(adapter.countFor('/pin'), 0);
      });
    }

    testWidgets('a spent budget reports only the server stated wait', (
      tester,
    ) async {
      await pumpSignUp(tester);
      adapter.onMethod(
        'POST',
        '/auth/register/manual',
        status: 429,
        body: errorBody(ApiErrorCode.pinRateLimitExceeded),
        headers: {
          'retry-after': ['42'],
        },
      );

      await submit(tester);

      expect(
        find.text('Too many attempts. Try again in 42 seconds.'),
        findsOneWidget,
      );
    });

    testWidgets('a spent budget without a server wait invents none', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration(
        status: 429,
        body: errorBody(ApiErrorCode.pinRateLimitExceeded),
      );

      await submit(tester);

      expect(
        find.text('Too many attempts. Try again shortly.'),
        findsOneWidget,
      );
      expect(find.textContaining('seconds'), findsNothing);
    });

    testWidgets('a lost registration is reported as unconfirmed', (
      tester,
    ) async {
      await pumpSignUp(tester);
      adapter.onOffline('/auth/register/manual');

      await submit(tester);

      expect(
        find.text(
          'No connection to the server. We could not confirm whether your '
          'registration started.',
        ),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('an unreadable registration reply is uncertain, not a refusal', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration(status: 201, body: 'not JSON');

      await submit(tester);

      expect(
        find.text(
          'We could not read the server\'s reply, so we cannot confirm whether '
          'your registration started or a PIN was sent. Check your inbox before '
          'trying again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('dismissing a failure does not resubmit it', (tester) async {
      await pumpSignUp(tester);
      scriptRegistration(
        status: 409,
        body: errorBody(ApiErrorCode.registrationAlreadyCompleted),
      );

      await submit(tester);
      final attemptsAfterFirst = adapter.countFor('/auth/register/manual');

      await tester.tap(find.widgetWithText(TextButton, 'Dismiss'));
      await tester.pumpAndSettle();

      expect(
        find.text('An account already exists for this email. Sign in instead.'),
        findsNothing,
      );
      expect(
        adapter.countFor('/auth/register/manual'),
        attemptsAfterFirst,
        reason: 'a dismissal is not a retry',
      );
    });
  });

  group('PIN-request failures', () {
    testWidgets(
      'a resend cooldown states no duration the server did not send',
      (tester) async {
        await pumpSignUp(tester);
        scriptRegistration();
        scriptPinFailure(ApiErrorCode.verificationResendCooldown);

        await submit(tester);

        expect(
          find.text(
            'A PIN was sent to this email recently. Try again shortly.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('seconds'), findsNothing);
        expect(find.text('Check your email'), findsNothing);
      },
    );

    testWidgets('an ended lifecycle is explained without claiming completion', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration();
      scriptPinFailure(ApiErrorCode.verificationNotPending);

      await submit(tester);

      expect(
        find.text('That registration can no longer continue. Start a new one.'),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('an unconfirmed delivery does not claim the PIN is missing', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration();
      scriptPinFailure(
        ApiErrorCode.pinEmailDeliveryFailed,
        status: 503,
        headers: {
          'retry-after': ['30'],
        },
      );

      await submit(tester);

      expect(
        find.text(
          'We could not confirm the PIN email was sent. Check your inbox before '
          'trying again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
      expect(find.textContaining('was not sent'), findsNothing);
      expect(find.textContaining('no PIN'), findsNothing);
    });

    testWidgets('an unreadable PIN reply is never described as definitely '
        'unsent', (tester) async {
      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        status: 201,
        body: 'not JSON',
      );

      await submit(tester);

      expect(
        find.text(
          'We could not read the server\'s reply, so we cannot confirm whether '
          'your registration started or a PIN was sent. Check your inbox before '
          'trying again.',
        ),
        findsOneWidget,
      );

      // The server persisted the code before answering, so the client cannot say
      // it does not exist. The success state is not claimed either.
      expect(find.text('Check your email'), findsNothing);
      expect(find.textContaining('was not sent'), findsNothing);
      expect(find.textContaining('no PIN'), findsNothing);
    });

    testWidgets('a lost PIN request is reported as unconfirmed', (
      tester,
    ) async {
      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onOffline('/verification/$verificationId/pin');

      await submit(tester);

      expect(
        find.text(
          'No connection to the server. We could not confirm whether your '
          'registration started.',
        ),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
    });
  });

  group('small screens', () {
    testWidgets('the longest failure wraps without overflowing at 320x640', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpSignUp(tester);
      scriptRegistration();
      adapter.onMethod(
        'POST',
        '/verification/$verificationId/pin',
        status: 201,
        body: 'not JSON',
      );

      await submit(tester);

      expect(find.widgetWithText(TextButton, 'Dismiss'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Dismiss'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
