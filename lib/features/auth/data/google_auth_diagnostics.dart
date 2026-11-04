import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Writes one diagnostic line for a Google authentication stage.
///
/// Callers pass stage names, outcomes, and non-credential detail only.
/// Authorization codes, tokens, PKCE values, request bodies, and headers must
/// never be passed here.
void logGoogleAuthStage(
  String stage, {
  String? outcome,
  String? detail,
  bool failure = false,
  StackTrace? stackTrace,
}) {
  final message = StringBuffer('stage=$stage');
  if (outcome != null) message.write(' outcome=$outcome');
  if (detail != null && detail.isNotEmpty) message.write(' $detail');

  developer.log(
    message.toString(),
    name: 'stash_it.google_auth',
    level: failure ? 1000 : 800,
    stackTrace: stackTrace,
  );
  debugPrint(message.toString());
}

/// Describes a failed Google token exchange without exposing credentials.
///
/// Only the Dio failure type, HTTP status, and Google's OAuth error fields are
/// returned. Any supplied secret occurring in the description is redacted
/// before the value reaches a log sink.
String googleTokenExchangeFailureDetail(
  DioException error, {
  required Iterable<String> secrets,
}) {
  final parts = <String>['type=${error.type.name}'];

  final status = error.response?.statusCode;
  if (status != null) parts.add('status=$status');

  final oauthError = googleOAuthErrorCode(error);
  if (oauthError != null && oauthError.isNotEmpty) {
    parts.add('google_error=${redactGoogleAuthDetail(oauthError, secrets)}');
  }

  final description = googleOAuthErrorDescription(error);
  if (description != null && description.isNotEmpty) {
    parts.add(
      'google_description=${redactGoogleAuthDetail(description, secrets)}',
    );
  }

  return parts.join(' ');
}

/// Google's OAuth error code from a token-endpoint response, when present.
String? googleOAuthErrorCode(DioException error) =>
    _stringField(error.response?.data, 'error');

/// Google's OAuth error description from a token-endpoint response.
String? googleOAuthErrorDescription(DioException error) =>
    _stringField(error.response?.data, 'error_description');

/// Replaces credential values that could occur inside a diagnostic string.
String redactGoogleAuthDetail(String value, Iterable<String> secrets) {
  var redacted = value;
  for (final secret in secrets) {
    if (secret.isEmpty) continue;
    redacted = redacted.replaceAll(secret, '[redacted]');
  }
  return redacted;
}

String? _stringField(Object? data, String key) {
  if (data is! Map) return null;
  final value = data[key];
  return value is String ? value : null;
}
