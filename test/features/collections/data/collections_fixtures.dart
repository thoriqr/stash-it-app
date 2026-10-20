class CollectionsFixtures {
  const CollectionsFixtures._();

  static Map<String, dynamic> collection({
    String id = 'c1',
    String name = 'Reading List',
    String type = 'user',
    String? systemKey,
    int savedItemsCount = 5,
    bool savedItemsCountOverflow = false,
    String createdAt = '2026-10-01T10:00:00Z',
    String updatedAt = '2026-10-01T10:00:00Z',
  }) =>
      {
        'id': id,
        'name': name,
        'type': type,
        'system_key': systemKey,
        'saved_items_count': savedItemsCount,
        'saved_items_count_overflow': savedItemsCountOverflow,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static Map<String, dynamic> page({
    List<Map<String, dynamic>> collections = const [],
    String? nextCursor,
    bool hasMore = false,
  }) =>
      {
        'data': {'collections': collections},
        'message': 'collections retrieved successfully',
        'meta': {
          'cursor': {'has_more': hasMore, 'next_cursor': nextCursor},
        },
      };

  static Map<String, dynamic> emptyPage() => page();
}
