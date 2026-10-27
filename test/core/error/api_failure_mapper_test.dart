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

    test('INVALID_URL is the same variant as a validation error', () {
      // Raised by the create route — a `400` after the body parsed, for a URL
      // that is well formed JSON and still not usable. To a caller it means what
      // `VALIDATION_ERROR` means: the input has to change. Mapping it anywhere
      // else would make a correctable URL read as an unreadable reply, which is a
      // different and wrong story.
      expect(
        mapApiFailure(badResponse(400, errorBody(ApiErrorCode.invalidUrl))),
        isA<ApiFailureValidation>(),
      );
    });

    test('INVALID_SEARCH_QUERY is actionable input, not an unreadable reply', () {
      // Search owns its query rules and reports them under this code rather
      // than VALIDATION_ERROR. The caller's action is still "change the input",
      // so it maps to the same variant. Leaving it unmapped would show the
      // unreadable-response copy for a query the user can simply correct.
      final failure = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.invalidSearchQuery)),
      );

      expect(failure, isA<ApiFailureValidation>());
      expect(failure, isNot(isA<ApiFailureUnreadableResponse>()));
    });

    test('INVALID_COLLECTION_NAME is actionable input', () {
      // The move route's own name rule. A blank or over-long name is well formed
      // JSON and still unusable, so the caller must correct the field rather than
      // read it as an unreadable reply.
      final failure = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.invalidCollectionName)),
      );

      expect(failure, isA<ApiFailureValidation>());
      expect(failure, isNot(isA<ApiFailureUnreadableResponse>()));
    });

    test('COLLECTION_NAME_ALREADY_EXISTS is its own conflict', () {
      // Well formed, but the create flow cannot take a name another collection
      // holds. A validation variant would describe the shape; this one says the
      // name is unavailable without claiming which collection owns it.
      final failure = mapApiFailure(
        badResponse(409, errorBody(ApiErrorCode.collectionNameAlreadyExists)),
      );

      expect(failure, isA<ApiFailureCollectionNameAlreadyExists>());
      expect(
        (failure as ApiFailureCollectionNameAlreadyExists).code,
        ApiErrorCode.collectionNameAlreadyExists,
      );
    });

    test('INVALID_COLLECTION_INTENT is malformed, never a name conflict', () {
      final failure = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.invalidCollectionIntent)),
      );

      expect(failure, isA<ApiFailureMalformedRequest>());
      expect(failure, isNot(isA<ApiFailureCollectionNameAlreadyExists>()));
      expect(failure, isNot(isA<ApiFailureValidation>()));
    });

    test('SAVED_ITEM_NOT_FOUND is the move route\'s not-found', () {
      final failure = mapApiFailure(
        badResponse(404, errorBody(ApiErrorCode.savedItemNotFound)),
      );

      expect(failure, isA<ApiFailureNotFound>());
      expect(
        (failure as ApiFailureNotFound).code,
        ApiErrorCode.savedItemNotFound,
        reason: 'retained for diagnosis, never displayed',
      );
    });

    test('COLLECTION_NOT_FOUND is the collection listing\'s not-found', () {
      // A missing collection and another user's collection share this code, so
      // the variant must not be used to say which happened. Without the mapping
      // it would land in the unreadable bucket and offer a retry that cannot
      // succeed.
      final failure = mapApiFailure(
        badResponse(404, errorBody(ApiErrorCode.collectionNotFound)),
      );

      expect(failure, isA<ApiFailureNotFound>());
      expect(
        (failure as ApiFailureNotFound).code,
        ApiErrorCode.collectionNotFound,
        reason: 'retained for diagnosis, never displayed',
      );
    });

    test('COLLECTION_DELETE_TARGET_NOT_FOUND names the destination', () {
      // The collection being deleted still exists; only the destination of the
      // bulk move is gone. Classifying this as `ApiFailureNotFound` would push
      // the collection screen into its not-found state and make choosing another
      // destination impossible.
      final failure = mapApiFailure(
        badResponse(
          404,
          errorBody(ApiErrorCode.collectionDeleteTargetNotFound),
        ),
      );

      expect(failure, isA<ApiFailureCollectionDeleteTargetNotFound>());
      expect(failure, isNot(isA<ApiFailureNotFound>()));
      expect(
        (failure as ApiFailureCollectionDeleteTargetNotFound).code,
        ApiErrorCode.collectionDeleteTargetNotFound,
        reason: 'retained for diagnosis, never displayed',
      );
    });

    test('a 404 with an unrecognised code is not the move not-found', () {
      expect(
        mapApiFailure(badResponse(404, errorBody('SOMETHING_ELSE'))),
        isA<ApiFailureUnreadableResponse>(),
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

  group('profile and password codes', () {
    test('USER_NOT_FOUND is the account, not the resource on screen', () {
      // Access tokens outlive the session they name, so this is reachable. It is
      // not `ApiFailureNotFound`: that variant describes the item or collection a
      // screen is showing, while this one says the authenticated account is gone.
      final failure = mapApiFailure(
        badResponse(404, errorBody(ApiErrorCode.userNotFound)),
      );

      expect(failure, isA<ApiFailureUserNotFound>());
      expect(failure, isNot(isA<ApiFailureNotFound>()));
      expect(
        (failure as ApiFailureUserNotFound).code,
        ApiErrorCode.userNotFound,
      );
    });

    test('CURRENT_PASSWORD_INVALID is a credential refusal, never auth', () {
      // 401 because the *current password* failed, not the bearer token. Mapping
      // it to auth-required would tell the user to sign in again for a problem
      // signing in cannot fix, and the interceptor must not refresh for it.
      final failure = mapApiFailure(
        badResponse(401, errorBody(ApiErrorCode.currentPasswordInvalid)),
      );

      expect(failure, isA<ApiFailureCurrentPasswordInvalid>());
      expect(failure, isNot(isA<ApiFailureAuthRequired>()));
      expect(failure, isNot(isA<ApiFailureSessionEnded>()));
      expect(
        (failure as ApiFailureCurrentPasswordInvalid).code,
        ApiErrorCode.currentPasswordInvalid,
      );
    });

    test('the two credential-state mismatches keep their direction', () {
      final required = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.currentPasswordRequired)),
      );
      final unexpected = mapApiFailure(
        badResponse(400, errorBody(ApiErrorCode.unexpectedCurrentPassword)),
      );

      expect(required, isA<ApiFailureCurrentPasswordRequired>());
      expect(unexpected, isA<ApiFailureUnexpectedCurrentPassword>());
      expect(
        (required as ApiFailureCurrentPasswordRequired).code,
        ApiErrorCode.currentPasswordRequired,
      );
      expect(
        (unexpected as ApiFailureUnexpectedCurrentPassword).code,
        ApiErrorCode.unexpectedCurrentPassword,
      );
      // Neither is a field-validation failure: the form's mode was wrong, not
      // the value in a field.
      expect(required, isNot(isA<ApiFailureValidation>()));
      expect(unexpected, isNot(isA<ApiFailureValidation>()));
    });

    test('the two concurrent-writer outcomes are distinct', () {
      final exists = mapApiFailure(
        badResponse(
          409,
          errorBody(ApiErrorCode.passwordCredentialAlreadyExists),
        ),
      );
      final changed = mapApiFailure(
        badResponse(409, errorBody(ApiErrorCode.passwordAlreadyChanged)),
      );

      expect(exists, isA<ApiFailurePasswordCredentialAlreadyExists>());
      expect(changed, isA<ApiFailurePasswordAlreadyChanged>());
      expect(
        (exists as ApiFailurePasswordCredentialAlreadyExists).code,
        ApiErrorCode.passwordCredentialAlreadyExists,
      );
      expect(
        (changed as ApiFailurePasswordAlreadyChanged).code,
        ApiErrorCode.passwordAlreadyChanged,
      );
    });

    test('PASSWORD_CREDENTIAL_NOT_FOUND is not a reachable response', () {
      // It exists in the backend but `SetPassword` consumes it internally to
      // select the create branch. A 404 carrying it is therefore outside the
      // verified list and must stay unmapped rather than gain a branch that
      // never runs.
      final failure = mapApiFailure(
        badResponse(404, errorBody('PASSWORD_CREDENTIAL_NOT_FOUND')),
      );

      expect(failure, isA<ApiFailureUnreadableResponse>());
    });
  });

  group('initial manual registration codes', () {
    test('each lifecycle code keeps its own typed outcome and code', () {
      final expected = <String, Type>{
        ApiErrorCode.registrationAlreadyCompleted:
            ApiFailureRegistrationAlreadyCompleted,
        ApiErrorCode.registrationAlreadyExists: ApiFailureRegistrationRetryable,
        ApiErrorCode.activeVerificationCodeExists:
            ApiFailureRegistrationRetryable,
        ApiErrorCode.verificationNotPending:
            ApiFailureRegistrationRestartRequired,
        ApiErrorCode.registrationNotPending:
            ApiFailureRegistrationRestartRequired,
        ApiErrorCode.registrationExpired: ApiFailureRegistrationRestartRequired,
        ApiErrorCode.verificationResendCooldown:
            ApiFailureVerificationResendCooldown,
      };

      for (final entry in expected.entries) {
        final failure = mapApiFailure(badResponse(409, errorBody(entry.key)));

        expect(
          failure,
          isA<ApiFailureRegistration>(),
          reason: '${entry.key} belongs to the registration group',
        );
        expect(
          failure.runtimeType,
          entry.value,
          reason: '${entry.key} must not collapse into another outcome',
        );
        expect(
          (failure as ApiFailureRegistration).code,
          entry.key,
          reason: '${entry.key} must be retained for diagnosis',
        );
      }
    });

    test('a completed registration points at sign-in, not a retry', () {
      final failure = mapApiFailure(
        badResponse(409, errorBody(ApiErrorCode.registrationAlreadyCompleted)),
      );

      expect(failure, isA<ApiFailureRegistrationAlreadyCompleted>());
      expect(failure, isNot(isA<ApiFailureRegistrationRetryable>()));
      expect(failure, isNot(isA<ApiFailureRegistrationRestartRequired>()));
    });

    test('concurrent registration conflicts are retryable', () {
      for (final code in [
        ApiErrorCode.registrationAlreadyExists,
        ApiErrorCode.activeVerificationCodeExists,
      ]) {
        expect(
          mapApiFailure(badResponse(409, errorBody(code))),
          isA<ApiFailureRegistrationRetryable>(),
          reason: '$code is a transient conflict, not a lifecycle end',
        );
      }
    });

    test('a finished lifecycle requires restarting registration', () {
      for (final code in [
        ApiErrorCode.verificationNotPending,
        ApiErrorCode.registrationNotPending,
        ApiErrorCode.registrationExpired,
      ]) {
        expect(
          mapApiFailure(badResponse(409, errorBody(code))),
          isA<ApiFailureRegistrationRestartRequired>(),
          reason: '$code cannot accept another lifecycle step',
        );
      }
    });

    test('the resend cooldown is its own outcome with no invented wait', () {
      // The backend answers this `409` without a `Retry-After`, and the variant
      // carries no duration. It must not become a rate limit: there is no budget
      // to report and no server-stated time to count down from.
      final failure = mapApiFailure(
        badResponse(409, errorBody(ApiErrorCode.verificationResendCooldown)),
      );

      expect(failure, isA<ApiFailureVerificationResendCooldown>());
      expect(failure, isNot(isA<ApiFailureRateLimited>()));
      expect(failure, isNot(isA<ApiFailureRegistrationRetryable>()));
    });

    test('PIN budgets retain server-provided Retry-After', () {
      for (final code in [
        ApiErrorCode.pinRateLimitExceeded,
        ApiErrorCode.pinEmailBudgetExceeded,
      ]) {
        final failure = mapApiFailure(
          badResponse(
            429,
            errorBody(code),
            headers: {
              'retry-after': ['45'],
            },
          ),
        );

        expect(failure, isA<ApiFailureRateLimited>());
        final limited = failure as ApiFailureRateLimited;
        expect(limited.code, code);
        expect(limited.retryAfter, const Duration(seconds: 45));
      }
    });

    test(
      'unavailable PIN budgets remain server-unavailable without a wait',
      () {
        for (final code in [
          ApiErrorCode.pinRateLimitUnavailable,
          ApiErrorCode.pinEmailBudgetUnavailable,
        ]) {
          final failure = mapApiFailure(badResponse(503, errorBody(code)));

          expect(failure, isA<ApiFailureServerUnavailable>());
          expect((failure as ApiFailureServerUnavailable).code, code);
        }
      },
    );

    test('PIN email delivery failure is distinct and keeps its cooldown', () {
      final failure = mapApiFailure(
        badResponse(
          503,
          errorBody(ApiErrorCode.pinEmailDeliveryFailed),
          headers: {
            'retry-after': ['60'],
          },
        ),
      );

      expect(failure, isA<ApiFailurePinEmailDeliveryFailed>());
      expect(
        (failure as ApiFailurePinEmailDeliveryFailed).retryAfter,
        const Duration(seconds: 60),
      );
      expect(failure, isNot(isA<ApiFailureServerUnavailable>()));
    });

    test('REGISTRATION_ALREADY_PENDING is its own recovery refusal', () {
      // Emitted by POST /auth/register/recovery/manual while the normal
      // verification is still pending. The registration is alive and the normal
      // PIN flow is its continuation, so this is not a restart, not the
      // concurrent-insert retry, and not a completed account.
      final failure = mapApiFailure(
        badResponse(409, errorBody(ApiErrorCode.registrationAlreadyPending)),
      );

      expect(failure, isA<ApiFailureRegistrationAlreadyPending>());
      expect(failure, isNot(isA<ApiFailureRegistrationRestartRequired>()));
      expect(failure, isNot(isA<ApiFailureRegistrationRetryable>()));
      expect(failure, isNot(isA<ApiFailureRegistrationAlreadyCompleted>()));
      expect(
        (failure as ApiFailureRegistrationAlreadyPending).code,
        ApiErrorCode.registrationAlreadyPending,
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
