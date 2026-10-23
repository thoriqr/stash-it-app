import 'package:dio/dio.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';

/// A collections repository whose pages are supplied by the test.
///
/// Each entry is a [CollectionPage] or an error to throw. Entries are read in
/// order and the last one repeats. Extending the concrete repository keeps the
/// production class interface-free, exactly as [FakeSavedItemsRepository] does.
///
/// [deleteResults] is read the same way. A `null` entry is a successful delete;
/// any other entry is thrown. Empty means the delete is not scripted, and reaching
/// it is a `StateError`.
class FakeCollectionsRepository extends CollectionsRepository {
  FakeCollectionsRepository({
    required this.results,
    this.deleteResults = const [],
    this.onDelete,
  }) : assert(results.isNotEmpty, 'provide at least one page or error'),
       super(api: CollectionsApi(Dio()));

  final List<Object> results;

  /// A `null` for success, or an error to throw.
  final List<Object?> deleteResults;

  /// An optional handler for one collection delete, used to hold it open.
  final Future<void> Function(String collectionId)? onDelete;

  int listCalls = 0;
  int deleteCalls = 0;

  /// The collection ids passed to [delete], in order.
  final List<String> deleteIds = [];

  /// The sort values passed to [list], in order.
  final List<String?> sorts = [];

  /// The limit values passed to [list], in order.
  final List<int?> limits = [];

  /// The cursor values passed to [list], in order.
  final List<String?> cursors = [];

  @override
  Future<CollectionPage> list({
    String? sort,
    int? limit,
    String? cursor,
  }) async {
    sorts.add(sort);
    limits.add(limit);
    cursors.add(cursor);
    listCalls++;

    final result =
        results[listCalls - 1 < results.length
            ? listCalls - 1
            : results.length - 1];

    if (result is CollectionPage) return result;
    throw result;
  }

  @override
  Future<void> delete({required String collectionId}) async {
    deleteCalls++;
    deleteIds.add(collectionId);

    final handler = onDelete;
    if (handler != null) return handler(collectionId);

    if (deleteResults.isEmpty) {
      throw StateError(
        'FakeCollectionsRepository has no delete result scripted',
      );
    }

    final result =
        deleteResults[deleteCalls - 1 < deleteResults.length
            ? deleteCalls - 1
            : deleteResults.length - 1];

    if (result == null) return;
    throw result;
  }
}
