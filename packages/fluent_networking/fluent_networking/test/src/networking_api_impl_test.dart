import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late NetworkingApiImpl networkingApi;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    networkingApi = NetworkingApiImpl(mockDio);
    Fluent.mock<Dio>(mockDio);
    addTearDown(Fluent.reset);
  });

  group('NetworkingApiImpl Tests', () {
    group('GET', () {
      test('should return Success when status is 200', () async {
        // Arrange
        when(
          () => mockDio.get<dynamic>(
            any(),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 200,
            data: {'id': 1},
          ),
        );

        // Act
        final result = await networkingApi.get<Map<String, dynamic>>('/');

        // Assert
        expect(result, isA<Success<Map<String, dynamic>>>());
        expect((result as Success<Map<String, dynamic>>).data['id'], 1);
      });

      test('should pass retryConfig to Dio options', () async {
        const retryConfig = RetryConfig(maxRetries: 5);
        when(
          () => mockDio.get<dynamic>(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 200,
          ),
        );

        await networkingApi.get<void>('/', retryConfig: retryConfig);

        final captured = verify(
          () => mockDio.get<dynamic>(
            any(),
            options: captureAny(named: 'options'),
          ),
        ).captured;

        final options = captured.first as Options;
        expect(options.extra!['retry_config'], retryConfig);
      });

      test('should NOT mutate original Options object', () async {
        const retryConfig = RetryConfig(maxRetries: 5);
        final originalOptions = Options(extra: {'existing': 'value'});

        when(
          () => mockDio.get<dynamic>(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 200,
          ),
        );

        await networkingApi.get<void>(
          '/',
          options: originalOptions,
          retryConfig: retryConfig,
        );

        expect(originalOptions.extra!['retry_config'], isNull);
        expect(originalOptions.extra!['existing'], 'value');
      });

      test(
        'should return Failure when Dio throws DioException (e.g. 400)',
        () async {
          // Arrange
          when(
            () => mockDio.get<dynamic>(any(), options: any(named: 'options')),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/'),
              response: Response(
                requestOptions: RequestOptions(path: '/'),
                statusCode: 400,
                data: {'message': 'Bad Request'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );

          // Act
          final result = await networkingApi.get<void>('/');

          // Assert
          expect(result, isA<Failure<void>>());
          final failure = result as Failure<void>;
          expect(failure.error.code, 400);
          expect(failure.error.message, 'Bad Request');
        },
      );

      test(
        'should return Failure when an unexpected exception occurs',
        () async {
          // Arrange
          when(
            () => mockDio.get<dynamic>(any(), options: any(named: 'options')),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await networkingApi.get<void>('/');

          // Assert
          expect(result, isA<Failure<void>>());
          expect(
            (result as Failure).error.message,
            contains('Unexpected Error'),
          );
        },
      );
    });

    group('POST', () {
      test('should return Success when status is 201', () async {
        when(
          () => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 201,
          ),
        );

        final result = await networkingApi.post<void>('/');

        expect(result, isA<Success<void>>());
      });

      test('should return Failure on DioException', () async {
        when(
          () => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await networkingApi.post<void>('/');

        expect(result, isA<Failure<void>>());
      });
    });

    group('PUT', () {
      test('should return Success when status is 200', () async {
        when(
          () => mockDio.put<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 200,
          ),
        );

        final result = await networkingApi.put<void>('/');

        expect(result, isA<Success<void>>());
      });
    });

    group('PATCH', () {
      test('should return Success when status is 200', () async {
        when(
          () => mockDio.patch<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 200,
          ),
        );

        final result = await networkingApi.patch<void>('/');

        expect(result, isA<Success<void>>());
      });
    });

    group('DELETE', () {
      test('should return Success when status is 204', () async {
        when(
          () => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 204,
          ),
        );

        final result = await networkingApi.delete<void>('/');

        expect(result, isA<Success<void>>());
      });

      test('should return Failure when Dio throws', () async {
        when(
          () => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 500,
              data: {'message': 'Internal Server Error'},
            ),
          ),
        );

        final result = await networkingApi.delete<void>('/');

        expect(result, isA<Failure<void>>());
        expect((result as Failure).error.code, 500);
      });
    });
  });
}
