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

  /// The whole `200` body of `GET /saved-items/{id}`.
  ///
  /// **The collection is a sibling of the item here**, not nested inside it as
  /// the listing reports it. The item's twelve fields are otherwise identical, so
  /// this reuses [item] and removes only the nested object rather than restating
  /// the shape and letting the two drift.
  ///
  /// There is no `meta`: the route reads one item and has nothing to paginate.
  static Map<String, dynamic> detail({
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
  }) {
    final savedItem = item(
      id: id,
      url: url,
      domain: domain,
      platform: platform,
      title: title,
      description: description,
      imageUrl: imageUrl,
      collectionId: collectionId,
      collectionName: collectionName,
      enrichmentStatus: enrichmentStatus,
      lastEnrichedAt: lastEnrichedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    )..remove('collection');

    return {
      'data': {
        'saved_item': savedItem,
        'collection': {'id': collectionId, 'name': collectionName},
      },
      'message': 'saved item retrieved successfully',
    };
  }

  /// The whole `200` body of `POST /saved-items/{id}/enrich`.
  ///
  /// **The saved item is the detail shape with no collection anywhere.** The
  /// enrich route never changes membership, so there is no nested `collection`
  /// inside the item and no sibling object beside it — and no `meta`. [item]
  /// supplies the twelve fields, then the nested object is removed rather than
  /// restating the shape in a second place.
  ///
  /// A `failed` status is expressed here as a `200` with `enrichment_status:
  /// failed`; that is the contract, not a fixture convenience.
  static Map<String, dynamic> enriched({
    String id = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? platform = 'web',
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String collectionId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String enrichmentStatus = 'completed',
    String? lastEnrichedAt = '2026-10-02T10:31:00Z',
    String createdAt = '2026-10-02T10:30:00Z',
    String updatedAt = '2026-10-02T10:31:00Z',
  }) {
    final savedItem = item(
      id: id,
      url: url,
      domain: domain,
      platform: platform,
      title: title,
      description: description,
      imageUrl: imageUrl,
      collectionId: collectionId,
      enrichmentStatus: enrichmentStatus,
      lastEnrichedAt: lastEnrichedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    )..remove('collection');

    return {
      'data': {'saved_item': savedItem},
      'message': 'saved item enriched successfully',
    };
  }

  /// The whole `200` body of `PUT /saved-items/{id}/collection`.
  ///
  /// **No `meta`**, and `data.saved_item` deliberately omits `description`,
  /// `image_url`, `enrichment_status` and `last_enriched_at`: the move neither
  /// reads nor writes enrichment. [collectionCreated] and [alreadyInCollection]
  /// are mutually exclusive in the contract; a test can still pass an impossible
  /// pair to check that the client does not turn it into a false create claim.
  static Map<String, dynamic> moved({
    String savedItemId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? platform = 'web',
    String? title = 'Understanding CRDTs',
    String collectionId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String collectionName = 'Wishlist',
    bool collectionCreated = false,
    bool alreadyInCollection = false,
    String createdAt = '2026-10-02T10:30:00Z',
    String updatedAt = '2026-10-02T10:31:00Z',
  }) => {
    'data': {
      'collection': {
        'id': collectionId,
        'name': collectionName,
        'type': 'user',
        'created_at': createdAt,
        'updated_at': updatedAt,
      },
      'saved_item': {
        'id': savedItemId,
        'url': url,
        'domain': domain,
        'platform': platform,
        'title': title,
        'collection_id': collectionId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      },
      'collection_created': collectionCreated,
      'already_in_collection': alreadyInCollection,
    },
    'message': 'saved item moved into collection successfully',
  };

  /// The whole `200` body of `DELETE /saved-items/{id}`.
  ///
  /// **The three flags are directly inside `data`**, not nested under a
  /// `saved_item`. They report what the delete left behind; they do not delete the
  /// collection.
  static Map<String, dynamic> deleted({
    String collectionId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    bool collectionEmpty = true,
    bool collectionDeletable = true,
  }) => {
    'data': {
      'collection_id': collectionId,
      'collection_empty': collectionEmpty,
      'collection_deletable': collectionDeletable,
    },
    'message': 'saved item deleted successfully',
  };

  /// The whole `201` body of `POST /saved-items`.
  ///
  /// **Exactly the four documented fields**, with no `domain`, `title`,
  /// `platform`, `created_at` or nested `collection`: the backend's create
  /// representation is deliberately minimal, and a fixture that added fields
  /// would let a client that reads them pass against a body the server never
  /// sends.
  static Map<String, dynamic> created({
    String id = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String url = 'https://example.com/articles/crdts-explained',
    String collectionId = '01a0f359-093b-737a-963a-80f7ca6768ed',
    String enrichmentStatus = 'pending',
  }) => {
    'data': {
      'saved_item': {
        'id': id,
        'url': url,
        'collection_id': collectionId,
        'enrichment_status': enrichmentStatus,
      },
    },
    'message': 'saved item created successfully',
  };
}
