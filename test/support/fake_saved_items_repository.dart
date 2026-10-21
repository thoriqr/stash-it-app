import 'package:dio/dio.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// A saved-items repository whose reads and writes are supplied by the test.
///
/// Extends the concrete repository rather than implementing an interface,
/// because the production class deliberately has no interface for one
/// implementation (`AGENTS.md` §2). The overridden methods are the whole of what
/// the Inbox, Detail and move sheet use; the inherited `create` is never reached
/// by these tests and would fail loudly if it were.
///
/// [detailResults] is read in order, with the last entry repeating, so a test can
/// script "fail, then succeed" without counting calls by hand — the same shape
/// as [FakeHttpAdapter.onSequence]. An entry is either a [SavedItemSummary] or an
/// error to throw. [moveResults] follows the same rule.
class FakeSavedItemsRepository extends SavedItemsRepository {
  FakeSavedItemsRepository({
    SavedItemPage? listPage,
    required this.detailResults,
    this.moveResults = const [],
    this.onMove,
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
  )?
  onMove;

  int listCalls = 0;
  int detailCalls = 0;
  int moveCalls = 0;

  /// The ids passed to [getById], in order.
  final List<String> detailIds = [];

  /// What was submitted to [moveToCollection], in order.
  final List<({String savedItemId, String collectionName})> moveRequests = [];

  @override
  Future<SavedItemPage> list({String? cursor}) async {
    listCalls++;
    return listPage;
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
  }) async {
    moveCalls++;
    moveRequests.add((
      savedItemId: savedItemId,
      collectionName: collectionName,
    ));

    final handler = onMove;
    if (handler != null) return handler(savedItemId, collectionName);

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
