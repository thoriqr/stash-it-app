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
    case ApiErrorCode.pinRateLimitExceeded:
    case ApiErrorCode.pinEmailBudgetExceeded:
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

    // The code was persisted before delivery was attempted. Its Retry-After is
    // the actual resend cooldown, so it must not be collapsed into a generic
    // unavailable service which has no known recovery time.
    case ApiErrorCode.pinEmailDeliveryFailed:
      return ApiFailurePinEmailDeliveryFailed(
        retryAfter: parseRetryAfter(response),
      );

    case ApiErrorCode.ipRateLimitUnavailable:
    case ApiErrorCode.loginRateLimitUnavailable:
    case ApiErrorCode.userRateLimitUnavailable:
    case ApiErrorCode.pinRateLimitUnavailable:
    case ApiErrorCode.pinEmailBudgetUnavailable:
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

    // Registration lifecycle refusals. They share a `409`, but each has a
    // different correction, so they are mapped to typed variants rather than one
    // conflict type. Branching on the code here is the only place it happens;
    // presentation selects on the variant. They are deliberately not inferred
    // from `409` alone: an unknown conflict stays unreadable so a future backend
    // code cannot silently select this flow.
    case ApiErrorCode.registrationAlreadyCompleted:
      return ApiFailureRegistrationAlreadyCompleted(code: code);

    // Recovery was asked to start while the normal verification is still
    // pending. It is not a restart — the registration is alive and the normal
    // PIN flow is its continuation. It is also not the concurrent-insert
    // variant: the correction is to re-enter `/register/manual` with the same
    // email, not to repeat the recovery call.
    case ApiErrorCode.registrationAlreadyPending:
      return ApiFailureRegistrationAlreadyPending(code: code);

    // A concurrent request won the insert, and the other request's row is what
    // remains. The request is well formed and the address need not change:
    // retrying is the correction.
    case ApiErrorCode.registrationAlreadyExists:
    case ApiErrorCode.activeVerificationCodeExists:
      return ApiFailureRegistrationRetryable(code: code);

    // The lifecycle is over. Repeating the same request cannot succeed; the flow
    // has to start a new registration.
    case ApiErrorCode.verificationNotPending:
    case ApiErrorCode.registrationNotPending:
    case ApiErrorCode.registrationExpired:
      return ApiFailureRegistrationRestartRequired(code: code);

    // A code was sent too recently. The server states no wait for this `409`, so
    // none is carried and `parseRetryAfter` is deliberately not called: a
    // duration taken from anywhere else would be invented.
    case ApiErrorCode.verificationResendCooldown:
      return ApiFailureVerificationResendCooldown(code: code);

    case ApiErrorCode.invalidVerificationCode:
      return ApiFailureInvalidVerificationCode(code: code);

    case ApiErrorCode.verificationCodeAttemptsExceeded:
      return ApiFailureVerificationCodeAttemptsExceeded(code: code);

    case ApiErrorCode.registrationContinuationRequired:
      return ApiFailureRegistrationContinuationRequired(code: code);

    case ApiErrorCode.registrationContinuationConsumed:
      return ApiFailureRegistrationContinuationConsumed(code: code);

    case ApiErrorCode.registrationContinuationExpired:
      return ApiFailureRegistrationContinuationExpired(code: code);

    case ApiErrorCode.invalidRegistrationType:
      return ApiFailureInvalidRegistrationType(code: code);

    case ApiErrorCode.userAlreadyExists:
    case ApiErrorCode.authIdentityAlreadyExists:
      return ApiFailureRegistrationAlreadyCompleted(code: code);

    case ApiErrorCode.validationError:
      return ApiFailureValidation(body.fields);

    // A `400` raised after the body passed validation: the URL is well formed
    // JSON and still not a usable address. It means exactly what
    // `VALIDATION_ERROR` means to a caller — the input has to change — and the
    // user's action is the same, so it is the same variant rather than a second
    // one with identical copy.
    case ApiErrorCode.invalidUrl:
    // Search's own query rule. Same reasoning: a correctable input, not an
    // unreadable reply.
    case ApiErrorCode.invalidSearchQuery:
    // The move endpoint's collection-name rule. Same reasoning again: the name
    // is well formed JSON and still outside its documented bounds.
    case ApiErrorCode.invalidCollectionName:
      return ApiFailureValidation(body.fields);

    // The body could not be parsed at all, or parsed without stating which
    // operation the move endpoint should run. Both are client defects with no
    // user-correctable field, so they share the standard malformed-request
    // handling. `INVALID_COLLECTION_INTENT` in particular must not fall through
    // to a duplicate-name conflict. The two collection-delete shape codes are
    // the same kind of defect: a well-formed client always sends `delete` with a
    // null target, so reaching either means this client sent an incoherent body.
    case ApiErrorCode.badRequest:
    case ApiErrorCode.invalidCollectionIntent:
    case ApiErrorCode.invalidCollectionDeleteAction:
    case ApiErrorCode.invalidCollectionDeleteTarget:
      return const ApiFailureMalformedRequest();

    // The resource named by the request is gone, or is not this caller's. Only
    // these verified codes produce the variant: a bare 404 without a readable
    // code stays an unreadable response.
    //
    // `COLLECTION_NOT_FOUND` is the collection read's own code. Without this arm
    // it would fall through to the unreadable bucket, and a collection that is
    // gone would be reported as a reply this client could not read — which is
    // both false and offers a retry that cannot succeed.
    case ApiErrorCode.resourceNotFound:
    case ApiErrorCode.savedItemNotFound:
    case ApiErrorCode.collectionNotFound:
      return ApiFailureNotFound(code: code);

    // The **account** behind a valid access token is gone. Kept apart from
    // `ApiFailureNotFound` because the account is not the resource a screen is
    // showing, and because it must not be read as a session expiry.
    case ApiErrorCode.userNotFound:
      return ApiFailureUserNotFound(code: code);

    // A wrong *current password* is a 401, but it is not a bearer-guard refusal
    // and never authorises a refresh: the access token was accepted. Mapping it
    // to `ApiFailureAuthRequired` would tell the user to sign in again for a
    // problem signing in cannot fix.
    case ApiErrorCode.currentPasswordInvalid:
      return ApiFailureCurrentPasswordInvalid(code: code);

    // The two directions of a credential-state mismatch. Both are known
    // not-written refusals, and both mean the form was rendered for the wrong
    // mode rather than that the input needs correcting field by field.
    case ApiErrorCode.currentPasswordRequired:
      return ApiFailureCurrentPasswordRequired(code: code);

    case ApiErrorCode.unexpectedCurrentPassword:
      return ApiFailureUnexpectedCurrentPassword(code: code);

    // Two concurrent-writer outcomes. Both wrote nothing: the create lost to an
    // existing primary key, and the change's conditional update matched no row.
    case ApiErrorCode.passwordCredentialAlreadyExists:
      return ApiFailurePasswordCredentialAlreadyExists(code: code);

    case ApiErrorCode.passwordAlreadyChanged:
      return ApiFailurePasswordAlreadyChanged(code: code);

    // The `move` action's destination is gone or is not this caller's. It is
    // not the collection being deleted, so it must not become
    // `ApiFailureNotFound`: the source is still there and the user can choose
    // another destination.
    case ApiErrorCode.collectionDeleteTargetNotFound:
      return ApiFailureCollectionDeleteTargetNotFound(code: code);

    // A `create` request whose name is already held by one of the user's
    // collections. Well formed, but not available as a new name: the user has to
    // choose another one. The backend wrote nothing.
    case ApiErrorCode.collectionNameAlreadyExists:
      return ApiFailureCollectionNameAlreadyExists(code: code);

    // A collection delete that found a concurrent insert, or named the protected
    // Unsorted collection. Both transactions wrote nothing, so both are known
    // not-deleted outcomes with different user-facing explanations.
    case ApiErrorCode.collectionNotEmpty:
      return ApiFailureCollectionNotEmpty(code: code);

    case ApiErrorCode.unsortedCollectionProtected:
      return ApiFailureUnsortedCollectionProtected(code: code);

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
