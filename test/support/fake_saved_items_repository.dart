import 'package:dio/dio.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// A saved-items repository whose reads are supplied by the test.
///
/// Extends the concrete repository rather than implementing an interface,
/// because the production class deliberately has no interface for one
/// implementation (`AGENTS.md` §2). The overridden methods are the whole of what
/// the Inbox and Detail screens use; the inherited `create` is never reached by
/// these tests and would fail loudly if it were.
///
/// [detailResults] is read in order, with the last entry repeating, so a test can
/// script "fail, then succeed" without counting calls by hand — the same shape
/// as [FakeHttpAdapter.onSequence]. An entry is either a [SavedItemSummary] or an
/// error to throw.
class FakeSavedItemsRepository extends SavedItemsRepository {
  FakeSavedItemsRepository({
    SavedItemPage? listPage,
    required this.detailResults,
  }) : assert(detailResults.isNotEmpty, 'provide at least one detail result'),
       listPage =
           listPage ??
           const SavedItemPage(items: [], nextCursor: null, hasMore: false),
       super(api: SavedItemsApi(Dio()));

  final SavedItemPage listPage;

  /// A `SavedItemSummary` to return, or an error to throw.
  final List<Object> detailResults;

  int listCalls = 0;
  int detailCalls = 0;

  /// The ids passed to [getById], in order.
  final List<String> detailIds = [];

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
}
