import 'package:fluent_networking_api/src/response_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_result.freezed.dart';

/// Definition of a response result
@freezed
class ResponseResult<T> with _$ResponseResult<T> {
  const factory ResponseResult.succeeded(T data) = Succeeded;
  const factory ResponseResult.failed(Object data) = Failed;
  const factory ResponseResult.error(ResponseError error) = Error;
}
