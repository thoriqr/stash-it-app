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
/// Carries the user alongside the tokens so the caller can adopt the session
/// immediately. It is returned rather than persisted — see [AuthUser].
class LoginOutcome {
  const LoginOutcome({required this.tokens, required this.user});

  final AuthTokens tokens;
  final AuthUser user;
}

/// The three supported outcomes of Google sign-in.
///
/// Only [GoogleSignInAuthenticated] carries a session. The other two are
/// intermediate states: the app must remain signed out and continue the
/// corresponding flow.
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

  /// The provider identifier returned for the pending account link.
  final String provider;
}

final class GoogleRegistrationRequired extends GoogleSignInResult {
  const GoogleRegistrationRequired({required this.verificationId});

  final String verificationId;
}

/// Auth operations with API failures translated into [ApiFailure].
///
/// This is the boundary that converts [DioException] into [ApiFailure], so
/// callers do not need to handle Dio-specific errors.
///
/// **Sign-in and sign-out only. Renewal is handled by [SessionController].**
/// The session controller coordinates concurrent renewals, persists rotated
/// credentials, and handles terminal session failures. Keeping renewal out of
/// this repository prevents callers from bypassing that lifecycle.
class AuthRepository {
  const AuthRepository({required this.authApi});

  final AuthApi authApi;

  /// Signs in with an email and password, creating a new session.
  ///
  /// Throws [ApiFailure] on refusal. `INVALID_CREDENTIALS` is mapped to
  /// [ApiFailureAuthRequired], but does not indicate that an existing session
  /// has expired.
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authApi.login(
        LoginRequest(email: email, password: password),
      );
      final data = response.data;

      // A successful response without data cannot be treated as a session.
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
  /// Only the authenticated outcome produces a session. Account-link and
  /// registration outcomes are intermediate states; the caller must not store
  /// or adopt credentials for them.
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
          // Unknown outcomes cannot be safely handled by this client.
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

  /// Reads account-link confirmation details without authorizing the link.
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

  /// Starts or resumes manual registration.
  ///
  /// Returns the full response because `verification_status` determines the
  /// next step: `verified` means PIN verification is already complete and no
  /// PIN should be requested. A successful response without data is unreadable
  /// because the client needs the verification ID to continue.
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

  /// Starts or resumes recovery when the continuation token for a verified
  /// manual registration is no longer available on this device.
  ///
  /// The response has the same shape as [registerManual] and reports `pending`.
  /// Its verification ID is used with the existing PIN, status, resend, and
  /// verify operations. A successful response without data is unreadable
  /// because the client needs the ID to request the recovery PIN.
  ///
  /// The existing registration remains valid until the recovery PIN is
  /// successfully verified.
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
  /// The response repeats the verification ID, which the caller already has,
  /// so this method returns nothing. The response is still decoded; if decoding
  /// fails, the client cannot determine whether the PIN was issued or delivered.
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
  /// A successful response without data is unreadable because the screen needs
  /// the status to represent the verification lifecycle.
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
  /// Returns the verification ID confirmed by the response. It remains
  /// unchanged. A successful response without data is unreadable.
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

  /// Revokes the current session.
  ///
  /// The operation is idempotent, so retrying after a lost response is safe.
  /// Failures propagate as [ApiFailure]. The caller remains responsible for
  /// clearing local credentials, even when the request fails.
  Future<void> logout() async {
    try {
      await authApi.logout();
    } on DioException catch (error) {
      throw mapApiFailure(error);
    }
  }

  /// Starts or resumes a password reset and returns its verification ID.
  ///
  /// The response has the same shape whether or not the email belongs to an
  /// existing account. The client must not use it to infer account existence.
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
  /// A response is available only while verification is pending. A terminal
  /// verification is returned as a typed refusal.
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
  /// The response repeats the verification ID, which the caller already has,
  /// so this method returns nothing. An unreadable response does not establish
  /// whether the PIN was issued.
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

  /// Completes the password reset with the continuation token and new password.
  ///
  /// A successful response confirms completion. All existing sessions for the
  /// account are revoked, so the user must sign in again on other devices.
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
