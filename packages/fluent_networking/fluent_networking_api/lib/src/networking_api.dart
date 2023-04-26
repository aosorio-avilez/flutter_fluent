import 'package:dio/dio.dart';
import 'package:fluent_networking_api/src/response_result.dart';

/// Interface defined to use the fluent networking functionalities
abstract class NetworkingApi {
  /// Makes a GET request to the specific url
  /// with optional configurations
  Future<ResponseResult<T>> get<T>(
    String url, {
    Options? options,
  });

  /// Makes a POST request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
  });

  /// Makes a PATCH request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
  });

  /// Makes a PUT request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
  });

  /// Makes a DELETE request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
  });
}
