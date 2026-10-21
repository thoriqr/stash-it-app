/// Fixtures for the verified `GET /search` contract.
///
/// One place that knows the wire shape, so a test asserting on behaviour does
/// not restate the envelope — and so every test decodes the same body the
/// backend actually sends.
///
/// **Exactly the documented fields, no more.** Search does not return
/// `description`, `platform`, `last_enriched_at`, `updated_at`, a top-level
/// `collection_id`, a score, collection counts, collection type or system
/// identity. A fixture that added one would let a client that reads it pass
/// against a body the server never sends.
class SearchFixtures {
  const SearchFixtures._();

  /// One saved-item result, with every documented key present.
  static Map<String, dynamic> savedItem({
    String id = 'item-1',
    String? title = 'Understanding CRDTs',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
    String createdAt = '2026-10-02T10:30:00Z',
  }) => {
    'id': id,
    'title': title,
    'url': url,
    'domain': domain,
    'image_url': imageUrl,
    'enrichment_status': enrichmentStatus,
    'collection': {'id': collectionId, 'name': collectionName},
    'created_at': createdAt,
  };

  /// One collection result. Only the two fields Search returns.
  static Map<String, dynamic> collection({
    String id = 'collection-1',
    String name = 'Camera Gear',
  }) => {'id': id, 'name': name};

  /// The whole `200` body. Both arrays are always present.
  static Map<String, dynamic> response({
    List<Map<String, dynamic>> savedItems = const [],
    List<Map<String, dynamic>> collections = const [],
  }) => {
    'data': {'saved_items': savedItems, 'collections': collections},
    'message': 'search completed successfully',
  };

  /// A successful search that matched nothing.
  static Map<String, dynamic> emptyResponse() => response();
}
