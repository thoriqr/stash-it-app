import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_collection_response.freezed.dart';
part 'delete_collection_response.g.dart';

/// The whole `200` body of `DELETE /collections/{id}`.
///
/// The backend sends `data: {}` and a `message`. Neither is needed to establish
/// success: a `200` means the transaction committed. `data` is deliberately not
/// modelled as a required object, so a success cannot be turned into a decode
/// failure by a change to an empty payload this client never reads.
@freezed
abstract class DeleteCollectionResponse with _$DeleteCollectionResponse {
  const factory DeleteCollectionResponse({String? message}) =
      _DeleteCollectionResponse;

  factory DeleteCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteCollectionResponseFromJson(json);
}
