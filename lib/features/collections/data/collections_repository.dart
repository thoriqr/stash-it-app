import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/collection_page.dart';
import 'collections_mapper.dart';
import 'datasources/collections_api.dart';
import 'models/delete_collection_request.dart';

/// Repository for collections listing.
class CollectionsRepository {
  const CollectionsRepository({required this.api});

  final CollectionsApi api;

  /// One page of collections.
  Future<CollectionPage> list({
    String? sort,
    int? limit,
    String? cursor,
  }) async {
    try {
      final response = await api.list(sort: sort, limit: limit, cursor: cursor);
      final meta = response.meta;
      if (meta == null) {
        throw const ApiFailureUnreadableResponse();
      }

      return CollectionPage(
        items: collectionsFrom(response.data.collections),
        nextCursor: meta.cursor.nextCursor,
        hasMore: meta.cursor.hasMore,
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Permanently removes [collectionId], deleting the saved items in it.
  ///
  /// **The action is explicit and has no target.** The backend requires both
  /// fields and rejects a target alongside `delete`, so the body always carries
  /// `saved_items_action: "delete"` and `target_collection_id: null`.
  ///
  /// **No emptiness precondition is assumed.** The saved-item delete reported the
  /// collection empty, but another request may have filed an item before this
  /// runs. The backend's transaction detects that and answers
  /// `COLLECTION_NOT_EMPTY` after rolling back, which maps to
  /// [ApiFailureCollectionNotEmpty] — a known not-deleted outcome.
  ///
  /// A `200` has no payload this client needs; success is the status. A `2xx`
  /// whose body does not decode is therefore still unestablished only in the
  /// sense that no receipt was read, but the route's success body is empty by
  /// design, so the response DTO does not require `data`.
  ///
  /// Throws [ApiFailure] for every refusal, including
  /// [ApiFailureUnsortedCollectionProtected] and
  /// [ApiFailureCollectionNotEmpty].
  Future<void> delete({required String collectionId}) async {
    try {
      await api.delete(
        collectionId,
        const DeleteCollectionRequest(
          savedItemsAction: 'delete',
          targetCollectionId: null,
        ),
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
