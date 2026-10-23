// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_item_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The GET happens in [build] because opening the detail is precisely the read the
/// screen exists for. The route is not rate limited, so a visit costs one indexed
/// read and nothing else.
///
/// **A notifier rather than a plain `FutureProvider` for one reason:**
/// [applyEnrichment] has to replace the loaded value in place after a confirmed
/// re-read. Invalidating the provider instead would issue a second GET for
/// information the POST already returned, and a failed follow-up would replace a
/// successful re-read with the screen's error state. The notifier keeps the
/// completed POST authoritative.

@ProviderFor(SavedItemDetail)
final savedItemDetailProvider = SavedItemDetailFamily._();

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The GET happens in [build] because opening the detail is precisely the read the
/// screen exists for. The route is not rate limited, so a visit costs one indexed
/// read and nothing else.
///
/// **A notifier rather than a plain `FutureProvider` for one reason:**
/// [applyEnrichment] has to replace the loaded value in place after a confirmed
/// re-read. Invalidating the provider instead would issue a second GET for
/// information the POST already returned, and a failed follow-up would replace a
/// successful re-read with the screen's error state. The notifier keeps the
/// completed POST authoritative.
final class SavedItemDetailProvider
    extends $AsyncNotifierProvider<SavedItemDetail, SavedItemSummary> {
  /// One saved item, read fresh from `GET /saved-items/{id}`.
  ///
  /// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
  /// Search results: it is keyed by the item id, belongs to one visit, and must not
  /// outlive the route. This is the opposite of `savedItemsProvider`, which is
  /// keep-alive because the Inbox is a retained destination.
  ///
  /// The GET happens in [build] because opening the detail is precisely the read the
  /// screen exists for. The route is not rate limited, so a visit costs one indexed
  /// read and nothing else.
  ///
  /// **A notifier rather than a plain `FutureProvider` for one reason:**
  /// [applyEnrichment] has to replace the loaded value in place after a confirmed
  /// re-read. Invalidating the provider instead would issue a second GET for
  /// information the POST already returned, and a failed follow-up would replace a
  /// successful re-read with the screen's error state. The notifier keeps the
  /// completed POST authoritative.
  SavedItemDetailProvider._({
    required SavedItemDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: _neverRetry,
         name: r'savedItemDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savedItemDetailHash();

  @override
  String toString() {
    return r'savedItemDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SavedItemDetail create() => SavedItemDetail();

  @override
  bool operator ==(Object other) {
    return other is SavedItemDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedItemDetailHash() => r'47a13e4a393027abc32abe724ab80ea1266649e8';

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The GET happens in [build] because opening the detail is precisely the read the
/// screen exists for. The route is not rate limited, so a visit costs one indexed
/// read and nothing else.
///
/// **A notifier rather than a plain `FutureProvider` for one reason:**
/// [applyEnrichment] has to replace the loaded value in place after a confirmed
/// re-read. Invalidating the provider instead would issue a second GET for
/// information the POST already returned, and a failed follow-up would replace a
/// successful re-read with the screen's error state. The notifier keeps the
/// completed POST authoritative.

final class SavedItemDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          SavedItemDetail,
          AsyncValue<SavedItemSummary>,
          SavedItemSummary,
          FutureOr<SavedItemSummary>,
          String
        > {
  SavedItemDetailFamily._()
    : super(
        retry: _neverRetry,
        name: r'savedItemDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One saved item, read fresh from `GET /saved-items/{id}`.
  ///
  /// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
  /// Search results: it is keyed by the item id, belongs to one visit, and must not
  /// outlive the route. This is the opposite of `savedItemsProvider`, which is
  /// keep-alive because the Inbox is a retained destination.
  ///
  /// The GET happens in [build] because opening the detail is precisely the read the
  /// screen exists for. The route is not rate limited, so a visit costs one indexed
  /// read and nothing else.
  ///
  /// **A notifier rather than a plain `FutureProvider` for one reason:**
  /// [applyEnrichment] has to replace the loaded value in place after a confirmed
  /// re-read. Invalidating the provider instead would issue a second GET for
  /// information the POST already returned, and a failed follow-up would replace a
  /// successful re-read with the screen's error state. The notifier keeps the
  /// completed POST authoritative.

  SavedItemDetailProvider call(String id) =>
      SavedItemDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'savedItemDetailProvider';
}

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The GET happens in [build] because opening the detail is precisely the read the
/// screen exists for. The route is not rate limited, so a visit costs one indexed
/// read and nothing else.
///
/// **A notifier rather than a plain `FutureProvider` for one reason:**
/// [applyEnrichment] has to replace the loaded value in place after a confirmed
/// re-read. Invalidating the provider instead would issue a second GET for
/// information the POST already returned, and a failed follow-up would replace a
/// successful re-read with the screen's error state. The notifier keeps the
/// completed POST authoritative.

abstract class _$SavedItemDetail extends $AsyncNotifier<SavedItemSummary> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<SavedItemSummary> build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SavedItemSummary>, SavedItemSummary>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedItemSummary>, SavedItemSummary>,
              AsyncValue<SavedItemSummary>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
