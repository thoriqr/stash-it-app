/// Fixtures for the documented `GET /saved-items` contract.
///
/// One place that knows the wire shape, so a test asserting on behaviour does
/// not restate the envelope — and so every test decodes the same thing the
/// backend actually sends.
class SavedItemsFixtures {
  const SavedItemsFixtures._();

  /// One fully-populated row, exactly as `ListedSavedItemResponse` documents it.
  static Map<String, dynamic> item({
    String id = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? platform = 'web',
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String collectionId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String collectionName = 'Camera Gear',
    String enrichmentStatus = 'completed',
    String? lastEnrichedAt = '2026-10-02T10:31:00Z',
    String createdAt = '2026-10-02T10:30:00Z',
    String updatedAt = '2026-10-02T10:31:00Z',
  }) => {
    'id': id,
    'url': url,
    'domain': domain,
    'platform': platform,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'collection_id': collectionId,
    'enrichment_status': enrichmentStatus,
    'last_enriched_at': lastEnrichedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'collection': {'id': collectionId, 'name': collectionName},
  };

  /// The whole `200` body.
  ///
  /// [nextCursor] null and [hasMore] false is the final page, which is the only
  /// shape where `next_cursor` is explicitly null.
  static Map<String, dynamic> page({
    List<Map<String, dynamic>> items = const [],
    String? nextCursor,
    bool hasMore = false,
  }) => {
    'data': {'saved_items': items},
    'message': 'saved items retrieved successfully',
    'meta': {
      'cursor': {'has_more': hasMore, 'next_cursor': nextCursor},
    },
  };

  /// An empty final page — what a user who has saved nothing receives.
  static Map<String, dynamic> emptyPage() => page();
}
