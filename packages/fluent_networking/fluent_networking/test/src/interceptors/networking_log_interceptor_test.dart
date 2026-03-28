import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/src/interceptors/networking_log_interceptor.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockLoggerApi mockLoggerApi;

  setUp(() async {
    await Fluent.reset();
    mockLoggerApi = MockLoggerApi();
    Fluent.mock<LoggerApi>(mockLoggerApi);
  });

  group('NetworkingLogInterceptor', () {
    const interceptor = NetworkingLogInterceptor();

    test('onRequest should log request and sanitize authorization header', () {
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer my-secret-token',
          'Content-Type': 'application/json',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('NETWORK REQUEST')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my-secret-token')),
        ),
      );
      verify(() => handler.next(options)).called(1);
    });

    test('onResponse should log response', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        statusCode: 200,
        statusMessage: 'OK',
        data: {'result': 'success'},
        headers: Headers.fromMap({
          'set-cookie': ['session=123'],
        }),
      );
      final handler = MockResponseInterceptorHandler();

      interceptor.onResponse(response, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('NETWORK RESPONSE')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('session=123')),
        ),
      );
      verify(() => handler.next(response)).called(1);
    });

    test('onError should log error', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        message: 'Timeout',
        error: 'Connection timeout',
      );
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);

      verify(
        () => mockLoggerApi.logError(
          any<String>(that: contains('NETWORK ERROR')),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verify(() => handler.next(err)).called(1);
    });
  });
}
