// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_destinations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bounded destination preview for the main Move to a collection sheet.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **Only one page is read.** The main sheet shows at most five rows and offers
/// `Browse all collections` when this page has more. The separate, paginated
/// picker follows `next_cursor` on demand; this provider must never fetch every
/// collection just to populate a bounded preview.
///
/// A `has_more: true` with no cursor is unreadable rather than complete, because
/// the sheet cannot tell whether `Browse all collections` can continue.
///
/// The server already sorts by name; this provider does not sort again (**D4**).
/// Every returned collection is kept, including system collections; the current
/// collection is excluded by id in the sheet because it is context, not a
/// destination (**D2**).

@ProviderFor(moveDestinations)
final moveDestinationsProvider = MoveDestinationsProvider._();

/// The bounded destination preview for the main Move to a collection sheet.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **Only one page is read.** The main sheet shows at most five rows and offers
/// `Browse all collections` when this page has more. The separate, paginated
/// picker follows `next_cursor` on demand; this provider must never fetch every
/// collection just to populate a bounded preview.
///
/// A `has_more: true` with no cursor is unreadable rather than complete, because
/// the sheet cannot tell whether `Browse all collections` can continue.
///
/// The server already sorts by name; this provider does not sort again (**D4**).
/// Every returned collection is kept, including system collections; the current
/// collection is excluded by id in the sheet because it is context, not a
/// destination (**D2**).

final class MoveDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CollectionPage>,
          CollectionPage,
          FutureOr<CollectionPage>
        >
    with $FutureModifier<CollectionPage>, $FutureProvider<CollectionPage> {
  /// The bounded destination preview for the main Move to a collection sheet.
  ///
  /// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
  /// Collections screen is keep-alive, has its own sort and pages, and silently
  /// swallows a failed `loadMore`. Reading it here would either display a stale
  /// first page as though it were complete or invoke state-changing methods on a
  /// destination the user is not looking at. This provider is created by the sheet,
  /// fetches `sort=name` from page one, and is discarded when the sheet closes, so
  /// reopening it always asks the server again.
  ///
  /// **Only one page is read.** The main sheet shows at most five rows and offers
  /// `Browse all collections` when this page has more. The separate, paginated
  /// picker follows `next_cursor` on demand; this provider must never fetch every
  /// collection just to populate a bounded preview.
  ///
  /// A `has_more: true` with no cursor is unreadable rather than complete, because
  /// the sheet cannot tell whether `Browse all collections` can continue.
  ///
  /// The server already sorts by name; this provider does not sort again (**D4**).
  /// Every returned collection is kept, including system collections; the current
  /// collection is excluded by id in the sheet because it is context, not a
  /// destination (**D2**).
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
  $FutureProviderElement<CollectionPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CollectionPage> create(Ref ref) {
    return moveDestinations(ref);
  }
}

String _$moveDestinationsHash() => r'59e9428e04f57ed00abda585db7c4728152143f4';
