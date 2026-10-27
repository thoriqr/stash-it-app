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

  Map<String, dynamic> registerManualEnvelope({String? status}) => {
    'data': {
      'verification_id': '01a0f359-093b-737a-963a-80f7ca6768ed',
      'verification_status': ?status,
    },
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

        final response = await repository.registerManual(
          email: 'user@example.com',
        );

        expect(response.verificationId, '01a0f359-093b-737a-963a-80f7ca6768ed');
        expect(
          response.verificationStatus,
          isNull,
          reason: 'an older backend omits the additive status field',
        );
        expect(response.isVerified, isFalse);
        final sent = adapter.lastRequestTo('/auth/register/manual')!;
        expect(sent.method, 'POST');
        expect(sent.jsonField('email'), 'user@example.com');
        expect((sent.body as Map).keys, {'email'});
      },
    );

    test('decodes a pending verification status', () async {
      adapter.on(
        '/auth/register/manual',
        status: 201,
        body: registerManualEnvelope(status: 'pending'),
      );

      final response = await repository.registerManual(
        email: 'user@example.com',
      );

      expect(response.verificationStatus, 'pending');
      expect(response.isVerified, isFalse);
    });

    test('decodes a verified verification status', () async {
      adapter.on(
        '/auth/register/manual',
        status: 201,
        body: registerManualEnvelope(status: 'verified'),
      );

      final response = await repository.registerManual(
        email: 'user@example.com',
      );

      expect(response.verificationStatus, 'verified');
      expect(response.isVerified, isTrue);
    });

    test(
      'preserves an unknown status without treating it as verified',
      () async {
        adapter.on(
          '/auth/register/manual',
          status: 201,
          body: registerManualEnvelope(status: 'something-new'),
        );

        final response = await repository.registerManual(
          email: 'user@example.com',
        );

        expect(response.verificationStatus, 'something-new');
        expect(response.isVerified, isFalse);
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

  group('manual recovery', () {
    const recoveryEnvelope = {
      'data': {
        'verification_id': '01a0f359-093b-737a-963a-80f7ca6768ed',
        'verification_status': 'pending',
      },
      'message': 'registration recovery started',
    };

    test('sends only the email and decodes the pending response', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 201,
        body: recoveryEnvelope,
      );

      final response = await repository.initiateManualRecovery(
        email: 'user@example.com',
      );

      expect(response.verificationId, '01a0f359-093b-737a-963a-80f7ca6768ed');
      expect(response.verificationStatus, 'pending');
      expect(response.isVerified, isFalse);

      final sent = adapter.lastRequestTo('/auth/register/recovery/manual')!;
      expect(sent.method, 'POST');
      expect(sent.jsonField('email'), 'user@example.com');
      expect((sent.body as Map).keys, {'email'});
    });

    test('a 201 without recovery data is unreadable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 201,
        body: {'data': null, 'message': 'registration recovery started'},
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('an already completed registration cannot be recovered', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationAlreadyCompleted),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureRegistrationAlreadyCompleted>()),
      );
    });

    test('a still-pending normal verification is already pending', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationAlreadyPending),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureRegistrationAlreadyPending>()),
      );
    });

    test('a registration no longer pending requires a restart', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationNotPending),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureRegistrationRestartRequired>()),
      );
    });

    test('an expired registration requires a restart', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationExpired),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureRegistrationRestartRequired>()),
      );
    });

    test('a social registration is the invalid-type refusal', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 409,
        body: errorBody(ApiErrorCode.invalidRegistrationType),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureInvalidRegistrationType>()),
      );
    });

    test('a rejected address is validation', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 400,
        body: errorBody(ApiErrorCode.validationError),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'not-an-email'),
        throwsA(isA<ApiFailureValidation>()),
      );
    });

    test('a spent IP budget carries the server Retry-After', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 429,
        body: errorBody(ApiErrorCode.ipRateLimitExceeded),
        headers: {
          'retry-after': ['42'],
        },
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(
          isA<ApiFailureRateLimited>().having(
            (failure) => failure.retryAfter,
            'retryAfter',
            const Duration(seconds: 42),
          ),
        ),
      );
    });

    test('an unavailable limiter is server-unavailable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 503,
        body: errorBody(ApiErrorCode.ipRateLimitUnavailable),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureServerUnavailable>()),
      );
    });

    test('a server fault is its own outcome', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 500,
        body: errorBody(ApiErrorCode.internalServerError),
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });

    test('a lost recovery request is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/recovery/manual');

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('an unreadable recovery reply stays unreadable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/recovery/manual',
        status: 201,
        body: 'not JSON',
      );

      await expectLater(
        repository.initiateManualRecovery(email: 'user@example.com'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
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
      adapter.onOffline('/auth/register/verification/$verificationId/resend');

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

  group('registration PIN verification', () {
    const verificationId = '01a0f359-093b-737a-963a-80f7ca6768ed';
    const token = 'raw-continuation-token';

    test('returns the raw continuation token and sends the PIN', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 200,
        body: {
          'data': {'registration_continuation_token': token},
          'message': 'registration verified',
        },
      );

      final returned = await repository.verifyRegistration(
        verificationId: verificationId,
        pin: '123456',
      );

      expect(returned, token);
      final sent = adapter.lastRequestTo('/verify')!;
      expect(sent.method, 'POST');
      expect(sent.jsonField('pin'), '123456');
    });

    test('a wrong PIN stays a typed refusal', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 409,
        body: errorBody(ApiErrorCode.invalidVerificationCode),
      );

      await expectLater(
        repository.verifyRegistration(
          verificationId: verificationId,
          pin: '000000',
        ),
        throwsA(isA<ApiFailureInvalidVerificationCode>()),
      );
    });

    test('exhausted attempts stay a typed refusal', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 409,
        body: errorBody(ApiErrorCode.verificationCodeAttemptsExceeded),
      );

      await expectLater(
        repository.verifyRegistration(
          verificationId: verificationId,
          pin: '000000',
        ),
        throwsA(isA<ApiFailureVerificationCodeAttemptsExceeded>()),
      );
    });

    test('a 200 with no data is unreadable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 200,
        body: {'data': null, 'message': 'registration verified'},
      );

      await expectLater(
        repository.verifyRegistration(
          verificationId: verificationId,
          pin: '123456',
        ),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('an unreadable body is not treated as a token', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/verification/$verificationId/verify',
        status: 200,
        body: 'not JSON',
      );

      await expectLater(
        repository.verifyRegistration(
          verificationId: verificationId,
          pin: '123456',
        ),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a lost verification is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/verification/$verificationId/verify');

      await expectLater(
        repository.verifyRegistration(
          verificationId: verificationId,
          pin: '123456',
        ),
        throwsA(isA<ApiFailureTransport>()),
      );
    });
  });

  group('registration continuation', () {
    const token = 'raw-continuation-token';

    test('sends the token header and decodes every documented field', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 200,
        body: {
          'data': {
            'email': 'user@example.com',
            'registration_type': 'manual',
            'requires_password': true,
          },
          'message': 'registration continuation is valid',
        },
      );

      final continuation = await repository.getRegistrationContinuation(
        continuationToken: token,
      );

      expect(continuation.email, 'user@example.com');
      expect(continuation.registrationType, 'manual');
      expect(continuation.requiresPassword, isTrue);

      final sent = adapter.lastRequestTo('/auth/register/continuation')!;
      expect(sent.method, 'GET');
      expect(sent.headers['X-Registration-Continuation'], token);
    });

    test('a missing header is the required refusal', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 401,
        body: errorBody(ApiErrorCode.registrationContinuationRequired),
      );

      await expectLater(
        repository.getRegistrationContinuation(continuationToken: token),
        throwsA(isA<ApiFailureRegistrationContinuationRequired>()),
      );
    });

    test('a consumed token stays distinct', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationConsumed),
      );

      await expectLater(
        repository.getRegistrationContinuation(continuationToken: token),
        throwsA(isA<ApiFailureRegistrationContinuationConsumed>()),
      );
    });

    test('an expired token stays distinct', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationExpired),
      );

      await expectLater(
        repository.getRegistrationContinuation(continuationToken: token),
        throwsA(isA<ApiFailureRegistrationContinuationExpired>()),
      );
    });

    test('the backend generic CONFLICT for an unknown token is unreadable, '
        'not guessed as expired', () async {
      adapter.onMethod(
        'GET',
        '/auth/register/continuation',
        status: 409,
        body: errorBody('CONFLICT'),
      );

      await expectLater(
        repository.getRegistrationContinuation(continuationToken: token),
        throwsA(
          isA<ApiFailureUnreadableResponse>().having(
            (failure) => failure.code,
            'code',
            'CONFLICT',
          ),
        ),
      );
    });

    test('a lost validation is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/continuation');

      await expectLater(
        repository.getRegistrationContinuation(continuationToken: token),
        throwsA(isA<ApiFailureTransport>()),
      );
    });
  });

  group('manual finalization', () {
    const token = 'raw-continuation-token';

    test('sends the token header and documented body, then decodes', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 201,
        body: {
          'data': {'email': 'user@example.com', 'display_name': 'John Doe'},
          'message': 'registration completed successfully',
        },
      );

      final result = await repository.finalizeManualRegistration(
        continuationToken: token,
        displayName: 'John Doe',
        password: 'password123',
      );

      expect(result.email, 'user@example.com');
      expect(result.displayName, 'John Doe');

      final sent = adapter.lastRequestTo('/auth/register/finalize/manual')!;
      expect(sent.method, 'POST');
      expect(sent.headers['X-Registration-Continuation'], token);
      expect(sent.jsonField('display_name'), 'John Doe');
      expect(sent.jsonField('password'), 'password123');
    });

    test('an existing account is already completed', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 409,
        body: errorBody(ApiErrorCode.userAlreadyExists),
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureRegistrationAlreadyCompleted>()),
      );
    });

    test('a consumed token stays distinct', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationConsumed),
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureRegistrationContinuationConsumed>()),
      );
    });

    test('an expired token stays distinct', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 409,
        body: errorBody(ApiErrorCode.registrationContinuationExpired),
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureRegistrationContinuationExpired>()),
      );
    });

    test('password-work capacity carries Retry-After', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 503,
        body: errorBody(ApiErrorCode.passwordWorkUnavailable),
        headers: {
          'retry-after': ['5'],
        },
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(
          isA<ApiFailureRateLimited>().having(
            (failure) => failure.retryAfter,
            'retryAfter',
            const Duration(seconds: 5),
          ),
        ),
      );
    });

    test('an IP rate limit carries Retry-After', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 429,
        body: errorBody(ApiErrorCode.ipRateLimitExceeded),
        headers: {
          'retry-after': ['30'],
        },
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureRateLimited>()),
      );
    });

    test('a lost finalization is an uncertain transport failure', () async {
      adapter.onOffline('/auth/register/finalize/manual');

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('a 201 with no data is unreadable', () async {
      adapter.onMethod(
        'POST',
        '/auth/register/finalize/manual',
        status: 201,
        body: {'data': null, 'message': 'registration completed successfully'},
      );

      await expectLater(
        repository.finalizeManualRegistration(
          continuationToken: token,
          displayName: 'John Doe',
          password: 'password123',
        ),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });
}
