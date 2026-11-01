import 'dart:async';

import 'package:dio/dio.dart';

import '../error/api_failure.dart';
import '../error/api_failure_mapper.dart';
import 'token_provider.dart';

/// Attaches the bearer token and renews the session at most once when a
/// protected request reports an expired access token.
///
/// The refresh decision is based on the API error code, never the HTTP status.
/// Several authentication failures can use the same status, but only an
/// expired access token can be resolved by refreshing:
///
/// | Code                            | Meaning                         | Refresh? |
/// | ------------------------------- | ------------------------------- | -------- |
/// | `ACCESS_TOKEN_EXPIRED`          | The access token has expired    | Yes      |
/// | `INVALID_ACCESS_TOKEN`          | The access token is invalid     | No       |
/// | `INVALID_AUTHORIZATION_HEADER`  | No usable authorization sent    | No       |
///
/// Refreshing for the latter two cannot succeed, and an unnecessary refresh
/// attempt is not free: a lost or duplicated refresh can invalidate the
/// session.
///
/// A request is marked in `RequestOptions.extra` after its first replay.
/// Without this marker, a request that receives `ACCESS_TOKEN_EXPIRED` again
/// could trigger another refresh. The marker makes subsequent attempts pass
/// through without refreshing, preventing retry loops.
///
/// Renewal is issued through [TokenProvider], which uses a separate Dio client
/// without this interceptor. A refresh response therefore cannot re-enter
/// this interceptor, making recursive renewal structurally impossible.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({required this.dio, required this.tokenProvider});

  /// Dio instance used to replay requests.
  ///
  /// Reusing the same instance preserves its interceptors, adapter, and
  /// timeouts. [Dio.fetch] replays the existing [RequestOptions], preserving
  /// the original method, headers, query parameters, body, [CancelToken],
  /// and content type without reconstructing the request.
  final Dio dio;

  /// Supplies the bearer token and performs session renewal.
  ///
  /// Using the interface keeps this interceptor independent of the auth
  /// feature and allows it to be tested with a stub. Holding the instance
  /// directly also makes provider dependency cycles detectable when the
  /// interceptor is constructed, rather than when the first request runs.
  final TokenProvider tokenProvider;

  /// Marks a request that has already been replayed after token renewal.
  static const String retriedKey = 'auth_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Read the token for every request instead of caching it. A cached token
    // could remain outdated for requests issued while a renewal is in flight.
    //
    // A failed storage read does not prevent the request from proceeding.
    // It is sent without authentication so the server can return the
    // appropriate authentication error.
    //
    // The error callback is explicit because Future.then passes both the error
    // and stack trace, while handler.next accepts only RequestOptions.
    unawaited(
      tokenProvider.readAccessToken().then<void>((token) {
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      }, onError: (Object _) => handler.next(options)),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Not every error response contains a readable API error envelope.
    // An unreadable body cannot be used as a signal to refresh.
    final body = parseApiErrorBody(err.response?.data);
    if (body == null || !body.isAccessTokenExpired) {
      handler.next(err);
      return;
    }

    // Do not refresh or replay a request more than once.
    if (err.requestOptions.extra[retriedKey] == true) {
      handler.next(err);
      return;
    }

    unawaited(_renewAndReplay(err, handler));
  }

  /// Renews the session and replays the original request exactly once.
  ///
  /// Every execution path must complete [handler] exactly once. If it is
  /// never completed, Dio's pending request remains unresolved. Completing it
  /// more than once also causes an error.
  ///
  /// Renewal can fail in several ways, not only through [DioException] or
  /// [SessionExpiredException]. Credential storage and platform-channel
  /// operations can also throw. Because this method is called through an
  /// unawaited future, every failure must be caught and forwarded to the
  /// original request instead of escaping and leaving it pending.
  Future<void> _renewAndReplay(
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    late final String accessToken;
    try {
      accessToken = await tokenProvider.refreshAccessToken();
    } on SessionExpiredException {
      // The session has ended. The provider has already cleared the
      // credentials and updated the authentication state.
      // Preserve the original error so the caller receives the original 401.
      handler.next(original);
      return;
    } on DioException catch (error) {
      // A transport or server failure does not necessarily mean the session
      // has ended. Keep the stored credentials and report the renewal failure
      // instead of signing the user out over a temporary network problem.
      handler.reject(
        _renewalFailure(
          original,
          mapApiFailure(error),
          response: error.response,
        ),
      );
      return;
    } on ApiFailure catch (failure) {
      // Preserve failures already classified by the API error layer.
      handler.reject(_renewalFailure(original, failure));
      return;
    } catch (error) {
      // Handle unexpected local failures, such as credential storage or
      // platform-channel errors. They do not establish that the session ended,
      // so leave the stored credentials untouched and do not replay the request.
      handler.reject(
        _renewalFailure(original, ApiFailureCredentialStorage(cause: error)),
      );
      return;
    }

    try {
      handler.resolve(await _replay(original.requestOptions, accessToken));
    } on DioException catch (error) {
      // The request has already been replayed once. Do not attempt another
      // refresh if the replay also fails.
      handler.next(error);
    } catch (error) {
      // Handle unexpected replay failures as well. The original request must
      // still be completed even when the failure is not represented by Dio.
      handler.reject(
        _renewalFailure(original, ApiFailureCredentialStorage(cause: error)),
      );
    }
  }

  /// Creates the error reported when session renewal fails.
  ///
  /// The failure is passed in from the renewal path rather than derived again
  /// from the original request. The renewal outcome is already known, and
  /// there may be no response available from which to determine it.
  ///
  /// When available, [response] preserves the renewal response so callers
  /// inspecting the error can still access its body.
  DioException _renewalFailure(
    DioException original,
    ApiFailure failure, {
    Response<dynamic>? response,
  }) {
    return DioException(
      requestOptions: original.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: failure,
    );
  }

  Future<Response<dynamic>> _replay(
    RequestOptions request,
    String accessToken,
  ) {
    // Copy the request options so the original remains unchanged for error
    // reporting. The retry marker is carried in `extra` and prevents another
    // refresh if this replay also receives an expired-token response.
    final replayOptions = RequestOptions(
      path: request.path,
      baseUrl: request.baseUrl,
      method: request.method,
      headers: Map<String, dynamic>.from(request.headers)
        ..['Authorization'] = 'Bearer $accessToken',
      extra: Map<String, dynamic>.from(request.extra)..[retriedKey] = true,
      data: request.data,
      queryParameters: Map<String, dynamic>.from(request.queryParameters),
      contentType: request.contentType,
      responseType: request.responseType,
      cancelToken: request.cancelToken,
      sendTimeout: request.sendTimeout,
      receiveTimeout: request.receiveTimeout,
      followRedirects: request.followRedirects,
      validateStatus: request.validateStatus,
      receiveDataWhenStatusError: request.receiveDataWhenStatusError,
      onSendProgress: request.onSendProgress,
      onReceiveProgress: request.onReceiveProgress,
    );

    return dio.fetch<dynamic>(replayOptions);
  }
}
