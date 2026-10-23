import 'package:dio/dio.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';

/// One recorded call to [FakeCollectionsRepository.moveItemsAndDelete].
typedef RecordedMove = ({String sourceId, String targetId});

/// A collections repository whose pages and writes are supplied by the test.
///
/// Each entry is a [CollectionPage] or an error to throw. Entries are read in
/// order and the last one repeats. Extending the concrete repository keeps the
/// production class interface-free, exactly as [FakeSavedItemsRepository] does.
///
/// [deleteResults] and [moveResults] are read the same way. A `null` entry is a
/// successful write; any other entry is thrown. Empty means the write is not
/// scripted, and reaching it is a `StateError`.
///
/// The two writes are scripted separately so a test can prove which one was
/// sent, and with what target, rather than assuming the disposition.
class FakeCollectionsRepository extends CollectionsRepository {
  FakeCollectionsRepository({
    required this.results,
    this.deleteResults = const [],
    this.moveResults = const [],
    this.onDelete,
    this.onMoveItemsAndDelete,
  }) : assert(results.isNotEmpty, 'provide at least one page or error'),
       super(api: CollectionsApi(Dio()));

  final List<Object> results;

  /// A `null` for success, or an error to throw.
  final List<Object?> deleteResults;

  /// A `null` for success, or an error to throw.
  final List<Object?> moveResults;

  /// An optional handler for one collection delete, used to hold it open.
  final Future<void> Function(String collectionId)? onDelete;

  /// An optional handler for one move-and-delete, used to hold it open.
  final Future<void> Function(String sourceId, String targetId)?
  onMoveItemsAndDelete;

  int listCalls = 0;
  int deleteCalls = 0;
  int moveCalls = 0;

  /// The collection ids passed to [delete], in order.
  final List<String> deleteIds = [];

  /// The source and target passed to [moveItemsAndDelete], in order.
  final List<RecordedMove> moves = [];

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

  @override
  Future<void> moveItemsAndDelete({
    required String collectionId,
    required String targetCollectionId,
  }) async {
    moveCalls++;
    moves.add((sourceId: collectionId, targetId: targetCollectionId));

    final handler = onMoveItemsAndDelete;
    if (handler != null) return handler(collectionId, targetCollectionId);

    if (moveResults.isEmpty) {
      throw StateError(
        'FakeCollectionsRepository has no moveItemsAndDelete result scripted',
      );
    }

    final result =
        moveResults[moveCalls - 1 < moveResults.length
            ? moveCalls - 1
            : moveResults.length - 1];

    if (result == null) return;
    throw result;
  }
}
