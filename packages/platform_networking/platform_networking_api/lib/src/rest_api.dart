import 'package:dio/dio.dart';
import 'package:platform_networking_api/src/rest_api_result.dart';

abstract class RestApi {
  Future<RestApiResult<T>> get<T>(
    String url, {
    Options? options,
  });

  Future<RestApiResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<RestApiResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<RestApiResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<RestApiResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
  });
}
