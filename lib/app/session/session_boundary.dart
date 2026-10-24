import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/collections/application/collections_controller.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/saved_items/application/saved_items_controller.dart';

/// Drops user-scoped caches when the authenticated account changes.
///
/// The three keep-alive providers below would otherwise survive a sign-out in
/// the same process, because their lifetime is the container's rather than a
/// destination's. `Profile` has no auth dependency at all, so a later sign-in
/// would show the previous account's profile until its own request completed;
/// the Inbox and Collections would do the same with their rows and names.
///
/// **Status transitions, not token changes.** `AuthStatus` stays `signedIn`
/// across a token rotation, and a rotation is not an account change: invalidating
/// there would refetch data that is still correct. A session that ends
/// server-side still moves to `signedOut`, so the terminal path is covered
/// without reading the credential pair.
///
/// **Sign-out clears; it does not invalidate.** Invalidation would immediately
/// rebuild any provider a screen is still listening to, issuing an
/// unauthenticated request just to empty a cache. Clearing makes the old value
/// unavailable without a request. On a following sign-in the providers are
/// cleared again *before* invalidation, so the next account's request starts
/// from a value-less loading state rather than exposing the previous account's
/// data while it runs — `ref.invalidate` alone preserves the previous
/// `AsyncData` in Riverpod 3.4.
///
/// **Never initialized, never touched.** [Ref.exists] keeps this from creating a
/// provider — and therefore a request — merely to clear something no screen ever
/// read.
///
/// Without this, an in-flight `Profile` build is just one example of the leak:
/// it can complete after a session boundary. The invalidation on sign-in
/// disposes that build, so its late result is ignored and the new account's
/// build owns the state.
final Provider<void> sessionBoundaryProvider = Provider<void>((ref) {
  ref.listen<AuthStatus>(authStateProvider, (previous, next) {
    if (previous == AuthStatus.signedIn && next == AuthStatus.signedOut) {
      _clearUserScoped(ref);
      return;
    }

    if (previous == AuthStatus.signedOut && next == AuthStatus.signedIn) {
      _clearUserScoped(ref);
      _invalidateUserScoped(ref);
    }
  });
});

/// Empties every initialized user-scoped provider without a request.
void _clearUserScoped(Ref ref) {
  if (ref.exists(profileProvider)) {
    ref.read(profileProvider.notifier).clearForSessionChange();
  }
  if (ref.exists(savedItemsProvider)) {
    ref.read(savedItemsProvider.notifier).clearForSessionChange();
  }
  if (ref.exists(collectionsProvider)) {
    ref.read(collectionsProvider.notifier).clearForSessionChange();
  }
}

/// Rebuilds every initialized user-scoped provider under the new session.
///
/// Called only after [_clearUserScoped], so the rebuild cannot surface the
/// previous account's value while it is loading.
void _invalidateUserScoped(Ref ref) {
  if (ref.exists(profileProvider)) ref.invalidate(profileProvider);
  if (ref.exists(savedItemsProvider)) ref.invalidate(savedItemsProvider);
  if (ref.exists(collectionsProvider)) ref.invalidate(collectionsProvider);
}
