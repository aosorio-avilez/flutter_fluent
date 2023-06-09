import 'package:dio/dio.dart';

import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class DioMock extends Mock implements Dio {}

void main() {
  setUpAll(() {
    Fluent.mock<Dio>(DioMock());
    addTearDown(Fluent.reset);
  });

  group('verify get request', () {
    test('return succeed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.get<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.get<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.get<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.get<void>(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.get<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify post request', () {
    test('return succeed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.post<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.post<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.post<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.post<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.post<void>(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.post<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify patch request', () {
    test('return succeed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.patch<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.patch<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.patch<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.patch<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.patch<void>(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.patch<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify put request', () {
    test('return succeed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.put<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.put<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.put<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.put<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.put<void>(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.put<void>('/');

      expect(result, isA<Error<void>>());
    });
  });

  group('verify delete request', () {
    test('return succeed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.delete<void>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.delete<void>('/');

      expect(result, isA<Succeeded<void>>());
    });

    test('return failed', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.delete<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {},
        ),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.delete<Map<String, dynamic>>('/');

      expect(result, isA<Failed<void>>());
    });

    test('return error', () async {
      final dio = Fluent.get<Dio>();
      when(() => dio.delete<void>(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );

      final networkingApi = NetworkingApiImpl(dio);

      final result = await networkingApi.delete<void>('/');

      expect(result, isA<Error<void>>());
    });
  });
}
