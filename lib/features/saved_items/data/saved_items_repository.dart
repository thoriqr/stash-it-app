import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/collection_saved_items_page.dart';
import '../domain/move_to_collection_intent.dart';
import '../domain/move_to_collection_result.dart';
import '../domain/saved_item_delete_result.dart';
import '../domain/saved_item_enrichment_result.dart';
import '../domain/saved_item_page.dart';
import '../domain/saved_item_summary.dart';
import 'collection_saved_items_mapper.dart';
import 'datasources/saved_items_api.dart';
import 'models/create_saved_item_request.dart';
import 'models/move_to_collection_request.dart';
import 'models/update_saved_item_note_request.dart';
import 'move_to_collection_mapper.dart';
import 'saved_item_deletion_mapper.dart';
import 'saved_item_detail_mapper.dart';
import 'saved_item_enrichment_mapper.dart';
import 'saved_item_mapper.dart';

/// Handles saved item reads and writes, translating request failures into
/// [ApiFailure] variants for the presentation layer.
class SavedItemsRepository {
  const SavedItemsRepository({required this.api, this.now = DateTime.now});

  final SavedItemsApi api;

  /// The clock used to calculate saved-time labels.
  ///
  /// Injected so labels are deterministic in tests. Production uses the
  /// default [DateTime.now] function.
  final DateTime Function() now;

  /// Saves [url] and an optional [note], confirming the server created the
  /// item.
  ///
  /// [note] is omitted from the request when null. Non-whitespace text is sent
  /// exactly as supplied, including line breaks.
  ///
  /// Returns no value because the create response does not contain enough
  /// information to build a [SavedItemSummary]. The caller should re-read the
  /// listing to obtain the complete item representation.
  ///
  /// All four fields in the create response are required. If a successful
  /// response cannot be decoded, this method throws
  /// [ApiFailureUnreadableResponse]. The server may have saved the item, but
  /// the client cannot establish the result from the response.
  ///
  /// The certainty of failures differs by variant:
  /// - [ApiFailureTransport]: the outcome is uncertain.
  /// - [ApiFailureUnreadableResponse]: the outcome is unestablished.
  /// - Other [ApiFailure] variants: the request is known not to have saved
  ///   the item.
  Future<void> create({required String url, String? note}) async {
    try {
      await api.create(CreateSavedItemRequest(url: url, note: note));
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body does not establish
      // the result of the write.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Moves one saved item into the named collection.
  ///
  /// Sends a collection name and an [intent], not a collection ID. The intent
  /// distinguishes an existing destination
  /// ([MoveToCollectionIntent.existing]) from a new collection name
  /// ([MoveToCollectionIntent.create]). The caller trims the submitted name
  /// but preserves its casing. The result reports the stored collection name.
  ///
  /// A successful response that cannot be decoded is unestablished: the move
  /// may have committed, so the caller must reconcile rather than report
  /// that the item did not move. [ApiFailureTransport] has the same uncertainty.
  ///
  /// [ApiFailureNotFound] means the saved item is unavailable to this caller;
  /// the client cannot distinguish a missing item from one owned by another
  /// user.
  ///
  /// [ApiFailureCollectionNameAlreadyExists] means a create intent was
  /// rejected because the name is already in use. Nothing was created or
  /// moved. With an existing intent, the matching collection is reused.
  ///
  /// Throws [ApiFailure] for every refusal.
  Future<MoveToCollectionResult> moveToCollection({
    required String savedItemId,
    required String collectionName,
    required MoveToCollectionIntent intent,
  }) async {
    try {
      final response = await api.moveToCollection(
        savedItemId,
        MoveToCollectionRequest(
          collectionName: collectionName,
          collectionIntent: intent.wireValue,
        ),
      );
      return moveToCollectionResultFrom(response);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body does not establish
      // whether the move committed.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Deletes one saved item and reports the availability of collection flags.
  ///
  /// Only a `200` response confirms that the item was deleted. A non-2xx
  /// response does not establish whether the deletion occurred, so a server
  /// error must not be interpreted as proof that the item still exists.
  ///
  /// If a successful response cannot be decoded, the deletion is still
  /// considered complete, but the collection flags are unavailable. This
  /// returns [SavedItemDeletionFlagsUnavailable] instead of throwing.
  ///
  /// A missing item and one owned by another user both map to
  /// [ApiFailureNotFound]. This variant indicates only that the item is
  /// unavailable to the current caller.
  ///
  /// Throws [ApiFailure] for every non-2xx response.
  Future<SavedItemDeleteResult> delete(String id) async {
    try {
      final response = await api.delete(id);
      return savedItemDeleteResultFrom(response);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError {
      // The successful response confirms deletion, but its collection flags
      // cannot be read.
      return const SavedItemDeletionFlagsUnavailable();
    } on FormatException {
      return const SavedItemDeletionFlagsUnavailable();
    }
  }

  /// Retrieves one page of recent saved items.
  ///
  /// [cursor] is passed to the server unchanged and is never parsed by the
  /// client. A null cursor starts from the newest item.
  ///
  /// Throws [ApiFailure] on any refusal. `BAD_REQUEST`, `VALIDATION_ERROR`
  /// and `INVALID_CURSOR` indicate that the request could not be accepted.
  Future<SavedItemPage> list({String? cursor}) async {
    try {
      final response = await api.list(cursor: cursor);
      final at = now();

      // Pagination requires cursor metadata. Without it, the client cannot
      // determine whether more pages are available.
      final meta = response.meta;
      if (meta == null) {
        throw const ApiFailureUnreadableResponse();
      }

      return SavedItemPage(
        items: response.data.savedItems
            .map((item) => savedItemFrom(item, now: at))
            .toList(growable: false),
        nextCursor: meta.cursor.nextCursor,
        hasMore: meta.cursor.hasMore,
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body cannot be used
      // as a listing page.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Retrieves one page of saved items from a collection.
  ///
  /// The collection name comes from the response rather than the tile that
  /// opened the screen. This ensures the displayed name reflects any rename
  /// that occurred before the request.
  ///
  /// [cursor] is passed to the server unchanged and is never parsed by the
  /// client. A null cursor starts from the newest item.
  ///
  /// A collection that does not exist and one owned by another user both map
  /// to [ApiFailureNotFound]. The client must not claim which situation
  /// occurred. An existing empty collection is a successful response with an
  /// empty `saved_items` list, not a not-found result.
  ///
  /// Throws [ApiFailure] on any refusal. A successful response that cannot
  /// be decoded throws [ApiFailureUnreadableResponse], not not-found.
  Future<CollectionSavedItemsPage> listInCollection(
    String collectionId, {
    String? cursor,
  }) async {
    try {
      final response = await api.listInCollection(collectionId, cursor: cursor);

      // Pagination requires cursor metadata. Without it, the client cannot
      // determine whether more pages are available.
      final meta = response.meta;
      if (meta == null) {
        throw const ApiFailureUnreadableResponse();
      }

      final data = response.data;

      return CollectionSavedItemsPage(
        collectionId: data.collection.id,
        collectionName: data.collection.name,
        items: collectionSavedItemsFrom(data, now: now()),
        nextCursor: meta.cursor.nextCursor,
        hasMore: meta.cursor.hasMore,
      );
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body cannot be used
      // as a collection listing page.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Adds or replaces one saved item's note and returns the stored text.
  ///
  /// [note] is sent exactly as supplied. The editor is responsible for refusing
  /// an effectively empty value; this method does not trim or rewrite the text.
  ///
  /// The response reports the note as stored. If a successful response omits
  /// that field, the caller may use the submitted value because the request was
  /// already accepted.
  ///
  /// A missing item and one owned by another user both map to
  /// [ApiFailureNotFound]. A `400` for an invalid note maps to
  /// [ApiFailureValidation].
  Future<String?> updateNote({
    required String savedItemId,
    required String note,
  }) async {
    try {
      final response = await api.updateNote(
        savedItemId,
        UpdateSavedItemNoteRequest(note: note),
      );
      return response.data.note;
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // The write may have completed even though its reply cannot be read. The
      // caller must treat this as an unconfirmed outcome, not a failure.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Clears one saved item's note without deleting the item.
  ///
  /// A `200` is the confirmation; the response body carries no note value. A
  /// successful status whose empty body cannot be decoded is still the delete's
  /// completion, because there is no result field to apply.
  ///
  /// A missing item and one owned by another user both map to
  /// [ApiFailureNotFound].
  Future<void> deleteNote(String savedItemId) async {
    try {
      await api.deleteNote(savedItemId);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError {
      // A 2xx response arrived, so the note was cleared. Its empty `data`
      // object carries nothing that presentation needs.
    } on FormatException {
      // Same as above: the successful status is the confirmation.
    }
  }

  /// Retrieves one saved item with its latest data from the server.
  ///
  /// This read does not trigger enrichment or change the item's collection.
  /// The collection name comes from the response's sibling `collection` object.
  ///
  /// A missing item and one owned by another user both map to
  /// [ApiFailureNotFound]. This variant indicates only that the item is
  /// unavailable to the current caller.
  ///
  /// Throws [ApiFailure] for every refusal. A successful response that cannot
  /// be decoded throws [ApiFailureUnreadableResponse], not not-found.
  Future<SavedItemSummary> getById(String id) async {
    try {
      final response = await api.getById(id);
      return savedItemDetailFrom(response, now: now());
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body cannot be used
      // as a detail result.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Re-reads one saved item's source page and reports the enrichment outcome.
  ///
  /// Sends exactly one synchronous request. The endpoint completes the
  /// extraction attempt before responding; this method does not retry or poll.
  ///
  /// A `200` response does not necessarily mean extraction succeeded.
  /// `enrichment_status` reports the outcome: `completed` may still have a
  /// null title, while `failed` preserves metadata already stored on the item.
  ///
  /// [ApiFailureNotFound] means the item is unavailable to this caller. This
  /// can also happen if the item is deleted while enrichment is in progress.
  ///
  /// A `429` or `503` refusal indicates that the request was not processed.
  /// A `500` does not provide an updated item representation, so callers must
  /// not treat it as a successful re-read.
  ///
  /// Throws [ApiFailure] for every refusal. If a successful response cannot
  /// be decoded, [ApiFailureUnreadableResponse] is thrown: the attempt may
  /// have been recorded, but the client has no result to apply.
  Future<SavedItemEnrichmentResult> enrich(String id) async {
    try {
      final response = await api.enrich(id);
      return savedItemEnrichmentFrom(response);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A successful HTTP response with an unreadable body cannot establish
      // the enrichment result.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
