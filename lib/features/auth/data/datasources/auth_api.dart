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

/// The authenticated API surface, issued over `appDio`.
///
/// Returns API envelopes rather than bare models, so `data`, `message` and
/// `meta` are decoded once at the boundary and the mapper above them never has
/// to reach into a raw map.
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// `POST /auth/login`
  ///
  /// Unauthenticated, and bounded per client address and per email address
  /// (30/10min and 10/15min). A `429` here is a real budget, not a defect.
  @POST('/auth/login')
  Future<ApiEnvelope<LoginResponse>> login(@Body() LoginRequest request);

  /// `POST /auth/login/google`
  ///
  /// Unauthenticated. The response carries one of three outcomes:
  /// `authenticated`, `account_link_required`, or `registration_required`.
  /// Only the authenticated outcome includes access and refresh tokens.
  @POST('/auth/login/google')
  Future<ApiEnvelope<LoginGoogleResponse>> loginGoogle(
    @Body() LoginGoogleRequest request,
  );

  /// `GET /auth/login/google/account-link/{confirmationId}`
  ///
  /// Reads a pending account-link confirmation. The confirmation id only names
  /// the flow; the confirm route also requires the Google ID token.
  @GET('/auth/login/google/account-link/{confirmationId}')
  Future<ApiEnvelope<AccountLinkConfirmationResponse>>
  getGoogleAccountLinkConfirmation(
    @Path('confirmationId') String confirmationId,
  );

  /// `POST /auth/login/google/account-link/{confirmationId}/confirm`
  ///
  /// Confirms the link and returns the same authenticated shape as Google
  /// login. The ID token must belong to the identity the confirmation was
  /// created for.
  @POST('/auth/login/google/account-link/{confirmationId}/confirm')
  Future<ApiEnvelope<LoginGoogleResponse>> confirmGoogleAccountLink(
    @Path('confirmationId') String confirmationId,
    @Body() ConfirmAccountLinkRequest request,
  );

  /// `POST /auth/register/finalize/social`
  ///
  /// Completes a social registration and creates an authenticated session. The
  /// continuation token header is the capability; no password is sent.
  @POST('/auth/register/finalize/social')
  Future<ApiEnvelope<LoginResponse>> finalizeSocialRegistration(
    @Header('X-Registration-Continuation') String continuationToken,
    @Body() FinalizeSocialRegistrationRequest request,
  );

  /// `POST /auth/register/manual`
  ///
  /// Starts (or resumes) the email registration lifecycle and returns the
  /// verification id needed to request its first PIN. This route is
  /// unauthenticated and has no registration rate middleware of its own.
  @POST('/auth/register/manual')
  Future<ApiEnvelope<RegisterManualResponse>> registerManual(
    @Body() RegisterManualRequest request,
  );

  /// `POST /auth/register/recovery/manual`
  ///
  /// Starts (or resumes) a recovery verification for a manual registration
  /// whose raw continuation token this device no longer has. The response has
  /// the same shape as [registerManual] and reports `pending`: the returned id
  /// must be used with the existing PIN, status, resend and verify routes.
  ///
  /// This route sends **no email** itself and does not expire or replace the
  /// registration. It is bounded by the same per-client-address budget as PIN
  /// issuance.
  @POST('/auth/register/recovery/manual')
  Future<ApiEnvelope<RegisterManualResponse>> initiateManualRecovery(
    @Body() RegisterManualRequest request,
  );

  /// `POST /auth/register/verification/{verificationId}/pin`
  ///
  /// The verification id is the complete input: this endpoint has **no request
  /// body**. The `201` carries an envelope repeating that id, which the caller
  /// already has, so this returns `void` rather than a second parsed value.
  ///
  /// **Dio still decodes the `201` body**, and a body it cannot decode fails the
  /// call. That failure does not prove the PIN was not issued: the server
  /// persisted the code before answering, so only the representation is
  /// unreadable. Callers must not present a decode failure as proof that no
  /// code was sent or emailed.
  @POST('/auth/register/verification/{verificationId}/pin')
  Future<void> createPin(@Path('verificationId') String verificationId);

  /// `GET /auth/register/verification/{verificationId}`
  ///
  /// Read-only status of a registration verification. No request body. Returns
  /// the verification status, whether a PIN has been issued, and the remaining
  /// resend cooldown in seconds.
  @GET('/auth/register/verification/{verificationId}')
  Future<ApiEnvelope<VerificationStatusResponse>> getVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/register/verification/{verificationId}/resend`
  ///
  /// Issues a replacement PIN. No request body. The verification id is unchanged.
  @POST('/auth/register/verification/{verificationId}/resend')
  Future<ApiEnvelope<ResendVerificationResponse>> resendVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/register/verification/{verificationId}/verify`
  ///
  /// Verifies the PIN and returns a registration continuation token.
  @POST('/auth/register/verification/{verificationId}/verify')
  Future<ApiEnvelope<VerifyRegistrationResponse>> verifyRegistration(
    @Path('verificationId') String verificationId,
    @Body() VerifyRegistrationRequest request,
  );

  /// `GET /auth/register/continuation`
  ///
  /// Validates the continuation token supplied in the `X-Registration-Continuation`
  /// header and returns registration details.
  @GET('/auth/register/continuation')
  Future<ApiEnvelope<RegistrationContinuationResponse>>
  getRegistrationContinuation(
    @Header('X-Registration-Continuation') String continuationToken,
  );

  /// `POST /auth/register/finalize/manual`
  ///
  /// Finalizes manual registration using the continuation token header and body.
  @POST('/auth/register/finalize/manual')
  Future<ApiEnvelope<FinalizeManualRegistrationResponse>>
  finalizeManualRegistration(
    @Header('X-Registration-Continuation') String continuationToken,
    @Body() FinalizeManualRegistrationRequest request,
  );

  /// `POST /auth/password-reset`
  ///
  /// Starts (or resumes) a password reset and returns the verification id needed
  /// to request its PIN. The response is identical for an address with no
  /// account — the id is then a random, unpersisted placeholder — so this call
  /// cannot be used to discover which addresses are registered.
  ///
  /// Bounded per client address (10/10min). A `429` is a real budget.
  @POST('/auth/password-reset')
  Future<ApiEnvelope<RequestPasswordResetResponse>> requestPasswordReset(
    @Body() RequestPasswordResetRequest request,
  );

  /// `GET /auth/password-reset/verification/{verificationId}`
  ///
  /// Read-only status. Returns a body only while the verification is `pending`;
  /// a verified request answers `409 VERIFICATION_NOT_PENDING`. This is the
  /// client's first validation step and is bounded per address (60/10min).
  @GET('/auth/password-reset/verification/{verificationId}')
  Future<ApiEnvelope<VerificationStatusResponse>> getPasswordResetVerification(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/pin`
  ///
  /// Issues the first PIN. No request body. Bounded per address and by the shared
  /// PIN email budgets, like the registration issuance route.
  @POST('/auth/password-reset/verification/{verificationId}/pin')
  Future<void> createPasswordResetPin(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/resend`
  ///
  /// Issues a replacement PIN. The verification id is unchanged.
  @POST('/auth/password-reset/verification/{verificationId}/resend')
  Future<ApiEnvelope<ResendVerificationResponse>> resendPasswordResetPin(
    @Path('verificationId') String verificationId,
  );

  /// `POST /auth/password-reset/verification/{verificationId}/verify`
  ///
  /// Verifies the PIN and returns the raw password-reset continuation token,
  /// which the client must persist immediately. The backend stores only its
  /// hash.
  @POST('/auth/password-reset/verification/{verificationId}/verify')
  Future<ApiEnvelope<VerifyPasswordResetResponse>> verifyPasswordReset(
    @Path('verificationId') String verificationId,
    @Body() VerifyPasswordResetRequest request,
  );

  /// `GET /auth/password-reset/continuation`
  ///
  /// Validates the continuation token supplied in the
  /// `X-Password-Reset-Continuation` header. Deliberately unlimited server-side.
  @GET('/auth/password-reset/continuation')
  Future<ApiEnvelope<PasswordResetContinuationResponse>>
  getPasswordResetContinuation(
    @Header('X-Password-Reset-Continuation') String continuationToken,
  );

  /// `POST /auth/password-reset/finalize`
  ///
  /// Completes the reset with the continuation header and the new password. A
  /// `200` is the receipt; the body carries no payload. The backend revokes every
  /// session for the account in the same transaction, so this flow never signs
  /// the user in.
  @POST('/auth/password-reset/finalize')
  Future<void> finalizePasswordReset(
    @Header('X-Password-Reset-Continuation') String continuationToken,
    @Body() FinalizePasswordResetRequest request,
  );

  /// `POST /auth/logout`
  ///
  /// **No request body.** The backend binds none: it revokes the session named
  /// by the verified token's `sid` claim, which the guard has already
  /// established, so a body would be ignored at best and misleading at worst.
  ///
  /// Returns `ApiEnvelope<LogoutData>` because the success body is
  /// `{"data": null, "message": "logout successful"}` — `httpx.OKMessage` writes
  /// a nil `Data` pointer. `ApiEnvelope.data` is nullable so that decodes; a
  /// dedicated payload type rather than `Object?` keeps the generated decoder
  /// meaningful instead of an identity cast.
  ///
  /// The call is idempotent server-side: a missing, already-revoked or
  /// foreign session all answer `200`, so a retry after a lost response is safe.
  @POST('/auth/logout')
  Future<ApiEnvelope<LogoutData>> logout();
}
