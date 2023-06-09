import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockRequestHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  test('verify rest api interceptor', () async {
    final handler = MockRequestHandler();
    final options = RequestOptions(path: 'http://path.com');

    NetworkingInterceptor().onRequest(options, handler);

    verify(() => handler.next(options)).called(1);
  });
}
