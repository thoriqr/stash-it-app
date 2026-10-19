import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_saved_item_request.freezed.dart';
part 'create_saved_item_request.g.dart';

/// Body of `POST /saved-items`.
///
/// ```json
/// { "url": "https://example.com/articles/1" }
/// ```
///
/// **Exactly one field, and it is the whole request.** The server binds
/// `validate:"required,url,max=2048"` (`saved_item/request.go`), and there is
/// nothing else to send: the domain is derived server-side, the collection is the
/// caller's Unsorted collection, and every metadata column is left for background
/// enrichment.
///
/// **The client does not pre-validate the URL.** D25 leaves validation timing
/// open (Q13) and §2.9 is still a `[Rec]`, so an unusable URL is the server's to
/// refuse: it comes back as `VALIDATION_ERROR` or `INVALID_URL`, both of which are
/// a known-not-saved `400`. The field is trimmed before it reaches here, which is
/// an input clean-up rather than a rule.
@freezed
abstract class CreateSavedItemRequest with _$CreateSavedItemRequest {
  const factory CreateSavedItemRequest({required String url}) =
      _CreateSavedItemRequest;

  factory CreateSavedItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemRequestFromJson(json);
}
