// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_saved_item_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The destructive saved-item flow: one item delete, then at most one optional
/// collection delete.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// destructive request is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when a route rebuilds.
///
/// **The item delete is never retried as part of a collection-delete failure.**
/// The two operations have separate outcomes. Once the item delete succeeds, the
/// collection step can fail for any reason without revisiting the item.
///
/// **No cache is invalidated to remove one row.** Loaded listings are edited in
/// place through their own tombstone-aware methods, preserving their pages,
/// cursors and sort. Only a confirmed collection deletion invalidates that
/// collection's contents provider, because a mounted collection screen must stop
/// showing a collection that no longer exists.

@ProviderFor(DeleteSavedItem)
final deleteSavedItemProvider = DeleteSavedItemProvider._();

/// The destructive saved-item flow: one item delete, then at most one optional
/// collection delete.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// destructive request is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when a route rebuilds.
///
/// **The item delete is never retried as part of a collection-delete failure.**
/// The two operations have separate outcomes. Once the item delete succeeds, the
/// collection step can fail for any reason without revisiting the item.
///
/// **No cache is invalidated to remove one row.** Loaded listings are edited in
/// place through their own tombstone-aware methods, preserving their pages,
/// cursors and sort. Only a confirmed collection deletion invalidates that
/// collection's contents provider, because a mounted collection screen must stop
/// showing a collection that no longer exists.
final class DeleteSavedItemProvider
    extends $NotifierProvider<DeleteSavedItem, bool> {
  /// The destructive saved-item flow: one item delete, then at most one optional
  /// collection delete.
  ///
  /// **One request per explicit user action.** The state is a plain `bool` — "a
  /// destructive request is in flight" — set synchronously before the first
  /// `await`, so a double tap cannot issue two requests. It is keep-alive so a
  /// request already sent is not abandoned when a route rebuilds.
  ///
  /// **The item delete is never retried as part of a collection-delete failure.**
  /// The two operations have separate outcomes. Once the item delete succeeds, the
  /// collection step can fail for any reason without revisiting the item.
  ///
  /// **No cache is invalidated to remove one row.** Loaded listings are edited in
  /// place through their own tombstone-aware methods, preserving their pages,
  /// cursors and sort. Only a confirmed collection deletion invalidates that
  /// collection's contents provider, because a mounted collection screen must stop
  /// showing a collection that no longer exists.
  DeleteSavedItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteSavedItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteSavedItemHash();

  @$internal
  @override
  DeleteSavedItem create() => DeleteSavedItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$deleteSavedItemHash() => r'f2477d715e49013858bf3371d7034cbec37ba5fd';

/// The destructive saved-item flow: one item delete, then at most one optional
/// collection delete.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// destructive request is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when a route rebuilds.
///
/// **The item delete is never retried as part of a collection-delete failure.**
/// The two operations have separate outcomes. Once the item delete succeeds, the
/// collection step can fail for any reason without revisiting the item.
///
/// **No cache is invalidated to remove one row.** Loaded listings are edited in
/// place through their own tombstone-aware methods, preserving their pages,
/// cursors and sort. Only a confirmed collection deletion invalidates that
/// collection's contents provider, because a mounted collection screen must stop
/// showing a collection that no longer exists.

abstract class _$DeleteSavedItem extends $Notifier<bool> {
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
