import 'package:dio/dio.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';

class RestApiImpl extends RestApi {
  RestApiImpl(this._httpClient);

  final Dio _httpClient;

  /// Make a get http request to the specific [url]
  /// with optional [options] configuration
  /// And return a [RestApiResult] response
  @override
  Future<RestApiResult<T>> get<T>(
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
  /// And return a [RestApiResult] response
  @override
  Future<RestApiResult<T>> post<T>(
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
  /// And return a [RestApiResult] response
  @override
  Future<RestApiResult<T>> patch<T>(
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
  /// And return a [RestApiResult] response
  @override
  Future<RestApiResult<T>> put<T>(
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
  /// And return a [RestApiResult] response
  @override
  Future<RestApiResult<T>> delete<T>(
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

  Future<RestApiResult<T>> _execute<T>(
    Future<Response<T>> Function() onExecute,
  ) async {
    try {
      final response = await onExecute();
      return response.toResult<T>();
    } on DioError catch (exception) {
      return exception.response?.toResult<T>() ?? exception.toResult();
    }
  }
}

extension ResponseExtension on Response<dynamic> {
  RestApiResult<T> toResult<T>() {
    // debugPrint(toString());

    if (statusCode! >= 200 && statusCode! <= 300) {
      return RestApiResult.succeeded(data as T);
    } else {
      return RestApiResult.failed(data as Object);
    }
  }
}

extension DioErrorExtension on DioError {
  RestApiResult<T> toResult<T>() {
    return RestApiResult.error(
      RestApiError(
        type.name,
        message,
      ),
    );
  }
}
