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
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/finalize_registration_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

void main() {
  const token = 'raw-continuation-token';
  const email = 'reader@example.com';

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

  Map<String, dynamic> continuationEnvelope({String address = email}) => {
    'data': {
      'email': address,
      'registration_type': 'manual',
      'requires_password': true,
    },
    'message': 'registration continuation is valid',
  };

  Map<String, dynamic> finalizeEnvelope() => {
    'data': {'email': email, 'display_name': 'John Doe'},
    'message': 'registration completed successfully',
  };

  void scriptContinuation({
    int status = 200,
    Object? body,
    Map<String, List<String>> headers = const {},
  }) {
    adapter.onMethod(
      'GET',
      '/auth/register/continuation',
      status: status,
      body: body ?? continuationEnvelope(),
      headers: headers,
    );
  }

  void scriptFinalize({
    int status = 201,
    Object? body,
    Map<String, List<String>> headers = const {},
  }) {
    adapter.onMethod(
      'POST',
      '/auth/register/finalize/manual',
      status: status,
      body: body ?? finalizeEnvelope(),
      headers: headers,
    );
  }

  Future<void> pumpFinalize(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const FinalizeRegistrationScreen(continuationToken: token),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps a routed finalize screen so sign-in/start-over navigation and the
  /// context it carries can be asserted.
  Future<void> pumpRoutedFinalize(WidgetTester tester) async {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = GoRouter(
      initialLocation: AppRoutes.finalizeRegistration,
      routes: [
        GoRoute(
          path: AppRoutes.finalizeRegistration,
          builder: (_, _) =>
              const FinalizeRegistrationScreen(continuationToken: token),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (_, state) =>
              Scaffold(body: Text('SIGNIN ${state.extra ?? 'none'}')),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (_, _) => const Scaffold(body: Text('SIGNUP')),
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

  Future<void> fillForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'John Doe');
    await tester.enterText(fields.at(1), 'password123');
    await tester.enterText(fields.at(2), 'password123');
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(AppButton, 'Create account'));
    await tester.pumpAndSettle();
  }

  group('loading the continuation', () {
    testWidgets('a valid token shows the form and repairs the stored record', (
      tester,
    ) async {
      scriptContinuation();

      await pumpFinalize(tester);

      expect(find.text('Complete your account'), findsOneWidget);
      expect(find.text('Account for $email'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Create account'), findsOneWidget);

      final stored = await continuationStore.read();
      expect(stored, isNotNull);
      expect(stored!.email, email);
      expect(stored.token, token);
    });

    testWidgets('a mismatched stored record is replaced with this token', (
      tester,
    ) async {
      await continuationStore.write(
        email: email,
        token: 'an-older-registration-token',
      );
      scriptContinuation();

      await pumpFinalize(tester);

      expect((await continuationStore.read())?.token, token);
    });

    testWidgets('a transient failure offers Retry and sends no write', (
      tester,
    ) async {
      adapter.onOffline('/auth/register/continuation');

      await pumpFinalize(tester);

      expect(
        find.text(
          'No connection to the server. We could not check this registration. '
          'Try again.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
      expect(adapter.countFor('/auth/register/finalize/manual'), 0);

      await tester.tap(find.widgetWithText(AppButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(
        adapter.countFor('/auth/register/continuation'),
        2,
        reason: 'Retry reads the token again and nothing else',
      );
    });

    testWidgets('a consumed token is already completed, not a retry state', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation(
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationConsumed),
      );

      await pumpFinalize(tester);

      expect(find.text('Registration already completed'), findsOneWidget);
      expect(find.textContaining('already completed. Sign in'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
      expect(find.widgetWithText(AppButton, 'Back to sign in'), findsOneWidget);
      expect(await continuationStore.read(), isNull);
    });

    testWidgets('an expired token asks for a new registration, not a retry', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation(
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationExpired),
      );

      await pumpFinalize(tester);

      expect(find.text('Registration unavailable'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Start a new registration'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
      expect(await continuationStore.read(), isNull);
    });

    testWidgets('a social token is not given a manual form', (tester) async {
      scriptContinuation(
        body: {
          'data': {
            'email': email,
            'registration_type': 'social',
            'requires_password': false,
          },
          'message': 'registration continuation is valid',
        },
      );

      await pumpFinalize(tester);

      expect(find.text('Registration unavailable'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });
  });

  group('submitting', () {
    testWidgets('a 201 is success, clears the token and carries context', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      scriptFinalize();

      await pumpRoutedFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      expect(adapter.countFor('/auth/register/finalize/manual'), 1);
      expect(find.text('SIGNIN registration-success'), findsOneWidget);
      expect(await continuationStore.read(), isNull);
    });

    testWidgets('an uncertain outcome keeps the token and claims nothing', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      adapter.onOffline('/auth/register/finalize/manual');

      await pumpFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      expect(adapter.countFor('/auth/register/finalize/manual'), 1);
      expect(
        find.textContaining('could not confirm whether registration completed'),
        findsOneWidget,
      );
      expect((await continuationStore.read())?.token, token);
      expect(find.text('Complete your account'), findsOneWidget);
    });

    testWidgets('a retry after an uncertain attempt discovers completion', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      adapter.onSequence('/auth/register/finalize/manual', [
        FakeReply(500, errorBody(ApiErrorCode.internalServerError)),
        FakeReply(
          409,
          errorBody(ApiErrorCode.registrationContinuationConsumed),
        ),
      ]);

      await pumpFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      expect(
        find.textContaining('could not confirm whether registration completed'),
        findsOneWidget,
      );

      await submit(tester);

      expect(adapter.countFor('/auth/register/finalize/manual'), 2);
      expect(find.text('Registration already completed'), findsOneWidget);
      expect(await continuationStore.read(), isNull);
    });

    testWidgets('an existing account is a completed registration', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      scriptFinalize(
        status: 409,
        body: errorBody(ApiErrorCode.userAlreadyExists),
      );

      await pumpFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      expect(find.text('Registration already completed'), findsOneWidget);
      expect(await continuationStore.read(), isNull);
    });

    testWidgets('a second submit is refused while the first is in flight', (
      tester,
    ) async {
      scriptContinuation();
      adapter.onBlocking(
        '/auth/register/finalize/manual',
        FakeReply(201, finalizeEnvelope()),
      );

      await pumpRoutedFinalize(tester);
      await fillForm(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Create account'));
      await tester.pump();

      // A busy button replaces its label with a spinner, so it is found by
      // variant rather than by text.
      final primary = find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.variant == AppButtonVariant.primary,
      );
      expect(tester.widget<AppButton>(primary).busy, isTrue);

      await tester.tap(primary, warnIfMissed: false);
      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(adapter.countFor('/auth/register/finalize/manual'), 1);
    });

    testWidgets('a validation refusal keeps the form and the token', (
      tester,
    ) async {
      await continuationStore.write(email: email, token: token);
      scriptContinuation();
      scriptFinalize(
        status: 400,
        body: errorBody(ApiErrorCode.validationError),
      );

      await pumpFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      expect(find.text('Check your details, then try again.'), findsOneWidget);
      expect(find.text('Complete your account'), findsOneWidget);
      expect((await continuationStore.read())?.token, token);
    });
  });

  group('sign-in context', () {
    testWidgets('leaving before any attempt claims no uncertainty', (
      tester,
    ) async {
      scriptContinuation();

      await pumpRoutedFinalize(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('SIGNIN none'), findsOneWidget);
      expect(find.textContaining('registration-uncertain'), findsNothing);
    });

    testWidgets('leaving after an ambiguous attempt carries uncertainty', (
      tester,
    ) async {
      scriptContinuation();
      adapter.onOffline('/auth/register/finalize/manual');

      await pumpRoutedFinalize(tester);
      await fillForm(tester);
      await submit(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('SIGNIN registration-uncertain'), findsOneWidget);
    });
  });
}
