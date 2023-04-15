import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:platform_sdk/platform_sdk.dart';

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
    Platform.build(modules);

    verify(() => module.build(any())).called(1);
  });
}
