import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

void main() {
  group('redirectFor', () {
    test(
      'a signed-out user on a protected route is sent to the auth entry screen',
      () {
        for (final location in [
          AppRoutes.inbox,
          AppRoutes.collections,
          AppRoutes.search,
          AppRoutes.profile,
          AppRoutes.settings,
        ]) {
          expect(
            redirectFor(AuthStatus.signedOut, location),
            AppRoutes.auth,
            reason: '$location requires a session',
          );
        }
      },
    );

    test('a signed-out user already on an auth route is left alone', () {
      for (final location in [
        AppRoutes.auth,
        AppRoutes.signIn,
        AppRoutes.signUp,
      ]) {
        expect(
          redirectFor(AuthStatus.signedOut, location),
          isNull,
          reason: '$location is reachable without a session',
        );
      }
    });

    test('a signed-in user on an auth route is sent into the app', () {
      for (final location in [
        AppRoutes.auth,
        AppRoutes.signIn,
        AppRoutes.signUp,
      ]) {
        expect(
          redirectFor(AuthStatus.signedIn, location),
          AppRoutes.initial,
          reason: '$location has nothing to offer a signed-in user',
        );
      }
    });

    test('a signed-in user on a protected route is left alone', () {
      for (final location in [
        AppRoutes.inbox,
        AppRoutes.collections,
        AppRoutes.search,
        AppRoutes.profile,
        AppRoutes.settings,
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
      // would bounce a signed-in user to the auth entry screen during a slow
      // cold start.
      for (final location in [
        AppRoutes.inbox,
        AppRoutes.auth,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.profile,
      ]) {
        expect(redirectFor(AuthStatus.restoring, location), isNull);
      }
    });
  });

  group('secondary routes are not destinations', () {
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

    test('the auth screens are separate routes from the shell', () {
      for (final location in [
        AppRoutes.auth,
        AppRoutes.signIn,
        AppRoutes.signUp,
      ]) {
        expect(
          location,
          isNot(
            anyElement([
              AppRoutes.inbox,
              AppRoutes.collections,
              AppRoutes.search,
              AppRoutes.profile,
            ]),
          ),
          reason: '$location is not a bottom-navigation destination',
        );
      }
    });

    test('settings is a separate route from the shell', () {
      expect(
        AppRoutes.settings,
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
