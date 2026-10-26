import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/network/token_provider.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/presentation/auth_entry_screen.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';

/// The signed-out landing screen.
///
/// The routing behaviour — where a signed-out or signed-in user is sent, and
/// that Sign in and Create an account do not bounce back — lives in
/// `test/app/auth_redirect_widget_test.dart`, because it needs the provider-built
/// router. This file covers the screen itself: its copy, the enabled
/// account-creation control, the one-shot expiry explanation, and the
/// small-screen layout.
void main() {
  const entryHeading = 'A place for things you find on the internet.';

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Pumps the screen with the app's real themes, so the tokens under test are
  /// the ones that ship.
  Future<void> pumpEntry(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const AuthEntryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Arms the one-shot session-ended flag through a real terminal path.
  ///
  /// A renewal with no stored refresh token can never succeed, so the controller
  /// ends the session, records that nothing has explained it yet, and throws
  /// `SessionExpiredException` (`session_controller.dart`, `_renew`). That is the
  /// same flag the router's expiry transition produces; the interceptor-driven
  /// path is covered in `session_expired_feedback_test.dart`. Using this one here
  /// keeps the screen test free of a scripted transport.
  Future<void> armSessionEnded() async {
    await expectLater(
      container.read(sessionControllerProvider.notifier).refreshAccessToken(),
      throwsA(isA<SessionExpiredException>()),
    );
  }

  testWidgets('shows the welcome copy and both actions', (tester) async {
    await pumpEntry(tester);

    expect(find.text(entryHeading), findsOneWidget);
    expect(
      find.text('Save a link from any browser, then find it again here.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Sign in'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Create an account'), findsOneWidget);

    // An expiry is only shown when one happened; a plain visit is not an event.
    expect(find.text(sessionEndedMessage), findsNothing);
  });

  testWidgets('the account-creation action is enabled', (tester) async {
    await pumpEntry(tester);

    final createAccount = find.widgetWithText(AppButton, 'Create an account');
    expect(
      tester.widget<AppButton>(createAccount).onPressed,
      isNotNull,
      reason: 'registration is reachable from this screen',
    );

    // No router is attached here; navigation itself is covered by
    // `auth_redirect_widget_test.dart`, which pumps the real router.
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows no Google sign-in UI', (tester) async {
    await pumpEntry(tester);

    expect(find.textContaining('Google'), findsNothing);
  });

  testWidgets('shows the session-ended warning once and can dismiss it', (
    tester,
  ) async {
    await armSessionEnded();
    await pumpEntry(tester);

    expect(find.text(sessionEndedMessage), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Dismiss'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text(sessionEndedMessage), findsNothing);
    expect(find.text(entryHeading), findsOneWidget);

    // A fresh mount is the stronger case: a new State runs initState again, and
    // only the consumed flag stops the message coming back.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpEntry(tester);
    expect(find.text(sessionEndedMessage), findsNothing);
  });

  testWidgets('does not overflow at 320x640 with the warning visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await armSessionEnded();
    await pumpEntry(tester);

    expect(find.text(sessionEndedMessage), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Sign in'), findsOneWidget);

    // The second action is below the fold on a narrow phone; the screen must
    // scroll to it rather than clip it.
    await tester.ensureVisible(
      find.widgetWithText(AppButton, 'Create an account'),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Create an account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
