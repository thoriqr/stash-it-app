import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/move_to_collection_result.dart';
import '../domain/saved_item_page.dart';
import '../domain/saved_item_summary.dart';
import 'datasources/saved_items_api.dart';
import 'models/create_saved_item_request.dart';
import 'models/move_to_collection_request.dart';
import 'move_to_collection_mapper.dart';
import 'saved_item_detail_mapper.dart';
import 'saved_item_mapper.dart';

/// Reads of the Inbox listing and detail, and the writes this milestone exposes,
/// with failures already translated.
///
/// The only layer that converts a [DioException] into an [ApiFailure], so
/// presentation never learns that Dio exists (`AGENTS.md` §2, rule 4). Concrete
/// with no interface, for one implementation.
class SavedItemsRepository {
  const SavedItemsRepository({required this.api, this.now = DateTime.now});

  final SavedItemsApi api;

  /// The clock the saved-time label is computed against.
  ///
  /// A parameter rather than a direct `DateTime.now` so the label is
  /// deterministic under test. Production passes the default and never reads it
  /// back.
  final DateTime Function() now;

  /// Saves [url], and confirms only that the server created the item.
  ///
  /// **Returns nothing on purpose.** The documented `201` carries exactly `id`,
  /// `url`, `collection_id` and `enrichment_status` — not enough to build a
  /// `SavedItemSummary`, and nothing in this milestone reads any of the four.
  /// Returning the id would be a value with no consumer. The response type still
  /// declares all four fields, so a change to the contract shows up as a decode
  /// failure here rather than as a silent difference.
  ///
  /// **A `201` whose body does not decode is not a success.** The create handler
  /// answers `201` only after the row committed, so the write landed — but this
  /// method has no created item to report, and the caller must not claim a save
  /// it cannot show. It throws [ApiFailureUnreadableResponse], which for a write
  /// means *unestablished* rather than *failed* (see that variant).
  ///
  /// Throws [ApiFailure] for every refusal. The certainty of each variant is
  /// **not** uniform, and the caller has to honour it (**D15**/**D16**):
  /// [ApiFailureTransport] is uncertain, [ApiFailureUnreadableResponse] is
  /// unestablished, and the rest are known not saved — a refused request never
  /// reached the insert, and a `500` is a commit that did not happen.
  Future<void> create({required String url}) async {
    try {
      await api.create(CreateSavedItemRequest(url: url));
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A `2xx` whose body does not match the documented shape. Dio only decodes
      // a status that passed `validateStatus`, so this is a committed write with
      // an unreadable representation, reported as unestablished rather than as a
      // refusal.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// Moves one saved item into the named collection, creating it if needed.
  ///
  /// **Sends a name, never an id.** The backend trims, matches case-insensitively
  /// and creates-or-reuses the collection atomically, so this client must not
  /// resolve a collection first. The caller trims the submitted value but must
  /// preserve its casing; the server's stored casing is what
  /// [MoveToCollectionResult.collectionName] reports.
  ///
  /// **A `200` whose body does not decode is unestablished, not failed.** The
  /// write may have committed and only its representation be unreadable, so this
  /// throws [ApiFailureUnreadableResponse] and the caller must reconcile rather
  /// than claim the item did not move. The same applies to [ApiFailureTransport].
  ///
  /// [ApiFailureNotFound] is the route's own `SAVED_ITEM_NOT_FOUND`: the item is
  /// missing or belongs to another user, and the client cannot tell which.
  /// [ApiFailureCollectionNameReserved] means the name is held by a system
  /// collection; the response does not identify it.
  ///
  /// Throws [ApiFailure] for every refusal.
  Future<MoveToCollectionResult> moveToCollection({
    required String savedItemId,
    required String collectionName,
  }) async {
    try {
      final response = await api.moveToCollection(
        savedItemId,
        MoveToCollectionRequest(collectionName: collectionName),
      );
      return moveToCollectionResultFrom(response);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A `200` whose body does not match the documented shape. Retrofit decodes
      // after Dio's transformer returns, so this never passes through Dio and
      // `mapApiFailure` cannot see it.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// One page of recent saved items.
  ///
  /// [cursor] is passed to the server **unchanged** and is never parsed: the
  /// contract states a cursor records a position rather than an item, and its
  /// encoding is not part of the API surface. Null starts at the newest item.
  ///
  /// Throws [ApiFailure] on any refusal. The route is not rate limited, so there
  /// is no budget variant to anticipate here; `BAD_REQUEST`,
  /// `VALIDATION_ERROR` and `INVALID_CURSOR` all mean *this request* was
  /// malformed rather than that the user did anything wrong.
  Future<SavedItemPage> list({String? cursor}) async {
    try {
      final response = await api.list(cursor: cursor);
      final at = now();

      // `meta` is absent on no documented response to this route, and
      // `meta.cursor` is the only place a cursor or `has_more` appears. A
      // response without it cannot be paginated safely, so it is reported
      // unreadable rather than silently treated as a single complete page — that
      // would hide pages the user can reach.
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
      // A `200` whose body does not match the documented shape. Retrofit decodes
      // after Dio's transformer returns, so this never passes through Dio and
      // `mapApiFailure` cannot see it.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }

  /// One saved item, fresh from the server.
  ///
  /// **This is the only read the detail screen performs**, and it changes
  /// nothing: the route starts no enrichment, fetches no page and moves no item.
  /// The collection name comes from the response's sibling `collection` object.
  ///
  /// A missing item and one owned by another user both answer `404` with
  /// `RESOURCE_NOT_FOUND`, which maps to [ApiFailureNotFound]. That variant says
  /// only that the named resource is unavailable to this caller — the screen
  /// must not claim which of the two happened.
  ///
  /// Throws [ApiFailure] for every refusal. A `200` whose body does not decode
  /// is [ApiFailureUnreadableResponse], not not-found: a malformed reply is not
  /// evidence that the item is gone.
  Future<SavedItemSummary> getById(String id) async {
    try {
      final response = await api.getById(id);
      return savedItemDetailFrom(response, now: now());
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A `200` whose body does not match the documented shape. Retrofit decodes
      // after Dio's transformer returns, so this never passes through Dio and
      // `mapApiFailure` cannot see it.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
