import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/interceptors/networking_cache_interceptor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

void main() {
  late NetworkingCacheInterceptor interceptor;
  late MockRequestInterceptorHandler requestHandler;
  late MockResponseInterceptorHandler responseHandler;

  setUp(() {
    interceptor = NetworkingCacheInterceptor();
    requestHandler = MockRequestInterceptorHandler();
    responseHandler = MockResponseInterceptorHandler();
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/')),
    );
  });

  test('should not cache if CacheConfig is missing', () {
    final options = RequestOptions(path: '/test');

    interceptor.onRequest(options, requestHandler);

    verify(() => requestHandler.next(options)).called(1);
  });

  test('should cache response and return it on subsequent request', () async {
    const cacheConfig = CacheConfig(duration: Duration(seconds: 1));
    final options = RequestOptions(
      path: '/test',
      extra: {NetworkingCacheInterceptor.extraCacheConfig: cacheConfig},
    );
    final response = Response<dynamic>(
      requestOptions: options,
      data: {'key': 'value'},
      statusCode: 200,
    );

    // First request: handle response to cache it
    interceptor.onResponse(response, responseHandler);
    verify(() => responseHandler.next(response)).called(1);

    // Second request: should resolve with cached response
    interceptor.onRequest(options, requestHandler);

    verify(
      () => requestHandler.resolve(
        any(
          that: isA<Response<dynamic>>().having(
            (r) => r.statusMessage,
            'statusMessage',
            'OK (Cached)',
          ),
        ),
      ),
    ).called(1);
  });

  test('should not return cached response if expired', () async {
    const cacheConfig = CacheConfig(duration: Duration(milliseconds: 10));
    final options = RequestOptions(
      path: '/test',
      extra: {NetworkingCacheInterceptor.extraCacheConfig: cacheConfig},
    );
    final response = Response<dynamic>(
      requestOptions: options,
      data: {'key': 'value'},
      statusCode: 200,
    );

    interceptor.onResponse(response, responseHandler);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    interceptor.onRequest(options, requestHandler);

    verify(() => requestHandler.next(options)).called(1);
  });

  test('should force refresh even if cached response exists', () {
    const cacheConfig = CacheConfig(duration: Duration(seconds: 1));
    final options = RequestOptions(
      path: '/test',
      extra: {NetworkingCacheInterceptor.extraCacheConfig: cacheConfig},
    );
    final response = Response<dynamic>(
      requestOptions: options,
      data: {'key': 'value'},
      statusCode: 200,
    );

    interceptor.onResponse(response, responseHandler);

    final forceOptions = options.copyWith(
      extra: {
        NetworkingCacheInterceptor.extraCacheConfig:
            const CacheConfig(forceRefresh: true),
      },
    );

    interceptor.onRequest(forceOptions, requestHandler);

    verify(() => requestHandler.next(forceOptions)).called(1);
  });
}
