import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/features/profile/presentation/profile_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

final DateTime _joined = DateTime(2026, 4, 12, 12);

UserProfile _profile({
  required DateTime? createdAt,
  String displayName = 'Reader',
  String email = 'reader@example.com',
  bool hasPasswordCredential = true,
  List<UserIdentity> identities = const [],
}) {
  return UserProfile(
    id: 'user-1',
    email: email,
    displayName: displayName,
    hasPasswordCredential: hasPasswordCredential,
    createdAt: createdAt,
    identities: identities,
  );
}

/// Records the screen's sign-out call without touching the auth machinery.
class _RecordingAuthState extends AuthState {
  int signOutCalls = 0;

  @override
  AuthStatus build() => AuthStatus.signedIn;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required FutureOr<UserProfile> Function() load,
    _RecordingAuthState? auth,
  }) async {
    final container = ProviderContainer(
      overrides: [
        profileProvider.overrideWithBuild((_, _) => load()),
        if (auth != null) authStateProvider.overrideWith(() => auth),
      ],
      // Riverpod 3 retries failed providers by default; these tests drive the
      // provider into an error state deliberately.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ProfileScreen(),
        ),
      ),
    );
  }

  testWidgets('renders the available account information', (tester) async {
    await pumpProfile(tester, load: () async => _profile(createdAt: _joined));
    await tester.pumpAndSettle();

    // Once as the header and once as the Display name value.
    expect(find.text('Reader'), findsNWidgets(2));
    expect(find.text('reader@example.com'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('joined 12 Apr 2026'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Sign out'), findsOneWidget);
  });

  testWidgets('does not repeat the email when there is no display name', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      load: () async => _profile(createdAt: _joined, displayName: ''),
    );
    await tester.pumpAndSettle();

    expect(find.text('reader@example.com'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  for (final (hasPassword, label) in const [
    (true, 'Change password'),
    (false, 'Create password'),
  ]) {
    testWidgets(
      'renders "$label" when has_password_credential is $hasPassword',
      (tester) async {
        await pumpProfile(
          tester,
          load: () async =>
              _profile(createdAt: _joined, hasPasswordCredential: hasPassword),
        );
        await tester.pumpAndSettle();

        expect(find.text(label), findsOneWidget);
        expect(
          find.text(hasPassword ? 'Create password' : 'Change password'),
          findsNothing,
        );
      },
    );
  }

  testWidgets('renders readable identities with linked dates', (tester) async {
    await pumpProfile(
      tester,
      load: () async => _profile(
        createdAt: _joined,
        identities: [
          UserIdentity(
            provider: 'google',
            linkedAt: DateTime(2026, 1, 2, 12),
            emailSnapshot: 'onfile@example.com',
          ),
          const UserIdentity(provider: 'discord', linkedAt: null),
          UserIdentity(
            provider: 'github',
            linkedAt: null,
            emailSnapshot: 'octocat@example.com',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('linked 02 Jan 2026'), findsOneWidget);
    // The linked date is the note; the snapshot is not needed underneath it.
    expect(find.text('onfile@example.com'), findsNothing);

    // An unknown provider still renders safely, without inventing a date.
    expect(find.text('Discord'), findsOneWidget);

    // With no usable date, a snapshot is used when it adds information.
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('octocat@example.com'), findsOneWidget);

    expect(find.text('Linked'), findsNothing);
  });

  testWidgets('renders a compact empty state for no linked identities', (
    tester,
  ) async {
    await pumpProfile(tester, load: () async => _profile(createdAt: _joined));
    await tester.pumpAndSettle();

    expect(find.text('LINKED IDENTITIES'), findsOneWidget);
    expect(find.text('No accounts connected yet.'), findsOneWidget);
  });

  testWidgets('omits unparseable dates instead of fabricating them', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      load: () async => _profile(
        createdAt: null,
        identities: const [UserIdentity(provider: 'google', linkedAt: null)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('joined'), findsNothing);
    expect(find.textContaining('linked'), findsNothing);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('shows a compact progress indicator and keeps sign out working', (
    tester,
  ) async {
    final completer = Completer<UserProfile>();
    final auth = _RecordingAuthState();

    await pumpProfile(tester, load: () => completer.future, auth: auth);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading profile…'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is Skeletonizer),
      findsNothing,
    );

    final signOut = find.widgetWithText(AppButton, 'Sign out');
    expect(signOut, findsOneWidget);

    await tester.tap(signOut);
    await tester.pump();
    expect(auth.signOutCalls, 1);

    completer.complete(_profile(createdAt: _joined));
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error with a retry that refetches the profile', (
    tester,
  ) async {
    var loads = 0;
    final auth = _RecordingAuthState();

    await pumpProfile(
      tester,
      auth: auth,
      load: () {
        loads++;
        if (loads == 1) throw const ApiFailureTransport();
        return _profile(createdAt: _joined);
      },
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No connection. We could not load your profile.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Sign out'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Sign out'));
    await tester.pump();
    expect(auth.signOutCalls, 1);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text('reader@example.com'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('uses the shared read copy for a server fault', (tester) async {
    await pumpProfile(
      tester,
      load: () async => throw const ApiFailureServerFault(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('We could not reach the server. Try again shortly.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
  });

  testWidgets('USER_NOT_FOUND never offers signing in as the fix', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      load: () async =>
          throw const ApiFailureUserNotFound(code: 'USER_NOT_FOUND'),
    );
    await tester.pumpAndSettle();

    expect(find.text('This account is no longer available.'), findsOneWidget);
    expect(find.textContaining('Sign in again'), findsNothing);
  });

  testWidgets('both account actions meet the 48 px row target', (tester) async {
    await pumpProfile(tester, load: () async => _profile(createdAt: _joined));
    await tester.pumpAndSettle();

    final displayRow = find.ancestor(
      of: find.text('Display name'),
      matching: find.byType(InkWell),
    );
    final passwordRow = find.ancestor(
      of: find.text('Change password'),
      matching: find.byType(InkWell),
    );

    expect(tester.getSize(displayRow).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(passwordRow).height, greaterThanOrEqualTo(48));
  });

  testWidgets('the display-name row opens the editor with the raw value', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      load: () async => _profile(createdAt: _joined, displayName: '  Reader  '),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Display name'));
    await tester.pumpAndSettle();

    expect(find.text('Edit display name'), findsOneWidget);
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(
      field.controller?.text,
      '  Reader  ',
      reason: 'the sheet must propose the stored value, not a trimmed one',
    );
  });

  testWidgets('the password row pushes the dedicated password route', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profileProvider.overrideWithBuild(
          (_, _) async => _profile(createdAt: _joined),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, _) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.password,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('PASSWORD FORM'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    expect(find.text('PASSWORD FORM'), findsOneWidget);
  });
}
