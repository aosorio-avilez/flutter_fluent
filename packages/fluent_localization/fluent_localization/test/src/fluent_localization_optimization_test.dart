import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Reset parser override to ensure we test the real logic
  setUp(() {
    FluentLocalization.parser = null;
  });

  // Generate a large JSON content (> 50KB)
  final largeJsonContent = StringBuffer('{"large": "value"');
  for (var i = 0; i < 5000; i++) {
    largeJsonContent.write(', "key$i": "value$i"');
  }
  largeJsonContent.write('}');
  final largeJsonString = largeJsonContent.toString();

  final fakeAssets = {
    'assets/languages/en.json': '{"small": "value", "nested": {"key": "nestedValue"}}',
    'assets/languages/es.json': largeJsonString,
  };

  group('FluentLocalization Optimization Tests', () {
    test('verify load handles small files correctly (Sync Path)', () async {
      final localization = FluentLocalization(
        locale: const Locale('en'),
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(localization.get('small'), 'value');
      expect(localization.get('nested.key'), 'nestedValue');
    });

    test('verify load handles large files correctly (Async Isolate Path)', () async {
      final localization = FluentLocalization(
        locale: const Locale('es'),
        bundle: FakeAssetBundle(fakeAssets),
      );

      await localization.load();

      expect(localization.get('large'), 'value');
      expect(localization.get('key0'), 'value0');
      expect(localization.get('key4999'), 'value4999');
    });
  });
}

class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.data);
  final Map<String, String> data;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (data.containsKey(key)) {
      return data[key]!;
    }
    throw FlutterError('Unable to load asset: "$key"');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError('Text-only bundle for testing');
  }
}
