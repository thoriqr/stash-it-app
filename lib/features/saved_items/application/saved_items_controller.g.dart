// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_items_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.

@ProviderFor(SavedItems)
final savedItemsProvider = SavedItemsProvider._();

/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.
final class SavedItemsProvider
    extends $AsyncNotifierProvider<SavedItems, SavedItemsState> {
  /// The Inbox listing: the first page, and any page after it.
  ///
  /// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
  /// has to genuinely **refetch** rather than re-read a cached future, and paging
  /// has to **append** to what is already on screen without the list ever passing
  /// through a loading state that would blank it.
  ///
  /// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
  /// provider, which would discard the loaded page every time the user leaves the
  /// Inbox for another destination and back. The listing is a recent-history
  /// screen, so keeping it is the point.
  SavedItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedItemsHash();

  @$internal
  @override
  SavedItems create() => SavedItems();
}

String _$savedItemsHash() => r'cd893d8edd37f9a6ae049f4245f3557789237bc6';

/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.

abstract class _$SavedItems extends $AsyncNotifier<SavedItemsState> {
  FutureOr<SavedItemsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SavedItemsState>, SavedItemsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedItemsState>, SavedItemsState>,
              AsyncValue<SavedItemsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
