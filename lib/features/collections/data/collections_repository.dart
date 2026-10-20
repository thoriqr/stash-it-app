import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/collection_page.dart';
import 'collections_mapper.dart';
import 'datasources/collections_api.dart';

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
}
