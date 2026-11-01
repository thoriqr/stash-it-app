import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/collections/application/collections_controller.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/saved_items/application/saved_items_controller.dart';

/// Clears user-scoped caches when the authenticated session changes.
///
/// These keep-alive providers can outlive the route that first read them.
/// Without clearing their state, data from a previous account could remain
/// visible after sign-out or while the next account's data is loading.
///
/// Listens to authentication status transitions rather than token changes.
/// Token rotation does not change the account and must not trigger unnecessary
/// data reloads.
///
/// On sign-out, providers are cleared without invalidation to avoid rebuilding
/// them and issuing unauthenticated requests while their screens are still
/// listening.
///
/// On sign-in, providers are cleared before invalidation. This prevents
/// Riverpod from retaining their previous [AsyncData] while the new account's
/// requests are loading.
///
/// [Ref.exists] ensures that only initialized providers are touched. A
/// provider that has never been read is not created just to clear its state.
///
/// Invalidating on sign-in also disposes in-flight builds from the previous
/// session, preventing their results from updating the new session's state.
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

/// Clears initialized user-scoped providers without triggering requests.
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

/// Invalidates initialized user-scoped providers after their state is cleared.
void _invalidateUserScoped(Ref ref) {
  if (ref.exists(profileProvider)) ref.invalidate(profileProvider);
  if (ref.exists(savedItemsProvider)) ref.invalidate(savedItemsProvider);
  if (ref.exists(collectionsProvider)) ref.invalidate(collectionsProvider);
}
