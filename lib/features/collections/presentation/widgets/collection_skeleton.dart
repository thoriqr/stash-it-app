import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/collection_summary.dart';
import 'collection_tile.dart';

final CollectionSummary _placeholder = CollectionSummary(
  id: 'skeleton',
  name: 'A long collection name that fills two lines',
  type: 'user',
  isUnsorted: false,
  savedItemsCount: 12,
  savedItemsCountOverflow: false,
  createdAt: DateTime(2026, 10, 2, 10, 30),
  updatedAt: DateTime(2026, 10, 2, 10, 30),
);

class CollectionSkeleton extends StatelessWidget {
  const CollectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(child: CollectionTile(item: _placeholder));
  }
}

class CollectionSkeletonList extends StatelessWidget {
  const CollectionSkeletonList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: count,
      itemBuilder: (context, index) => const CollectionSkeleton(),
    );
  }
}
