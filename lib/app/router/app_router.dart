import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/collections/presentation/collections_screen.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_screen.dart';
import 'package:stash_it_app/features/profile/presentation/profile_screen.dart';
import 'package:stash_it_app/features/search/presentation/search_screen.dart';

/// The application router.
///
/// D1 fixes four destinations: Inbox, Collections, Search, Profile. They are
/// peers, so they sit in a `StatefulShellRoute.indexedStack` and each destination
/// keeps its own navigation state as the user moves between them.
///
/// The pending-URL queue is deliberately absent here: D18 and D25 place it as a
/// section inside the Inbox, not as a fifth destination.
final GoRouter appRouter = createAppRouter();

/// Builds a router with the current route structure.
///
/// Exposed so tests can supply a router that carries no navigation history
/// between test cases.
GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
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
  ],
);

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
