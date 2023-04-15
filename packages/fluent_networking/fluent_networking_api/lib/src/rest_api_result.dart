import 'package:fluent_networking_api/src/rest_api_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rest_api_result.freezed.dart';

@freezed
class RestApiResult<T> with _$RestApiResult<T> {
  const factory RestApiResult.succeeded(T data) = Succeeded;
  const factory RestApiResult.failed(Object data) = Failed;
  const factory RestApiResult.error(RestApiError error) = Error;
}
