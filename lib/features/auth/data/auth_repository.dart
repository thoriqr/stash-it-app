import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import 'datasources/auth_api.dart';
import 'models/account_link_confirmation_response.dart';
import 'models/auth_tokens.dart';
import 'models/auth_user.dart';
import 'models/confirm_account_link_request.dart';
import 'models/finalize_social_registration_request.dart';
import 'models/login_google_request.dart';
import 'models/login_google_response.dart';
import 'models/login_request.dart';
import 'models/finalize_manual_registration_request.dart';
import 'models/finalize_manual_registration_response.dart';
import 'models/finalize_password_reset_request.dart';
import 'models/password_reset_continuation_response.dart';
import 'models/register_manual_request.dart';
import 'models/register_manual_response.dart';
import 'models/registration_continuation_response.dart';
import 'models/request_password_reset_request.dart';
import 'models/verify_password_reset_request.dart';
import 'models/verify_registration_request.dart';
import 'models/verification_status_response.dart';

/// The outcome of a successful sign-in.
///
/// Carries the user alongside the tokens so the caller can act on the sign-in
/// immediately. It is returned rather than persisted — see [AuthUser].
class LoginOutcome {
  const LoginOutcome({required this.tokens, required this.user});

  final AuthTokens tokens;
  final AuthUser user;
}

/// The three documented outcomes of `POST /auth/login/google`.
///
/// Only [GoogleSignInAuthenticated] carries a session. The other two are
/// intermediate states: the app must remain signed out and continue the named
/// flow.
sealed class GoogleSignInResult {
  const GoogleSignInResult();
}

final class GoogleSignInAuthenticated extends GoogleSignInResult {
  const GoogleSignInAuthenticated(this.session);

  final LoginOutcome session;
}

final class GoogleAccountLinkRequired extends GoogleSignInResult {
  const GoogleAccountLinkRequired({
    required this.confirmationId,
    required this.provider,
  });

  final String confirmationId;

  /// The provider string the backend returned for the pending link.
  final String provider;
}

final class GoogleRegistrationRequired extends GoogleSignInResult {
  const GoogleRegistrationRequired({required this.verificationId});

  final String verificationId;
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

  /// Signs in with a Google ID token.
  ///
  /// Only the authenticated outcome produces a session. The account-link and
  /// registration outcomes are returned as intermediate states, and the caller
  /// must not store or adopt anything for them.
  Future<GoogleSignInResult> loginGoogle({required String idToken}) async {
    try {
      final response = await authApi.loginGoogle(
        LoginGoogleRequest(idToken: idToken),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }

      switch (data.outcome) {
        case 'authenticated':
          return GoogleSignInAuthenticated(_googleSession(data));

        case 'account_link_required':
          final confirmationId = data.confirmationId;
          final provider = data.provider;
          if (confirmationId == null ||
              confirmationId.isEmpty ||
              provider == null ||
              provider.isEmpty) {
            throw const ApiFailureUnreadableResponse();
          }
          return GoogleAccountLinkRequired(
            confirmationId: confirmationId,
            provider: provider,
          );

        case 'registration_required':
          final verificationId = data.verificationId;
          if (verificationId == null || verificationId.isEmpty) {
            throw const ApiFailureUnreadableResponse();
          }
          return GoogleRegistrationRequired(verificationId: verificationId);

        default:
          // An outcome this client does not understand cannot be acted on.
          throw const ApiFailureUnreadableResponse();
      }
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Reads the account-link confirmation details without authorizing anything.
  Future<AccountLinkConfirmationResponse> getGoogleAccountLinkConfirmation({
    required String confirmationId,
  }) async {
    try {
      final response = await authApi.getGoogleAccountLinkConfirmation(
        confirmationId,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Confirms a Google account link and returns the newly created session.
  Future<LoginOutcome> confirmGoogleAccountLink({
    required String confirmationId,
    required String idToken,
  }) async {
    try {
      final response = await authApi.confirmGoogleAccountLink(
        confirmationId,
        ConfirmAccountLinkRequest(idToken: idToken),
      );
      final data = response.data;
      if (data == null || data.outcome != 'authenticated') {
        throw const ApiFailureUnreadableResponse();
      }
      return _googleSession(data);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Completes a social registration and returns its authenticated session.
  Future<LoginOutcome> finalizeSocialRegistration({
    required String continuationToken,
    required String displayName,
  }) async {
    try {
      final response = await authApi.finalizeSocialRegistration(
        continuationToken,
        FinalizeSocialRegistrationRequest(displayName: displayName),
      );
      final data = response.data;
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
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  LoginOutcome _googleSession(LoginGoogleResponse data) {
    final accessToken = data.accessToken;
    final refreshToken = data.refreshToken;
    final user = data.user;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        user == null) {
      throw const ApiFailureUnreadableResponse();
    }

    return LoginOutcome(
      tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
      user: user,
    );
  }

  /// Starts (or resumes) manual registration.
  ///
  /// Returns the whole response rather than only the verification id, because
  /// `verification_status` decides what the caller must do next: `verified` means
  /// PIN verification has already completed and no PIN may be requested. A `201`
  /// whose envelope lacks `data` is unreadable rather than a successful
  /// registration: without an id the client cannot make the next contractually
  /// required call.
  Future<RegisterManualResponse> registerManual({required String email}) async {
    try {
      final response = await authApi.registerManual(
        RegisterManualRequest(email: email),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }

      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Starts (or resumes) recovery for a verified manual registration whose raw
  /// continuation token this device no longer has.
  ///
  /// The response has the same shape as [registerManual] and reports `pending`;
  /// the returned id is used with the existing PIN, status, resend and verify
  /// routes. A `201` whose envelope lacks `data` is unreadable: without an id
  /// the caller cannot request the recovery PIN.
  ///
  /// This call does not expire or replace the old registration. That happens
  /// only when the recovery PIN is verified.
  Future<RegisterManualResponse> initiateManualRecovery({
    required String email,
  }) async {
    try {
      final response = await authApi.initiateManualRecovery(
        RegisterManualRequest(email: email),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }

      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Requests the first registration PIN for [verificationId].
  ///
  /// The `201` body repeats [verificationId], which the caller already has, so
  /// this returns nothing instead of a second parsed id. The body is still
  /// decoded, and a body that cannot be decoded surfaces as
  /// [ApiFailureUnreadableResponse]. Because the server issued the code before
  /// answering, that failure does not establish that issuance or email delivery
  /// failed, and no caller may say that it does (**D15**, **D16**).
  ///
  /// Dio, transport and decoder failures remain classified through the same
  /// boundary as every other repository call.
  Future<void> createPin({required String verificationId}) async {
    try {
      await authApi.createPin(verificationId);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Reads the current status of a registration verification.
  ///
  /// A `200` whose envelope lacks `data` is unreadable: without the status the
  /// screen cannot represent the verification lifecycle.
  Future<VerificationStatusResponse> getVerification({
    required String verificationId,
  }) async {
    try {
      final response = await authApi.getVerification(verificationId);
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Requests a replacement PIN for [verificationId].
  ///
  /// Returns the verification id the server confirms (unchanged). A `200` whose
  /// envelope lacks `data` is unreadable.
  Future<String> resendVerification({required String verificationId}) async {
    try {
      final response = await authApi.resendVerification(verificationId);
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data.verificationId;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Verifies a registration PIN and returns the continuation token.
  Future<String> verifyRegistration({
    required String verificationId,
    required String pin,
  }) async {
    try {
      final response = await authApi.verifyRegistration(
        verificationId,
        VerifyRegistrationRequest(pin: pin),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data.registrationContinuationToken;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Reads registration continuation details for a token.
  Future<RegistrationContinuationResponse> getRegistrationContinuation({
    required String continuationToken,
  }) async {
    try {
      final response = await authApi.getRegistrationContinuation(
        continuationToken,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Finalizes a manual registration.
  Future<FinalizeManualRegistrationResponse> finalizeManualRegistration({
    required String continuationToken,
    required String displayName,
    required String password,
  }) async {
    try {
      final response = await authApi.finalizeManualRegistration(
        continuationToken,
        FinalizeManualRegistrationRequest(
          displayName: displayName,
          password: password,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
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

  /// Starts (or resumes) a password reset and returns the server-issued
  /// verification id.
  ///
  /// The id is identical in shape for an address with no account; the client must
  /// not use the response to infer account existence.
  Future<String> requestPasswordReset({required String email}) async {
    try {
      final response = await authApi.requestPasswordReset(
        RequestPasswordResetRequest(email: email),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data.verificationId;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Reads the current password-reset verification status.
  ///
  /// A body is returned only while the verification is pending; a terminal
  /// verification surfaces as a typed refusal.
  Future<VerificationStatusResponse> getPasswordResetVerification({
    required String verificationId,
  }) async {
    try {
      final response = await authApi.getPasswordResetVerification(
        verificationId,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Issues the first PIN for a pending password reset.
  ///
  /// The `201` body repeats the id the caller already has, so this returns
  /// nothing. An unreadable `201` is not proof that no PIN was issued.
  Future<void> createPasswordResetPin({required String verificationId}) async {
    try {
      await authApi.createPasswordResetPin(verificationId);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Issues a replacement PIN for a pending password reset.
  Future<String> resendPasswordResetPin({
    required String verificationId,
  }) async {
    try {
      final response = await authApi.resendPasswordResetPin(verificationId);
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data.verificationId;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Verifies a password-reset PIN and returns the raw continuation token.
  ///
  /// The token is returned exactly once; the caller must persist it immediately.
  Future<String> verifyPasswordReset({
    required String verificationId,
    required String pin,
  }) async {
    try {
      final response = await authApi.verifyPasswordReset(
        verificationId,
        VerifyPasswordResetRequest(pin: pin),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data.passwordResetContinuationToken;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Validates a password-reset continuation token.
  Future<PasswordResetContinuationResponse> getPasswordResetContinuation({
    required String continuationToken,
  }) async {
    try {
      final response = await authApi.getPasswordResetContinuation(
        continuationToken,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiFailureUnreadableResponse();
      }
      return data;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Completes the reset with the continuation token and new password.
  ///
  /// A successful `200` is the only receipt; the backend returns no payload and
  /// revokes every session for the account.
  Future<void> finalizePasswordReset({
    required String continuationToken,
    required String password,
  }) async {
    try {
      await authApi.finalizePasswordReset(
        continuationToken,
        FinalizePasswordResetRequest(password: password),
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
