import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/presentation/sign_in_screen.dart';
import 'package:stash_it_app/features/collections/presentation/collections_screen.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_screen.dart';
import 'package:stash_it_app/features/profile/presentation/password_screen.dart';
import 'package:stash_it_app/features/profile/presentation/profile_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/collection_saved_items_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/saved_item_detail_screen.dart';
import 'package:stash_it_app/features/search/presentation/search_screen.dart';
import 'package:stash_it_app/features/settings/presentation/settings_screen.dart';

part 'app_router.g.dart';

/// The application router.
///
/// Owned by Riverpod rather than a top-level `final` for two reasons: the
/// redirect needs a `Ref` to read auth state, and the router must be rebuilt
/// when the session changes so `refreshListenable` fires. A top-level singleton
/// could do neither — it has no `Ref`, and one built once would keep a
/// `refreshListenable` that outlives any particular session.
///
/// D1 fixes four destinations: Inbox, Collections, Search, Profile. They are
/// peers, so they sit in a `StatefulShellRoute.indexedStack` and each destination
/// keeps its own navigation state as the user moves between them.
///
/// The pending-URL queue is deliberately absent here: D18 and D25 place it as a
/// section inside the Inbox, not as a fifth destination.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = AuthRefreshNotifier(ref);

  // `GoRouter.dispose` removes its listener from `refreshListenable` but does
  // not dispose the notifier, so the subscription is closed here. Without this
  // the listener outlives the router and fires into a disposed delegate.
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.initial,
    refreshListenable: notifier,
    redirect: (context, state) =>
        redirectFor(ref.read(authStateProvider), state.matchedLocation),
    routes: _routes,
  );
}

/// Sends the user to sign-in, or back into the app.
///
/// A pure function of the session and the current location, so the rule can be
/// tested exhaustively without pumping a router — and so there is exactly one
/// statement of it rather than one per call site.
///
/// **Redirects, not per-screen checks** (`AGENTS.md` §2, rule 5). A screen that
/// guards itself can be reached by a route that does not, and the gap shows up
/// only as a flash of protected content.
///
/// Returns null to leave navigation alone.
String? redirectFor(AuthStatus auth, String location) {
  // Startup has not settled. Returning null parks the navigation rather than
  // guessing. In practice `bootstrap` has already answered by the first frame,
  // so this is a guard rather than a state the user sees.
  if (!auth.isResolved) return null;

  final atSignIn = location == AppRoutes.signIn;

  if (auth.isSignedOut) {
    // Everything except sign-in needs a session. Pending URLs are held behind
    // this gate and surface on return (D6); that queue is not built yet, and
    // this redirect is what will later release it.
    return atSignIn ? null : AppRoutes.signIn;
  }

  // Signed in and looking at sign-in: there is nothing to sign in to.
  if (atSignIn) return AppRoutes.initial;

  return null;
}

final List<RouteBase> _routes = [
  GoRoute(
    path: AppRoutes.signIn,
    builder: (context, state) => const SignInScreen(),
  ),
  // A top-level route, not a shell branch: Settings is pushed above the shell
  // and popped back to the destination that opened it. The redirect above still
  // protects it like every route except sign-in.
  GoRoute(
    path: AppRoutes.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
  // The saved-item detail, also outside the shell. It is not a fifth
  // destination: it is pushed from a row and popped back to the destination that
  // opened it. `createAppRouter` builds the same `_routes`, so tests exercise the
  // same tree; only the production router adds the auth redirect.
  //
  // The id is a path parameter, not query state, so a detail location names one
  // item and nothing else.
  GoRoute(
    path: AppRoutes.savedItemDetailPattern,
    builder: (context, state) {
      final extra = state.extra;
      return SavedItemDetailScreen(
        itemId: state.pathParameters['id']!,
        // Only a collection contents screen supplies this. Inbox, Search and a
        // direct entry leave it null, so they keep the ordinary single pop.
        originCollectionId: extra is SavedItemDetailOrigin
            ? extra.collectionId
            : null,
      );
    },
  ),
  // One collection's saved items, outside the shell for the same reason as the
  // saved-item detail above: it is pushed from a collection tile and popped back
  // to the Collections destination, which keeps its sort choice and scroll
  // position while the detail is on top of it.
  //
  // `/collections/:id` cannot compete with the Collections branch's
  // `/collections`: they differ in segment count, so the branch is matched only
  // by the exact location.
  GoRoute(
    path: AppRoutes.collectionDetailPattern,
    builder: (context, state) =>
        CollectionSavedItemsScreen(collectionId: state.pathParameters['id']!),
  ),
  // Password create/change, outside the shell for the same reason: it is pushed
  // from Profile and popped back to the retained Profile branch. The route reads
  // the loaded profile for its mode; a direct entry has no shell page beneath it,
  // so the screen falls back to Profile on Back.
  GoRoute(
    path: AppRoutes.password,
    builder: (context, state) => const PasswordScreen(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        _AppShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.inbox,
            builder: (context, state) => const InboxScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.collections,
            builder: (context, state) => const CollectionsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),
];

/// Bridges Riverpod's auth state into the [Listenable] `GoRouter` expects.
///
/// `GoRouter` takes a `Listenable` and nothing else, so this is the adapter
/// between the two. It notifies rather than re-creating the router, so
/// navigation state survives a sign-in or sign-out.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthStatus>(authStateProvider, (previous, next) {
      if (previous != next) notifyListeners();
    });
  }

  late final ProviderSubscription<AuthStatus> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// The frame shared by every destination: the destination's own `Scaffold` above
/// a navigation bar that switches between the four branches.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Collections',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Builds a router for a test, isolated from any other test's history.
///
/// Tests that pump [StashItApp] with an explicit router get one with no
/// navigation history carried in from a previous case.
GoRouter createAppRouter() =>
    GoRouter(initialLocation: AppRoutes.initial, routes: _routes);
