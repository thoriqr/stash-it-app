import 'package:dio/dio.dart';

import '../../../core/error/api_failure_mapper.dart';
import 'datasources/user_feedback_api.dart';
import 'models/create_user_feedback_request.dart';

/// Sends user feedback and classifies every failure through the shared mapper.
class UserFeedbackRepository {
  const UserFeedbackRepository({required this.api});

  final UserFeedbackApi api;

  /// Files [request].
  ///
  /// The response is parsed by the API client; the report id and creation time
  /// are not needed by the screen. A refusal is thrown as an [ApiFailure], and
  /// a successfully received but undecodable response is unreadable rather
  /// than a transport failure.
  Future<void> submit(CreateUserFeedbackRequest request) async {
    try {
      await api.create(request);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
