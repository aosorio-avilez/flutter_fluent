import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/src/interceptors/networking_log_interceptor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

void main() {
  test('NetworkingLogInterceptor should redact password in URI userInfo', () {
    final mockLoggerApi = MockLoggerApi();
    final interceptor = NetworkingLogInterceptor(logger: mockLoggerApi);
    final options = RequestOptions(
      path: 'https://user:password@api.example.com/path',
    );

    interceptor.onRequest(options, MockRequestInterceptorHandler());

    verify(
      () => mockLoggerApi.logInfo(
        any<String>(
          that: contains('https://user:***REDACTED***@api.example.com/path'),
        ),
      ),
    ).called(1);
    verifyNever(
      () => mockLoggerApi.logInfo(any<String>(that: contains('password'))),
    );
  });

  test(
    'NetworkingLogInterceptor should redact sensitive keys in URI fragment',
    () {
      final mockLoggerApi = MockLoggerApi();
      final interceptor = NetworkingLogInterceptor(logger: mockLoggerApi);
      final options = RequestOptions(
        path:
            'https://api.example.com/path#access_token=secret_token&other=value',
      );

      interceptor.onRequest(options, MockRequestInterceptorHandler());

      verify(
        () => mockLoggerApi.logInfo(
          any<String>(that: contains('access_token=***REDACTED***')),
        ),
      ).called(1);
      verifyNever(
        () =>
            mockLoggerApi.logInfo(any<String>(that: contains('secret_token'))),
      );
    },
  );
}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}
