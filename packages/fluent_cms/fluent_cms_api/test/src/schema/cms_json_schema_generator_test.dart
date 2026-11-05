import 'dart:convert';
import 'dart:io';

import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _BannerTestModule extends SduiModule {
  const _BannerTestModule();

  @override
  String get type => 'loyalty_banner';

  @override
  Map<String, dynamic> get propsSchema => const <String, dynamic>{
    'type': 'object',
    'required': <String>['greeting'],
    'properties': <String, dynamic>{
      'greeting': <String, dynamic>{'type': 'string'},
    },
  };

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('CmsJsonSchemaGenerator', () {
    test('generates valid Draft 2020-12 schema with registered modules', () {
      const generator = CmsJsonSchemaGenerator();
      expect(generator, isNotNull);

      final schema = CmsJsonSchemaGenerator.generate(
        modules: const [_BannerTestModule(), _BannerTestModule()],
      );

      expect(schema[r'$schema'], CmsJsonSchemaGenerator.draft202012Uri);
      expect(schema[r'$id'], CmsJsonSchemaGenerator.defaultSchemaId);
      expect(
        schema['required'],
        containsAll(['schemaVersion', 'pageId', 'layout', 'zones']),
      );

      final defs = schema[r'$defs'] as Map<String, dynamic>;
      expect(
        defs.keys,
        containsAll([
          'AsyncSource',
          'ResponsiveLayoutConfig',
          'BreakpointLayout',
          'ColumnSpanConfig',
          'ContentZone',
          'ModuleNode',
          'A11yConfig',
          'ActionNode',
          'OptimisticMutation',
          'RepeaterConfig',
          'PaginationConfig',
          'ModulePropsSchemas',
        ]),
      );

      final moduleNodeDef = defs['ModuleNode'] as Map<String, dynamic>;
      final props = moduleNodeDef['properties'] as Map<String, dynamic>;
      final typeProp = props['type'] as Map<String, dynamic>;
      expect(typeProp['enum'], ['cms_repeater', 'loyalty_banner']);

      final prettyJson = CmsJsonSchemaGenerator.generateJsonString(
        modules: const [_BannerTestModule()],
      );
      final compactJson = CmsJsonSchemaGenerator.generateJsonString(
        pretty: false,
      );
      expect(jsonDecode(prettyJson), isA<Map<String, dynamic>>());
      expect(jsonDecode(compactJson), isA<Map<String, dynamic>>());
    });

    test('generates and matches repository cms_schema.json', () {
      final generatedJson = CmsJsonSchemaGenerator.generateJsonString();

      // Ensure local schema file in packages/fluent_cms/fluent_cms/schema exists
      final candidatePaths = [
        '../fluent_cms/schema/cms_schema.json',
        'packages/fluent_cms/fluent_cms/schema/cms_schema.json',
      ];

      File? schemaFile;
      for (final path in candidatePaths) {
        final file = File(path);
        if (file.existsSync()) {
          schemaFile = file;
          break;
        }
      }

      if (schemaFile == null) {
        for (final path in candidatePaths) {
          final file = File(path);
          if (file.parent.parent.existsSync()) {
            file.parent.createSync(recursive: true);
            file.writeAsStringSync('$generatedJson\n');
            schemaFile = file;
            break;
          }
        }
      }

      expect(schemaFile, isNotNull);
      expect(
        schemaFile!.readAsStringSync().trim(),
        equals(generatedJson.trim()),
      );
    });
  });
}
