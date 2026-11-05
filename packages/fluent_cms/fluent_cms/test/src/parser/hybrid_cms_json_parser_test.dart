import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HybridCmsJsonParser', () {
    const parser = HybridCmsJsonParser();

    test('parses payload < 50KB synchronously on main thread', () async {
      const smallJson = '''
{
  "schemaVersion": "1.0.0",
  "pageId": "small_page",
  "layout": {
    "mobile": { "type": "single_column", "zonesOrder": ["main"] }
  },
  "zones": {
    "main": {
      "modules": [
        { "id": "m1", "type": "banner", "props": { "title": "Hello" } }
      ]
    }
  }
}
''';
      expect(
        smallJson.length,
        lessThan(HybridCmsJsonParser.isolateThreshold),
      );

      final page = await parser.parse(smallJson);
      expect(page.pageId, 'small_page');
      expect(page.zones['main']?.modules.first.id, 'm1');
    });

    test('parses payload >= 50KB using Isolate.run', () async {
      final paddingText = 'x' * 52000;
      final largeJson =
          '''
{
  "schemaVersion": "1.0.0",
  "pageId": "large_page",
  "dataContext": { "blob": "$paddingText" },
  "layout": {
    "mobile": { "type": "single_column", "zonesOrder": ["main"] }
  },
  "zones": {
    "main": { "modules": [] }
  }
}
''';
      expect(
        largeJson.length,
        greaterThanOrEqualTo(HybridCmsJsonParser.isolateThreshold),
      );

      final page = await parser.parse(largeJson);
      expect(page.pageId, 'large_page');
      expect((page.dataContext?['blob'] as String?)?.length, 52000);
    });

    test('throws FormatException when root JSON is not an object', () {
      expect(
        () => HybridCmsJsonParser.parseSync('[1, 2, 3]'),
        throwsFormatException,
      );
    });
  });
}
