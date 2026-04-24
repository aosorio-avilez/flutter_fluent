import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/interceptors/networking_cache_interceptor.dart';
import 'package:fluent_networking/src/interceptors/networking_retry_interceptor.dart';

class NetworkingApiImpl extends NetworkingApi {
  NetworkingApiImpl(this._httpClient);

  final Dio _httpClient;

  @override
  Future<ResponseResult<T>> get<T>(
    String url, {
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  }) {
    return _execute(
      () => _httpClient.get<dynamic>(
        url,
        options: _mergeOptions(options, retryConfig, cacheConfig),
      ),
    );
  }

  @override
  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  }) {
    return _execute(
      () => _httpClient.post<dynamic>(
        url,
        data: body,
        options: _mergeOptions(options, retryConfig, cacheConfig),
      ),
    );
  }

  @override
  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  }) {
    return _execute(
      () => _httpClient.put<dynamic>(
        url,
        data: body,
        options: _mergeOptions(options, retryConfig, cacheConfig),
      ),
    );
  }

  @override
  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  }) {
    return _execute(
      () => _httpClient.patch<dynamic>(
        url,
        data: body,
        options: _mergeOptions(options, retryConfig, cacheConfig),
      ),
    );
  }

  @override
  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  }) {
    return _execute(
      () => _httpClient.delete<dynamic>(
        url,
        data: body,
        options: _mergeOptions(options, retryConfig, cacheConfig),
      ),
    );
  }

  Options _mergeOptions(
    Options? options,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
  ) {
    if (retryConfig == null && cacheConfig == null) return options ?? Options();

    final effectiveOptions = options ?? Options();
    final extra = Map<String, dynamic>.from(effectiveOptions.extra ?? {});

    if (retryConfig != null) {
      extra[NetworkingRetryInterceptor.extraRetryConfig] = retryConfig;
    }

    if (cacheConfig != null) {
      extra[NetworkingCacheInterceptor.extraCacheConfig] = cacheConfig;
    }

    return effectiveOptions.copyWith(extra: extra);
  }

  Future<ResponseResult<T>> _execute<T>(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      return Success(response.data as T);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } on Object catch (e, s) {
      return Failure(
        HttpError(
          message: 'Unexpected Error: $e',
          data: s.toString(),
        ),
      );
    }
  }

  HttpError _mapDioError(DioException e) {
    var msg = e.message ?? 'Unknown network error';
    final dynamic errorData = e.response?.data;

    if (errorData is Map && errorData.containsKey('message')) {
      msg = errorData['message'].toString();
    }

    return HttpError(
      code: e.response?.statusCode,
      message: msg,
      data: errorData,
    );
  }
}
