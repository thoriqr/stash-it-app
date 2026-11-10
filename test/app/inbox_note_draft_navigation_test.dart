import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/inbox/presentation/widgets/inbox_note_composer_sheet.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';

import '../support/fake_collections_repository.dart';
import '../support/fake_http.dart';
import '../support/fake_saved_items_repository.dart';
import '../support/pending_urls.dart';

/// The retained Inbox branch keeps the manual note draft while the user visits
/// another destination, without persisting it or sharing it with other flows.
void main() {
  testWidgets('a note draft survives switching destinations', (tester) async {
    final saved = FakeSavedItemsRepository(
      listPage: const SavedItemPage(
        items: [],
        nextCursor: null,
        hasMore: false,
      ),
      createResults: const [null],
    );
    final collections = FakeCollectionsRepository(
      results: const [
        CollectionPage(items: [], nextCursor: null, hasMore: false),
      ],
    );
    final router = createAppRouter();
    addTearDown(router.dispose);
    final pendingStore = await testPendingUrlStore();

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          pendingUrlStoreProvider.overrideWithValue(pendingStore),
          savedItemsRepositoryProvider.overrideWithValue(saved),
          collectionsRepositoryProvider.overrideWithValue(collections),
        ],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add a personal note'));
    await tester.pumpAndSettle();

    final composerField = find.descendant(
      of: find.byType(InboxNoteComposerSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(composerField, 'Draft kept across tabs');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Draft kept across tabs'), findsOneWidget);

    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Draft kept across tabs'), findsOneWidget);
    expect(find.text('Add a personal note'), findsNothing);
  });
}
