import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:platform_networking/src/dio_mock.dart';
import 'package:platform_networking/src/rest_api_impl.dart';
import 'package:platform_networking_api/platform_networking_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  setUpAll(() => mockApi<Dio>(DioMock()));

  group('verify get request', () {
    test('return succeed', () async {
      final dio = getApi<Dio>();
      when(() => dio.get<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.get<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = getApi<Dio>();
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.get<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = getApi<Dio>();
      when(() => dio.get<void>(any())).thenThrow(
        DioError(requestOptions: RequestOptions(path: '/')),
      );

      final api = RestApiImpl(dio);

      final result = await api.get<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify post request', () {
    test('return succeed', () async {
      final dio = getApi<Dio>();
      when(() => dio.post<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.post<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = getApi<Dio>();
      when(() => dio.post<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.post<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = getApi<Dio>();
      when(() => dio.post<void>(any())).thenThrow(
        DioError(requestOptions: RequestOptions(path: '/')),
      );

      final api = RestApiImpl(dio);

      final result = await api.post<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify patch request', () {
    test('return succeed', () async {
      final dio = getApi<Dio>();
      when(() => dio.patch<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.patch<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = getApi<Dio>();
      when(() => dio.patch<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.patch<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = getApi<Dio>();
      when(() => dio.patch<void>(any())).thenThrow(
        DioError(requestOptions: RequestOptions(path: '/')),
      );

      final api = RestApiImpl(dio);

      final result = await api.patch<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify put request', () {
    test('return succeed', () async {
      final dio = getApi<Dio>();
      when(() => dio.put<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.put<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = getApi<Dio>();
      when(() => dio.put<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.put<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = getApi<Dio>();
      when(() => dio.put<void>(any())).thenThrow(
        DioError(requestOptions: RequestOptions(path: '/')),
      );

      final api = RestApiImpl(dio);

      final result = await api.put<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify delete request', () {
    test('return succeed', () async {
      final dio = getApi<Dio>();
      when(() => dio.delete<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.delete<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = getApi<Dio>();
      when(() => dio.delete<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final api = RestApiImpl(dio);

      final result = await api.delete<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = getApi<Dio>();
      when(() => dio.delete<void>(any())).thenThrow(
        DioError(requestOptions: RequestOptions(path: '/')),
      );

      final api = RestApiImpl(dio);

      final result = await api.delete<void>('/');

      expect(result, isA<Error<void>>());
    });
  });
}
