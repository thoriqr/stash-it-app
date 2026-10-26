import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/error/api_envelope.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/logout_data.dart';
import '../models/finalize_manual_registration_request.dart';
import '../models/finalize_manual_registration_response.dart';
import '../models/register_manual_request.dart';
import '../models/register_manual_response.dart';
import '../models/registration_continuation_response.dart';
import '../models/resend_verification_response.dart';
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

  /// `POST /auth/register/manual`
  ///
  /// Starts (or resumes) the email registration lifecycle and returns the
  /// verification id needed to request its first PIN. This route is
  /// unauthenticated and has no registration rate middleware of its own.
  @POST('/auth/register/manual')
  Future<ApiEnvelope<RegisterManualResponse>> registerManual(
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
  Future<ApiEnvelope<RegistrationContinuationResponse>> getRegistrationContinuation(
    @Header('X-Registration-Continuation') String continuationToken,
  );

  /// `POST /auth/register/finalize/manual`
  ///
  /// Finalizes manual registration using the continuation token header and body.
  @POST('/auth/register/finalize/manual')
  Future<ApiEnvelope<FinalizeManualRegistrationResponse>> finalizeManualRegistration(
    @Header('X-Registration-Continuation') String continuationToken,
    @Body() FinalizeManualRegistrationRequest request,
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
