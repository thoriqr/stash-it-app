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
/// The provider performs the GET in [build] because opening the detail is
/// precisely the read the screen exists for. The route is not rate limited, so a
/// visit costs one indexed read and nothing else.
///
/// **This request never enriches anything.** It is a plain read; the enrichment
/// endpoint is not called by this feature.

@ProviderFor(savedItemDetail)
final savedItemDetailProvider = SavedItemDetailFamily._();

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The provider performs the GET in [build] because opening the detail is
/// precisely the read the screen exists for. The route is not rate limited, so a
/// visit costs one indexed read and nothing else.
///
/// **This request never enriches anything.** It is a plain read; the enrichment
/// endpoint is not called by this feature.

final class SavedItemDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedItemSummary>,
          SavedItemSummary,
          FutureOr<SavedItemSummary>
        >
    with $FutureModifier<SavedItemSummary>, $FutureProvider<SavedItemSummary> {
  /// One saved item, read fresh from `GET /saved-items/{id}`.
  ///
  /// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
  /// Search results: it is keyed by the item id, belongs to one visit, and must not
  /// outlive the route. This is the opposite of `savedItemsProvider`, which is
  /// keep-alive because the Inbox is a retained destination.
  ///
  /// The provider performs the GET in [build] because opening the detail is
  /// precisely the read the screen exists for. The route is not rate limited, so a
  /// visit costs one indexed read and nothing else.
  ///
  /// **This request never enriches anything.** It is a plain read; the enrichment
  /// endpoint is not called by this feature.
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
  $FutureProviderElement<SavedItemSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavedItemSummary> create(Ref ref) {
    final argument = this.argument as String;
    return savedItemDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavedItemDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedItemDetailHash() => r'9f67b4fb2cc37321011ffe8abaa2f31408d1e8a6';

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The provider performs the GET in [build] because opening the detail is
/// precisely the read the screen exists for. The route is not rate limited, so a
/// visit costs one indexed read and nothing else.
///
/// **This request never enriches anything.** It is a plain read; the enrichment
/// endpoint is not called by this feature.

final class SavedItemDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SavedItemSummary>, String> {
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
  /// The provider performs the GET in [build] because opening the detail is
  /// precisely the read the screen exists for. The route is not rate limited, so a
  /// visit costs one indexed read and nothing else.
  ///
  /// **This request never enriches anything.** It is a plain read; the enrichment
  /// endpoint is not called by this feature.

  SavedItemDetailProvider call(String id) =>
      SavedItemDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'savedItemDetailProvider';
}
