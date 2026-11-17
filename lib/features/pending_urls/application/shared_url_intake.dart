import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/saved_items/data/client_metadata_fetcher.dart';
import 'package:stash_it_app/features/saved_items/data/models/client_metadata.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/client_enrichment_host.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';

/// Describes the result of attempting to save a shared URL.
///
/// A confirmed save is the only success. An uncertain outcome must not be
/// reported as a definite failure.
enum ShareSaveOutcome {
  /// The server confirmed the save. Any local entry for it was removed.
  saved,

  /// The save failed for a known reason. The URL is kept locally.
  storedAfterFailure,

  /// The request outcome could not be confirmed. The URL is kept locally
  /// with an uncertainty marker because the server may have saved it.
  storedAfterUncertain,

  /// The shared text did not contain a URL this client can submit.
  invalid,

  /// The remote save failed and the local write also failed.
  /// The URL could not be safely preserved.
  notStored,

  /// The share contained no text, so there is nothing to process.
  ignored;

  /// Whether this outcome added, updated, or removed a local entry.
  bool get touchedStore =>
      this == saved ||
      this == storedAfterFailure ||
      this == storedAfterUncertain;

  /// Whether the native share handler should show feedback.
  bool get hasFeedback => this != ignored;

  /// Serializes the outcome for the platform channel with its localized
  /// message. The protocol keys and outcome values are unchanged.
  Map<String, Object?> toChannelMap(String message) => {
    'outcome': name,
    'message': message,
    'stored': this == storedAfterFailure || this == storedAfterUncertain,
  };
}

/// Returns the first submittable URL in the shared text, or null.
///
/// Prefers the entire trimmed value, which is the usual format for a URL
/// share. If that value is not accepted, checks whitespace-delimited tokens
/// in order, allowing text such as `Look at this https://…`.
///
/// Reuses [isSubmittableUrl] so shared URLs follow the same validation rule
/// as URLs submitted elsewhere in the app.
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

/// Handles saving a URL received through the native share flow.
///
/// Uses [SavedItemsRepository.create] for the remote save and [PendingUrlStore]
/// to keep the URL on the device before the request, so an interrupted save
/// cannot lose it. The entry is removed after a confirmed save and is marked
/// uncertain or definite according to the outcome. This service does not depend
/// on a widget tree or foreground UI.
///
/// For a host whose enrichment the server leaves to the client,
/// [ClientMetadataFetcher] reads the page on this device first and the result
/// travels in the create request. Every other host keeps server-side
/// enrichment.
///
/// Each shared URL gets one attempt. There is no automatic retry, timer,
/// queue drain, or background synchronization.
class SharedUrlIntake {
  const SharedUrlIntake({
    required this.repository,
    required this.store,
    required this.metadataFetcher,
  });

  final SavedItemsRepository repository;
  final PendingUrlStore store;
  final ClientMetadataFetcher metadataFetcher;

  Future<ShareSaveOutcome> save(String rawText) async {
    if (rawText.trim().isEmpty) return ShareSaveOutcome.ignored;

    final url = extractSharedUrl(rawText);
    if (url == null) return ShareSaveOutcome.invalid;

    // Keep the URL locally before contacting the page or the server. A request
    // that is interrupted by process death or the native watchdog then still
    // leaves the link on the device.
    final written = await _write(url, uncertain: true);
    final metadata = await _metadataFor(url);

    try {
      await repository.create(url: url, metadata: metadata);

      // The server confirmed the save, so the local copy is no longer needed.
      // Cleanup is best-effort: a failed local delete must not change the
      // confirmed remote result into a reported failure.
      try {
        await store.removeExact(url);
      } catch (_) {
        // Keep the local entry for later cleanup.
      }

      return ShareSaveOutcome.saved;
    } on ApiFailure catch (failure) {
      final uncertain =
          failure is ApiFailureTransport ||
          failure is ApiFailureUnreadableResponse;

      if (uncertain) {
        return written
            ? ShareSaveOutcome.storedAfterUncertain
            : _store(url, uncertain: true);
      }

      // A known failure must not leave the entry claiming an unknown outcome.
      // If that write fails, the uncertain entry written above still keeps the
      // URL safely on the device.
      final downgraded = await _write(url, uncertain: false);
      return downgraded || written
          ? ShareSaveOutcome.storedAfterFailure
          : ShareSaveOutcome.notStored;
    } catch (_) {
      // Unexpected errors do not establish whether the remote save succeeded.
      return written
          ? ShareSaveOutcome.storedAfterUncertain
          : _store(url, uncertain: true);
    }
  }

  /// Extracts metadata for a host the server leaves to the client.
  ///
  /// Returns null for every other host so the request omits the field. For a
  /// client-enrichment host the result is never null: a failed fetch becomes an
  /// empty object, which the server records as a failed attempt rather than
  /// leaving the item pending.
  Future<ClientMetadata?> _metadataFor(String url) async {
    final platform = clientEnrichmentPlatformForUrl(url);
    if (platform == null) return null;

    try {
      return await metadataFetcher.fetch(url, platform: platform) ??
          const ClientMetadata();
    } catch (_) {
      return const ClientMetadata();
    }
  }

  /// Writes [url] and reports whether the store accepted it.
  Future<bool> _write(String url, {required bool uncertain}) async {
    try {
      await store.upsert(url: url, uncertain: uncertain);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ShareSaveOutcome> _store(String url, {required bool uncertain}) async {
    if (!await _write(url, uncertain: uncertain)) {
      return ShareSaveOutcome.notStored;
    }

    return uncertain
        ? ShareSaveOutcome.storedAfterUncertain
        : ShareSaveOutcome.storedAfterFailure;
  }
}

/// Provides the shared URL intake service using the existing repository
/// and local store.
final Provider<SharedUrlIntake> sharedUrlIntakeProvider =
    Provider<SharedUrlIntake>(
      (ref) => SharedUrlIntake(
        repository: ref.watch(savedItemsRepositoryProvider),
        store: ref.watch(pendingUrlStoreProvider),
        metadataFetcher: ref.watch(clientMetadataFetcherProvider),
      ),
    );
