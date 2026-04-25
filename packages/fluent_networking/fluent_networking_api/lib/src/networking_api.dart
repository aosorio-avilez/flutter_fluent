import 'package:dio/dio.dart';
import 'package:fluent_networking_api/src/cache_config.dart';
import 'package:fluent_networking_api/src/response_result.dart';
import 'package:fluent_networking_api/src/retry_config.dart';

/// Interface defined to use the fluent networking functionalities
abstract class NetworkingApi {
  /// Makes a GET request to the specific url
  /// with optional configurations
  Future<ResponseResult<T>> get<T>(
    String url, {
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  });

  /// Makes a POST request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  });

  /// Makes a PATCH request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  });

  /// Makes a PUT request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  });

  /// Makes a DELETE request to the specific url
  /// with an optional body and optional configurations
  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  });
}
