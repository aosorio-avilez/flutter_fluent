import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RegistryMock extends Mock implements Registry {}

class ModuleMock extends Mock implements Module {}

void main() {
  final registryMock = RegistryMock();

  setUpAll(() {
    registerFallbackValue(registryMock);
  });

  test('verify platform build build each module', () async {
    final module = ModuleMock();
    final modules = [module];
    Fluent.build(modules);

    verify(() => module.build(any())).called(1);
  });
}
