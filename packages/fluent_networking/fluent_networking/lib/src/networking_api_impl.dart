import 'package:dio/dio.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';

class NetworkingApiImpl extends NetworkingApi {
  NetworkingApiImpl(this._httpClient);

  final Dio _httpClient;

  /// Make a get http request to the specific [url]
  /// with optional [options] configuration
  /// And return a [ResponseResult] response
  @override
  Future<ResponseResult<T>> get<T>(
    String url, {
    Options? options,
  }) async {
    return _execute(
      () => _httpClient.get<T>(
        url,
        options: options,
      ),
    );
  }

  /// Make a post http request to the specific [url]
  /// with an optional [body] and optional [options] configuration
  /// And return a [ResponseResult] response
  @override
  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
  }) async {
    return _execute(
      () => _httpClient.post<T>(
        url,
        options: options,
        data: body,
      ),
    );
  }

  // Make a patch http request to the specific [url]
  /// with an optional [body] and optional [options] configuration
  /// And return a [ResponseResult] response
  @override
  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
  }) async {
    return _execute(
      () => _httpClient.patch<T>(
        url,
        options: options,
        data: body,
      ),
    );
  }

  // Make a put http request to the specific [url]
  /// with an optional [body] and optional [options] configuration
  /// And return a [ResponseResult] response
  @override
  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
  }) async {
    return _execute(
      () => _httpClient.put<T>(
        url,
        options: options,
        data: body,
      ),
    );
  }

  // Make a delete http request to the specific [url]
  /// with an optional [body] and optional [options] configuration
  /// And return a [ResponseResult] response
  @override
  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
  }) async {
    return _execute(
      () => _httpClient.delete<T>(
        url,
        options: options,
        data: body,
      ),
    );
  }

  Future<ResponseResult<T>> _execute<T>(
    Future<Response<T>> Function() onExecute,
  ) async {
    try {
      final response = await onExecute();
      return response.toResult<T>();
    } on DioException catch (exception) {
      return exception.response?.toResult<T>() ?? exception.toResult();
    }
  }
}

extension ResponseExtension on Response<dynamic> {
  ResponseResult<T> toResult<T>() {
    if (statusCode! >= 200 && statusCode! <= 300) {
      return ResponseResult.succeeded(data as T);
    } else {
      return ResponseResult.failed(data as Object);
    }
  }
}

extension DioErrorExtension on DioException {
  ResponseResult<T> toResult<T>() {
    return ResponseResult.error(
      ResponseError(
        type.name,
        message,
      ),
    );
  }
}
