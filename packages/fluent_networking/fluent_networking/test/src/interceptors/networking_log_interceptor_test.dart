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
    late NetworkingLogInterceptor interceptor;

    setUp(() {
      interceptor = NetworkingLogInterceptor(logger: mockLoggerApi);
    });

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
          any<String>(that: contains('HTTP REQUEST')),
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

    test('onRequest should log request and sanitize custom header', () {
      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        sensitiveHeaders: {'X-Api-Key'},
      );
      final options = RequestOptions(
        path: 'https://api.example.com',
        headers: {'X-Api-Key': 'my-api-key'},
      );
      final handler = MockRequestInterceptorHandler();

      customInterceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my-api-key')),
        ),
      );
    });

    test('onRequest should log request and sanitize sensitive body keys', () {
      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        sensitiveBodyKeys: {'password', 'token'},
      );
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'POST',
        data: {
          'email': 'test@example.com',
          'password': 'secret-password',
          'nested': {
            'token': 'secret-token',
          },
        },
      );
      final handler = MockRequestInterceptorHandler();

      customInterceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(2);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-password')),
        ),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-token')),
        ),
      );
    });

    test('onResponse should log response and sanitize sensitive body keys', () {
      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        sensitiveBodyKeys: {'secret'},
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        data: {
          'public': 'data',
          'secret': 'hidden',
        },
      );
      final handler = MockResponseInterceptorHandler();

      customInterceptor.onResponse(response, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('hidden')),
        ),
      );
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
          any<String>(that: contains('HTTP RESPONSE')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('success')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('session=123')),
        ),
      );
      verify(() => handler.next(response)).called(1);
    });

    test('onRequest should log request with body', () {
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'POST',
        data: {'key': 'value'},
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () =>
            mockLoggerApi.logInfo(any<String>(that: contains('HTTP REQUEST'))),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('"key": "value"')),
        ),
      ).called(1);
      verify(() => handler.next(options)).called(1);
    });

    test('onResponse should handle null data and log duration', () async {
      final options = RequestOptions(path: 'https://api.example.com');
      // Set start time to simulate duration
      options.extra['networking_start_time'] =
          DateTime.now().millisecondsSinceEpoch - 100;

      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
      );
      final handler = MockResponseInterceptorHandler();

      interceptor.onResponse(response, handler);

      verify(
        () =>
            mockLoggerApi.logInfo(any<String>(that: contains('HTTP RESPONSE'))),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(any<String>(that: contains('Duration:'))),
      ).called(1);
      verify(() => handler.next(response)).called(1);
    });

    test('onResponse should handle invalid JSON string data', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        statusCode: 200,
        data: '{invalid json}',
      );
      final handler = MockResponseInterceptorHandler();

      interceptor.onResponse(response, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('{invalid json}')),
        ),
      ).called(1);
      verify(() => handler.next(response)).called(1);
    });

    test('onError should log error without response', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        message: 'Network error',
      );
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);

      verify(
        () => mockLoggerApi.logError(
          any<String>(that: contains('HTTP ERROR')),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verify(() => handler.next(err)).called(1);
    });

    test('onError should log error with response data', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'https://api.example.com'),
        response: Response(
          requestOptions: RequestOptions(path: 'https://api.example.com'),
          statusCode: 400,
          data: {'error': 'bad request'},
        ),
      );
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);

      verify(
        () => mockLoggerApi.logError(
          any<String>(that: contains('HTTP ERROR')),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logError(
          any<String>(that: contains('bad request')),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verify(() => handler.next(err)).called(1);
    });

    test('should handle gracefully if LoggerApi is not provided', () async {
      final noLoggerInterceptor = NetworkingLogInterceptor(logger: null);

      final options = RequestOptions(path: 'https://api.example.com');
      final handler = MockRequestInterceptorHandler();

      expect(
        () => noLoggerInterceptor.onRequest(options, handler),
        returnsNormally,
      );
    });
  });
}
