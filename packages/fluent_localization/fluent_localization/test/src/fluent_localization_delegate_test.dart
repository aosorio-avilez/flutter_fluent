import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/fake_assets_bundle.dart';
// Importa tu FakeAssetBundle aquí

void main() {
  setUpAll(() {
    FluentLocalization.parser = (content) async =>
        parseJson(content); // Changed parseJson to jsonDecode
  });

  // Definimos un JSON de prueba
  final fakeAssets = {
    'test/assets/languages/en.json':
        '{"title": "Title", "test": {"hello": "Hello {name}!"}}',
    'test/assets/languages/es.json': '{"title": "Titulo"}',
  };

  group('FluentLocalization Unit Tests', () {
    test('verify load resolves strings correctly using FakeBundle', () async {
      final localization = FluentLocalization(
        path: 'test/assets/languages',
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(
        localization.get('test.hello', args: {'name': 'Dev'}),
        'Hello Dev!',
      );
    });

    test('verify load handles missing file gracefully', () async {
      final localization = FluentLocalization(
        path: 'wrong/path',
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(localization.get('title'), 'title');
    });
  });
}
