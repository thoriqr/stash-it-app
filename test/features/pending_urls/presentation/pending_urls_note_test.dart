import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_urls_screen.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/note_composer_sheet.dart';

import '../../../support/fake_http.dart';
import '../../../support/pending_urls.dart';

void main() {
  testWidgets('a local note previews in two lines and edits locally', (
    tester,
  ) async {
    const url = 'https://example.com/articles/1';
    final store = await testPendingUrlStore();
    await store.upsert(
      url: url,
      uncertain: true,
      note: 'First line\nSecond line\nThird line',
    );

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          pendingUrlStoreProvider.overrideWithValue(store),
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          restoredTokensProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PendingUrlsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your note'), findsOneWidget);
    final preview = tester.widget<Text>(find.textContaining('First line'));
    expect(preview.maxLines, 2);

    await tester.tap(find.textContaining('First line'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteComposerSheet), findsOneWidget);
    final field = find.descendant(
      of: find.byType(NoteComposerSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'Edited note');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteComposerSheet), findsNothing);
    expect(find.text('Edited note'), findsOneWidget);
    expect((await store.readAll()).entries.single.note, 'Edited note');
  });

  testWidgets('an empty note offers the add affordance', (tester) async {
    final store = await testPendingUrlStore();
    await store.upsert(url: 'https://example.com/articles/2', uncertain: true);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          pendingUrlStoreProvider.overrideWithValue(store),
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          restoredTokensProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PendingUrlsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add a personal note'), findsOneWidget);

    await tester.tap(find.text('Add a personal note'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteComposerSheet), findsOneWidget);
  });
}
