import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import 'datasources/auth_api.dart';
import 'models/auth_tokens.dart';
import 'models/auth_user.dart';
import 'models/login_request.dart';

/// The outcome of a successful sign-in.
///
/// Carries the user alongside the tokens so the caller can act on the sign-in
/// immediately. It is returned rather than persisted — see [AuthUser].
class LoginOutcome {
  const LoginOutcome({required this.tokens, required this.user});

  final AuthTokens tokens;
  final AuthUser user;
}

/// Auth operations, with failures already translated.
///
/// This is the only layer that converts a [DioException] into an [ApiFailure],
/// so a caller never has to know Dio exists (`AGENTS.md` §2, rule 4). It is a
/// concrete class with no interface: there is one implementation, and
/// `AGENTS.md` §2 explicitly declines interfaces for that case.
///
/// **Sign-in and sign-out only. Renewal is not here.** `SessionController`
/// performs it directly against `refreshApi`, and has to: only that path
/// coordinates concurrent renewals into one submission, reads the refresh token
/// as renewal begins, persists the rotated pair before handing it back, and ends
/// the session on a terminal refusal. A repository method could do none of those
/// — the backend revokes the whole session on a second presentation of a spent
/// token — so offering one here was a way to reach a session-destroying call by
/// accident. An earlier version of this class did offer it and had no callers.
class AuthRepository {
  const AuthRepository({required this.authApi});

  final AuthApi authApi;

  /// Signs in with an email and password, creating a new server session.
  ///
  /// Throws [ApiFailure] on any refusal. `INVALID_CREDENTIALS` arrives as
  /// [ApiFailureAuthRequired] — a `401` that means these details were wrong,
  /// which is the same shape as "you are not signed in" and different in
  /// meaning, so it is mapped like any other `401` and never read as a session
  /// event.
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authApi.login(
        LoginRequest(email: email, password: password),
      );
      final data = response.data;

      // A `200` with no `data` is a shape this client does not understand.
      // Treated as unreadable rather than as an empty session.
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }

      return LoginOutcome(
        tokens: AuthTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        ),
        user: data.user,
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    }
  }

  /// Revokes the current server session.
  ///
  /// Idempotent server-side, so a retry after a lost response is harmless.
  /// Failures propagate as [ApiFailure]: a logout whose network call failed must
  /// still clear local credentials, and that ordering is enforced by the caller,
  /// which is why this does not clear anything itself.
  Future<void> logout() async {
    try {
      await authApi.logout();
    } on DioException catch (error) {
      throw mapApiFailure(error);
    }
  }
}
