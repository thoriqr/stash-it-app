import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/saved_item_page.dart';
import 'datasources/saved_items_api.dart';
import 'saved_item_mapper.dart';

/// Reads of the Inbox listing, with failures already translated.
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
}
