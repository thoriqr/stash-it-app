import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_enrichment_poller.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// The Inbox enrichment poller: one bounded loop, sequential requests, and a
/// per-item eligibility window.
///
/// Time is simulated through an injected timer factory, so these tests do not
/// wait for the real 1.5–10 second intervals and cannot race the test runner.
void main() {
  group('eligibility', () {
    final now = DateTime.utc(2026, 1, 1, 12);

    SavedItemSummary item({
      EnrichmentStatus status = EnrichmentStatus.pending,
      DateTime? createdAt,
    }) => SavedItemSummary(
      id: 'item',
      collectionId: 'collection',
      url: 'https://example.com/article',
      collectionName: 'Collection',
      enrichmentStatus: status,
      createdAt: createdAt,
    );

    bool eligible(SavedItemSummary value) =>
        isSavedItemEnrichmentPollingEligible(value, now);

    test('a pending item inside the window is eligible', () {
      expect(
        eligible(item(createdAt: now.subtract(const Duration(seconds: 50)))),
        isTrue,
      );
      expect(
        eligible(item(createdAt: now.subtract(const Duration(seconds: 60)))),
        isTrue,
      );
    });

    test('a pending item older than the window is not eligible', () {
      expect(
        eligible(
          item(
            createdAt: now.subtract(
              const Duration(seconds: 60, milliseconds: 1),
            ),
          ),
        ),
        isFalse,
      );
      expect(
        eligible(item(createdAt: now.subtract(const Duration(seconds: 70)))),
        isFalse,
      );
    });

    test('completed and failed items are never eligible', () {
      for (final status in <EnrichmentStatus>[
        EnrichmentStatus.completed,
        EnrichmentStatus.failed,
      ]) {
        expect(
          eligible(
            item(
              status: status,
              createdAt: now.subtract(const Duration(seconds: 5)),
            ),
          ),
          isFalse,
        );
      }
    });

    test('an item without a parseable creation time is not eligible', () {
      expect(eligible(item()), isFalse);
    });

    test('clock skew is bounded by the polling window', () {
      // The server clock may be slightly ahead of the device. A timestamp inside
      // the window is treated as newly created rather than disabling polling.
      expect(
        eligible(item(createdAt: now.add(const Duration(seconds: 30)))),
        isTrue,
      );

      // A timestamp further ahead cannot be aged by this client, so the item is
      // not polled indefinitely.
      expect(
        eligible(item(createdAt: now.add(const Duration(seconds: 61)))),
        isFalse,
      );
    });
  });

  test('the interval progression is bounded at ten seconds', () {
    expect(
      [
        for (var attempt = 0; attempt < 7; attempt++)
          savedItemEnrichmentPollingDelay(attempt),
      ],
      const <Duration>[
        Duration(milliseconds: 1500),
        Duration(seconds: 3),
        Duration(seconds: 5),
        Duration(seconds: 8),
        Duration(seconds: 10),
        Duration(seconds: 10),
        Duration(seconds: 10),
      ],
    );
  });

  group('schedule', () {
    late _FakeTimerFactory timers;
    late bool eligible;
    late bool pending;
    late int syncs;
    Completer<void>? gate;
    late SavedItemsEnrichmentPoller poller;

    SavedItemsEnrichmentPoller buildPoller({
      Future<void> Function()? synchronize,
    }) => SavedItemsEnrichmentPoller(
      synchronize:
          synchronize ??
          () async {
            syncs++;
            final currentGate = gate;
            if (currentGate != null) await currentGate.future;
          },
      hasEligibleItems: () => eligible,
      hasPendingItems: () => pending,
      timerFactory: timers.create,
    );

    setUp(() {
      timers = _FakeTimerFactory();
      eligible = true;
      pending = true;
      syncs = 0;
      gate = null;
      poller = buildPoller();
      addTearDown(poller.dispose);
    });

    test('waits for each request before scheduling the next', () async {
      poller.activate(synchronizeOnActivation: false);

      final delays = <Duration>[];
      for (var attempt = 0; attempt < 6; attempt++) {
        final timer = timers.pending;
        delays.add(timer.delay);

        gate = Completer<void>();
        timer.fire();
        await pumpEventQueue();

        expect(syncs, attempt + 1);
        expect(
          timers.hasPending,
          isFalse,
          reason: 'the next request is scheduled only after this one completes',
        );

        gate!.complete();
        gate = null;
        await pumpEventQueue();
      }

      expect(delays, const <Duration>[
        Duration(milliseconds: 1500),
        Duration(seconds: 3),
        Duration(seconds: 5),
        Duration(seconds: 8),
        Duration(seconds: 10),
        Duration(seconds: 10),
      ]);
    });

    test(
      'activation can perform one head synchronisation before scheduling',
      () async {
        poller.activate(synchronizeOnActivation: true);
        await pumpEventQueue();

        expect(syncs, 1);
        expect(timers.pending.delay, const Duration(milliseconds: 1500));

        poller.activate(synchronizeOnActivation: true);
        await pumpEventQueue();

        expect(syncs, 1, reason: 'an already active poller is not restarted');
      },
    );

    test('reactivation performs one head synchronisation', () async {
      poller.activate(synchronizeOnActivation: true);
      await pumpEventQueue();
      expect(syncs, 1);

      poller.deactivate();
      expect(timers.hasPending, isFalse);

      poller.activate(synchronizeOnActivation: true);
      await pumpEventQueue();

      expect(syncs, 2);
      expect(timers.pending.delay, const Duration(milliseconds: 1500));
    });

    test('deactivating during a request prevents rescheduling', () async {
      poller.activate(synchronizeOnActivation: false);

      gate = Completer<void>();
      timers.pending.fire();
      await pumpEventQueue();
      expect(syncs, 1);

      poller.deactivate();
      gate!.complete();
      gate = null;
      await pumpEventQueue();

      expect(timers.hasPending, isFalse);
    });

    test('a failed request continues on the bounded schedule', () async {
      var attempts = 0;
      poller = buildPoller(
        synchronize: () async {
          attempts++;
          throw StateError('offline');
        },
      );

      poller.activate(synchronizeOnActivation: false);
      timers.pending.fire();
      await pumpEventQueue();

      expect(attempts, 1);
      expect(timers.pending.delay, const Duration(seconds: 3));
    });

    test('a new pending item restarts the interval progression', () async {
      poller.activate(synchronizeOnActivation: false);

      gate = Completer<void>();
      timers.pending.fire();
      await pumpEventQueue();
      gate!.complete();
      gate = null;
      await pumpEventQueue();

      expect(timers.pending.delay, const Duration(seconds: 3));

      poller.update(newPending: true);

      expect(timers.pending.delay, const Duration(milliseconds: 1500));
    });

    test(
      'a new pending item during a request cannot start a second one',
      () async {
        poller.activate(synchronizeOnActivation: false);

        gate = Completer<void>();
        timers.pending.fire();
        await pumpEventQueue();
        expect(syncs, 1);

        poller.update(newPending: true);
        await pumpEventQueue();

        expect(syncs, 1);
        expect(timers.hasPending, isFalse);

        gate!.complete();
        gate = null;
        await pumpEventQueue();

        expect(syncs, 1);
        expect(timers.pending.delay, const Duration(milliseconds: 1500));
      },
    );

    test('stops when no eligible pending item remains', () async {
      poller.activate(synchronizeOnActivation: false);
      expect(timers.pending.delay, const Duration(milliseconds: 1500));

      eligible = false;
      poller.update(newPending: false);

      expect(timers.hasPending, isFalse);
    });

    test(
      'a timer that fires after eligibility ends sends no request',
      () async {
        poller.activate(synchronizeOnActivation: false);

        final timer = timers.pending;
        eligible = false;
        timer.fire();
        await pumpEventQueue();

        expect(syncs, 0);
        expect(timers.hasPending, isFalse);
      },
    );

    test('dispose cancels the timer and refuses to reschedule', () async {
      poller.activate(synchronizeOnActivation: false);

      gate = Completer<void>();
      timers.pending.fire();
      await pumpEventQueue();
      expect(syncs, 1);

      poller.dispose();
      gate!.complete();
      gate = null;
      await pumpEventQueue();

      expect(timers.hasPending, isFalse);
    });
  });
}

class _FakeTimer implements SavedItemsPollingTimer {
  _FakeTimer(this.delay, this.callback);

  final Duration delay;
  final void Function() callback;
  bool canceled = false;
  bool fired = false;

  @override
  void cancel() => canceled = true;

  void fire() {
    if (canceled || fired) return;
    fired = true;
    callback();
  }
}

class _FakeTimerFactory {
  final List<_FakeTimer> timers = <_FakeTimer>[];

  SavedItemsPollingTimer create(Duration delay, void Function() callback) {
    final timer = _FakeTimer(delay, callback);
    timers.add(timer);
    return timer;
  }

  bool get hasPending => timers.any((timer) => !timer.canceled && !timer.fired);

  _FakeTimer get pending {
    final candidates = timers
        .where((timer) => !timer.canceled && !timer.fired)
        .toList();
    expect(candidates, hasLength(1), reason: 'one coordinated polling timer');
    return candidates.single;
  }
}
