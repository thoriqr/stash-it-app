import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/pin_entry_screen.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

void main() {
  const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;
  late RegistrationContinuationStore continuationStore;

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
    continuationStore = RegistrationContinuationStore(backend);
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        registrationContinuationStoreProvider.overrideWithValue(
          continuationStore,
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpScreen(WidgetTester tester, {String? email}) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: PinEntryScreen(verificationId: verificationId, email: email),
        ),
      ),
    );
  }

  testWidgets('shows loading then pending state', (tester) async {
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

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Resend PIN'), findsOneWidget);
  });

  testWidgets('disables resend during cooldown', (tester) async {
    adapter.onMethod(
      'GET',
      '/auth/register/verification/$verificationId',
      status: 200,
      body: {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 30,
        },
        'message': 'verification retrieved',
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final resend = find.widgetWithText(AppButton, 'Resend PIN in 30 s');
    expect(resend, findsOneWidget);
    expect(tester.widget<AppButton>(resend).onPressed, isNull);
  });

  testWidgets('a non-pending status is terminal, never a success claim', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/register/verification/$verificationId',
      status: 200,
      body: {
        'data': {
          'verification_id': verificationId,
          'status': 'verified',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Registration unavailable'), findsOneWidget);
    expect(find.textContaining('no longer open'), findsOneWidget);
    expect(find.text('PIN verified'), findsNothing);
    expect(find.textContaining('sign in to your account'), findsNothing);
  });

  testWidgets('successful resend refreshes status', (tester) async {
    adapter.onSequence('/auth/register/verification/$verificationId', [
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      }),
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 60,
        },
        'message': 'verification retrieved',
      }),
    ]);
    adapter.onMethod(
      'POST',
      '/auth/register/verification/$verificationId/resend',
      status: 200,
      body: {
        'data': {'verification_id': verificationId},
        'message': 'verification code resent',
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    int getCount(String method, String fragment) => adapter.requests
        .where(
          (request) =>
              request.method == method && request.path.contains(fragment),
        )
        .length;

    await tester.tap(find.widgetWithText(AppButton, 'Resend PIN'));
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (getCount('POST', '/resend') < 1 ||
        getCount('GET', '/auth/register/verification/$verificationId') < 2) {
      if (DateTime.now().isAfter(deadline)) break;
      await tester.pump(const Duration(milliseconds: 1));
    }
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppButton, 'Resend PIN in 60 s'),
      findsOneWidget,
    );
  });

  testWidgets('duplicate resend taps issue one request', (tester) async {
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
    adapter.onBlocking(
      '/auth/register/verification/$verificationId/resend',
      FakeReply(200, {
        'data': {'verification_id': verificationId},
        'message': 'verification code resent',
      }),
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    int resendCount() => adapter.requests
        .where(
          (request) =>
              request.method == 'POST' && request.path.contains('/resend'),
        )
        .length;

    final resendFinder = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.secondary,
    );

    await tester.tap(resendFinder);
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (resendCount() < 1) {
      if (DateTime.now().isAfter(deadline)) break;
      await tester.pump(const Duration(milliseconds: 1));
    }

    await tester.tap(resendFinder, warnIfMissed: false);
    await tester.tap(resendFinder, warnIfMissed: false);
    await tester.pump();

    expect(resendCount(), 1);

    adapter.releaseBlocked();
    await tester.pumpAndSettle();
  });

  testWidgets('delivery failure communicates uncertainty', (tester) async {
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
    adapter.onMethod(
      'POST',
      '/auth/register/verification/$verificationId/resend',
      status: 503,
      body: errorBody(ApiErrorCode.pinEmailDeliveryFailed),
      headers: {
        'retry-after': ['60'],
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Resend PIN'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'We could not confirm the PIN email was sent. Check your inbox before '
        'trying again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('was not sent'), findsNothing);
    expect(find.textContaining('no PIN'), findsNothing);
    expect(
      find.widgetWithText(AppButton, 'Resend PIN in 60 s'),
      findsOneWidget,
    );
    final resend = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.secondary,
    );
    expect(tester.widget<AppButton>(resend).onPressed, isNull);
  });

  testWidgets('a stale refresh cannot clear an active delivery cooldown', (
    tester,
  ) async {
    adapter.onSequence('/auth/register/verification/$verificationId', [
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      }),
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      }),
    ]);
    adapter.onMethod(
      'POST',
      '/auth/register/verification/$verificationId/resend',
      status: 503,
      body: errorBody(ApiErrorCode.pinEmailDeliveryFailed),
      headers: {
        'retry-after': ['60'],
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Resend PIN'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppButton, 'Resend PIN in 60 s'),
      findsOneWidget,
    );
  });

  testWidgets('expired verification offers recovery instead of resend', (
    tester,
  ) async {
    adapter.onMethod(
      'GET',
      '/auth/register/verification/$verificationId',
      status: 409,
      body: errorBody(ApiErrorCode.registrationExpired),
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Start over'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Resend PIN'), findsNothing);
  });

  testWidgets('verification locks all controls', (tester) async {
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
    adapter.onBlocking(
      '/auth/register/verification/$verificationId/verify',
      FakeReply(200, {
        'data': {'registration_continuation_token': 'token'},
        'message': 'registration verified',
      }),
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '123456');
    final verifyFinder = find.widgetWithText(AppButton, 'Verify PIN');
    await tester.tap(verifyFinder);
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (adapter.countFor('/verify') < 1) {
      if (DateTime.now().isAfter(deadline)) break;
      await tester.pump(const Duration(milliseconds: 1));
    }

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    final resendFinder = find.byWidgetPredicate(
      (widget) =>
          widget is AppButton && widget.variant == AppButtonVariant.secondary,
    );
    expect(tester.widget<AppButton>(resendFinder).onPressed, isNull);
    final backFinder = find.widgetWithText(AppButton, 'Back to sign in');
    expect(tester.widget<AppButton>(backFinder).onPressed, isNull);

    adapter.releaseBlocked();
    await tester.pumpAndSettle();
  });

  testWidgets('resend success publishes global feedback', (tester) async {
    adapter.onSequence('/auth/register/verification/$verificationId', [
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      }),
      FakeReply(200, {
        'data': {
          'verification_id': verificationId,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 60,
        },
        'message': 'verification retrieved',
      }),
    ]);
    adapter.onMethod(
      'POST',
      '/auth/register/verification/$verificationId/resend',
      status: 200,
      body: {
        'data': {'verification_id': verificationId},
        'message': 'verification code resent',
      },
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Resend PIN'));
    await tester.pumpAndSettle();

    final feedback = container.read(feedbackProvider);
    expect(feedback, isNotNull);
    expect(feedback!.tone, FeedbackTone.success);
    expect(feedback.copy, 'A new PIN has been sent.');
  });

  group('continuation persistence', () {
    Map<String, dynamic> pendingEnvelope() => {
      'data': {
        'verification_id': verificationId,
        'status': 'pending',
        'pin_issued': true,
        'resend_in_seconds': 0,
      },
      'message': 'verification retrieved',
    };

    Map<String, dynamic> verifyEnvelope() => {
      'data': {'registration_continuation_token': 'raw-token'},
      'message': 'registration verified',
    };

    void scriptPendingAndVerify() {
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        status: 200,
        body: pendingEnvelope(),
      );
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 200,
        body: verifyEnvelope(),
      );
    }

    Future<void> verify(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.widgetWithText(AppButton, 'Verify PIN'));
      await tester.pumpAndSettle();
    }

    testWidgets('a successful verification writes the token for the email', (
      tester,
    ) async {
      scriptPendingAndVerify();

      await pumpScreen(tester, email: '  Reader@Example.com  ');
      await verify(tester);

      final stored = await continuationStore.read();
      expect(stored, isNotNull);
      expect(stored!.email, 'reader@example.com');
      expect(stored.token, 'raw-token');
    });

    testWidgets('a direct entry with no email cannot scope a token', (
      tester,
    ) async {
      scriptPendingAndVerify();

      await pumpScreen(tester);
      await verify(tester);

      expect(await continuationStore.read(), isNull);
    });

    testWidgets('a storage failure still lets verification continue, with a '
        'warning', (tester) async {
      scriptPendingAndVerify();
      backend.failingWrites.add(RegistrationContinuationStore.storageKey);

      await pumpScreen(tester, email: 'reader@example.com');
      await verify(tester);

      expect(tester.takeException(), isNull);
      final feedback = container.read(feedbackProvider);
      expect(feedback, isNotNull);
      expect(feedback!.tone, FeedbackTone.warning);
      expect(feedback.copy, contains('could not save'));
      expect(feedback.copy, contains('PIN verified'));
    });
  });
}
