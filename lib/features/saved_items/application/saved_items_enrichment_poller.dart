import 'dart:async';

import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// How long after creation an item remains eligible for enrichment polling.
///
/// The window is evaluated per item, so an older item that is still pending
/// stops being polled while a newer pending item keeps the Inbox synchronising.
const Duration savedItemEnrichmentPollingWindow = Duration(seconds: 60);

/// The bounded, progressively increasing Inbox polling intervals.
///
/// The first request follows activation by 1.5 seconds. Each later request
/// waits for the previous one to complete before its own delay starts, so a
/// slow network cannot create overlapping requests.
const List<Duration> savedItemEnrichmentPollingIntervals = <Duration>[
  Duration(milliseconds: 1500),
  Duration(seconds: 3),
  Duration(seconds: 5),
  Duration(seconds: 8),
  Duration(seconds: 10),
];

/// The delay before attempt [attempt], capped at the last configured interval.
Duration savedItemEnrichmentPollingDelay(int attempt) {
  final index = attempt.clamp(
    0,
    savedItemEnrichmentPollingIntervals.length - 1,
  );
  return savedItemEnrichmentPollingIntervals[index];
}

/// Whether [item] should keep the Inbox polling at [now].
///
/// Only a `pending` item is eligible. Enrichment is server-side and
/// asynchronous, so a client that stopped polling must not infer that it
/// failed; the status remains whatever the server last reported.
///
/// The age comes from the item's `created_at`, which is server time. A missing
/// or unparseable timestamp cannot be aged, so it is not eligible. A timestamp
/// slightly ahead of the device clock is treated as newly created; one further
/// ahead than the whole window cannot be aged either and is not eligible, which
/// bounds polling under clock skew instead of letting it run indefinitely.
bool isSavedItemEnrichmentPollingEligible(SavedItemSummary item, DateTime now) {
  if (item.enrichmentStatus != EnrichmentStatus.pending) return false;

  final createdAt = item.createdAt;
  if (createdAt == null) return false;

  final age = now.toUtc().difference(createdAt.toUtc());
  if (age < -savedItemEnrichmentPollingWindow) return false;
  return age <= savedItemEnrichmentPollingWindow;
}

/// A cancellable scheduled callback.
///
/// Abstracted so the poller's sequencing can be tested without real time.
abstract interface class SavedItemsPollingTimer {
  void cancel();
}

/// Creates the timer that drives the next polling attempt.
typedef SavedItemsPollingTimerFactory =
    SavedItemsPollingTimer Function(Duration delay, void Function() callback);

SavedItemsPollingTimer _createDartTimer(
  Duration delay,
  void Function() callback,
) {
  return _DartPollingTimer(Timer(delay, callback));
}

class _DartPollingTimer implements SavedItemsPollingTimer {
  _DartPollingTimer(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}

/// Coordinates one Inbox enrichment polling loop.
///
/// **One loop, never one per item.** [activate] starts a single timer. Each
/// timer callback awaits its synchronisation before the next delay is
/// scheduled, and [update] cannot start a second request while one is in
/// flight.
///
/// **Lifecycle is external.** The Inbox owns activation because visibility and
/// foreground state belong to the widget; this type only schedules work while
/// it is active. [deactivate] cancels the scheduled callback, and an in-flight
/// request is allowed to finish without scheduling another.
///
/// **Best effort.** A failed synchronisation is swallowed here; the caller's
/// synchronisation is expected to preserve its own state and stay silent. The
/// bounded schedule continues while eligible items remain.
class SavedItemsEnrichmentPoller {
  SavedItemsEnrichmentPoller({
    required this._synchronize,
    required this._hasEligibleItems,
    required this._hasPendingItems,
    this._intervals = savedItemEnrichmentPollingIntervals,
    SavedItemsPollingTimerFactory? timerFactory,
  }) : _createTimer = timerFactory ?? _createDartTimer;

  final Future<void> Function() _synchronize;
  final bool Function() _hasEligibleItems;
  final bool Function() _hasPendingItems;
  final List<Duration> _intervals;
  final SavedItemsPollingTimerFactory _createTimer;

  SavedItemsPollingTimer? _timer;
  bool _active = false;
  bool _syncing = false;
  bool _disposed = false;
  bool _resetAfterSync = false;
  int _attempt = 0;

  /// Whether the Inbox currently wants this poller to run.
  bool get isActive => _active;

  /// Whether a synchronisation request is currently in flight.
  bool get isSynchronizing => _syncing;

  /// Starts a polling cycle without an immediate request.
  ///
  /// Used for the first Inbox activation, where the initial listing read is
  /// already the head synchronisation. Subsequent activations pass
  /// `synchronizeOnActivation: true` to [activate].
  void activate({required bool synchronizeOnActivation}) {
    if (_disposed || _active) return;

    _active = true;
    _attempt = 0;
    _resetAfterSync = false;
    _cancelTimer();

    if (synchronizeOnActivation && _hasPendingItems()) {
      if (_syncing) {
        // A request from the previous activation is still in flight. Let it
        // stand as this activation's synchronisation and restart the interval
        // progression when it completes.
        _resetAfterSync = true;
        return;
      }
      unawaited(_synchronizeOnce(advanceSchedule: false));
      return;
    }

    _scheduleNext();
  }

  /// Stops scheduling and leaves any in-flight request to finish silently.
  void deactivate() {
    if (!_active) return;

    _active = false;
    _resetAfterSync = false;
    _cancelTimer();
  }

  /// Re-evaluates polling after a Saved Items state change.
  ///
  /// [newPending] is true when the change introduced a newly loaded eligible
  /// pending item, such as a confirmed save. That starts a fresh cycle at the
  /// first interval instead of continuing at the current one.
  void update({required bool newPending}) {
    if (!_active || _disposed) return;

    if (!_hasEligibleItems()) {
      _cancelTimer();
      return;
    }

    if (_syncing) {
      if (newPending) _resetAfterSync = true;
      return;
    }

    if (newPending) {
      _attempt = 0;
      _cancelTimer();
      _scheduleNext();
      return;
    }

    if (_timer == null) _scheduleNext();
  }

  /// Permanently stops polling for a disposed screen.
  void dispose() {
    _disposed = true;
    _active = false;
    _cancelTimer();
  }

  void _scheduleNext() {
    if (!_active || _disposed || !_hasEligibleItems()) {
      _cancelTimer();
      return;
    }

    _cancelTimer();
    final delay = _delayFor(_attempt);
    _timer = _createTimer(delay, _onTimer);
  }

  Duration _delayFor(int attempt) {
    if (_intervals.isEmpty) return savedItemEnrichmentPollingIntervals.last;

    final index = attempt < 0
        ? 0
        : (attempt >= _intervals.length ? _intervals.length - 1 : attempt);
    return _intervals[index];
  }

  void _onTimer() {
    _timer = null;
    unawaited(_synchronizeOnce(advanceSchedule: true));
  }

  Future<void> _synchronizeOnce({required bool advanceSchedule}) async {
    if (!_active || _disposed || _syncing) return;

    // A timer may have been scheduled before the last eligible item's window
    // closed. Re-check at the moment it fires so no request is sent for a list
    // that no longer has anything to synchronise.
    if (advanceSchedule && !_hasEligibleItems()) {
      _cancelTimer();
      return;
    }

    _syncing = true;
    _cancelTimer();

    try {
      await _synchronize();
    } catch (_) {
      // Polling is best effort. The caller's synchronisation preserves its own
      // loaded state, and the bounded schedule decides whether to try again.
    } finally {
      _syncing = false;
    }

    if (!_active || _disposed) return;

    if (_resetAfterSync) {
      _resetAfterSync = false;
      _attempt = 0;
    } else if (advanceSchedule) {
      _attempt++;
    }

    _scheduleNext();
  }

  void _cancelTimer() {
    final timer = _timer;
    _timer = null;
    timer?.cancel();
  }
}
