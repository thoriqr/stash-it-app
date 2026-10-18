// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiEnvelope<T> _$ApiEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiEnvelope<T>(
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  message: json['message'] as String?,
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiEnvelopeToJson<T>(
  _ApiEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'message': instance.message,
  'meta': instance.meta,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
