import 'package:dio/dio.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';

/// A collections repository whose pages are supplied by the test.
///
/// Each entry is a [CollectionPage] or an error to throw. Entries are read in
/// order and the last one repeats. Extending the concrete repository keeps the
/// production class interface-free, exactly as [FakeSavedItemsRepository] does.
class FakeCollectionsRepository extends CollectionsRepository {
  FakeCollectionsRepository({required this.results})
    : assert(results.isNotEmpty, 'provide at least one page or error'),
      super(api: CollectionsApi(Dio()));

  final List<Object> results;

  int listCalls = 0;

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
}
