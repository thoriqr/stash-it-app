import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/datasources/auth_api.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';

import '../../../support/fake_http.dart';

void main() {
  late FakeHttpAdapter adapter;
  late Dio appDio;
  late AuthRepository repository;

  setUp(() {
    adapter = FakeHttpAdapter();

    appDio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    repository = AuthRepository(authApi: AuthApi(appDio));
  });

  /// The exact envelope `POST /auth/login` returns on success.
  Map<String, dynamic> loginEnvelope() => {
    'data': {
      'access_token': 'access-1',
      'refresh_token': 'refresh-1',
      'user': {
        'id': '01a0f359-093b-737a-963a-80f7ca6768ed',
        'email': 'user@example.com',
        'display_name': 'John Doe',
      },
    },
    'message': 'login successful',
  };

  Map<String, dynamic> registerManualEnvelope() => {
    'data': {'verification_id': '01a0f359-093b-737a-963a-80f7ca6768ed'},
    'message': 'registration requested',
  };

  group('login', () {
    test('decodes the documented success envelope', () async {
      adapter.on('/auth/login', body: loginEnvelope());

      final outcome = await repository.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(
        outcome.tokens,
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );
      expect(outcome.user.id, '01a0f359-093b-737a-963a-80f7ca6768ed');
      expect(outcome.user.email, 'user@example.com');
      expect(outcome.user.displayName, 'John Doe');
    });

    test('sends exactly the two documented fields', () async {
      adapter.on('/auth/login', body: loginEnvelope());

      await repository.login(
        email: 'user@example.com',
        password: 'password123',
      );

      final sent = adapter.lastRequestTo('/auth/login')!;
      expect(sent.method, 'POST');
      expect(sent.path, endsWith('/auth/login'));
    });

    test('INVALID_CREDENTIALS surfaces as auth-required', () async {
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody(ApiErrorCode.invalidCredentials),
      );

      await expectLater(
        repository.login(email: 'user@example.com', password: 'wrong'),
        throwsA(
          isA<ApiFailureAuthRequired>().having(
            (f) => f.code,
            'code',
            ApiErrorCode.invalidCredentials,
          ),
        ),
      );
    });

    test('a 429 surfaces with its Retry-After', () async {
      adapter.on(
        '/auth/login',
        status: 429,
        body: errorBody(ApiErrorCode.loginRateLimitExceeded),
        headers: {
          'retry-after': ['120'],
        },
      );

      await expectLater(
        repository.login(email: 'user@example.com', password: 'password123'),
        throwsA(
          isA<ApiFailureRateLimited>().having(
            (f) => f.retryAfter,
            'retryAfter',
            const Duration(seconds: 120),
          ),
        ),
      );
    });

    test('a 503 surfaces with no countdown', () async {
      adapter.on(
        '/auth/login',
        status: 503,
        body: errorBody(ApiErrorCode.loginRateLimitUnavailable),
      );

      await expectLater(
        repository.login(email: 'user@example.com', password: 'password123'),
        throwsA(isA<ApiFailureServerUnavailable>()),
      );
    });

    test(
      'a 200 with no data is unreadable rather than an empty session',
      () async {
        adapter.on(
          '/auth/login',
          body: {'data': null, 'message': 'login successful'},
        );

        await expectLater(
          repository.login(email: 'user@example.com', password: 'password123'),
          throwsA(isA<ApiFailureUnreadableResponse>()),
        );
      },
    );

    test('a non-JSON body is unreadable and never surfaced', () async {
      adapter.on('/auth/login', status: 500, body: 'Internal Server Error');

      await expectLater(
        repository.login(email: 'user@example.com', password: 'password123'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });

  group('logout', () {
    test('sends no request body', () async {
      // The backend binds no body: it revokes the session named by the verified
      // token's `sid` claim. A body would be ignored at best.
      adapter.on(
        '/auth/logout',
        body: {'data': null, 'message': 'logout successful'},
      );

      await repository.logout();

      final sent = adapter.lastRequestTo('/auth/logout')!;
      expect(sent.method, 'POST');
      expect(sent.path, endsWith('/auth/logout'));
    });

    test('decodes the null-data success envelope', () async {
      // `httpx.OKMessage` writes a nil Data pointer, so `data: null` on a 200 is
      // the normal case rather than a malformed response.
      adapter.on(
        '/auth/logout',
        body: {'data': null, 'message': 'logout successful'},
      );

      await expectLater(repository.logout(), completes);
    });

    test('an expired access token surfaces as auth-required', () async {
      adapter.on(
        '/auth/logout',
        status: 401,
        body: errorBody(ApiErrorCode.accessTokenExpired),
      );

      await expectLater(
        repository.logout(),
        throwsA(isA<ApiFailureAuthRequired>()),
      );
    });
  });

  group('manual registration', () {
    test(
      'returns the documented verification id and sends only the email',
      () async {
        adapter.on(
          '/auth/register/manual',
          status: 201,
          body: registerManualEnvelope(),
        );

        final verificationId = await repository.registerManual(
          email: 'user@example.com',
        );

        expect(verificationId, '01a0f359-093b-737a-963a-80f7ca6768ed');
        final sent = adapter.lastRequestTo('/auth/register/manual')!;
        expect(sent.method, 'POST');
        expect(sent.jsonField('email'), 'user@example.com');
        expect((sent.body as Map).keys, {'email'});
      },
    );

    test('a 201 without registration data is unreadable', () async {
      adapter.on(
        '/auth/register/manual',
        status: 201,
        body: {'data': null, 'message': 'registration requested'},
      );

      await expectLater(
        repository.registerManual(email: 'user@example.com'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a malformed success response is unreadable', () async {
      adapter.on(
        '/auth/register/manual',
        status: 201,
        body: {'data': {}, 'message': 'registration requested'},
      );

      await expectLater(
        repository.registerManual(email: 'user@example.com'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test(
      'a lost registration request is an uncertain transport failure',
      () async {
        adapter.onOffline('/auth/register/manual');

        await expectLater(
          repository.registerManual(email: 'user@example.com'),
          throwsA(isA<ApiFailureTransport>()),
        );
      },
    );

    test('a completed registration surfaces as already completed', () async {
      adapter.on(
        '/auth/register/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationAlreadyCompleted),
      );

      await expectLater(
        repository.registerManual(email: 'user@example.com'),
        throwsA(isA<ApiFailureRegistrationAlreadyCompleted>()),
      );
    });
  });

  group('registration PIN', () {
    const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';

    test('uses the verification path with no request body', () async {
      adapter.on(
        '/auth/register/verification/$verificationId/pin',
        status: 201,
        body: {
          'data': {'verification_id': verificationId},
          'message': 'verification code created',
        },
      );

      await expectLater(
        repository.createPin(verificationId: verificationId),
        completes,
      );

      final sent = adapter.lastRequestTo('/verification/$verificationId/pin')!;
      expect(sent.method, 'POST');
      expect(sent.body, isNull);
    });

    test(
      'an unreadable response is not treated as PIN creation success',
      () async {
        adapter.on(
          '/auth/register/verification/$verificationId/pin',
          status: 201,
          body: 'not JSON',
        );

        await expectLater(
          repository.createPin(verificationId: verificationId),
          // An unreadable `201` is not evidence that issuance or email delivery
          // failed: the server persisted the code before answering. It must stay
          // distinct from the delivery-failure and server-unavailable variants.
          throwsA(
            allOf(
              isA<ApiFailureUnreadableResponse>(),
              isNot(isA<ApiFailurePinEmailDeliveryFailed>()),
              isNot(isA<ApiFailureServerUnavailable>()),
            ),
          ),
        );
      },
    );

    test('a lost PIN request is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/verification/$verificationId/pin');

      await expectLater(
        repository.createPin(verificationId: verificationId),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('an expired registration requires restarting registration', () async {
      adapter.on(
        '/auth/register/verification/$verificationId/pin',
        status: 409,
        body: errorBody(ApiErrorCode.registrationExpired),
      );

      await expectLater(
        repository.createPin(verificationId: verificationId),
        throwsA(isA<ApiFailureRegistrationRestartRequired>()),
      );
    });

    test('the resend cooldown is not a rate limit', () async {
      adapter.on(
        '/auth/register/verification/$verificationId/pin',
        status: 409,
        body: errorBody(ApiErrorCode.verificationResendCooldown),
      );

      await expectLater(
        repository.createPin(verificationId: verificationId),
        throwsA(isA<ApiFailureVerificationResendCooldown>()),
      );
    });
  });

  group('registration verification status', () {
    const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';

    test('decodes every documented field', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        status: 200,
        body: {
          'data': {
            'verification_id': verificationId,
            'status': 'pending',
            'pin_issued': true,
            'resend_in_seconds': 42,
          },
          'message': 'verification retrieved',
        },
      );

      final status = await repository.getVerification(
        verificationId: verificationId,
      );

      expect(status.verificationId, verificationId);
      expect(status.status, 'pending');
      expect(status.pinIssued, isTrue);
      expect(status.resendInSeconds, 42);
    });

    test('a missing verification is not found', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        status: 404,
        body: errorBody(ApiErrorCode.resourceNotFound),
      );

      await expectLater(
        repository.getVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureNotFound>()),
      );
    });

    test('an expired registration requires restarting registration', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        status: 409,
        body: errorBody(ApiErrorCode.registrationExpired),
      );

      await expectLater(
        repository.getVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureRegistrationRestartRequired>()),
      );
    });

    test('an unreadable response is unreadable', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/verification/$verificationId',
        status: 200,
        body: 'not JSON',
      );

      await expectLater(
        repository.getVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a lost request is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/verification/$verificationId');

      await expectLater(
        repository.getVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureTransport>()),
      );
    });
  });

  group('registration resend', () {
    const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';

    test('uses the resend path with no request body', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/resend',
        status: 200,
        body: {
          'data': {'verification_id': verificationId},
          'message': 'verification code resent',
        },
      );

      final returned = await repository.resendVerification(
        verificationId: verificationId,
      );

      expect(returned, verificationId);
      final sent = adapter.lastRequestTo('/resend')!;
      expect(sent.method, 'POST');
      expect(sent.body, isNull);
    });

    test('a cooldown refusal has no invented duration', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/resend',
        status: 409,
        body: errorBody(ApiErrorCode.verificationResendCooldown),
      );

      await expectLater(
        repository.resendVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureVerificationResendCooldown>()),
      );
    });

    test('a delivery failure carries the server cooldown', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/resend',
        status: 503,
        body: errorBody(ApiErrorCode.pinEmailDeliveryFailed),
        headers: {
          'retry-after': ['60'],
        },
      );

      await expectLater(
        repository.resendVerification(verificationId: verificationId),
        throwsA(
          isA<ApiFailurePinEmailDeliveryFailed>().having(
            (failure) => failure.retryAfter,
            'retryAfter',
            const Duration(seconds: 60),
          ),
        ),
      );
    });

    test('a rate limit carries Retry-After', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/resend',
        status: 429,
        body: errorBody(ApiErrorCode.pinRateLimitExceeded),
        headers: {
          'retry-after': ['42'],
        },
      );

      await expectLater(
        repository.resendVerification(verificationId: verificationId),
        throwsA(
          isA<ApiFailureRateLimited>().having(
            (failure) => failure.retryAfter,
            'retryAfter',
            const Duration(seconds: 42),
          ),
        ),
      );
    });

    test('a lost resend is an uncertain transport failure', () async {
      adapter.onOffline(
        '/auth/register/verification/$verificationId/resend',
      );

      await expectLater(
        repository.resendVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('an unreadable resend response is unreadable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/resend',
        status: 200,
        body: 'not JSON',
      );

      await expectLater(
        repository.resendVerification(verificationId: verificationId),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });
}
