import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/src/interceptors/networking_curl_interceptor.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class ThrowingRequestOptions extends RequestOptions {
  ThrowingRequestOptions() : super(path: 'https://api.example.com');

  @override
  String get method => throw Exception('Simulated exception');
}

void main() {
  late MockLoggerApi mockLoggerApi;

  setUp(() async {
    await Fluent.reset();
    mockLoggerApi = MockLoggerApi();
    Fluent.mock<LoggerApi>(mockLoggerApi);
  });

  group('NetworkingCurlInterceptor', () {
    late NetworkingCurlInterceptor interceptor;

    setUp(() {
      interceptor = NetworkingCurlInterceptor(logger: mockLoggerApi);
    });

    test('onRequest should log simple GET request as cURL command', () {
      final options = RequestOptions(
        path: 'https://api.example.com/users',
        method: 'GET',
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('curl -X GET "https://api.example.com/users"'));
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest should format headers correctly', () {
      final options = RequestOptions(
        path: 'https://api.example.com/data',
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('-H "Content-Type: application/json"'));
      expect(log, contains('-H "Accept: */*"'));
    });

    test('onRequest should sanitize sensitive headers', () {
      final options = RequestOptions(
        path: 'https://api.example.com/secure',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer my-secret-token',
          'X-Api-Key': 'my-secret-key',
          'Keep-Alive': 'timeout=5',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('-H "Authorization: ***REDACTED***"'));
      expect(log, contains('-H "X-Api-Key: ***REDACTED***"'));
      expect(log, contains('-H "Keep-Alive: timeout=5"'));
      expect(log, isNot(contains('my-secret-token')));
      expect(log, isNot(contains('my-secret-key')));
    });

    test('onRequest should sanitize custom sensitive headers', () {
      final customInterceptor = NetworkingCurlInterceptor(
        logger: mockLoggerApi,
        sensitiveHeaders: {'Custom-Secret-Header'},
      );
      final options = RequestOptions(
        path: 'https://api.example.com',
        method: 'GET',
        headers: {
          'Custom-Secret-Header': 'my-custom-value',
        },
      );
      final handler = MockRequestInterceptorHandler();

      customInterceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('-H "Custom-Secret-Header: ***REDACTED***"'));
      expect(log, isNot(contains('my-custom-value')));
    });

    test('onRequest should sanitize sensitive query parameters', () {
      final options = RequestOptions(
        path:
            'https://api.example.com/query?token=secret-token&search=flutter&password=123',
        method: 'GET',
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('token=%2A%2A%2AREDACTED%2A%2A%2A'));
      expect(log, contains('password=%2A%2A%2AREDACTED%2A%2A%2A'));
      expect(log, contains('search=flutter'));
      expect(log, isNot(contains('secret-token')));
      expect(log, isNot(contains('123')));
    });

    test('onRequest should log POST request with JSON body', () {
      final options = RequestOptions(
        path: 'https://api.example.com/login',
        method: 'POST',
        data: {
          'username': 'john_doe',
          'password': 'my-password',
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('curl -X POST "https://api.example.com/login"'));
      expect(
        log,
        contains(
          "-d '{\"username\":\"john_doe\",\"password\":\"***REDACTED***\"}'",
        ),
      );
      expect(log, isNot(contains('my-password')));
    });

    test('onRequest should log POST request with JSON String body', () {
      final options = RequestOptions(
        path: 'https://api.example.com/login',
        method: 'POST',
        data: '{"username":"john_doe","password":"my-password"}',
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('curl -X POST "https://api.example.com/login"'));
      expect(
        log,
        contains(
          "-d '{\"username\":\"john_doe\",\"password\":\"***REDACTED***\"}'",
        ),
      );
      expect(log, isNot(contains('my-password')));
    });

    test('onRequest should log POST request with FormData body', () {
      final formData = FormData.fromMap({
        'username': 'john_doe',
        'password': 'my-password',
        'file': MultipartFile.fromString('filecontent', filename: 'avatar.png'),
      });
      final options = RequestOptions(
        path: 'https://api.example.com/upload',
        method: 'POST',
        data: formData,
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('curl -X POST "https://api.example.com/upload"'));
      expect(log, contains('-F "username=john_doe"'));
      expect(log, contains('-F "password=***REDACTED***"'));
      expect(log, contains('-F "file=@avatar.png"'));
      expect(log, isNot(contains('my-password')));
    });

    test('onRequest should log POST request with non-JSON string body', () {
      final options = RequestOptions(
        path: 'https://api.example.com/text',
        method: 'POST',
        data: 'plain text data',
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains("-d 'plain text data'"));
    });

    test(
      'onRequest should log POST request with non-standard body type (int)',
      () {
        final options = RequestOptions(
          path: 'https://api.example.com/int',
          method: 'POST',
          data: 12345,
        );
        final handler = MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        final captured = verify(
          () => mockLoggerApi.logInfo(captureAny<String>()),
        ).captured;
        final log = captured.first as String;

        expect(log, contains("-d '12345'"));
      },
    );

    test('onRequest should sanitize sensitive keys in nested JSON body', () {
      final options = RequestOptions(
        path: 'https://api.example.com/nested',
        method: 'POST',
        data: {
          'user': {
            'email': 'test@example.com',
            'profile': {
              'password': 'my-password',
            },
          },
        },
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('"email":"***REDACTED***"'));
      expect(log, contains('"password":"***REDACTED***"'));
      expect(log, isNot(contains('test@example.com')));
      expect(log, isNot(contains('my-password')));
    });

    test('onRequest should sanitize sensitive keys in JSON List body', () {
      final options = RequestOptions(
        path: 'https://api.example.com/list',
        method: 'POST',
        data: [
          {'email': 'test@example.com'},
          {'password': 'my-password'},
        ],
      );
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      final captured = verify(
        () => mockLoggerApi.logInfo(captureAny<String>()),
      ).captured;
      final log = captured.first as String;

      expect(log, contains('"email":"***REDACTED***"'));
      expect(log, contains('"password":"***REDACTED***"'));
      expect(log, isNot(contains('test@example.com')));
      expect(log, isNot(contains('my-password')));
    });

    test('onRequest should log error if curl serialization throws', () {
      final options = ThrowingRequestOptions();
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => mockLoggerApi.logError(
          any<String>(
            that: contains('NetworkingCurlInterceptor: Failed to log curl'),
          ),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
      verify(() => handler.next(options)).called(1);
    });
  });
}
