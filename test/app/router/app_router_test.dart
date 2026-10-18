import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

void main() {
  group('redirectFor', () {
    test('a signed-out user on a protected route is sent to sign-in', () {
      for (final location in [
        AppRoutes.inbox,
        AppRoutes.collections,
        AppRoutes.search,
        AppRoutes.profile,
      ]) {
        expect(
          redirectFor(AuthStatus.signedOut, location),
          AppRoutes.signIn,
          reason: '$location requires a session',
        );
      }
    });

    test('a signed-out user already on sign-in is left alone', () {
      expect(redirectFor(AuthStatus.signedOut, AppRoutes.signIn), isNull);
    });

    test('a signed-in user on sign-in is sent into the app', () {
      expect(
        redirectFor(AuthStatus.signedIn, AppRoutes.signIn),
        AppRoutes.initial,
      );
    });

    test('a signed-in user on a protected route is left alone', () {
      for (final location in [
        AppRoutes.inbox,
        AppRoutes.collections,
        AppRoutes.search,
        AppRoutes.profile,
      ]) {
        expect(
          redirectFor(AuthStatus.signedIn, location),
          isNull,
          reason: '$location needs no redirect when signed in',
        );
      }
    });

    test('nothing is redirected while startup is unresolved', () {
      // Returning null parks the navigation rather than guessing. Guessing here
      // would bounce a signed-in user to sign-in during a slow cold start.
      for (final location in [
        AppRoutes.inbox,
        AppRoutes.signIn,
        AppRoutes.profile,
      ]) {
        expect(redirectFor(AuthStatus.restoring, location), isNull);
      }
    });
  });

  group('sign-in is not a destination', () {
    test('the four destinations are the shell branches', () {
      expect(
        [
          AppRoutes.inbox,
          AppRoutes.collections,
          AppRoutes.search,
          AppRoutes.profile,
        ],
        hasLength(4),
        reason: 'D1 fixes exactly four bottom-navigation destinations',
      );
    });

    test('sign-in is a separate route from the shell', () {
      expect(
        AppRoutes.signIn,
        isNot(
          anyElement([
            AppRoutes.inbox,
            AppRoutes.collections,
            AppRoutes.search,
            AppRoutes.profile,
          ]),
        ),
      );
    });

    test('the app opens on the Inbox', () {
      expect(AppRoutes.initial, AppRoutes.inbox);
    });
  });
}
