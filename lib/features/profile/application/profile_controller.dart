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

  /// Refetches the profile after an outcome that must be reconciled.
  ///
  /// Used for a write whose result the client could not establish, and for a
  /// credential-state mismatch. Both are answered by asking the server again
  /// rather than by editing the loaded profile to guess.
  void reconcile() {
    ref.invalidateSelf();
  }

  /// Replaces the loaded profile with the complete one a rename returned.
  ///
  /// **Only when a loaded profile exists and names the same account.** A response
  /// that arrives for a different id — impossible through this endpoint today,
  /// but cheaper to guard than to reason about — or one that arrives before the
  /// first read has completed is not applied: the provider is refetched instead.
  /// Applying it blindly would either replace one account's profile with another's
  /// or establish a "loaded" state the client never actually read.
  void applyUpdatedProfile(UserProfile updated) {
    if (!ref.mounted) return;

    final current = state;
    if (!current.hasValue || current.value!.id != updated.id) {
      ref.invalidateSelf();
      return;
    }

    state = AsyncData(updated);
  }

  /// Records a confirmed password create or change.
  ///
  /// **Called only after a `200`.** The flag is never set optimistically: a write
  /// whose outcome is unknown must leave the profile as it was and be reconciled
  /// by refetching, not by assuming the credential exists.
  void markPasswordCredentialSet() {
    if (!ref.mounted) return;

    final current = state;
    if (!current.hasValue) {
      ref.invalidateSelf();
      return;
    }

    final profile = current.value!;
    if (profile.hasPasswordCredential) return;

    state = AsyncData(profile.withPasswordCredential(true));
  }
}
