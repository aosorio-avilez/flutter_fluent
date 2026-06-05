import 'package:dio/dio.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/src/interceptors/networking_log_interceptor.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

class MockEnvironmentApi extends Mock implements EnvironmentApi {}

class MockEnvironment extends Mock implements Environment {}

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

    test('onRequest should sanitize default sensitive headers (x-api-key)', () {
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'GET',
        headers: {
          'x-api-key': 'my-secret-key',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my-secret-key')),
        ),
      );
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

    test('onRequest should redact default sensitive query parameters', () {
      final options = RequestOptions(
        path:
            'https://api.example.com?api_key=secret-key&token=my-token&password=my-password&q=flutter',
        method: 'GET',
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(
            that: allOf(
              contains('api_key=%2A%2A%2AREDACTED%2A%2A%2A'),
              contains('token=%2A%2A%2AREDACTED%2A%2A%2A'),
              contains('password=%2A%2A%2AREDACTED%2A%2A%2A'),
              contains('q=flutter'),
            ),
          ),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-key')),
        ),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my-token')),
        ),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my-password')),
        ),
      );
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest should redact custom sensitive query parameters', () {
      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        sensitiveQueryParams: {'my_param'},
      );
      final options = RequestOptions(
        path: 'https://api.example.com?my_param=secret-value',
        method: 'GET',
      );
      final handler = MockRequestInterceptorHandler();

      customInterceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('my_param=%2A%2A%2AREDACTED%2A%2A%2A')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-value')),
        ),
      );
    });

    test('onRequest should redact default sensitive body keys', () {
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'POST',
        data: {
          'email': 'test@example.com',
          'password': 'secret-password',
          'credit_card': '1234-5678-9012-3456',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(3);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('test@example.com')),
        ),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-password')),
        ),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('1234-5678-9012-3456')),
        ),
      );
    });

    test('onRequest should log request and sanitize sensitive body keys', () {
      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        sensitiveBodyKeys: {'custom_key'},
      );
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'POST',
        data: {
          'password': 'secret-password',
          'custom_key': 'secret-custom',
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
          any<String>(that: contains('secret-custom')),
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

    test('onRequest should redact sensitive fields in FormData', () {
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'POST',
        data: FormData.fromMap({
          'email': 'test@example.com',
          'password': 'secret-password',
          'file': MultipartFile.fromString('hello', filename: 'test.txt'),
        }),
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('***REDACTED***')),
        ),
      ).called(2); // email and password
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('[FILE: test.txt]')),
        ),
      ).called(1);
      verifyNever(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('secret-password')),
        ),
      );
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

    test('onRequest should redact sensitive keys from Environment', () {
      final mockEnvironmentApi = MockEnvironmentApi();
      final mockEnvironment = MockEnvironment();
      when(() => mockEnvironmentApi.environment).thenReturn(mockEnvironment);
      when(() => mockEnvironment.sensitiveKeys).thenReturn({'env_secret'});

      final customInterceptor = NetworkingLogInterceptor(
        logger: mockLoggerApi,
        environmentApi: mockEnvironmentApi,
      );

      final options = RequestOptions(
        path: 'https://api.example.com?env_secret=value',
        method: 'POST',
        headers: {'env_secret': 'header-value'},
        data: {'env_secret': 'body-value'},
      );
      final handler = MockRequestInterceptorHandler();

      customInterceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('env_secret=%2A%2A%2AREDACTED%2A%2A%2A')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('env_secret: ***REDACTED***')),
        ),
      ).called(1);
      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('"env_secret": "***REDACTED***"')),
        ),
      ).called(1);

      verifyNever(
        () => mockLoggerApi.logInfo(any<String>(that: contains('header-value'))),
      );
      verifyNever(
        () => mockLoggerApi.logInfo(any<String>(that: contains('body-value'))),
      );
    });
  });
}
