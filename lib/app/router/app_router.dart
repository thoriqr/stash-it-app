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
/// Managed by Riverpod so the router can react to authentication state changes
/// through [AuthRefreshNotifier]. Keeping the router alive preserves its
/// navigation state throughout the application lifecycle.
///
/// The four main destinations use [StatefulShellRoute.indexedStack]. Each
/// destination retains its own navigation state when switching between tabs.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = AuthRefreshNotifier(ref);

  // GoRouter removes its listener when disposed but does not dispose the
  // notifier itself. Close the notifier's Riverpod subscription with the router.
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.initial,
    refreshListenable: notifier,
    redirect: (context, state) =>
        redirectFor(ref.read(authStateProvider), state.matchedLocation),
    routes: _routes,
  );
}

/// Determines whether navigation should be redirected based on authentication.
///
/// This pure function centralizes route access rules so they can be tested
/// independently of the router.
///
/// Signed-out users can access authentication routes and the device-local
/// saved URL list. Other destinations require an authenticated session.
/// Signed-in users are redirected away from authentication routes.
///
/// Returns null when the current location is allowed.
String? redirectFor(AuthStatus auth, String location) {
  // Wait until authentication state has been restored before making a
  // navigation decision.
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
    // Authentication routes and device-local saved URLs are available without
    // an account or an authenticated session.
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

  // Authenticated users should not return to authentication screens.
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
      // Manual registration passes the email as a String. Social registration
      // passes a typed object containing the email and suggested display name.
      // Both flows share the same PIN screen.
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
      // The email is used only for local display. The continuation token is
      // persisted by the PIN screen and is not included in the route location.
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
  // Settings is pushed above the shell so returning restores the previously
  // selected destination and its navigation state.
  GoRoute(
    path: AppRoutes.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
  // Saved-item details are pushed above the shell and return to the destination
  // that opened them.
  //
  // The optional origin identifies the collection when the detail was opened
  // from a collection's contents. Other entry points leave it null.
  GoRoute(
    path: AppRoutes.savedItemDetailPattern,
    builder: (context, state) {
      final extra = state.extra;
      return SavedItemDetailScreen(
        itemId: state.pathParameters['id']!,
        originCollectionId: extra is SavedItemDetailOrigin
            ? extra.collectionId
            : null,
      );
    },
  ),
  // Collection contents are pushed above the shell so the Collections
  // destination retains its scroll position and other navigation state.
  GoRoute(
    path: AppRoutes.collectionDetailPattern,
    builder: (context, state) =>
        CollectionSavedItemsScreen(collectionId: state.pathParameters['id']!),
  ),
  // Password creation and changes are pushed above the shell so returning
  // restores the Profile destination.
  //
  // When opened directly without a previous route, the screen handles its
  // own fallback navigation.
  GoRoute(
    path: AppRoutes.password,
    builder: (context, state) => const PasswordScreen(),
  ),
  // This screen uses device-local storage only and remains accessible without
  // an authenticated session.
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

/// Adapts authentication state changes to the [Listenable] expected by GoRouter.
///
/// Notifies the router when authentication state changes so its redirect logic
/// can run again without recreating the router or losing navigation state.
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

/// Shared layout for the main application destinations.
///
/// Displays the active destination above the bottom navigation bar.
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

/// Creates an isolated router for tests.
///
/// Each test receives a fresh router without navigation history from previous
/// test cases.
GoRouter createAppRouter() =>
    GoRouter(initialLocation: AppRoutes.initial, routes: _routes);
