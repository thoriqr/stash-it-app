import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/profile_providers.dart';
import '../domain/user_profile.dart';

part 'profile_controller.g.dart';

Duration? _neverRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _neverRetry)
class Profile extends _$Profile {
  @override
  Future<UserProfile> build() async {
    return ref.watch(profileRepositoryProvider).getUser();
  }

  Future<void> retry() async {
    ref.invalidateSelf();
  }
}
