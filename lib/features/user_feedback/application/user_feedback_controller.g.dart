// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits one user feedback report and publishes its success notice.
///
/// The state is only the in-flight flag. Failures are returned to the screen
/// as typed [ApiFailure] values so it can keep the draft and show the correct
/// inline message. No automatic retry is performed: a retried report could be
/// stored twice.

@ProviderFor(UserFeedbackController)
final userFeedbackControllerProvider = UserFeedbackControllerProvider._();

/// Submits one user feedback report and publishes its success notice.
///
/// The state is only the in-flight flag. Failures are returned to the screen
/// as typed [ApiFailure] values so it can keep the draft and show the correct
/// inline message. No automatic retry is performed: a retried report could be
/// stored twice.
final class UserFeedbackControllerProvider
    extends $NotifierProvider<UserFeedbackController, bool> {
  /// Submits one user feedback report and publishes its success notice.
  ///
  /// The state is only the in-flight flag. Failures are returned to the screen
  /// as typed [ApiFailure] values so it can keep the draft and show the correct
  /// inline message. No automatic retry is performed: a retried report could be
  /// stored twice.
  UserFeedbackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'userFeedbackControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFeedbackControllerHash();

  @$internal
  @override
  UserFeedbackController create() => UserFeedbackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$userFeedbackControllerHash() =>
    r'45005e5a5746660180aff18df43d7bfeb86d5ff3';

/// Submits one user feedback report and publishes its success notice.
///
/// The state is only the in-flight flag. Failures are returned to the screen
/// as typed [ApiFailure] values so it can keep the draft and show the correct
/// inline message. No automatic retry is performed: a retried report could be
/// stored twice.

abstract class _$UserFeedbackController extends $Notifier<bool> {
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
