import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        // Inyectamos el bundle falso para no depender de Flutter Engine
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      // Verificamos traducciones simples y anidadas
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

    test(
      'verify load handles missing file gracefully (Safe Fallback)',
      () async {
        final localization = FluentLocalization(
          path: 'wrong/path', // Ruta que no existe en el fake
          bundle: FakeAssetBundle(fakeAssets),
        );

        // No debe lanzar excepción, simplemente no carga nada
        await localization.load();

        // Al no cargar, devuelve la llave misma
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
