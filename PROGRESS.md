## Collections list integration (2026-10-21)

### Verified backend contract (stash-it-backend)
- Route: CollectionRoutes registers GET / on /collections group (mounted at /collections) -> handler.ListCollections (internal/api/collection/routes.go, handler.go). Auth required per route.
- Response envelope: {"data": {"collections": [...]}, "message": "...", "meta": {"cursor": {"next_cursor": null|string, "has_more": bool}}} with meta.cursor always present; next_cursor explicitly null on final/empty page.
- ListedCollection fields (response.go ListedCollectionResponse): id, name, type, system_key (*string) for Unsorted identification by system_key=="unsorted" (D2, never by display name); saved_items_count (int64, never null) - whole collection count identical on every page (0-99 exact; 99 with overflow true means "99 or more"); saved_items_count_overflow (bool); created_at, updated_at.
- Ordering: server-provided order; Unsorted pinned first under every sort (sort defaults "newest", supports "newest"/"oldest"/"name"). Cursor pagination (opaque). limit defaults 20, capped 50. No total count. INVALID_CURSOR if token invalid/wrong sort/version.
- Errors: INVALID_COLLECTION_SORT, INVALID_CURSOR, VALIDATION_ERROR (limit), INVALID_AUTHORIZATION_HEADER, INVALID_ACCESS_TOKEN, ACCESS_TOKEN_EXPIRED, INTERNAL_SERVER_ERROR.

### Flutter implementation
- Feature structure under lib/features/collections/ mirroring SavedItems: data (datasources/collections_api.dart @RestApi over appDio, models/listed_collection.dart Freezed DTOs, collections_mapper.dart, collections_repository.dart, collections_providers.dart), domain (collection_summary.dart with displayCount returning "99+" if overflow else number, collection_page.dart), application (collections_state.dart Freezed with sort, collections_controller.dart @Riverpod keepAlive retry:_neverRetry with sort state, cursor pagination/load-more/dedup), presentation (collections_screen.dart replacing placeholder with dropdown sort selector, grid list with refresh, empty, error-with-retry, pagination), widgets (collection_tile.dart with count badge, Unsorted marked by system_key with accent border and "system" tag, collection_skeleton.dart).
- Sorting: Added dropdown in Collections screen (Newest/Oldest/Name) sending exact API values (newest/oldest/name), default newest. Changing sort calls controller.setSort() which increments list version, sets loading state, refetches first page with new sort (no cursor reuse), and guards against stale responses. loadMore/refresh use current sort. Cursor reset on sort change.
- Counts: displayed per entry from backend whole-collection count; overflow true -> "99+". No local counting.
- Ordering/Unsorted: server order preserved; identified by system_key only, no hardcoded ID.
- States: loading skeleton, populated grid, empty, error-with-retry (typed ApiFailure), pagination indicator.
- Tests/generation: dart run build_runner build completed. dart format applied. flutter analyze clean. flutter test all passed (436 tests). SavedItems tests still pass.

### Notes
- Product decisions had older note against showing counts; implemented per task instruction to display counts with overflow as 99+. Discrepancy noted here without editing decision history.

### Remaining limitations
- Collection detail screen and mutations not implemented.
- Sort UI added; no additional sort controls.
