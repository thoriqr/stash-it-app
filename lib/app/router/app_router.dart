import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/presentation/auth_entry_screen.dart';
import 'package:stash_it_app/features/auth/presentation/finalize_registration_screen.dart';
import 'package:stash_it_app/features/auth/presentation/finalize_social_registration_screen.dart';
import 'package:stash_it_app/features/auth/presentation/google_account_link_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_finalize_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_pin_screen.dart';
import 'package:stash_it_app/features/auth/presentation/password_reset_request_screen.dart';
import 'package:stash_it_app/features/auth/presentation/pin_entry_screen.dart';
import 'package:stash_it_app/features/auth/presentation/sign_in_screen.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart';
import 'package:stash_it_app/features/collections/presentation/collections_screen.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_screen.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_urls_screen.dart';
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

/// Sends the user to the auth entry screen, or back into the app.
///
/// A pure function of the session and the current location, so the rule can be
/// tested exhaustively without pumping a router — and so there is exactly one
/// statement of it rather than one per call site.
///
/// **Redirects, not per-screen checks** (`AGENTS.md` §2, rule 5). A screen that
/// guards itself can be reached by a route that does not, and the gap shows up
/// only as a flash of protected content.
///
/// **All three signed-out auth routes are allowed while signed out.** The entry
/// screen's Sign in and Create an account actions navigate to `/sign-in` and
/// `/sign-up`; allow-listing only the entry screen would send those navigations
/// straight back and loop.
///
/// Returns null to leave navigation alone.
String? redirectFor(AuthStatus auth, String location) {
  // Startup has not settled. Returning null parks the navigation rather than
  // guessing. In practice `bootstrap` has already answered by the first frame,
  // so this is a guard rather than a state the user sees.
  if (!auth.isResolved) return null;

  final atAuthEntry = location == AppRoutes.auth;
  final atSignIn = location == AppRoutes.signIn;
  final atSignUp = location == AppRoutes.signUp;
  final atSignUpVerify = location.startsWith('/sign-up/verify/');
  final atFinalize = location == AppRoutes.finalizeRegistration;
  final atFinalizeSocial = location == AppRoutes.finalizeSocialRegistration;
  final atGoogleAccountLink = location.startsWith(
    '/sign-in/google/account-link/',
  );
  final atForgotPassword = location == AppRoutes.forgotPassword;
  final atForgotPasswordVerify = location.startsWith(
    '/forgot-password/verify/',
  );
  final atForgotPasswordFinalize = location == AppRoutes.forgotPasswordFinalize;

  if (auth.isSignedOut) {
    // The auth screens and the device-local URL list are reachable without a
    // session. The local list reads no account data and never calls the API.
    if (atAuthEntry ||
        atSignIn ||
        atSignUp ||
        atSignUpVerify ||
        atFinalize ||
        atFinalizeSocial ||
        atGoogleAccountLink ||
        atForgotPassword ||
        atForgotPasswordVerify ||
        atForgotPasswordFinalize ||
        location == AppRoutes.savedOnDevice) {
      return null;
    }
    return AppRoutes.auth;
  }

  // Signed in and looking at an auth screen: there is nothing to sign in to or
  // register.
  if (atAuthEntry ||
      atSignIn ||
      atSignUp ||
      atSignUpVerify ||
      atFinalize ||
      atFinalizeSocial ||
      atGoogleAccountLink ||
      atForgotPassword ||
      atForgotPasswordVerify ||
      atForgotPasswordFinalize) {
    return AppRoutes.initial;
  }

  return null;
}

final List<RouteBase> _routes = [
  GoRoute(
    path: AppRoutes.auth,
    builder: (context, state) => const AuthEntryScreen(),
  ),
  GoRoute(
    path: AppRoutes.signIn,
    builder: (context, state) {
      final extra = state.extra;
      return SignInScreen(contextualMessage: extra is String ? extra : null);
    },
  ),
  GoRoute(
    path: AppRoutes.signUp,
    builder: (context, state) => const SignUpScreen(),
  ),
  GoRoute(
    path: AppRoutes.signUpVerify,
    builder: (context, state) {
      // The manual route carries the email as a String. The social route uses
      // the typed in-memory object so the same generic PIN screen can branch to
      // social finalization without changing the manual route's extra.
      final extra = state.extra;
      final social = extra is SocialRegistrationVerification;
      return PinEntryScreen(
        verificationId: state.pathParameters['verificationId']!,
        email: social
            ? extra.email
            : extra is String && extra.isNotEmpty
            ? extra
            : null,
        socialRegistration: social,
        suggestedDisplayName: social ? extra.displayName : null,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.finalizeRegistration,
    redirect: (context, state) {
      final extra = state.extra;
      if (extra is! String || extra.isEmpty) {
        return AppRoutes.signUp;
      }
      return null;
    },
    builder: (context, state) =>
        FinalizeRegistrationScreen(continuationToken: state.extra as String),
  ),
  GoRoute(
    path: AppRoutes.finalizeSocialRegistration,
    redirect: (context, state) {
      final extra = state.extra;
      if (extra is! FinalizeSocialRegistrationArgs ||
          extra.continuationToken.isEmpty) {
        return AppRoutes.auth;
      }
      return null;
    },
    builder: (context, state) {
      final extra = state.extra! as FinalizeSocialRegistrationArgs;
      return FinalizeSocialRegistrationScreen(
        continuationToken: extra.continuationToken,
        suggestedDisplayName: extra.suggestedDisplayName,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.googleAccountLinkPattern,
    redirect: (context, state) {
      final extra = state.extra;
      if (extra is! GoogleAccountLinkArgs || extra.idToken.isEmpty) {
        return AppRoutes.auth;
      }
      return null;
    },
    builder: (context, state) {
      final extra = state.extra! as GoogleAccountLinkArgs;
      return GoogleAccountLinkScreen(
        confirmationId: state.pathParameters['confirmationId']!,
        idToken: extra.idToken,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.forgotPassword,
    builder: (context, state) => PasswordResetRequestScreen(
      startWithEmailForm: state.extra is PasswordResetEmailSelection,
    ),
  ),
  GoRoute(
    path: AppRoutes.forgotPasswordVerify,
    builder: (context, state) {
      // The email is local scoping only; the continuation token is persisted in
      // secure storage by the PIN screen and never travels in the location.
      final extra = state.extra;
      return PasswordResetPinScreen(
        verificationId: state.pathParameters['verificationId']!,
        email: extra is String && extra.isNotEmpty ? extra : null,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.forgotPasswordFinalize,
    builder: (context, state) => const PasswordResetFinalizeScreen(),
  ),
  // A top-level route, not a shell branch: Settings is pushed above the shell
  // and popped back to the destination that opened it. The redirect above still
  // protects it like every route except the two auth screens.
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
  // The device-local fallback list. It is not an authenticated destination: the
  // screen reads only local storage, and the redirect allows it while signed
  // out so the auth entry screen can open it before any account exists.
  GoRoute(
    path: AppRoutes.savedOnDevice,
    builder: (context, state) => const PendingUrlsScreen(),
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
