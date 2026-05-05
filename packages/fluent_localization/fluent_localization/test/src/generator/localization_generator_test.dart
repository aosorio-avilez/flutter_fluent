import 'dart:io';

import 'package:fluent_localization/src/generator/localization_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalizationGenerator', () {
    late Directory tempDir;
    late String inputPath;
    late String outputPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fluent_loc_test');
      inputPath = '${tempDir.path}/assets/languages';
      outputPath = '${tempDir.path}/lib/generated_keys.g.dart';

      await Directory(inputPath).create(recursive: true);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('should generate correct code from flat JSON', () async {
      final file = File('$inputPath/en.json');
      await file.writeAsString('{"title": "My App", "login": "Login"}');

      final generator = LocalizationGenerator(
        inputPath: inputPath,
        outputPath: outputPath,
      );

      await generator.generate();

      final outputFile = File(outputPath);
      expect(outputFile.existsSync(), isTrue);

      final content = await outputFile.readAsString();
      expect(content, contains("String get title => _context.tr('title');"));
      expect(content, contains("String get login => _context.tr('login');"));
    });

    test('should generate correct code from nested JSON', () async {
      final file = File('$inputPath/en.json');
      await file.writeAsString('''
      {
        "home": {
          "title": "Welcome",
          "subtitle": "Subtitle"
        }
      }
      ''');

      final generator = LocalizationGenerator(
        inputPath: inputPath,
        outputPath: outputPath,
      );

      await generator.generate();

      final content = await File(outputPath).readAsString();
      expect(
        content,
        contains("String get homeTitle => _context.tr('home.title');"),
      );
      expect(
        content,
        contains("String get homeSubtitle => _context.tr('home.subtitle');"),
      );
    });

    test('should generate methods for keys with arguments', () async {
      final file = File('$inputPath/en.json');
      await file.writeAsString('''
      {
        "greet": "Hello {name}!",
        "points": "You have {count} points in {category}"
      }
      ''');

      final generator = LocalizationGenerator(
        inputPath: inputPath,
        outputPath: outputPath,
      );

      await generator.generate();

      final content = await File(outputPath).readAsString();

      // Check greet method
      expect(content, contains('String greet({required String name})'));
      expect(
        content,
        contains("return _context.tr('greet', args: {'name': name});"),
      );

      // Check points method
      expect(
        content,
        contains(
          'String points({required String count, required String category})',
        ),
      );
      expect(content, contains("'count': count"));
      expect(content, contains("'category': category"));
    });

    test('should throw if base locale file is missing', () async {
      final generator = LocalizationGenerator(
        inputPath: inputPath,
        outputPath: outputPath,
        baseLocale: 'fr',
      );

      expect(generator.generate(), throwsException);
    });

    test(
      'should generate correct code from a different base locale (es.json)',
      () async {
        final file = File('$inputPath/es.json');
        await file.writeAsString('{"hola": "Hola Mundo"}');

        final generator = LocalizationGenerator(
          inputPath: inputPath,
          outputPath: outputPath,
          baseLocale: 'es',
        );

        await generator.generate();

        final content = await File(outputPath).readAsString();
        expect(content, contains("String get hola => _context.tr('hola');"));
      },
    );
  });
}
