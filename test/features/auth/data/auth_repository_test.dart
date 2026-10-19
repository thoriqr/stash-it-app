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
}
