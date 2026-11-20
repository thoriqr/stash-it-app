import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_user_feedback_request.dart';
import '../models/create_user_feedback_response.dart';

part 'user_feedback_api.g.dart';

/// User feedback API, issued over the application's `appDio`.
///
/// `appDio` carries the bearer token and the client metadata interceptor, so
/// `X-Platform` is added without being part of the request body.
@RestApi()
abstract class UserFeedbackApi {
  factory UserFeedbackApi(Dio dio, {String? baseUrl}) = _UserFeedbackApi;

  /// Files one report for the authenticated user.
  @POST('/feedback')
  Future<CreateUserFeedbackResponse> create(
    @Body() CreateUserFeedbackRequest request,
  );
}
