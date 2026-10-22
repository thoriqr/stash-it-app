// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_collection_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cursor-paginated collection browser for the Move to a collection flow.
///
/// **One page at a time, on demand.** The main sheet loads only its bounded
/// preview; this controller starts with one page and follows `next_cursor` only
/// when the user asks for more. Nothing here sweeps every page eagerly.
///
/// **The collections listing has no name filter.** A typed name can therefore
/// only be compared with collections the client has already fetched. Discovering
/// an existing collection outside the preview requires browsing these pages;
/// there is no efficient global lookup to claim, and the client does not pretend
/// there is one.
///
/// Pages are appended in server order and de-duplicated by id. The server already
/// sorts by name; this controller never sorts again (**D4**). System and user
/// collections are both kept (**D2**); the sheet filters out its current
/// collection by id because that collection is context, not a destination.

@ProviderFor(MoveCollectionPicker)
final moveCollectionPickerProvider = MoveCollectionPickerProvider._();

/// Cursor-paginated collection browser for the Move to a collection flow.
///
/// **One page at a time, on demand.** The main sheet loads only its bounded
/// preview; this controller starts with one page and follows `next_cursor` only
/// when the user asks for more. Nothing here sweeps every page eagerly.
///
/// **The collections listing has no name filter.** A typed name can therefore
/// only be compared with collections the client has already fetched. Discovering
/// an existing collection outside the preview requires browsing these pages;
/// there is no efficient global lookup to claim, and the client does not pretend
/// there is one.
///
/// Pages are appended in server order and de-duplicated by id. The server already
/// sorts by name; this controller never sorts again (**D4**). System and user
/// collections are both kept (**D2**); the sheet filters out its current
/// collection by id because that collection is context, not a destination.
final class MoveCollectionPickerProvider
    extends
        $AsyncNotifierProvider<
          MoveCollectionPicker,
          MoveCollectionPickerState
        > {
  /// Cursor-paginated collection browser for the Move to a collection flow.
  ///
  /// **One page at a time, on demand.** The main sheet loads only its bounded
  /// preview; this controller starts with one page and follows `next_cursor` only
  /// when the user asks for more. Nothing here sweeps every page eagerly.
  ///
  /// **The collections listing has no name filter.** A typed name can therefore
  /// only be compared with collections the client has already fetched. Discovering
  /// an existing collection outside the preview requires browsing these pages;
  /// there is no efficient global lookup to claim, and the client does not pretend
  /// there is one.
  ///
  /// Pages are appended in server order and de-duplicated by id. The server already
  /// sorts by name; this controller never sorts again (**D4**). System and user
  /// collections are both kept (**D2**); the sheet filters out its current
  /// collection by id because that collection is context, not a destination.
  MoveCollectionPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'moveCollectionPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveCollectionPickerHash();

  @$internal
  @override
  MoveCollectionPicker create() => MoveCollectionPicker();
}

String _$moveCollectionPickerHash() =>
    r'299f3769e927d0f1a845071d4fec6d880178842f';

/// Cursor-paginated collection browser for the Move to a collection flow.
///
/// **One page at a time, on demand.** The main sheet loads only its bounded
/// preview; this controller starts with one page and follows `next_cursor` only
/// when the user asks for more. Nothing here sweeps every page eagerly.
///
/// **The collections listing has no name filter.** A typed name can therefore
/// only be compared with collections the client has already fetched. Discovering
/// an existing collection outside the preview requires browsing these pages;
/// there is no efficient global lookup to claim, and the client does not pretend
/// there is one.
///
/// Pages are appended in server order and de-duplicated by id. The server already
/// sorts by name; this controller never sorts again (**D4**). System and user
/// collections are both kept (**D2**); the sheet filters out its current
/// collection by id because that collection is context, not a destination.

abstract class _$MoveCollectionPicker
    extends $AsyncNotifier<MoveCollectionPickerState> {
  FutureOr<MoveCollectionPickerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<MoveCollectionPickerState>,
              MoveCollectionPickerState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MoveCollectionPickerState>,
                MoveCollectionPickerState
              >,
              AsyncValue<MoveCollectionPickerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
