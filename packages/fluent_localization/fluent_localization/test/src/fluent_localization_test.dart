import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    FluentLocalization.parser = (content) async => parseJson(content);
  });
  // Definimos los "archivos" que existen en nuestra memoria para la prueba
  final fakeAssets = {
    'assets/languages/en.json': '''
      {
        "title": "Title", 
        "test": {
          "hello": "Hello {name}!",
          "nested": "Nested Value"
        }
      }
    ''',
    'assets/languages/es.json': '{"title": "Titulo"}',
  };

  group('FluentLocalization Unit Tests', () {
    test('verify load resolves strings correctly using FakeBundle', () async {
      final localization = FluentLocalization(
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(localization.get('title'), 'Title');
      expect(localization.get('test.nested'), 'Nested Value');
    });

    test('verify get returns formatted string with arguments', () async {
      final localization = FluentLocalization(
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(
        localization.get('test.hello', args: {'name': 'Dev'}),
        'Hello Dev!',
      );
    });

    test('verify get ignores unused arguments', () async {
      final localization = FluentLocalization(
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(
        localization.get(
          'test.hello',
          args: {'name': 'Dev', 'unused': 'Value'},
        ),
        'Hello Dev!',
      );
    });

    test('verify get preserves placeholders for missing arguments', () async {
      final localization = FluentLocalization(
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(
        localization.get('test.hello', args: {'wrong': 'Dev'}),
        'Hello {name}!',
      );
    });

    test(
      'verify load handles missing file gracefully (Safe Fallback)',
      () async {
        final localization = FluentLocalization(
          path: 'wrong/path',
          bundle: FakeAssetBundle(fakeAssets),
        );

        await localization.load();

        expect(localization.get('title'), 'title');
      },
    );

    test('verify get returns key when translation is missing', () async {
      final localization = FluentLocalization(
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(localization.get('missing.key'), 'missing.key');
    });
  });
}

// --- UTILITY CLASS ---

/// Un AssetBundle falso que sirve datos desde un Map en memoria.
/// Esto elimina la necesidad de usar 'testWidgets' o 'BinaryMessenger'.
class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.data);
  final Map<String, String> data;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (data.containsKey(key)) {
      return data[key]!;
    }
    // Simulamos el error nativo de Flutter cuando no encuentra un asset
    throw FlutterError('Unable to load asset: "$key"');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError('Text-only bundle for testing');
  }
}
