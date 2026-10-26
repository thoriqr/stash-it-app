// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_collection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The destructive collection flow: one request, chosen by the disposition the
/// user confirmed.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// collection deletion is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when the sheet or route rebuilds.
///
/// **The two actions are separate methods rather than one parameterised call.**
/// An empty collection has no destination to name, and a non-empty one must name
/// the destination the user picked. Keeping them apart makes it impossible for a
/// caller to send `delete` with a target or `move` without one.
///
/// **No cache is invalidated.** Loaded listings are edited in place through
/// their own reconciliation methods: the Inbox drops or rewrites the rows it
/// already holds, and the Collections list loses the source collection without
/// resetting its sort. A successful bulk move then refreshes that list so the
/// destination's count is authoritative. Search is deliberately untouched.

@ProviderFor(CollectionDeletion)
final collectionDeletionProvider = CollectionDeletionProvider._();

/// The destructive collection flow: one request, chosen by the disposition the
/// user confirmed.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// collection deletion is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when the sheet or route rebuilds.
///
/// **The two actions are separate methods rather than one parameterised call.**
/// An empty collection has no destination to name, and a non-empty one must name
/// the destination the user picked. Keeping them apart makes it impossible for a
/// caller to send `delete` with a target or `move` without one.
///
/// **No cache is invalidated.** Loaded listings are edited in place through
/// their own reconciliation methods: the Inbox drops or rewrites the rows it
/// already holds, and the Collections list loses the source collection without
/// resetting its sort. A successful bulk move then refreshes that list so the
/// destination's count is authoritative. Search is deliberately untouched.
final class CollectionDeletionProvider
    extends $NotifierProvider<CollectionDeletion, bool> {
  /// The destructive collection flow: one request, chosen by the disposition the
  /// user confirmed.
  ///
  /// **One request per explicit user action.** The state is a plain `bool` — "a
  /// collection deletion is in flight" — set synchronously before the first
  /// `await`, so a double tap cannot issue two requests. It is keep-alive so a
  /// request already sent is not abandoned when the sheet or route rebuilds.
  ///
  /// **The two actions are separate methods rather than one parameterised call.**
  /// An empty collection has no destination to name, and a non-empty one must name
  /// the destination the user picked. Keeping them apart makes it impossible for a
  /// caller to send `delete` with a target or `move` without one.
  ///
  /// **No cache is invalidated.** Loaded listings are edited in place through
  /// their own reconciliation methods: the Inbox drops or rewrites the rows it
  /// already holds, and the Collections list loses the source collection without
  /// resetting its sort. A successful bulk move then refreshes that list so the
  /// destination's count is authoritative. Search is deliberately untouched.
  CollectionDeletionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionDeletionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionDeletionHash();

  @$internal
  @override
  CollectionDeletion create() => CollectionDeletion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$collectionDeletionHash() =>
    r'f561aa8f237fe98350d8c09cc8c7d304a16849da';

/// The destructive collection flow: one request, chosen by the disposition the
/// user confirmed.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// collection deletion is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when the sheet or route rebuilds.
///
/// **The two actions are separate methods rather than one parameterised call.**
/// An empty collection has no destination to name, and a non-empty one must name
/// the destination the user picked. Keeping them apart makes it impossible for a
/// caller to send `delete` with a target or `move` without one.
///
/// **No cache is invalidated.** Loaded listings are edited in place through
/// their own reconciliation methods: the Inbox drops or rewrites the rows it
/// already holds, and the Collections list loses the source collection without
/// resetting its sort. A successful bulk move then refreshes that list so the
/// destination's count is authoritative. Search is deliberately untouched.

abstract class _$CollectionDeletion extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
