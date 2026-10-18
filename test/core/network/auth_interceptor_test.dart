import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/network/auth_interceptor.dart';
import 'package:stash_it_app/core/network/token_provider.dart';

import '../../support/fake_http.dart';

/// Pumps the event loop until [condition] holds, or fails after a short budget.
///
/// Concurrency tests need a rendezvous point: something has to wait until the
/// requests are genuinely in flight rather than assuming a fixed delay is
/// enough. A microtask drain is not sufficient because Dio's pipeline crosses
/// several `await`s before the interceptor runs.
Future<void> untilCalled(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within ${timeout.inMilliseconds}ms');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

/// A [TokenProvider] under test control.
///
/// Stands in for the session controller so these tests can drive renewal
/// outcomes — including the interleavings that matter — without a storage layer
/// or a second HTTP client in the way.
class StubTokenProvider implements TokenProvider {
  StubTokenProvider({this.accessToken = 'access-1'});

  String? accessToken;

  /// How many times renewal was requested. The single-flight assertion reads
  /// this.
  int refreshCalls = 0;

  /// What renewal should throw, if anything.
  Object? refreshError;

  /// Holds renewal open so requests genuinely overlap.
  Completer<void>? refreshGate;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String> refreshAccessToken() {
    refreshCalls++;
    final gate = refreshGate;
    if (gate != null) {
      return gate.future.then((_) => _result());
    }
    return Future.value(_result());
  }

  String _result() {
    final error = refreshError;
    if (error != null) throw error;
    return accessToken ?? 'access-1';
  }
}

void main() {
  late FakeHttpAdapter adapter;

  Dio buildDio(TokenProvider tokens) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(dio: dio, tokenProvider: tokens));
    return dio;
  }

  setUp(() {
    adapter = FakeHttpAdapter();
  });

  group('request preparation', () {
    test('attaches the bearer token read from the provider', () async {
      final tokens = StubTokenProvider(accessToken: 'token-abc');
      final dio = buildDio(tokens);
      adapter.on('/protected', body: {'data': 'ok'});

      await dio.get<dynamic>('/protected');

      expect(adapter.lastRequestTo('/protected')?.bearer, 'token-abc');
    });

    test('omits the header when there is no token', () async {
      final dio = buildDio(StubTokenProvider(accessToken: null));
      adapter.on('/protected', body: {'data': 'ok'});

      await dio.get<dynamic>('/protected');

      expect(adapter.lastRequestTo('/protected')?.bearer, isNull);
    });

    test('re-reads the token per request rather than caching it', () async {
      // A cached token would still be the pre-renewal value on any request
      // issued while a renewal is in flight, costing a needless round trip.
      final tokens = StubTokenProvider(accessToken: 'first');
      final dio = buildDio(tokens);
      adapter.on('/protected', body: {'data': 'ok'});

      await dio.get<dynamic>('/protected');
      tokens.accessToken = 'second';
      await dio.get<dynamic>('/protected');

      expect(adapter.requests.first.bearer, 'first');
      expect(adapter.requests.last.bearer, 'second');
    });
  });

  group('which failures trigger renewal', () {
    test('ACCESS_TOKEN_EXPIRED renews and replays once', () async {
      final tokens = StubTokenProvider(accessToken: 'new-token');
      final dio = buildDio(tokens);
      adapter.onSequence('/protected', [
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        const FakeReply(200, {'data': 'ok'}),
      ]);

      final response = await dio.get<dynamic>('/protected');

      expect(response.data, {'data': 'ok'});
      expect(tokens.refreshCalls, 1);
      expect(adapter.countFor('/protected'), 2);
      expect(adapter.requests.last.bearer, 'new-token');
    });

    test('INVALID_ACCESS_TOKEN does not renew', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on(
        '/protected',
        status: 401,
        body: errorBody(ApiErrorCode.invalidAccessToken),
      );

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
      expect(adapter.countFor('/protected'), 1);
    });

    test('INVALID_AUTHORIZATION_HEADER does not renew', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on(
        '/protected',
        status: 401,
        body: errorBody(ApiErrorCode.invalidAuthorizationHeader),
      );

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
    });

    test('a 401 with an unrecognised code does not renew', () async {
      // Status alone must never be the trigger: a 401 covers expired, unusable
      // and never-sent alike, and renewing for the latter two cannot succeed.
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on('/protected', status: 401, body: errorBody('SOMETHING_ELSE'));

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
    });

    test('a 401 with no readable body does not renew', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on('/protected', status: 401, body: 'Unauthorized');

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
    });

    test('a 500 does not renew', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on(
        '/protected',
        status: 500,
        body: errorBody(ApiErrorCode.internalServerError),
      );

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
    });

    test('a 429 does not renew', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on(
        '/protected',
        status: 429,
        body: errorBody(ApiErrorCode.userRateLimitExceeded),
      );

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 0);
    });
  });

  group('retry bound', () {
    test('a request that expires twice is replayed exactly once', () async {
      // Without the retry marker this loops: each expiry renews again, and a
      // renewal per expiry is what trips backend reuse detection.
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.on(
        '/protected',
        status: 401,
        body: errorBody(ApiErrorCode.accessTokenExpired),
      );

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 1, reason: 'renewal happens once');
      expect(
        adapter.countFor('/protected'),
        2,
        reason: 'original plus exactly one replay',
      );
    });

    test('the replay carries the retried marker', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.onSequence('/protected', [
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        const FakeReply(200, {'data': 'ok'}),
      ]);

      await dio.get<dynamic>('/protected');

      expect(adapter.requests.last.extra[AuthInterceptor.retriedKey], isTrue);
    });

    test('a failed replay does not trigger a second renewal', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.onSequence('/protected', [
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        FakeReply.error(500, ApiErrorCode.internalServerError),
      ]);

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(tokens.refreshCalls, 1);
      expect(adapter.countFor('/protected'), 2);
    });
  });

  group('concurrent expiries', () {
    // Single-flight is SessionController's responsibility, not the
    // interceptor's — the interceptor only delegates to `TokenProvider`. These
    // tests therefore assert delegation: every expired response asks the
    // provider for a renewal, and it is the provider that shares one operation
    // across them. The sharing itself is covered in
    // `features/auth/application/session_controller_test.dart`, where the real
    // implementation is exercised.

    test('each expired response asks the provider for a renewal', () async {
      final tokens = StubTokenProvider(accessToken: 'shared');
      final dio = buildDio(tokens);

      adapter.onExpiring(
        '/protected',
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        const FakeReply(200, {'data': 'ok'}),
        retriedMarker: AuthInterceptor.retriedKey,
      );

      final responses = await Future.wait([
        dio.get<dynamic>('/protected'),
        dio.get<dynamic>('/protected'),
      ]);

      expect(
        tokens.refreshCalls,
        2,
        reason:
            'one delegation per expired response; sharing is the '
            "provider's job",
      );
      expect(
        responses.map((r) => r.data),
        everyElement({'data': 'ok'}),
        reason: 'both are replayed with the renewed token',
      );
    });

    test(
      'a terminal renewal fails every concurrent request, with no replay',
      () async {
        final tokens = StubTokenProvider();
        tokens.refreshError = const SessionExpiredException(
          ApiErrorCode.sessionRevoked,
        );
        final dio = buildDio(tokens);

        adapter.onBlockingUntil(
          '/protected',
          2,
          FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        );

        await Future.wait([
          expectLater(
            dio.get<dynamic>('/protected'),
            throwsA(isA<DioException>()),
          ),
          expectLater(
            dio.get<dynamic>('/protected'),
            throwsA(isA<DioException>()),
          ),
        ]);

        // Both observe the session ending and neither replays: once the session is
        // gone a replay cannot succeed.
        expect(adapter.countFor('/protected'), 2, reason: 'no replays');
      },
    );

    test(
      'each request is replayed at most once even when several expire',
      () async {
        final tokens = StubTokenProvider(accessToken: 'shared');
        final dio = buildDio(tokens);

        adapter.onExpiring(
          '/protected',
          FakeReply.error(401, ApiErrorCode.accessTokenExpired),
          const FakeReply(200, {'data': 'ok'}),
          retriedMarker: AuthInterceptor.retriedKey,
        );

        await Future.wait([
          dio.get<dynamic>('/protected'),
          dio.get<dynamic>('/protected'),
          dio.get<dynamic>('/protected'),
        ]);

        expect(
          adapter.countFor('/protected'),
          6,
          reason: 'three originals plus one replay each',
        );
      },
    );
  });

  group('renewal outcomes', () {
    test(
      'a terminal expiry surfaces the original 401 and skips the replay',
      () async {
        final tokens = StubTokenProvider();
        tokens.refreshError = const SessionExpiredException(
          ApiErrorCode.sessionRevoked,
        );
        final dio = buildDio(tokens);
        adapter.on(
          '/protected',
          status: 401,
          body: errorBody(ApiErrorCode.accessTokenExpired),
        );

        await expectLater(
          dio.get<dynamic>('/protected'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              401,
            ),
          ),
        );

        expect(
          adapter.countFor('/protected'),
          1,
          reason: 'the session is over, so a replay cannot help',
        );
      },
    );

    test(
      'an ambiguous renewal is reported, not treated as a lost session',
      () async {
        final tokens = StubTokenProvider();
        tokens.refreshError = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.connectionError,
        );
        final dio = buildDio(tokens);
        adapter.on(
          '/protected',
          status: 401,
          body: errorBody(ApiErrorCode.accessTokenExpired),
        );

        Object? carried;
        try {
          await dio.get<dynamic>('/protected');
          fail('expected the request to fail');
        } on DioException catch (error) {
          carried = error.error;
        }

        expect(
          carried,
          isNotNull,
          reason: 'the renewal failure is carried to the caller, not discarded',
        );
        expect(adapter.countFor('/protected'), 1, reason: 'no replay');
      },
    );
  });

  group('replay fidelity', () {
    test('the replay preserves method, path, query and body', () async {
      final tokens = StubTokenProvider();
      final dio = buildDio(tokens);
      adapter.onSequence('/items', [
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        const FakeReply(200, {'data': 'ok'}),
      ]);

      await dio.post<dynamic>(
        '/items',
        data: {'url': 'https://example.com'},
        queryParameters: {'limit': '20'},
      );

      final replay = adapter.requests.last;
      expect(replay.method, 'POST');
      expect(replay.path, contains('/items'));
      expect(replay.path, contains('limit=20'));
      expect(replay.bearer, isNotNull);
    });

    test('the replay carries content type and the new bearer token', () async {
      final tokens = StubTokenProvider(accessToken: 'renewed');
      final dio = buildDio(tokens);
      adapter.onSequence('/items', [
        FakeReply.error(401, ApiErrorCode.accessTokenExpired),
        const FakeReply(200, {'data': 'ok'}),
      ]);

      await dio.post<dynamic>('/items', data: {'a': 1});

      expect(adapter.requests.last.bearer, 'renewed');
      expect(
        adapter.requests.last.headers[Headers.contentTypeHeader],
        Headers.jsonContentType,
      );
    });
  });
}
