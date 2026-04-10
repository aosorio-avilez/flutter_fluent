import 'package:dio/dio.dart';
import 'package:fluent_networking/src/interceptors/networking_retry_interceptor.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockDio mockDio;
  late MockErrorInterceptorHandler mockHandler;
  late NetworkingRetryInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(
      DioException(requestOptions: RequestOptions()),
    );
  });

  setUp(() {
    mockDio = MockDio();
    mockHandler = MockErrorInterceptorHandler();
    interceptor = NetworkingRetryInterceptor(dio: mockDio);
  });

  group('NetworkingRetryInterceptor', () {
    test('should retry and resolve on success', () async {
      final options = RequestOptions(path: 'test');
      options.extra[NetworkingRetryInterceptor.extraRetryConfig] =
          const RetryConfig(maxRetries: 1, retryInterval: Duration.zero);

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );

      final response = Response(requestOptions: options, data: 'success');

      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);

      await interceptor.onError(error, mockHandler);

      verify(() => mockDio.fetch<dynamic>(options)).called(1);
      verify(() => mockHandler.resolve(response)).called(1);
    });

    test('should respect maxRetries and call next on exhaustion', () async {
      final options = RequestOptions(path: 'test');
      options.extra[NetworkingRetryInterceptor.extraRetryConfig] =
          const RetryConfig(maxRetries: 2, retryInterval: Duration.zero);

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockDio.fetch<dynamic>(any())).thenThrow(error);
      when(() => mockHandler.next(any())).thenAnswer((_) async {});

      await interceptor.onError(error, mockHandler);

      verify(() => mockDio.fetch<dynamic>(options)).called(2);
      verify(() => mockHandler.next(error)).called(1);
    });

    test('should retry on 5xx errors', () async {
      final options = RequestOptions(path: 'test');
      options.extra[NetworkingRetryInterceptor.extraRetryConfig] =
          const RetryConfig(maxRetries: 1, retryInterval: Duration.zero);

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 500,
        ),
      );

      final response = Response(requestOptions: options, data: 'success');

      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);

      await interceptor.onError(error, mockHandler);

      verify(() => mockDio.fetch<dynamic>(options)).called(1);
      verify(() => mockHandler.resolve(response)).called(1);
    });

    test('should not retry on 4xx errors', () async {
      final options = RequestOptions(path: 'test');
      options.extra[NetworkingRetryInterceptor.extraRetryConfig] =
          const RetryConfig(maxRetries: 1, retryInterval: Duration.zero);

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 404,
        ),
      );

      when(() => mockHandler.next(any())).thenAnswer((_) async {});

      await interceptor.onError(error, mockHandler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => mockHandler.next(error)).called(1);
    });

    test(
      'should use globalRetryConfig if per-request config is missing',
      () async {
        interceptor = NetworkingRetryInterceptor(
          dio: mockDio,
          globalRetryConfig: const RetryConfig(
            maxRetries: 1,
            retryInterval: Duration.zero,
          ),
        );

        final options = RequestOptions(path: 'test');
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );

        final response = Response(requestOptions: options, data: 'success');

        when(
          () => mockDio.fetch<dynamic>(any()),
        ).thenAnswer((_) async => response);

        await interceptor.onError(error, mockHandler);

        verify(() => mockDio.fetch<dynamic>(options)).called(1);
        verify(() => mockHandler.resolve(response)).called(1);
      },
    );
  });
}
