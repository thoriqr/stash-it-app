// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_saved_items_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One collection's saved items, with cursor pagination.
///
/// **Keyed by collection id and auto-dispose.** The detail is transient screen
/// state: it belongs to one visit to one collection and must not outlive the
/// route. This is the opposite of `collectionsProvider`, which is keep-alive
/// because Collections is a retained destination. Pushing the saved-item detail on
/// top does **not** dispose this: the collection screen stays mounted, so the
/// provider is still watched and the loaded pages and scroll position survive.
///
/// **The read is the screen's whole purpose.** Opening a collection issues exactly
/// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
/// writes, because the endpoint is read-only and looking at a collection is not a
/// reason to fetch anything.

@ProviderFor(CollectionSavedItems)
final collectionSavedItemsProvider = CollectionSavedItemsFamily._();

/// One collection's saved items, with cursor pagination.
///
/// **Keyed by collection id and auto-dispose.** The detail is transient screen
/// state: it belongs to one visit to one collection and must not outlive the
/// route. This is the opposite of `collectionsProvider`, which is keep-alive
/// because Collections is a retained destination. Pushing the saved-item detail on
/// top does **not** dispose this: the collection screen stays mounted, so the
/// provider is still watched and the loaded pages and scroll position survive.
///
/// **The read is the screen's whole purpose.** Opening a collection issues exactly
/// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
/// writes, because the endpoint is read-only and looking at a collection is not a
/// reason to fetch anything.
final class CollectionSavedItemsProvider
    extends
        $AsyncNotifierProvider<
          CollectionSavedItems,
          CollectionSavedItemsState
        > {
  /// One collection's saved items, with cursor pagination.
  ///
  /// **Keyed by collection id and auto-dispose.** The detail is transient screen
  /// state: it belongs to one visit to one collection and must not outlive the
  /// route. This is the opposite of `collectionsProvider`, which is keep-alive
  /// because Collections is a retained destination. Pushing the saved-item detail on
  /// top does **not** dispose this: the collection screen stays mounted, so the
  /// provider is still watched and the loaded pages and scroll position survive.
  ///
  /// **The read is the screen's whole purpose.** Opening a collection issues exactly
  /// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
  /// writes, because the endpoint is read-only and looking at a collection is not a
  /// reason to fetch anything.
  CollectionSavedItemsProvider._({
    required CollectionSavedItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: _neverRetry,
         name: r'collectionSavedItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionSavedItemsHash();

  @override
  String toString() {
    return r'collectionSavedItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CollectionSavedItems create() => CollectionSavedItems();

  @override
  bool operator ==(Object other) {
    return other is CollectionSavedItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionSavedItemsHash() =>
    r'dca003ff5500e20fc9a2a133722f53c5e22f5431';

/// One collection's saved items, with cursor pagination.
///
/// **Keyed by collection id and auto-dispose.** The detail is transient screen
/// state: it belongs to one visit to one collection and must not outlive the
/// route. This is the opposite of `collectionsProvider`, which is keep-alive
/// because Collections is a retained destination. Pushing the saved-item detail on
/// top does **not** dispose this: the collection screen stays mounted, so the
/// provider is still watched and the loaded pages and scroll position survive.
///
/// **The read is the screen's whole purpose.** Opening a collection issues exactly
/// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
/// writes, because the endpoint is read-only and looking at a collection is not a
/// reason to fetch anything.

final class CollectionSavedItemsFamily extends $Family
    with
        $ClassFamilyOverride<
          CollectionSavedItems,
          AsyncValue<CollectionSavedItemsState>,
          CollectionSavedItemsState,
          FutureOr<CollectionSavedItemsState>,
          String
        > {
  CollectionSavedItemsFamily._()
    : super(
        retry: _neverRetry,
        name: r'collectionSavedItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One collection's saved items, with cursor pagination.
  ///
  /// **Keyed by collection id and auto-dispose.** The detail is transient screen
  /// state: it belongs to one visit to one collection and must not outlive the
  /// route. This is the opposite of `collectionsProvider`, which is keep-alive
  /// because Collections is a retained destination. Pushing the saved-item detail on
  /// top does **not** dispose this: the collection screen stays mounted, so the
  /// provider is still watched and the loaded pages and scroll position survive.
  ///
  /// **The read is the screen's whole purpose.** Opening a collection issues exactly
  /// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
  /// writes, because the endpoint is read-only and looking at a collection is not a
  /// reason to fetch anything.

  CollectionSavedItemsProvider call(String collectionId) =>
      CollectionSavedItemsProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionSavedItemsProvider';
}

/// One collection's saved items, with cursor pagination.
///
/// **Keyed by collection id and auto-dispose.** The detail is transient screen
/// state: it belongs to one visit to one collection and must not outlive the
/// route. This is the opposite of `collectionsProvider`, which is keep-alive
/// because Collections is a retained destination. Pushing the saved-item detail on
/// top does **not** dispose this: the collection screen stays mounted, so the
/// provider is still watched and the loaded pages and scroll position survive.
///
/// **The read is the screen's whole purpose.** Opening a collection issues exactly
/// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
/// writes, because the endpoint is read-only and looking at a collection is not a
/// reason to fetch anything.

abstract class _$CollectionSavedItems
    extends $AsyncNotifier<CollectionSavedItemsState> {
  late final _$args = ref.$arg as String;
  String get collectionId => _$args;

  FutureOr<CollectionSavedItemsState> build(String collectionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CollectionSavedItemsState>,
              CollectionSavedItemsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CollectionSavedItemsState>,
                CollectionSavedItemsState
              >,
              AsyncValue<CollectionSavedItemsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
