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
    await _submit(
      collectionId,
      const DeleteCollectionRequest(
        savedItemsAction: 'delete',
        targetCollectionId: null,
      ),
    );
  }

  /// Permanently removes [collectionId], moving its saved items into
  /// [targetCollectionId] first.
  ///
  /// **One request, one destination.** The action and target travel together in
  /// the body, so the backend performs the move and the delete in one
  /// transaction. There is no per-item move and no second request to recover a
  /// partial result.
  ///
  /// **The target is authoritative and already chosen.** It must differ from
  /// [collectionId]; the backend rejects the source as a target. Unsorted is a
  /// valid destination.
  ///
  /// Throws [ApiFailure] for every refusal. The two rollback outcomes are
  /// distinct: [ApiFailureCollectionDeleteTargetNotFound] leaves the source and
  /// its items untouched and the user can choose another destination, while
  /// [ApiFailureCollectionNotEmpty] means a concurrent insert made the backend
  /// abandon the whole transaction.
  Future<void> moveItemsAndDelete({
    required String collectionId,
    required String targetCollectionId,
  }) async {
    await _submit(
      collectionId,
      DeleteCollectionRequest(
        savedItemsAction: 'move',
        targetCollectionId: targetCollectionId,
      ),
    );
  }

  /// Sends one collection-delete request and translates every failure once.
  Future<void> _submit(
    String collectionId,
    DeleteCollectionRequest request,
  ) async {
    try {
      await api.delete(collectionId, request);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
