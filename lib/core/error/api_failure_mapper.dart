import 'package:dio/dio.dart';

import 'api_error_body.dart';
import 'api_error_codes.dart';
import 'api_failure.dart';

/// Converts a [DioException] into an [ApiFailure].
///
/// This is the only place that interprets failed HTTP responses. All other
/// layers select behavior from the resulting [ApiFailure], not from status
/// codes or raw API error codes.
///
/// Classification uses `error.code`, never the backend's human-readable
/// message. The message is parsed only as part of decoding the response.
ApiFailure mapApiFailure(DioException error) {
  // Preserve failures already classified upstream. An ambiguous refresh
  // outcome, for example, cannot be reclassified from a response that does
  // not exist. Reinterpreting it here could turn an unknown outcome into a
  // definite authentication refusal.
  final classified = error.error;
  if (classified is ApiFailure) return classified;

  final response = error.response;

  // A missing response can mean either that a response arrived but could not
  // be decoded, or that no response arrived at all.
  //
  // A decoding failure is a known outcome: the server replied, so the request
  // is not uncertain. A transport failure or timeout is uncertain because
  // the client cannot determine whether the server processed the request.
  if (response == null) {
    if (_isDecodeFailure(error)) {
      return const ApiFailureUnreadableResponse();
    }
    return const ApiFailureTransport();
  }

  final body = parseApiErrorBody(response.data);

  // A response arrived, but it does not contain a readable error code.
  // This includes plain-text framework errors and HTML responses from
  // proxies or load balancers. The outcome is known, but its meaning is not.
  if (body == null || body.code == null || body.code!.isEmpty) {
    return ApiFailureUnreadableResponse(code: body?.code);
  }

  final code = body.code!;

  // Rate limits and temporary capacity restrictions are identified by code,
  // not HTTP status. Different failures can share the same status.
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

    // Password verification capacity is temporarily exhausted. Its
    // Retry-After value represents the actual remaining wait.
    case ApiErrorCode.passwordWorkUnavailable:
      return ApiFailureRateLimited(
        code: code,
        retryAfter: parseRetryAfter(response),
      );

    // The verification code was persisted, but email delivery failed.
    // Retry-After carries the actual resend cooldown.
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

    // These refresh failures mean the session has ended. They are returned
    // only after the server has committed the corresponding session state.
    case ApiErrorCode.refreshTokenInvalid:
    case ApiErrorCode.sessionRevoked:
    case ApiErrorCode.sessionExpired:
      return ApiFailureSessionEnded(code: code);

    // Bearer-token failures. The interceptor has already attempted the
    // refresh flow when the error code allows it.
    case ApiErrorCode.invalidAuthorizationHeader:
    case ApiErrorCode.invalidAccessToken:
    case ApiErrorCode.accessTokenExpired:
      return ApiFailureAuthRequired(code: code);

    case ApiErrorCode.invalidCredentials:
      return const ApiFailureAuthRequired(
        code: ApiErrorCode.invalidCredentials,
      );

    // Registration lifecycle failures have different recovery actions.
    // Keep them as distinct variants rather than inferring behavior from
    // their shared HTTP status.
    case ApiErrorCode.registrationAlreadyCompleted:
      return ApiFailureRegistrationAlreadyCompleted(code: code);

    // Registration is still pending. Continue the normal verification
    // flow instead of attempting to start a separate recovery flow.
    case ApiErrorCode.registrationAlreadyPending:
      return ApiFailureRegistrationAlreadyPending(code: code);

    // Another concurrent request created the registration or verification
    // record first. Retrying the same request is a valid correction.
    case ApiErrorCode.registrationAlreadyExists:
    case ApiErrorCode.activeVerificationCodeExists:
      return ApiFailureRegistrationRetryable(code: code);

    // The registration lifecycle has ended. A new registration is required.
    case ApiErrorCode.verificationNotPending:
    case ApiErrorCode.registrationNotPending:
    case ApiErrorCode.registrationExpired:
      return ApiFailureRegistrationRestartRequired(code: code);

    // The server does not provide a wait duration for this refusal.
    // Do not infer a countdown from another source.
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

    case ApiErrorCode.registrationIdentityMismatch:
      return ApiFailureRegistrationIdentityMismatch(code: code);

    // Google authentication failures have distinct recovery paths.
    // An invalid token can be retried with a fresh token, while a committed
    // account link with a failed session requires a fresh Google login.
    case ApiErrorCode.invalidGoogleToken:
      return ApiFailureInvalidGoogleToken(code: code);

    case ApiErrorCode.accountLinkConfirmationInvalid:
      return ApiFailureAccountLinkConfirmationInvalid(code: code);

    case ApiErrorCode.accountLinkIdentityMismatch:
      return ApiFailureAccountLinkIdentityMismatch(code: code);

    case ApiErrorCode.accountLinkSessionFailed:
      return ApiFailureAccountLinkSessionFailed(code: code);

    // Password-reset failures are separate from registration and bearer
    // authentication failures because they belong to a different flow.
    // In particular, a missing continuation header is not a session error.
    case ApiErrorCode.passwordResetAlreadyPending:
      return ApiFailurePasswordResetAlreadyPending(code: code);

    case ApiErrorCode.passwordResetNotPending:
      return ApiFailurePasswordResetNotPending(code: code);

    case ApiErrorCode.passwordResetExpired:
      return ApiFailurePasswordResetExpired(code: code);

    case ApiErrorCode.passwordResetContinuationConsumed:
      return ApiFailurePasswordResetContinuationConsumed(code: code);

    case ApiErrorCode.passwordResetContinuationRequired:
      return ApiFailurePasswordResetContinuationRequired(code: code);

    case ApiErrorCode.passwordResetContinuationExpired:
      return ApiFailurePasswordResetContinuationExpired(code: code);

    case ApiErrorCode.userAlreadyExists:
    case ApiErrorCode.authIdentityAlreadyExists:
      return ApiFailureRegistrationAlreadyCompleted(code: code);

    case ApiErrorCode.validationError:
      return ApiFailureValidation(body.fields);

    // These errors describe correctable input that passed basic request
    // parsing but failed a more specific validation rule.
    case ApiErrorCode.invalidUrl:
    case ApiErrorCode.invalidSearchQuery:
    case ApiErrorCode.invalidCollectionName:
      return ApiFailureValidation(body.fields);

    // These codes indicate a malformed request rather than a user-correctable
    // field error. The client should not infer a collection action or target.
    case ApiErrorCode.badRequest:
    case ApiErrorCode.invalidCollectionIntent:
    case ApiErrorCode.invalidCollectionDeleteAction:
    case ApiErrorCode.invalidCollectionDeleteTarget:
      return const ApiFailureMalformedRequest();

    // Only explicit resource codes produce a not-found failure. A bare 404
    // without a readable code remains an unreadable response.
    case ApiErrorCode.resourceNotFound:
    case ApiErrorCode.savedItemNotFound:
    case ApiErrorCode.collectionNotFound:
      return ApiFailureNotFound(code: code);

    // The account behind a valid access token no longer exists. This is
    // distinct from a missing resource and must not be treated as session
    // expiry.
    case ApiErrorCode.userNotFound:
      return ApiFailureUserNotFound(code: code);

    // A wrong current password does not indicate a bearer-token failure.
    // The access token was accepted, so this must not trigger a refresh.
    case ApiErrorCode.currentPasswordInvalid:
      return ApiFailureCurrentPasswordInvalid(code: code);

    // These indicate that the form was submitted for the wrong credential
    // state: a current password is required, or one should not be supplied.
    case ApiErrorCode.currentPasswordRequired:
      return ApiFailureCurrentPasswordRequired(code: code);

    case ApiErrorCode.unexpectedCurrentPassword:
      return ApiFailureUnexpectedCurrentPassword(code: code);

    // Concurrent credential changes. The current request did not perform
    // the requested write.
    case ApiErrorCode.passwordCredentialAlreadyExists:
      return ApiFailurePasswordCredentialAlreadyExists(code: code);

    case ApiErrorCode.passwordAlreadyChanged:
      return ApiFailurePasswordAlreadyChanged(code: code);

    // The requested destination collection is missing or inaccessible.
    // The source collection remains unchanged, so the user can choose
    // another destination.
    case ApiErrorCode.collectionDeleteTargetNotFound:
      return ApiFailureCollectionDeleteTargetNotFound(code: code);

    // The requested collection name is already in use.
    case ApiErrorCode.collectionNameAlreadyExists:
      return ApiFailureCollectionNameAlreadyExists(code: code);

    // These collection deletion failures leave the collection unchanged.
    case ApiErrorCode.collectionNotEmpty:
      return ApiFailureCollectionNotEmpty(code: code);

    case ApiErrorCode.unsortedCollectionProtected:
      return ApiFailureUnsortedCollectionProtected(code: code);

    case ApiErrorCode.internalServerError:
      return const ApiFailureServerFault();
  }

  // Unknown codes must not be assigned a meaning based on their status or
  // resemblance to a known code. Presentation handles this with client-owned
  // fallback copy.
  return ApiFailureUnreadableResponse(code: code);
}

/// Converts a response-body decoding failure into an [ApiFailure].
///
/// Retrofit can fail while converting a successfully received response into
/// a typed model. Such failures occur after Dio returns and therefore do not
/// pass through [mapApiFailure]. The response arrived, but the client could
/// not understand its shape, so the outcome is known rather than uncertain.
///
/// The response body itself is never exposed to presentation.
ApiFailure mapDecodeFailure(Object error) {
  if (error is ApiFailure) return error;
  return const ApiFailureUnreadableResponse();
}

/// Detects whether Dio failed while decoding a response body.
///
/// A [FormatException] from JSON decoding, or a [TypeError] caused by an
/// incompatible response shape, indicates that a response arrived but could
/// not be decoded. This distinguishes it from a transport failure, which has
/// no response because nothing was received.
bool _isDecodeFailure(DioException error) {
  final cause = error.error;

  if (cause is FormatException) return true;

  // A null value cast to a non-nullable type is one way a response-shape
  // mismatch can surface from the transformer.
  if (cause is TypeError) {
    final message = cause.toString();
    return message.contains('is not a subtype of') ||
        message.contains('Null is not a subtype');
  }

  return false;
}

/// Decodes an API error body, or returns null when the response is not
/// a readable API error envelope.
///
/// The response may contain plain text, HTML, null, or another unexpected
/// shape. These responses cannot be interpreted as API errors and must not
/// be exposed directly to presentation.
ApiErrorBody? parseApiErrorBody(Object? data) {
  if (data is! Map) return null;

  final error = data['error'];
  if (error is! Map) return null;

  final code = error['code'];
  final message = error['message'];

  // Coded API errors normally include a fields array. Read it defensively
  // because responses from intermediaries may not follow that contract.
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

/// Reads the `Retry-After` header when it contains a valid duration in seconds.
///
/// The server sends the remaining wait as an integer number of seconds.
/// Returns null when the header is absent, malformed, or negative rather
/// than inventing a countdown.
Duration? parseRetryAfter(Response<dynamic> response) {
  final raw = response.headers.value('retry-after');
  if (raw == null) return null;

  final seconds = int.tryParse(raw.trim());
  if (seconds == null || seconds < 0) return null;

  return Duration(seconds: seconds);
}
