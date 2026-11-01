import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_collection_response.freezed.dart';
part 'delete_collection_response.g.dart';

/// Response body for a successful collection deletion.
///
/// A `200` response indicates that the operation completed. The `data` object
/// is not needed by this client, and `message` is optional, so neither should
/// cause decoding to fail if the unused response payload changes.
@freezed
abstract class DeleteCollectionResponse with _$DeleteCollectionResponse {
  const factory DeleteCollectionResponse({String? message}) =
      _DeleteCollectionResponse;

  factory DeleteCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteCollectionResponseFromJson(json);
}
