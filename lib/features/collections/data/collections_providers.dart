import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'collections_repository.dart';
import 'datasources/collections_api.dart';

/// Collections API client over appDio.
final Provider<CollectionsApi> collectionsApiProvider =
    Provider<CollectionsApi>(
      (ref) => CollectionsApi(ref.watch(appDioProvider)),
    );

/// Collections repository.
final Provider<CollectionsRepository> collectionsRepositoryProvider =
    Provider<CollectionsRepository>(
      (ref) => CollectionsRepository(api: ref.watch(collectionsApiProvider)),
    );
