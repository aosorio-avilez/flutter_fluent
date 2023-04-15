import 'package:dio/dio.dart';
import 'package:fluent_networking_api/src/response_result.dart';

abstract class NetworkingApi {
  Future<ResponseResult<T>> get<T>(
    String url, {
    Options? options,
  });

  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
  });

  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
  });
}
