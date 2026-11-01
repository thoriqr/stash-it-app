import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/api_envelope.dart';
import '../models/account_link_confirmation_response.dart';
import '../models/confirm_account_link_request.dart';
import '../models/finalize_manual_registration_request.dart';
import '../models/finalize_manual_registration_response.dart';
import '../models/finalize_password_reset_request.dart';
import '../models/finalize_social_registration_request.dart';
import '../models/login_google_request.dart';
import '../models/login_google_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/logout_data.dart';
import '../models/password_reset_continuation_response.dart';
import '../models/register_manual_request.dart';
import '../models/register_manual_response.dart';
import '../models/registration_continuation_response.dart';
import '../models/request_password_reset_request.dart';
import '../models/request_password_reset_response.dart';
import '../models/resend_verification_response.dart';
import '../models/verify_password_reset_request.dart';
import '../models/verify_password_reset_response.dart';
import '../models/verify_registration_request.dart';
import '../models/verify_registration_response.dart';
import '../models/verification_status_response.dart';

part 'auth_api.g.dart';

/// Defines the authentication API operations used by the client.
///
/// Methods return API envelopes so response data and metadata are decoded
/// consistently at the network boundary.
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// `POST /auth/login`
  ///
  /// Authenticates with email and password and returns the resulting session.
  @POST('/auth/login')
  Future<ApiEnvelope<LoginResponse>> login(@Body() LoginRequest request);

  /// `POST /auth/login/google`
  ///
  /// Returns one of three outcomes: `authenticated`, `account_link_required`,
  /// or `registration_required`. Only the authenticated outcome includes
  /// access and refresh tokens.
  @POST('/auth/login/google')
  Future<ApiEnvelope<LoginGoogleResponse>> loginGoogle(
    @Body() LoginGoogleRequest request,
  );

  /// `GET /auth/login/google/account-link/{confirmationId}`
  ///
  /// Retrieves the details of a pending account-link confirmation.
  /// The confirmation ID identifies the flow; confirming it also requires
  /// the Google ID token.
  @GET('/auth/login/google/account-link/{confirmationId}')
  Future<ApiEnvelope<AccountLinkConfirmationResponse>>
  getGoogleAccountLinkConfirmation(
    @Path('confirmationId') String confirmationId,
  );

  /// `POST /auth/login/google/account-link/{confirmationId}/confirm`
  ///
  /// Confirms the account link and returns the authenticated session.
  /// The Google ID token must belong to the identity associated with
  /// the pending confirmation.
  @POST('/auth/login/google/account-link/{confirmationId}/confirm')
  Future<ApiEnvelope<LoginGoogleResponse>> confirmGoogleAccountLink(
    @Path('confirmationId') String confirmationId,
    @Body() ConfirmAccountLinkRequest request,
  );

  /// `POST /auth/register/finalize/social`
  ///
  /// Completes social registration and returns an authenticated session.
  /// The continuation token is sent through the request header.
  @POST('/auth/register/finalize/social')
  Future<ApiEnvelope<LoginResponse>> finalizeSocialRegistration(
    @Header('X-Registration-Continuation') String continuationToken,
    @Body() FinalizeSocialRegistrationRequest request,
  );

  /// `POST /auth/register/manual`
  ///
  /// Starts or resumes email registration and returns the verification ID
  /// used by the PIN verification flow.
  @POST('/auth/register/manual')
  Future<ApiEnvelope<RegisterManualResponse>> registerManual(
    @Body() RegisterManualRequest request,
  );

  /// `POST /auth/register/recovery/manual`
  ///
  /// Starts or resumes recovery verification when the client no longer has
  /// the original registration continuation token.
  ///
  /// Returns the same response shape as [registerManual]. The returned
  /// verification ID is used with the existing PIN, status, resend, and
  /// verification operations. This request does not send a PIN itself.
  @POST('/auth/register/recovery/manual')
  Future<ApiEnvelope<RegisterManualResponse>> initiateManualRecovery(
    @Body() RegisterManualRequest request,
  );

  /// `POST /auth/register/verification/{verificationId}/pin`
  ///
  /// Requests the first PIN. The verification ID is the only input;
  /// this endpoint has no request body.
  ///
  /// Returns `void` because the response contains no additional information
  /// the client needs beyond the verification ID it already has.
  ///
  /// The response body is still decoded by Dio. If decoding fails, the PIN
  /// may already have been issued. The client must not interpret a decode
  /// failure as proof that no PIN was sent.
  @POST('/auth/register/verification/{verificationId}/pin')
  Future<void> createPin(@Path('verificationId') String verificationId);

  /// `GET /auth/register/verification/{verificationId}`
  ///
  /// Retrieves the verification status, PIN issuance state, and remaining
  /// resend cooldown in seconds.
  @GET('/auth/register/verification/{verificationId}')
  Future<ApiEnvelope<VerificationStatusResponse>> getVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/register/verification/{verificationId}/resend`
  ///
  /// Requests a replacement PIN without changing the verification ID.
  @POST('/auth/register/verification/{verificationId}/resend')
  Future<ApiEnvelope<ResendVerificationResponse>> resendVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/register/verification/{verificationId}/verify`
  ///
  /// Verifies the submitted PIN and returns a registration continuation token.
  @POST('/auth/register/verification/{verificationId}/verify')
  Future<ApiEnvelope<VerifyRegistrationResponse>> verifyRegistration(
    @Path('verificationId') String verificationId,
    @Body() VerifyRegistrationRequest request,
  );

  /// `GET /auth/register/continuation`
  ///
  /// Validates the continuation token supplied through the
  /// `X-Registration-Continuation` header and returns registration details.
  @GET('/auth/register/continuation')
  Future<ApiEnvelope<RegistrationContinuationResponse>>
  getRegistrationContinuation(
    @Header('X-Registration-Continuation') String continuationToken,
  );

  /// `POST /auth/register/finalize/manual`
  ///
  /// Completes manual registration using the continuation token header
  /// and the submitted registration details.
  @POST('/auth/register/finalize/manual')
  Future<ApiEnvelope<FinalizeManualRegistrationResponse>>
  finalizeManualRegistration(
    @Header('X-Registration-Continuation') String continuationToken,
    @Body() FinalizeManualRegistrationRequest request,
  );

  /// `POST /auth/password-reset`
  ///
  /// Starts or resumes password reset and returns the verification ID
  /// used by the PIN flow.
  ///
  /// The response does not reveal whether the submitted email address
  /// belongs to an existing account.
  @POST('/auth/password-reset')
  Future<ApiEnvelope<RequestPasswordResetResponse>> requestPasswordReset(
    @Body() RequestPasswordResetRequest request,
  );

  /// `GET /auth/password-reset/verification/{verificationId}`
  ///
  /// Retrieves the password-reset verification status.
  /// A response is available while verification is pending. An already
  /// verified request returns `409 VERIFICATION_NOT_PENDING`.
  @GET('/auth/password-reset/verification/{verificationId}')
  Future<ApiEnvelope<VerificationStatusResponse>> getPasswordResetVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/pin`
  ///
  /// Requests the first password-reset PIN. The verification ID is the only
  /// input; this endpoint has no request body.
  @POST('/auth/password-reset/verification/{verificationId}/pin')
  Future<void> createPasswordResetPin(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/resend`
  ///
  /// Requests a replacement PIN without changing the verification ID.
  @POST('/auth/password-reset/verification/{verificationId}/resend')
  Future<ApiEnvelope<ResendVerificationResponse>> resendPasswordResetPin(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/verify`
  ///
  /// Verifies the submitted PIN and returns the raw password-reset
  /// continuation token. The client must persist this token securely.
  @POST('/auth/password-reset/verification/{verificationId}/verify')
  Future<ApiEnvelope<VerifyPasswordResetResponse>> verifyPasswordReset(
    @Path('verificationId') String verificationId,
    @Body() VerifyPasswordResetRequest request,
  );

  /// `GET /auth/password-reset/continuation`
  ///
  /// Validates the continuation token supplied through the
  /// `X-Password-Reset-Continuation` header.
  @GET('/auth/password-reset/continuation')
  Future<ApiEnvelope<PasswordResetContinuationResponse>>
  getPasswordResetContinuation(
    @Header('X-Password-Reset-Continuation') String continuationToken,
  );

  /// `POST /auth/password-reset/finalize`
  ///
  /// Completes password reset using the continuation token header
  /// and the new password.
  ///
  /// Returns `void` because a successful response carries no additional
  /// payload. Completing this flow does not sign the user in; the client
  /// must use the normal sign-in flow afterward.
  @POST('/auth/password-reset/finalize')
  Future<void> finalizePasswordReset(
    @Header('X-Password-Reset-Continuation') String continuationToken,
    @Body() FinalizePasswordResetRequest request,
  );

  /// `POST /auth/logout`
  ///
  /// Logs out the current session. This endpoint requires no request body.
  ///
  /// Returns an API envelope with nullable `data`, matching the response
  /// shape even though a successful logout has no payload.
  ///
  /// Logout is safe to retry: a successful response is returned even when
  /// the session is already revoked or no longer available.
  @POST('/auth/logout')
  Future<ApiEnvelope<LogoutData>> logout();
}
