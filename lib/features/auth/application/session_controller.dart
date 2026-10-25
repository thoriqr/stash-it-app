import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../../../core/network/token_provider.dart';
import '../../../core/storage/secure_credential_store.dart';
import '../data/auth_api_providers.dart';
import '../data/datasources/refresh_api.dart';
import '../data/models/auth_tokens.dart';
import '../data/models/refresh_request.dart';

part 'session_controller.g.dart';

/// Secure credential storage.
///
/// A plain [Provider] rather than generated code: it holds a value that never
/// changes, so there is nothing to generate, and keeping it here is what lets
/// tests substitute a fake store without touching a platform channel.
final Provider<SecureCredentialStore> credentialStoreProvider =
    Provider<SecureCredentialStore>(
      (ref) => throw UnimplementedError(
        'credentialStoreProvider must be overridden with a real or fake store',
      ),
    );

/// Credentials recovered from storage during startup, if any.
///
/// Overridden in `main` after `bootstrap` reads secure storage. That override is
/// what makes "load before `runApp`" possible at all: a provider cannot read
/// storage synchronously, and deferring it to `build` would put a loading state
/// in front of every screen.
///
/// Declared beside [credentialStoreProvider] — the other value `bootstrap`
/// injects — because [SessionController] is its only consumer. Declaring it in
/// `auth_state.dart` instead would make this file import that one purely for a
/// provider override, and give the two files a mutual import for no gain.
final Provider<AuthTokens?> restoredTokensProvider = Provider<AuthTokens?>(
  (ref) => null,
);

/// Owns the credential pair, and is the only provider the API client depends on.
///
/// Implements [TokenProvider], which is how `core/network` reaches the session
/// without importing anything from this feature (`AGENTS.md` §2, rule 1).
///
/// ## Why this provider must not depend on the auth repository
///
/// `appDio` reads this provider to obtain the bearer token, so anything this
/// provider depends on sits underneath `appDio` in the dependency graph. If
/// this provider also depended on `authRepositoryProvider` — which is built
/// from `appDio` — the graph would close into a loop:
///
/// ```text
/// appDio -> sessionController -> authRepository -> authApi -> appDio
/// ```
///
/// Riverpod rejects that: `_debugAssertCanDependOn` walks the reader's
/// *dependents* and throws `CircularDependencyError` if the target is among
/// them. The check is a static property of the graph and runs on **every**
/// `read`/`watch`, so deferring the lookup into a closure does not avoid it — it
/// only postpones the throw to the first request, where it surfaces as an
/// unexplained transport failure.
///
/// Depending only on [refreshApiProvider] makes renewal *structurally* unable to
/// recurse as a second-order effect: the refresh client is built from
/// `refreshDio`, which carries no auth interceptor and therefore no path back
/// into this provider.
///
/// ## Why renewal is serialized here
///
/// The backend rotates the refresh token on **every** use and treats a second
/// presentation of an already-rotated token as reuse: it revokes the entire
/// session and answers `SESSION_REVOKED`
/// (`documentation/auth-sessions.md`, "Reuse detection"). It cannot distinguish
/// a client retry from a replay, so two concurrent renewals cost the user their
/// session outright.
///
/// One [Future] shared by every caller is the whole mitigation. Concurrent
/// callers do not each submit the token; they await the same operation and
/// receive the same new token.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController implements TokenProvider {
  @override
  AuthTokens? build() {
    // Only `refreshDio`-backed dependencies. See the class doc for why.
    _refreshApi = ref.watch(refreshApiProvider);
    _store = ref.watch(credentialStoreProvider);

    // Synchronous, and returning the pair `bootstrap` already read. The initial
    // value is deliberately *not* re-read here: doing so would make `build`
    // asynchronous, turn this into an `AsyncNotifier`, and force every caller to
    // unwrap an `AsyncValue` for what is a settled fact by the first frame.
    return ref.watch(restoredTokensProvider);
  }

  late final RefreshApi _refreshApi;
  late final SecureCredentialStore _store;

  /// The in-flight renewal, or null when none is running.
  ///
  /// App-wide because the provider is keep-alive: an auto-disposed provider
  /// would drop this field whenever no listener remained, and the next burst of
  /// concurrent `401`s would each start their own renewal — reintroducing
  /// exactly the failure this prevents.
  Future<String>? _inFlight;

  /// The session this provider currently believes it holds.
  ///
  /// Null means signed out. It is the single source of truth for "does a
  /// session exist": [AuthState] derives its user-facing status by watching this
  /// provider, and a renewal that ends the session clears it here rather than
  /// pushing a notification somewhere else.
  AuthTokens? get current => state;

  /// Whether a session has ended that nothing has yet told the user about.
  ///
  /// Set only by [_endSession], and read once by whoever explains it. A field
  /// here rather than a separate notice provider, because it is a fact about
  /// *this* session ending — a second provider holding it would be a second
  /// source of truth for the same thing, and a notification channel this project
  /// deliberately does not have.
  bool _endedWithoutNotice = false;

  /// Whether this controller has processed an end for the current session.
  ///
  /// Unlike `state == null`, this stays true after [_endedWithoutNotice] is
  /// consumed, so a late expired request cannot re-arm the one-time notice. It
  /// also cannot be used in place of a null state at startup: in a test that
  /// seeds only storage, or during bootstrap, there is no adopted session yet
  /// but there may still be credentials that must be cleared.
  bool _sessionEnded = false;

  /// Whether a session has just ended, consuming the fact.
  ///
  /// Returns `true` **once** per ended session: the flag is cleared before the
  /// answer is given, so a rebuild or a later visit to the auth entry screen
  /// gets `false` and cannot repeat the explanation.
  ///
  /// Consuming rather than reading is the point. A flag that outlived its first
  /// reader would re-announce the same expiry every time the screen rebuilt,
  /// which is exactly what a one-time notice exists to prevent.
  bool consumeSessionEnded() {
    if (!_endedWithoutNotice) return false;
    _endedWithoutNotice = false;
    return true;
  }

  /// Records a freshly obtained pair after it has been persisted.
  ///
  /// Persistence is deliberately **not** this provider's job at sign-in time.
  /// Doing it here would make the auth state depend on this provider for a write
  /// the store already performs atomically, and the resulting edge is the cycle
  /// described in the class documentation.
  void adopt(AuthTokens tokens) {
    if (!ref.mounted) return;
    _sessionEnded = false;
    state = tokens;
  }

  /// Records that no session is held. The credentials are cleared by the caller.
  void discard() {
    if (!ref.mounted) return;
    _sessionEnded = true;
    state = null;
  }

  @override
  Future<String?> readAccessToken() => _store.readAccessToken();

  @override
  Future<String> refreshAccessToken() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    // Assigned through a local so `whenComplete` can compare identity.
    // Comparing with `==` risks clearing a *newer* operation's handle.
    late final Future<String> future;
    future = _renew().whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    _inFlight = future;

    return future;
  }

  Future<String> _renew() async {
    // Read at the moment renewal begins, never cached in a field. A request
    // whose `401` arrives *after* an earlier renewal completed must rotate the
    // token that earlier renewal produced. Sending the one it already spent is
    // precisely the replay the backend revokes sessions for.
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) {
      // Nothing to renew with, and nothing ever will be. Terminal by
      // construction: an access token with no refresh token can never be
      // renewed again.
      await _endSession();
      throw const SessionExpiredException('NO_REFRESH_TOKEN');
    }

    final AuthTokens tokens;
    try {
      final response = await _refreshApi.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );
      final data = response.data;

      if (data == null) {
        // A `200` whose body this client cannot read. The server answered, but
        // whether it committed the rotation is unknown — the same position as a
        // lost response, so the credentials are kept and no retry is attempted.
        throw _uncertain(const ApiFailureUnreadableResponse());
      }

      tokens = AuthTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      );
    } on DioException catch (error) {
      final failure = mapApiFailure(error);

      if (failure is ApiFailureSessionEnded) {
        // Definitive. The backend has already committed the revocation, so
        // there is nothing to keep and retrying cannot help.
        await _endSession();
        throw SessionExpiredException(failure.code);
      }

      // `429`, `503`, `500`, or a transport failure. None of these consumed the
      // token with certainty: the limiter mounts in front of the handler and
      // fails closed without rotating, and a `500` means the commit did not
      // succeed. Reported as *uncertain* rather than as itself, because the
      // outcome is genuinely unknown. Credentials are deliberately kept; see
      // `ApiFailureRefreshUncertain`.
      throw _uncertain(failure);
    }

    // Written before this future completes, so no caller can replay a protected
    // request against a token that exists only in memory.
    await _persist(tokens);
    adopt(tokens);

    return tokens.accessToken;
  }

  /// Stores a rotated pair, all-or-nothing.
  ///
  /// [SecureCredentialStore.write] discards whatever landed if the second write
  /// fails, so a failed rotation leaves no session rather than a mismatched one.
  Future<void> _persist(AuthTokens tokens) async {
    try {
      await _store.write(tokens);
    } catch (error) {
      // The pair is unusable and the session is gone. Signed out deliberately:
      // continuing with a half-written pair would fail the user's next request
      // and loop, whereas signed out is the one state certainly true.
      await _endSession();
      throw ApiFailureCredentialStorage(cause: error);
    }
  }

  /// Clears the stored credentials and records that no session is held.
  ///
  /// The [ref.mounted] check is load-bearing rather than defensive. This runs
  /// after an `await`, and by then the caller may have been disposed — a test
  /// tearing down its container, or the app shutting down mid-renewal. Writing
  /// `state` on a disposed notifier throws, and Riverpod reports it as a
  /// programming error rather than something to swallow.
  ///
  /// It deliberately does **not** touch `authStateProvider`. That provider reads
  /// this one to derive the user-facing status, so a reference back would be an
  /// edge in the wrong direction and would recreate the cycle this class exists
  /// to avoid.
  Future<void> _endSession() async {
    // A late expired request can re-enter renewal after an earlier terminal
    // response already ended the session. There is nothing left to clear, and
    // running on would re-arm the one-time notice after sign-in consumed it.
    //
    // This cannot be written as `state == null`: a null state is also the
    // starting state for a test (or bootstrap) that has credentials in storage
    // but has not adopted them yet, and those credentials still have to be
    // cleared. The marker records that an end has actually been processed.
    if (_sessionEnded) return;
    _sessionEnded = true;

    try {
      await _store.clear();
    } catch (_) {
      // A cleanup that failed did not end the session locally. Leave the
      // credentials and the state alone, and allow a later attempt; a failure
      // must not claim the session ended when storage says otherwise.
      _sessionEnded = false;
      rethrow;
    }

    // Recorded **before** `discard`, because discarding is what moves the app to
    // sign-in. The fact has to be in place before anything can react to that
    // transition, or the screen which explains it arrives to find nothing.
    //
    // Only once `clear` has succeeded, so a cleanup failure never arms the
    // notice.
    _endedWithoutNotice = true;
    discard();
  }
}

/// Wraps a renewal failure whose outcome is unknown as a [DioException].
///
/// Carrying it as a [DioException] with the typed failure in `error` is what
/// lets the interceptor's existing error path handle it unchanged, and lets
/// [mapApiFailure] hand the typed failure straight back to the caller rather
/// than re-deriving one from a status code.
DioException _uncertain(ApiFailure cause) {
  return DioException(
    requestOptions: RequestOptions(path: '/auth/refresh'),
    type: DioExceptionType.badResponse,
    error: ApiFailureRefreshUncertain(cause: cause),
  );
}
