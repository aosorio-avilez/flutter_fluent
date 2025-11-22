import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';

class NetworkingApiImpl extends NetworkingApi {
  NetworkingApiImpl(this._httpClient);

  final Dio _httpClient;

  @override
  Future<ResponseResult<T>> get<T>(String url, {Options? options}) {
    return _execute(() => _httpClient.get<T>(url, options: options));
  }

  @override
  Future<ResponseResult<T>> post<T>(
    String url, {
    Object? body,
    Options? options,
  }) {
    return _execute(
      () => _httpClient.post<T>(url, data: body, options: options),
    );
  }

  @override
  Future<ResponseResult<T>> put<T>(
    String url, {
    Object? body,
    Options? options,
  }) {
    return _execute(
      () => _httpClient.put<T>(url, data: body, options: options),
    );
  }

  @override
  Future<ResponseResult<T>> patch<T>(
    String url, {
    Object? body,
    Options? options,
  }) {
    return _execute(
      () => _httpClient.patch<T>(url, data: body, options: options),
    );
  }

  @override
  Future<ResponseResult<T>> delete<T>(
    String url, {
    Object? body,
    Options? options,
  }) {
    return _execute(
      () => _httpClient.delete<T>(url, data: body, options: options),
    );
  }

  Future<ResponseResult<T>> _execute<T>(
    Future<Response<T>> Function() call,
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
