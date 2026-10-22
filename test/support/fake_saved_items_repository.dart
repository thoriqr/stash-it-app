import 'package:dio/dio.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// A saved-items repository whose reads and writes are supplied by the test.
///
/// Extends the concrete repository rather than implementing an interface,
/// because the production class deliberately has no interface for one
/// implementation (`AGENTS.md` §2). The overridden methods are the whole of what
/// the Inbox, Detail, collection detail and move sheet use; the inherited `create`
/// is never reached by these tests and would fail loudly if it were.
///
/// [detailResults] is read in order, with the last entry repeating, so a test can
/// script "fail, then succeed" without counting calls by hand — the same shape
/// as [FakeHttpAdapter.onSequence]. An entry is either a [SavedItemSummary] or an
/// error to throw. [moveResults] and [collectionResults] follow the same rule.
class FakeSavedItemsRepository extends SavedItemsRepository {
  FakeSavedItemsRepository({
    SavedItemPage? listPage,
    required this.detailResults,
    this.moveResults = const [],
    this.onMove,
    this.collectionResults = const [],
    this.onListInCollection,
  }) : assert(detailResults.isNotEmpty, 'provide at least one detail result'),
       listPage =
           listPage ??
           const SavedItemPage(items: [], nextCursor: null, hasMore: false),
       super(api: SavedItemsApi(Dio()));

  final SavedItemPage listPage;

  /// A `SavedItemSummary` to return, or an error to throw.
  final List<Object> detailResults;

  /// A `MoveToCollectionResult` to return, or an error to throw.
  final List<Object> moveResults;

  /// An optional handler that can hold the move open or assert its arguments.
  final Future<MoveToCollectionResult> Function(
    String savedItemId,
    String collectionName,
    MoveToCollectionIntent intent,
  )?
  onMove;

  /// A `CollectionSavedItemsPage` to return, or an error to throw.
  ///
  /// Empty means the collection listing is not scripted; reaching it is then a
  /// `StateError` rather than a silent empty page, so a test that forgets to
  /// supply one fails loudly.
  final List<Object> collectionResults;

  /// An optional handler for one collection page.
  ///
  /// Used where a test needs the request held open, which a fixed list of results
  /// cannot express: the test closes over its own completer and returns
  /// `completer.future`.
  final Future<CollectionSavedItemsPage> Function(
    String collectionId,
    String? cursor,
  )?
  onListInCollection;

  int listCalls = 0;
  int detailCalls = 0;
  int moveCalls = 0;
  int collectionCalls = 0;

  /// The ids passed to [getById], in order.
  final List<String> detailIds = [];

  /// The collection ids passed to [listInCollection], in order.
  final List<String> collectionIds = [];

  /// The cursors passed to [listInCollection], in order.
  final List<String?> collectionCursors = [];

  /// What was submitted to [moveToCollection], in order.
  final List<
    ({String savedItemId, String collectionName, MoveToCollectionIntent intent})
  >
  moveRequests = [];

  @override
  Future<SavedItemPage> list({String? cursor}) async {
    listCalls++;
    return listPage;
  }

  @override
  Future<CollectionSavedItemsPage> listInCollection(
    String collectionId, {
    String? cursor,
  }) async {
    collectionCalls++;
    collectionIds.add(collectionId);
    collectionCursors.add(cursor);

    final handler = onListInCollection;
    if (handler != null) return handler(collectionId, cursor);

    if (collectionResults.isEmpty) {
      throw StateError(
        'FakeSavedItemsRepository has no collection result scripted',
      );
    }

    final result =
        collectionResults[collectionCalls - 1 < collectionResults.length
            ? collectionCalls - 1
            : collectionResults.length - 1];

    if (result is CollectionSavedItemsPage) return result;
    throw result;
  }

  @override
  Future<SavedItemSummary> getById(String id) async {
    detailCalls++;
    detailIds.add(id);

    final result =
        detailResults[detailCalls - 1 < detailResults.length
            ? detailCalls - 1
            : detailResults.length - 1];

    if (result is SavedItemSummary) return result;
    throw result;
  }

  @override
  Future<MoveToCollectionResult> moveToCollection({
    required String savedItemId,
    required String collectionName,
    required MoveToCollectionIntent intent,
  }) async {
    moveCalls++;
    moveRequests.add((
      savedItemId: savedItemId,
      collectionName: collectionName,
      intent: intent,
    ));

    final handler = onMove;
    if (handler != null) return handler(savedItemId, collectionName, intent);

    if (moveResults.isEmpty) {
      throw StateError('FakeSavedItemsRepository has no move result scripted');
    }

    final result =
        moveResults[moveCalls - 1 < moveResults.length
            ? moveCalls - 1
            : moveResults.length - 1];

    if (result is MoveToCollectionResult) return result;
    throw result;
  }
}
