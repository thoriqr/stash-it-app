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

  /// Drops the loaded profile at an authentication boundary.
  ///
  /// **An [AsyncLoading] reset, not an invalidation.** Invalidation rebuilds the
  /// provider while keeping the previous `AsyncData` readable, and a rebuild is a
  /// request. This changes the state's *kind* instead: every consumer here treats
  /// only `AsyncData` as a loaded account, so the previous profile stops being
  /// rendered without an unauthenticated fetch on sign-out. A following sign-in
  /// clears and then invalidates from the session boundary.
  ///
  /// Note that Riverpod merges the previous value into a new `AsyncLoading` —
  /// `hasValue` stays true while loading. That is why account-ownership checks
  /// below test the `AsyncData` subtype rather than `hasValue`: a loading value
  /// can still carry the previous account's profile.
  void clearForSessionChange() {
    if (!ref.mounted) return;
    state = const AsyncLoading();
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
    // `AsyncData`, not `hasValue`: a loading state can carry the previous
    // account's profile, and applying a response to it would publish that
    // account as this session's loaded data.
    if (current is! AsyncData<UserProfile> || current.value.id != updated.id) {
      ref.invalidateSelf();
      return;
    }

    state = AsyncData(updated);
  }

  /// Records a confirmed password create or change for [accountId].
  ///
  /// **Called only after a `200`.** The flag is never set optimistically: a write
  /// whose outcome is unknown must leave the profile as it was and be reconciled
  /// by refetching, not by assuming the credential exists.
  ///
  /// **The completion must belong to the profile on screen.** A write issued by
  /// one account can complete after a session boundary has put another account's
  /// profile in this provider. Applying its flag blindly would claim that the
  /// current account has a password it may not have. A mismatched id therefore
  /// changes nothing and refetches nothing.
  ///
  /// Returns whether the loaded profile was updated (or already recorded the
  /// credential). The caller uses this to decide whether its success notice still
  /// describes the account on screen.
  bool markPasswordCredentialSet({required String accountId}) {
    if (!ref.mounted) return false;

    // `AsyncData`, not `hasValue`: while another account's profile is loading,
    // Riverpod carries the previous account's value inside the `AsyncLoading`.
    // Treating that as loaded would apply this write to the wrong account.
    final current = state;
    if (current is! AsyncData<UserProfile>) return false;

    final profile = current.value;
    if (profile.id != accountId) return false;
    if (profile.hasPasswordCredential) return true;

    state = AsyncData(profile.withPasswordCredential(true));
    return true;
  }
}
