import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/inbox/presentation/widgets/inbox_intake.dart';
import 'package:stash_it_app/features/inbox/presentation/widgets/inbox_note_composer_sheet.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../../support/fake_http.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The manual intake's optional-note interaction, without a real transport.
///
/// These are behavioral checks: the composer, confirmation choices, request
/// payload and draft cleanup. No layout or visual property is asserted.
void main() {
  const url = 'https://example.com/articles/1';
  const note = 'Compare this with other options.\nCheck the specifications.';

  Future<FakeSavedItemsRepository> pumpIntake(
    WidgetTester tester, {
    List<Object?> createResults = const [null],
  }) async {
    final saved = FakeSavedItemsRepository(
      listPage: const SavedItemPage(
        items: [],
        nextCursor: null,
        hasMore: false,
      ),
      createResults: createResults,
    );

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          savedItemsRepositoryProvider.overrideWithValue(saved),
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          restoredTokensProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: InboxIntake()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return saved;
  }

  Finder composerField() => find.descendant(
    of: find.byType(InboxNoteComposerSheet),
    matching: find.byType(TextField),
  );

  Future<void> composeNote(WidgetTester tester, String text) async {
    await tester.tap(find.text('Add a personal note'));
    await tester.pumpAndSettle();
    await tester.enterText(composerField(), text);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  }

  Future<void> enterUrl(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), url);
    await tester.pump();
  }

  testWidgets('no note saves directly and keeps the URL-only request', (
    tester,
  ) async {
    final saved = await pumpIntake(tester);

    await enterUrl(tester);
    await tester.tap(find.text('Save URL'));
    await tester.pumpAndSettle();

    expect(find.text('Save URL with this note?'), findsNothing);
    expect(saved.createCalls, 1);
    expect(saved.createUrls, [url]);
    expect(saved.createNotes, [null]);
  });

  testWidgets('Save with note sends one POST and clears the draft', (
    tester,
  ) async {
    final saved = await pumpIntake(tester);

    await composeNote(tester, note);
    expect(find.text(note), findsOneWidget);

    await enterUrl(tester);
    await tester.tap(find.text('Save URL'));
    await tester.pumpAndSettle();

    expect(find.text('Save URL with this note?'), findsOneWidget);
    await tester.tap(find.text('Save with note'));
    await tester.pumpAndSettle();

    expect(saved.createCalls, 1);
    expect(saved.createUrls, [url]);
    expect(saved.createNotes, [note]);
    expect(find.text('Add a personal note'), findsOneWidget);
    expect(find.text(note), findsNothing);
  });

  testWidgets('Save without note sends only the URL and clears the draft', (
    tester,
  ) async {
    final saved = await pumpIntake(tester);

    await composeNote(tester, note);
    await enterUrl(tester);
    await tester.tap(find.text('Save URL'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save without note'));
    await tester.pumpAndSettle();

    expect(saved.createCalls, 1);
    expect(saved.createUrls, [url]);
    expect(saved.createNotes, [null]);
    expect(find.text('Add a personal note'), findsOneWidget);
  });

  testWidgets('Cancel sends nothing and preserves URL and note', (
    tester,
  ) async {
    final saved = await pumpIntake(tester);

    await composeNote(tester, note);
    await enterUrl(tester);
    await tester.tap(find.text('Save URL'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(saved.createCalls, 0);
    expect(find.text(note), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      url,
    );
  });

  testWidgets('a failed save keeps the draft for another attempt', (
    tester,
  ) async {
    final saved = await pumpIntake(
      tester,
      createResults: [const ApiFailureServerFault()],
    );

    await composeNote(tester, note);
    await enterUrl(tester);
    await tester.tap(find.text('Save URL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save with note'));
    await tester.pumpAndSettle();

    expect(saved.createCalls, 1);
    expect(saved.createNotes, [note]);
    expect(find.text(note), findsOneWidget);
    expect(find.text('Add a personal note'), findsNothing);
  });

  testWidgets('clearing the composer returns to the add affordance', (
    tester,
  ) async {
    final saved = await pumpIntake(tester);

    await composeNote(tester, note);
    expect(find.text(note), findsOneWidget);

    await tester.tap(find.text(note));
    await tester.pumpAndSettle();
    await tester.enterText(composerField(), '');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(saved.createCalls, 0);
    expect(find.text('Add a personal note'), findsOneWidget);
    expect(find.text(note), findsNothing);
  });
}
