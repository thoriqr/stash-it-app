import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_mapper.dart';

import '../../support/fake_http.dart';

void main() {
  /// Runs [action] and returns the `TypeError` it throws, failing if it does not.
  Object captureTypeError(void Function() action) {
    try {
      action();
    } on TypeError catch (error) {
      return error;
    }
    fail('expected a TypeError');
  }

  /// A `DioException` shaped like the one Dio raises for a non-2xx response.
  DioException badResponse(
    int status,
    Object? body, {
    Map<String, List<String>> headers = const {},
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: status,
        data: body,
        headers: Headers.fromMap(headers),
      ),
      type: DioExceptionType.badResponse,
    );
  }

  group('bearer guard codes', () {
    test('all three map to a single auth-required failure', () {
      for (final code in [
        ApiErrorCode.invalidAuthorizationHeader,
        ApiErrorCode.invalidAccessToken,
        ApiErrorCode.accessTokenExpired,
      ]) {
        final failure = mapApiFailure(badResponse(401, errorBody(code)));

        expect(
          failure,
          isA<ApiFailureAuthRequired>(),
          reason: '$code must map to auth-required',
        );
        expect((failure as ApiFailureAuthRequired).code, code);
      }
    });

    test('INVALID_CREDENTIALS is auth-required, never a session event', () {
      final failure = mapApiFailure(
        badResponse(401, errorBody(ApiErrorCode.invalidCredentials)),
      );

      expect(failure, isA<ApiFailureAuthRequired>());
      expect(failure, isNot(isA<ApiFailureSessionEnded>()));
    });
  });

  group('refresh terminal codes', () {
    test('each maps to a session-ended failure carrying its code', () {
      for (final code in ApiErrorCode.terminalRefresh) {
        final failure = mapApiFailure(badResponse(401, errorBody(code)));

        expect(
          failure,
          isA<ApiFailureSessionEnded>(),
          reason: '$code must end the session',
        );
        expect((failure as ApiFailureSessionEnded).code, code);
      }
    });

    test('the terminal set is exactly the three verified codes', () {
      // Guards against a code being added here on assumption. A 401 from the
      // bearer guard must never clear credentials, so the set is pinned.
      expect(ApiErrorCode.terminalRefresh, {
        'REFRESH_TOKEN_INVALID',
        'SESSION_REVOKED',
        'SESSION_EXPIRED',
      });
    });
  });

  group('rate limiting', () {
    test('a 429 with Retry-After carries the stated wait', () {
      final failure = mapApiFailure(
        badResponse(
          429,
          errorBody(ApiErrorCode.userRateLimitExceeded),
          headers: {
            'retry-after': ['90'],
          },
        ),
      );

      expect(failure, isA<ApiFailureRateLimited>());
      expect(
        (failure as ApiFailureRateLimited).retryAfter,
        const Duration(seconds: 90),
      );
    });

    test('a 429 without Retry-After yields no countdown', () {
      final failure = mapApiFailure(
        badResponse(429, errorBody(ApiErrorCode.ipRateLimitExceeded)),
      );

      expect(failure, isA<ApiFailureRateLimited>());
      expect((failure as ApiFailureRateLimited).retryAfter, isNull);
    });

    test('a malformed Retry-After yields no countdown rather than a guess', () {
      for (final raw in ['soon', '', '-5', '1.5']) {
        final failure = mapApiFailure(
          badResponse(
            429,
            errorBody(ApiErrorCode.loginRateLimitExceeded),
            headers: {
              'retry-after': [raw],
            },
          ),
        );

        expect(
          (failure as ApiFailureRateLimited).retryAfter,
          isNull,
          reason: '"$raw" must not produce a fabricated countdown',
        );
      }
    });

    test('a 503 never produces a countdown', () {
      for (final code in [
        ApiErrorCode.ipRateLimitUnavailable,
        ApiErrorCode.loginRateLimitUnavailable,
        ApiErrorCode.userRateLimitUnavailable,
        ApiErrorCode.clientIpUnavailable,
        ApiErrorCode.serviceUnavailable,
      ]) {
        final failure = mapApiFailure(badResponse(503, errorBody(code)));

        expect(
          failure,
          isA<ApiFailureServerUnavailable>(),
          reason: '$code must be server-unavailable',
        );
      }
    });

    test('PASSWORD_WORK_UNAVAILABLE is a 503 that does carry a wait', () {
      // The one 503 with a real recovery time: the caller was already held for
      // the bounded Argon2id wait.
      final failure = mapApiFailure(
        badResponse(
          503,
          errorBody(ApiErrorCode.passwordWorkUnavailable),
          headers: {
            'retry-after': ['3'],
          },
        ),
      );

      expect(failure, isA<ApiFailureRateLimited>());
      expect(
        (failure as ApiFailureRateLimited).retryAfter,
        const Duration(seconds: 3),
      );
    });
  });

  group('request and server failures', () {
    test('VALIDATION_ERROR carries its fields', () {
      final failure = mapApiFailure(
        badResponse(
          400,
          errorBody(
            ApiErrorCode.validationError,
            fields: [
              {'field': 'email', 'message': 'is required'},
            ],
          ),
        ),
      );

      expect(failure, isA<ApiFailureValidation>());
      final validation = failure as ApiFailureValidation;
      expect(validation.fields, hasLength(1));
      expect(validation.fields.single.field, 'email');
    });

    test('VALIDATION_ERROR tolerates an empty field list', () {
      final failure = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.validationError)),
      );

      expect((failure as ApiFailureValidation).fields, isEmpty);
    });

    test('BAD_REQUEST is a malformed request', () {
      expect(
        mapApiFailure(badResponse(400, errorBody(ApiErrorCode.badRequest))),
        isA<ApiFailureMalformedRequest>(),
      );
    });

    test('INTERNAL_SERVER_ERROR is a server fault', () {
      expect(
        mapApiFailure(
          badResponse(500, errorBody(ApiErrorCode.internalServerError)),
        ),
        isA<ApiFailureServerFault>(),
      );
    });
  });

  group('unreadable and unknown responses', () {
    test('a non-JSON body is unreadable, never surfaced', () {
      // Fiber's default handler answers text/plain for a *fiber.Error.
      final failure = mapApiFailure(badResponse(500, 'Internal Server Error'));

      expect(failure, isA<ApiFailureUnreadableResponse>());
      expect((failure as ApiFailureUnreadableResponse).code, isNull);
    });

    test('an HTML body from a proxy is unreadable', () {
      final failure = mapApiFailure(
        badResponse(502, '<html><body>Bad Gateway</body></html>'),
      );

      expect(failure, isA<ApiFailureUnreadableResponse>());
    });

    test('a JSON body with no error key is unreadable', () {
      expect(
        mapApiFailure(badResponse(500, {'data': null, 'message': 'oops'})),
        isA<ApiFailureUnreadableResponse>(),
      );
    });

    test('an unrecognised code is unmapped rather than guessed at', () {
      final failure = mapApiFailure(badResponse(418, errorBody('TEAPOT')));

      expect(failure, isA<ApiFailureUnreadableResponse>());
      expect((failure as ApiFailureUnreadableResponse).code, 'TEAPOT');
    });

    test('an empty code is unreadable', () {
      expect(
        mapApiFailure(
          badResponse(500, {
            'error': {'code': '', 'message': ''},
          }),
        ),
        isA<ApiFailureUnreadableResponse>(),
      );
    });

    test('a null body is unreadable', () {
      expect(
        mapApiFailure(badResponse(500, null)),
        isA<ApiFailureUnreadableResponse>(),
      );
    });
  });

  group('transport failures', () {
    test('no response at all is the uncertain category', () {
      final failure = mapApiFailure(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(failure, isA<ApiFailureTransport>());
    });

    test('a timeout with no response is also uncertain', () {
      final failure = mapApiFailure(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(failure, isA<ApiFailureTransport>());
    });

    test('a body that arrived but could not be decoded is NOT uncertain', () {
      // Dio's transformer throws while parsing and the exception carries no
      // response, so it is structurally identical to a dropped connection. A
      // reply did arrive, so the outcome is known: group F, not G or H.
      final failure = mapApiFailure(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
          error: const FormatException('Unexpected character'),
        ),
      );

      expect(failure, isA<ApiFailureUnreadableResponse>());
    });

    test('a null cast while decoding is an unreadable response', () {
      // The shape mismatch a wrong wire key produces, seen from inside the
      // transformer: a value that is absent, cast to a non-nullable `String`.
      final payload = <String, dynamic>{'data': <String, dynamic>{}};
      String castAbsent() => payload['access_token'] as String;

      final failure = mapApiFailure(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
          error: captureTypeError(castAbsent),
        ),
      );

      expect(failure, isA<ApiFailureUnreadableResponse>());
    });
  });

  group('already-classified failures', () {
    test('a typed failure inside error is returned unchanged', () {
      // How SessionController reports an ambiguous renewal: the outcome cannot be
      // re-derived from a response, so re-deciding it here would lose it.
      const original = ApiFailureServerFault();
      final failure = mapApiFailure(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
          error: original,
        ),
      );

      expect(failure, same(original));
    });
  });
}
