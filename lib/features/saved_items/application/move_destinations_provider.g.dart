// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_destinations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every collection the current item can be moved into.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **All pages are followed.** The contract's default limit is 20 and its cap is
/// 50; a picker that stopped at the first page would omit destinations. A
/// `has_more: true` with no cursor is unreadable rather than complete, because
/// continuing is impossible and stopping would silently hide collections.
///
/// Rows are de-duplicated by id in the server's order. The server already sorts
/// by name; this provider does not sort again (**D4**).
///
/// **Every returned collection is kept, including system collections.** The
/// picker is a view of `GET /collections`; nothing here filters by `type`, name,
/// or `system_key` (**D2**). The current collection is excluded by id in the
/// sheet, because it is context rather than a destination.

@ProviderFor(moveDestinations)
final moveDestinationsProvider = MoveDestinationsProvider._();

/// Every collection the current item can be moved into.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **All pages are followed.** The contract's default limit is 20 and its cap is
/// 50; a picker that stopped at the first page would omit destinations. A
/// `has_more: true` with no cursor is unreadable rather than complete, because
/// continuing is impossible and stopping would silently hide collections.
///
/// Rows are de-duplicated by id in the server's order. The server already sorts
/// by name; this provider does not sort again (**D4**).
///
/// **Every returned collection is kept, including system collections.** The
/// picker is a view of `GET /collections`; nothing here filters by `type`, name,
/// or `system_key` (**D2**). The current collection is excluded by id in the
/// sheet, because it is context rather than a destination.

final class MoveDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CollectionSummary>>,
          List<CollectionSummary>,
          FutureOr<List<CollectionSummary>>
        >
    with
        $FutureModifier<List<CollectionSummary>>,
        $FutureProvider<List<CollectionSummary>> {
  /// Every collection the current item can be moved into.
  ///
  /// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
  /// Collections screen is keep-alive, has its own sort and pages, and silently
  /// swallows a failed `loadMore`. Reading it here would either display a stale
  /// first page as though it were complete or invoke state-changing methods on a
  /// destination the user is not looking at. This provider is created by the sheet,
  /// fetches `sort=name` from page one, and is discarded when the sheet closes, so
  /// reopening it always asks the server again.
  ///
  /// **All pages are followed.** The contract's default limit is 20 and its cap is
  /// 50; a picker that stopped at the first page would omit destinations. A
  /// `has_more: true` with no cursor is unreadable rather than complete, because
  /// continuing is impossible and stopping would silently hide collections.
  ///
  /// Rows are de-duplicated by id in the server's order. The server already sorts
  /// by name; this provider does not sort again (**D4**).
  ///
  /// **Every returned collection is kept, including system collections.** The
  /// picker is a view of `GET /collections`; nothing here filters by `type`, name,
  /// or `system_key` (**D2**). The current collection is excluded by id in the
  /// sheet, because it is context rather than a destination.
  MoveDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'moveDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveDestinationsHash();

  @$internal
  @override
  $FutureProviderElement<List<CollectionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CollectionSummary>> create(Ref ref) {
    return moveDestinations(ref);
  }
}

String _$moveDestinationsHash() => r'9beea6e81de681cc0b6e2ea5efea796fd80d55f6';
