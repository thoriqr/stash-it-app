import 'dart:async';

import 'package:dio/dio.dart';

import '../error/api_failure.dart';
import '../error/api_failure_mapper.dart';
import 'token_provider.dart';

/// Attaches the bearer token, and renews the session at most once when a
/// protected request reports an expired access token.
///
/// ## Why the refresh decision is made here and nowhere else
///
/// The trigger is the error **code** `ACCESS_TOKEN_EXPIRED`, never the HTTP
/// status. All three bearer-guard refusals are `401`
/// (`internal/middleware/auth.go`), so status alone cannot tell them apart, and
/// the two non-expiry ones cannot be fixed by renewing:
///
/// | Code                        | Meaning                    | Refresh? |
/// | --------------------------- | -------------------------- | -------- |
/// | `ACCESS_TOKEN_EXPIRED`      | signed, 15 min elapsed     | **yes**  |
/// | `INVALID_ACCESS_TOKEN`      | signed wrong, wrong alg    | no       |
/// | `INVALID_AUTHORIZATION_HEADER` | no usable token sent    | no       |
///
/// Renewing for the latter two cannot succeed, and the attempt itself is not
/// free — a lost or duplicated refresh can cost the session outright. This is
/// the client half of `decisions.md` D15 group A.
///
/// ## Why at most one retry
///
/// A retried request is marked in `RequestOptions.extra`, not re-derived from
/// its status. Without the marker, a request that legitimately receives
/// `ACCESS_TOKEN_EXPIRED` twice would renew twice and retry twice. The marker
/// makes the second pass a pass-through, so no input can produce a loop.
///
/// ## Why renewal cannot recurse
///
/// Renewal is issued by [TokenProvider], which reaches the backend through
/// `refreshDio` — an instance without this interceptor. A refresh response can
/// never re-enter this code. No path comparison or flag is needed to guarantee
/// it, and adding one would only create a second thing to keep in step.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({required this.dio, required this.tokenProvider});

  /// The instance a retry is issued through.
  ///
  /// Reusing the same [Dio] rather than reconstructing one is what makes the
  /// replay identical to the original: same interceptors, same adapter, same
  /// timeouts. `Dio.fetch` is used instead of `Dio.request` so the existing
  /// [RequestOptions] is replayed as-is — method, headers, query, body,
  /// [CancelToken] and content type all survive, which a path-and-payload
  /// reconstruction would quietly drop.
  final Dio dio;

  /// Supplies the bearer token and performs renewal.
  ///
  /// Held as an instance rather than a lookup callback so that a dependency
  /// cycle in the caller's provider graph surfaces when the interceptor is
  /// constructed, not as an unexplained transport failure on the first request.
  ///
  /// Typed as the interface, so this file never imports the auth feature and the
  /// interceptor is testable with a stub.
  final TokenProvider tokenProvider;

  /// Marks a request that has already been replayed with a renewed token.
  static const String retriedKey = 'auth_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Resolved per request rather than cached. A token read once would still be
    // the pre-refresh value on every request issued while a renewal is in
    // flight, so a screen opened immediately after sign-in would 401 and pay
    // for a needless round trip.
    //
    // A failed read (an unreachable secure store, say) does not fail the
    // request: it goes out unauthenticated and the bearer guard answers with its
    // own refusal, which is the honest outcome. `handler.next` cannot be passed
    // straight to `then` as the error callback, because `Future.then` invokes it
    // with `(Object, StackTrace)` and `next` takes a single `RequestOptions`.
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
    // The envelope is not guaranteed: Fiber answers `text/plain` for a
    // `*fiber.Error`, and anything in front of the API may answer with HTML.
    // An unreadable body is never a refresh signal — there is no code to match.
    final body = parseApiErrorBody(err.response?.data);
    if (body == null || !body.isAccessTokenExpired) {
      handler.next(err);
      return;
    }

    // Already replayed once for this request. Passing through here is what
    // bounds the retry at one regardless of how the server answers.
    if (err.requestOptions.extra[retriedKey] == true) {
      handler.next(err);
      return;
    }

    unawaited(_renewAndReplay(err, handler));
  }

  /// Renews, then replays the original request exactly once.
  ///
  /// ## Why every arm completes `handler`
  ///
  /// An [ErrorInterceptorHandler] that is never completed leaves Dio's internal
  /// completer pending, so the caller's `await` never returns: the request
  /// hangs rather than fails, and there is no error to report. Completion is
  /// not idempotent either — Dio throws `StateError` on a second call — so
  /// both "never" and "twice" are defects.
  ///
  /// Hence the arms below are exhaustive **and** mutually exclusive: each
  /// completes `handler` and returns, so whichever way this method exits, the
  /// original request is completed once. "Exhaustive" is the part that is easy
  /// to get wrong, because [SessionExpiredException] and [DioException] are
  /// not the only things a renewal can throw:
  ///
  /// - [ApiFailureCredentialStorage], when the rotated pair cannot be written.
  /// - a platform-channel error reading the refresh token, before any request.
  /// - a storage error clearing credentials on a terminal outcome.
  ///
  /// Each of those previously escaped this `unawaited` future and hung the
  /// request. A bare `catch` is what stops that recurring; it is not a
  /// catch-all that swallows, because every failure it converts still reaches
  /// the caller with its cause attached.
  Future<void> _renewAndReplay(
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    late final String accessToken;
    try {
      accessToken = await tokenProvider.refreshAccessToken();
    } on SessionExpiredException {
      // Terminal. The backend has already committed the revocation; the
      // provider has cleared the credentials and moved auth state to signed out.
      // The original error is surfaced unchanged so the caller sees a `401`.
      handler.next(original);
      return;
    } on DioException catch (error) {
      // Everything else — transport failure, 429, 503, 500 — leaves the stored
      // credentials in place and is not retried automatically. Surfacing the
      // refresh failure rather than the original 401 is deliberate: the request
      // did not fail because the session ended, and telling the user otherwise
      // would sign them out over a network blip.
      handler.reject(
        _renewalFailure(
          original,
          mapApiFailure(error),
          response: error.response,
        ),
      );
      return;
    } on ApiFailure catch (failure) {
      // Already classified by the layer that raised it, and carried past this
      // point unchanged: re-deriving a decision from a status would discard the
      // reason the renewal actually failed.
      handler.reject(_renewalFailure(original, failure));
      return;
    } catch (error) {
      // A failure of the local credential layer that arrives unclassified — a
      // platform channel that cannot be reached, most likely. It is reported
      // rather than dropped, and it is emphatically not terminal: nothing here
      // says the session ended, so the stored credentials are left alone and
      // this request is simply not replayed.
      handler.reject(
        _renewalFailure(original, ApiFailureCredentialStorage(cause: error)),
      );
      return;
    }

    try {
      handler.resolve(await _replay(original.requestOptions, accessToken));
    } on DioException catch (error) {
      // The replay failed. It passes through without further renewal: this
      // request has already had its one attempt.
      handler.next(error);
    } catch (error) {
      // Same reasoning as the renewal above. A renewal that succeeded is not
      // replayable when the replay itself throws something Dio does not model,
      // and leaving `handler` uncompleted would hang the request.
      handler.reject(
        _renewalFailure(original, ApiFailureCredentialStorage(cause: error)),
      );
    }
  }

  /// A failed renewal, reported as the original request's failure.
  ///
  /// [failure] is decided by the renewal and passed in rather than derived
  /// here: the outcome is already known, and on the paths that matter there may
  /// be no response left to derive it from. [response] is the renewal's own
  /// response when it had one, carried through so a caller inspecting the body
  /// still sees it.
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
    // A copy, so the original options are left intact for the caller's error
    // reporting. The marker rides in `extra`, which `fetch` carries over
    // verbatim, so a replay of a replay still short-circuits.
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
