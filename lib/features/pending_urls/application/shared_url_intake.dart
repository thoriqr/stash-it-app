import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';

/// What a shared URL attempt produced.
///
/// The distinctions are user-facing, not implementation detail: a confirmed save
/// is the only success, and an uncertain outcome must never be described as a
/// definite failure (D15/D16).
enum ShareSaveOutcome {
  /// The server confirmed the create. No local entry was added.
  saved,

  /// The server refused the save for a known reason. The URL is kept locally.
  storedAfterFailure,

  /// The request's outcome could not be established. The URL is kept locally
  /// with the uncertain marker; the server may also have committed the write.
  storedAfterUncertain,

  /// The shared text did not contain a URL this client would submit.
  invalid,

  /// The remote attempt failed and the local write also failed. The URL is not
  /// safely preserved anywhere.
  notStored,

  /// The share contained no text at all; there is nothing to report.
  ignored;

  /// Whether this outcome changed the local list (added, refreshed, or removed
  /// after a confirmed save).
  bool get touchedStore =>
      this == saved ||
      this == storedAfterFailure ||
      this == storedAfterUncertain;

  /// Whether the native share handler should show feedback for this outcome.
  bool get hasFeedback => this != ignored;

  /// The sentence shown by the Android Toast.
  ///
  /// Client-owned copy, like every other user-facing string. The uncertain case
  /// deliberately says what is not known rather than claiming the save failed.
  String get message => switch (this) {
    ShareSaveOutcome.saved => 'Saved to your account.',
    ShareSaveOutcome.storedAfterFailure =>
      "Couldn't save it. Kept on this device.",
    ShareSaveOutcome.storedAfterUncertain =>
      'Save not confirmed. Kept on this device.',
    ShareSaveOutcome.invalid => "That's not a link, so nothing was saved.",
    ShareSaveOutcome.notStored => "Couldn't save or keep this link.",
    ShareSaveOutcome.ignored => '',
  };

  /// The values sent over the platform channel.
  Map<String, Object?> toChannelMap() => {
    'outcome': name,
    'message': message,
    'stored': this == storedAfterFailure || this == storedAfterUncertain,
  };
}

/// Returns the first submittable URL in a shared text, or null.
///
/// The whole trimmed value is preferred because a normal share sends just the
/// URL. Otherwise the first whitespace-delimited token that passes the existing
/// gate is used, which handles a share such as `Look at this https://…`. This
/// deliberately reuses [isSubmittableUrl] rather than defining a second URL
/// rule.
String? extractSharedUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (isSubmittableUrl(trimmed)) return trimmed;

  for (final token in trimmed.split(RegExp(r'\s+'))) {
    final candidate = token.trim();
    if (isSubmittableUrl(candidate)) return candidate;
  }

  return null;
}

/// The one remote-save path used by a shared URL.
///
/// It reuses [SavedItemsRepository.create] and therefore the existing
/// `appDio` + `AuthInterceptor`; no API call or authentication logic is
/// duplicated. It deliberately does **not** call `SaveUrl.submit`: that
/// controller publishes foreground feedback, refreshes the Inbox provider, and
/// collapses every outcome to `bool`, while the share handler needs the typed
/// certainty and must run without a widget tree.
///
/// One attempt per shared URL. There is no retry, timer, queue drain, or
/// background synchronization.
class SharedUrlIntake {
  const SharedUrlIntake({required this.repository, required this.store});

  final SavedItemsRepository repository;
  final PendingUrlStore store;

  Future<ShareSaveOutcome> save(String rawText) async {
    if (rawText.trim().isEmpty) return ShareSaveOutcome.ignored;

    final url = extractSharedUrl(rawText);
    if (url == null) return ShareSaveOutcome.invalid;

    try {
      await repository.create(url: url);

      // A confirmed save means no local copy should remain. Cleanup is
      // best-effort: the server already has the item, so a failed delete must
      // not turn a confirmed create into a reported failure.
      try {
        await store.removeExact(url);
      } catch (_) {
        // Leave the stale entry for a later cleanup.
      }

      return ShareSaveOutcome.saved;
    } on ApiFailure catch (failure) {
      final uncertain =
          failure is ApiFailureTransport ||
          failure is ApiFailureUnreadableResponse;
      return _store(url, uncertain: uncertain);
    } catch (_) {
      // A non-ApiFailure is unexpected, but the remote outcome is still not
      // established. Keeping the URL is the safe interpretation.
      return _store(url, uncertain: true);
    }
  }

  Future<ShareSaveOutcome> _store(String url, {required bool uncertain}) async {
    try {
      await store.upsert(url: url, uncertain: uncertain);
    } catch (_) {
      return ShareSaveOutcome.notStored;
    }

    return uncertain
        ? ShareSaveOutcome.storedAfterUncertain
        : ShareSaveOutcome.storedAfterFailure;
  }
}

/// The shared URL service, over the existing repository and local store.
final Provider<SharedUrlIntake> sharedUrlIntakeProvider =
    Provider<SharedUrlIntake>(
      (ref) => SharedUrlIntake(
        repository: ref.watch(savedItemsRepositoryProvider),
        store: ref.watch(pendingUrlStoreProvider),
      ),
    );
