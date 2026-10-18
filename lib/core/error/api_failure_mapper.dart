import 'package:dio/dio.dart';

import 'api_error_body.dart';
import 'api_error_codes.dart';
import 'api_failure.dart';

/// Converts a [DioException] into an [ApiFailure].
///
/// The one place in the client that reads a failed HTTP response
/// (`AGENTS.md` §2, presentation boundaries). Everything above it selects on the
/// returned [ApiFailure]; nothing else inspects a status code or an
/// `error.code`.
///
/// Branching is on `error.code` only. `error.message` is human-facing prose and
/// is never displayed ([D22]); it is parsed so a malformed payload can be
/// *detected*, not shown.
ApiFailure mapApiFailure(DioException error) {
  // Already classified upstream. `SessionController` wraps an ambiguous renewal
  // this way because the outcome cannot be re-derived from a response — there
  // is no response — and re-deciding it here from the status would discard the
  // distinction between "the server refused" and "we do not know".
  final classified = error.error;
  if (classified is ApiFailure) return classified;

  final response = error.response;

  // No response object reached us.
  //
  // Two different things produce this shape, and they mean opposite things, so
  // they are separated by the cause rather than lumped together:
  //
  // - **A response arrived but could not be decoded.** Dio's transformer throws
  //   while parsing a body it declared as JSON, and the resulting exception
  //   carries no `response`. This is group F: known not saved, because a reply
  //   did arrive.
  // - **Nothing arrived.** A dropped connection or a timeout is groups G and H:
  //   uncertain, and the only category allowed to say so.
  //
  // Both look identical by shape, so the decoder failure is recognised by its
  // cause. Defaulting to "uncertain" would be the wrong answer in the first case,
  // because it tells the user their write may not have landed when the server
  // has already answered.
  if (response == null) {
    if (_isDecodeFailure(error)) {
      return const ApiFailureUnreadableResponse();
    }
    return const ApiFailureTransport();
  }

  final body = parseApiErrorBody(response.data);

  // A non-2xx with no readable code. Fiber's default handler answers
  // `text/plain` for any `*fiber.Error`, and a proxy or load balancer can answer
  // with HTML. **[D15] group F — known not saved, because a response arrived.**
  if (body == null || body.code == null || body.code!.isEmpty) {
    return ApiFailureUnreadableResponse(code: body?.code);
  }

  final code = body.code!;

  // Budgets first: a 429 and a 503 are decided by the code, never by the
  // status, because different codes share both.
  switch (code) {
    case ApiErrorCode.userRateLimitExceeded:
    case ApiErrorCode.ipRateLimitExceeded:
    case ApiErrorCode.loginRateLimitExceeded:
      return ApiFailureRateLimited(
        code: code,
        retryAfter: parseRetryAfter(response),
      );

    // `PASSWORD_WORK_UNAVAILABLE` is the one 503 that carries a `Retry-After`:
    // the wait is the bounded time the caller was already held for, so the
    // countdown is real rather than invented (`login/service.go:266`).
    case ApiErrorCode.passwordWorkUnavailable:
      return ApiFailureRateLimited(
        code: code,
        retryAfter: parseRetryAfter(response),
      );

    case ApiErrorCode.ipRateLimitUnavailable:
    case ApiErrorCode.loginRateLimitUnavailable:
    case ApiErrorCode.userRateLimitUnavailable:
    case ApiErrorCode.clientIpUnavailable:
    case ApiErrorCode.serviceUnavailable:
      return ApiFailureServerUnavailable(code: code);

    // A terminal refresh refusal. Only `POST /auth/refresh` can produce these,
    // and the backend has already committed the revocation before answering.
    case ApiErrorCode.refreshTokenInvalid:
    case ApiErrorCode.sessionRevoked:
    case ApiErrorCode.sessionExpired:
      return ApiFailureSessionEnded(code: code);

    // The three bearer-guard codes. Grouped because the interceptor has already
    // acted on the only actionable one by the time this runs.
    case ApiErrorCode.invalidAuthorizationHeader:
    case ApiErrorCode.invalidAccessToken:
    case ApiErrorCode.accessTokenExpired:
      return ApiFailureAuthRequired(code: code);

    case ApiErrorCode.invalidCredentials:
      return const ApiFailureAuthRequired(
        code: ApiErrorCode.invalidCredentials,
      );

    case ApiErrorCode.validationError:
      return ApiFailureValidation(body.fields);

    case ApiErrorCode.badRequest:
      return const ApiFailureMalformedRequest();

    case ApiErrorCode.internalServerError:
      return const ApiFailureServerFault();
  }

  // A code this client does not recognise. It is not a guess at one it does:
  // unmapped is handled defensively and gets client-owned copy, exactly as
  // **[Confirmed]** `decisions.md` D15 requires of anything outside the verified
  // table.
  return ApiFailureUnreadableResponse(code: code);
}

/// Whether a response arrived but could not be decoded.
///
/// Dio's `FusedTransformer` runs `jsonDecode` on a body it was told was JSON,
/// and a `FormatException` from that escapes as a `DioException` with no
/// `response` attached — structurally identical to a dropped connection. The
/// cause is the only thing that distinguishes them.
/// Converts a body that arrived but could not be decoded into an [ApiFailure].
///
/// **[D15] group F. Known not saved** — a reply did arrive, so the outcome is
/// determinate. There is no `DioException` to pass to [mapApiFailure] in this
/// case: Retrofit decodes the body *after* Dio's transformer returns it, so a
/// shape mismatch surfaces as a `TypeError` from the generated `fromJson` and
/// never passes through Dio at all.
///
/// Without this, a body the client does not understand would escape as a raw
/// `TypeError` and reach presentation unclassified, bypassing the taxonomy that
/// exists precisely so nothing above the mapper inspects a failure's shape.
///
/// The backend's body is never surfaced, only its arrival.
ApiFailure mapDecodeFailure(Object error) {
  if (error is ApiFailure) return error;
  return const ApiFailureUnreadableResponse();
}

/// Whether a response arrived but could not be decoded.
///
/// Dio's `FusedTransformer` runs `jsonDecode` on a body it was told was JSON,
/// and a `FormatException` from that escapes as a `DioException` with no
/// `response` attached — structurally identical to a dropped connection. The
/// cause is the only thing that distinguishes them.
bool _isDecodeFailure(DioException error) {
  final cause = error.error;

  if (cause is FormatException) return true;

  // A cast of `null` to a non-nullable type is what a shape mismatch looks like
  // from inside the transformer, and it means a response arrived and could not
  // be understood — group F, not a transport failure.
  if (cause is TypeError) {
    final message = cause.toString();
    return message.contains('is not a subtype of') ||
        message.contains('Null is not a subtype');
  }

  return false;
}

/// Decodes an error body, or returns null when it is not one.
///
/// Tolerant by necessity. `response.data` is `dynamic` and may be a `String`
/// (Fiber's `text/plain` default handler), an HTML page from something in front
/// of the API, or `null`. None of those is an error this client can read, and
/// none of them may be rendered.
ApiErrorBody? parseApiErrorBody(Object? data) {
  if (data is! Map) return null;

  final error = data['error'];
  if (error is! Map) return null;

  final code = error['code'];
  final message = error['message'];

  // `fields` is `[]` rather than absent on every coded error, but a proxy's
  // payload need not honour that, so it is read defensively too.
  final fields = <ApiErrorField>[];
  final rawFields = error['fields'];
  if (rawFields is List) {
    for (final field in rawFields) {
      if (field is! Map) continue;
      final name = field['field'];
      final fieldMessage = field['message'];
      fields.add(
        ApiErrorField(
          field: name is String ? name : '',
          message: fieldMessage is String ? fieldMessage : '',
        ),
      );
    }
  }

  return ApiErrorBody(
    code: code is String ? code : null,
    message: message is String ? message : null,
    fields: fields,
  );
}

/// Reads the `Retry-After` header, if the server sent one.
///
/// The value is integer seconds, written by `httpx.NewErrorHandler` from the
/// limiter's remaining TTL and rounded up, so it is a real "not before" moment
/// rather than a configured window.
///
/// Returns null when the header is absent, unparseable, or not a whole number of
/// seconds. A malformed header yields no countdown: fabricating one would be a
/// guess presented as a fact.
Duration? parseRetryAfter(Response<dynamic> response) {
  final raw = response.headers.value('retry-after');
  if (raw == null) return null;

  final seconds = int.tryParse(raw.trim());
  if (seconds == null || seconds < 0) return null;

  return Duration(seconds: seconds);
}
