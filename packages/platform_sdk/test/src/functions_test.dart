import 'package:flutter_test/flutter_test.dart';
import 'package:platform_sdk/platform_sdk.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';

void main() {
  test('verify getApi return specific instance', () async {
    GetIt.instance.registerLazySingleton(TestClass.new);

    expect(getApi<TestClass>(), isA<TestClass>());
  });

  test('verify mockApi register a new instance of the same type', () async {
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerLazySingleton(TestClass.new);

    mockApi<TestClass>(TestClass2());

    expect(getApi<TestClass>(), isA<TestClass2>());
  });
}
