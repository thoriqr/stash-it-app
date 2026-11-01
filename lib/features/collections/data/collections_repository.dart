import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/collection_page.dart';
import 'collections_mapper.dart';
import 'datasources/collections_api.dart';
import 'models/delete_collection_request.dart';

/// Repository for collection listing and deletion operations.
class CollectionsRepository {
  const CollectionsRepository({required this.api});

  final CollectionsApi api;

  /// Fetches one page of collections.
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

  /// Deletes [collectionId] and its saved items.
  ///
  /// Sends an explicit `delete` action with a null target. Both fields are
  /// required by the request contract, and a target must not accompany `delete`.
  ///
  /// The collection may become non-empty between the user's check and this
  /// request. In that case, the operation is rejected without deleting anything
  /// and [ApiFailureCollectionNotEmpty] is thrown.
  ///
  /// A successful response does not require a response payload. Refusals,
  /// including [ApiFailureUnsortedCollectionProtected] and
  /// [ApiFailureCollectionNotEmpty], are surfaced as [ApiFailure].
  Future<void> delete({required String collectionId}) async {
    await _submit(
      collectionId,
      const DeleteCollectionRequest(
        savedItemsAction: 'delete',
        targetCollectionId: null,
      ),
    );
  }

  /// Moves saved items from [collectionId] to [targetCollectionId], then deletes
  /// the source collection.
  ///
  /// The move and deletion are performed as one operation. The target must
  /// differ from the source; Unsorted is a valid destination.
  ///
  /// Refusals are surfaced as [ApiFailure]. If the target no longer exists,
  /// [ApiFailureCollectionDeleteTargetNotFound] is thrown and the source remains
  /// unchanged. If a concurrent insert makes the source non-empty in a way that
  /// prevents deletion, [ApiFailureCollectionNotEmpty] is thrown and the
  /// operation is not partially applied.
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

  /// Sends a collection deletion request and translates API and decoding errors.
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
