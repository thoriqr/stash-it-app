import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/user_feedback_api.dart';
import 'user_feedback_repository.dart';

final Provider<UserFeedbackApi> userFeedbackApiProvider =
    Provider<UserFeedbackApi>(
      (ref) => UserFeedbackApi(ref.watch(appDioProvider)),
    );

final Provider<UserFeedbackRepository> userFeedbackRepositoryProvider =
    Provider<UserFeedbackRepository>(
      (ref) => UserFeedbackRepository(api: ref.watch(userFeedbackApiProvider)),
    );
