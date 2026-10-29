import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_url_save_state.freezed.dart';

/// Why an explicit bulk save run stopped before every entry was attempted.
///
/// The reason is kept separately from [ApiFailure] so the state has value
/// equality and the presentation layer can select copy without holding a
/// request-level error. `none` means the run walked the snapshot it started
/// with; individual per-URL refusals can still have been recorded in
/// [PendingUrlSaveSummary.knownFailed].
enum PendingUrlSaveStop {
  none,
  rateLimited,
  authRequired,
  server,
  malformed,
  localList,
  unknown,
}

/// What the bulk save action is doing, and what the last run concluded.
///
/// Freezed for value equality: the screen watches this provider, and Riverpod
/// compares state with `==`. [isRunning], [processed], and [total] drive the
/// progress line; [lastSummary] is the one persistent outcome band.
@freezed
abstract class PendingUrlSaveState with _$PendingUrlSaveState {
  const factory PendingUrlSaveState({
    @Default(false) bool isRunning,
    @Default(0) int processed,
    @Default(0) int total,
    PendingUrlSaveSummary? lastSummary,
  }) = _PendingUrlSaveState;
}

/// The counts from one completed run.
///
/// [total] is the snapshot length the run started with. [saved] entries were
/// confirmed by the server; [knownFailed] and [uncertain] describe the entry
/// the run stopped on or rejected. [notAttempted] is the number of snapshot
/// entries after the stop point. [remaining] is read from the local store at the
/// end, so it also includes entries added or pruned while the run was in
/// progress; null means that read failed and the count must not be invented.
@freezed
abstract class PendingUrlSaveSummary with _$PendingUrlSaveSummary {
  const factory PendingUrlSaveSummary({
    @Default(0) int total,
    @Default(0) int saved,
    @Default(0) int knownFailed,
    @Default(0) int uncertain,
    @Default(0) int notAttempted,
    int? remaining,
    @Default(PendingUrlSaveStop.none) PendingUrlSaveStop stoppedBy,
    Duration? retryAfter,
  }) = _PendingUrlSaveSummary;
}
