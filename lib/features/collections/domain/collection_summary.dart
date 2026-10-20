import 'package:flutter/foundation.dart';

/// Presentation model for a collection in the list.
@immutable
class CollectionSummary {
  const CollectionSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.isUnsorted,
    required this.savedItemsCount,
    required this.savedItemsCountOverflow,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final bool isUnsorted;
  final int savedItemsCount;
  final bool savedItemsCountOverflow;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Display count string - returns "99+" if overflow, otherwise the number.
  String get displayCount {
    if (savedItemsCountOverflow) return '99+';
    return savedItemsCount.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is CollectionSummary &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.isUnsorted == isUnsorted &&
      other.savedItemsCount == savedItemsCount &&
      other.savedItemsCountOverflow == savedItemsCountOverflow &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    isUnsorted,
    savedItemsCount,
    savedItemsCountOverflow,
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'CollectionSummary($name, count:$displayCount)';
}
