import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/profile_api.dart';
import 'profile_repository.dart';

final Provider<ProfileApi> profileApiProvider = Provider<ProfileApi>(
  (ref) => ProfileApi(ref.watch(appDioProvider)),
);

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (ref) => ProfileRepository(api: ref.watch(profileApiProvider)),
    );
