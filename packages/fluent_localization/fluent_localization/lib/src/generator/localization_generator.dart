import 'dart:convert';
import 'dart:io';

import 'package:fluent_localization/src/generator/string_utils.dart';

/// A class that generates type-safe localization keys from JSON files.
class LocalizationGenerator {
  const LocalizationGenerator({
    this.inputPath = 'assets/languages',
    this.outputPath = 'lib/localization_keys.g.dart',
  });

  final String inputPath;
  final String outputPath;

  static final _argRegExp = RegExp(r'\{([^\}]+)\}');

  /// Starts the generation process.
  Future<void> generate() async {
    final directory = Directory(inputPath);
    // ignore: avoid_slow_async_io, Required for CLI tool to check directory existence.
    if (!await directory.exists()) {
      throw Exception('Directory not found: $inputPath');
    }

    final englishFile = File('$inputPath/en.json');
    // ignore: avoid_slow_async_io, Required for CLI tool to read the base translation file.
    if (!await englishFile.exists()) {
      throw Exception('Base localization file not found: $inputPath/en.json');
    }

    final content = await englishFile.readAsString();
    final dynamic jsonMap = json.decode(content);

    if (jsonMap is! Map<String, dynamic>) {
      throw Exception('Invalid JSON format in en.json');
    }

    final entries = <String, String>{};
    _flattenEntries(jsonMap, entries);

    final buffer = StringBuffer();
    _writeHeader(buffer);
    _writeExtension(buffer);
    _writeHelperClass(buffer, entries);

    final outputFile = File(outputPath);
    final parent = outputFile.parent;
    // ignore: avoid_slow_async_io, Required for CLI tool to ensure output directory exists.
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await outputFile.writeAsString(buffer.toString());
  }

  void _flattenEntries(
    Map<String, dynamic> data,
    Map<String, String> result, [
    String prefix = '',
  ]) {
    data.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _flattenEntries(value, result, newKey);
      } else {
        result[newKey] = value.toString();
      }
    });
  }

  void _writeHeader(StringBuffer buffer) {
    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln(
        '// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars, public_member_api_docs, unused_element, prefer_const_constructors, library_private_types_in_public_api, directives_ordering',
      )
      ..writeln()
      ..writeln(
        "import 'package:fluent_localization/fluent_localization.dart';",
      )
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln();
  }

  void _writeExtension(StringBuffer buffer) {
    buffer
      ..writeln('extension LocalizationKeysExtension on BuildContext {')
      ..writeln('  /// Helper to access localization keys in a type-safe way.')
      ..writeln('  _LocalizationKeys get loc => _LocalizationKeys(this);')
      ..writeln('}')
      ..writeln();
  }

  void _writeHelperClass(StringBuffer buffer, Map<String, String> entries) {
    buffer
      ..writeln('class _LocalizationKeys {')
      ..writeln('  const _LocalizationKeys(this._context);')
      ..writeln()
      ..writeln('  final BuildContext _context;')
      ..writeln();

    entries.forEach((key, value) {
      final camelCaseKey = StringUtils.toCamelCase(key);
      final args = _extractArgs(value);

      buffer
        ..writeln('  /// Translation for "$key"')
        ..writeln('  /// Value: "$value"');

      if (args.isEmpty) {
        buffer.writeln(
          "  String get $camelCaseKey => _context.tr('$key');",
        );
      } else {
        final params = args.map((a) => 'required String $a').join(', ');
        final mapEntries = args.map((a) => "'$a': $a").join(', ');

        buffer
          ..writeln('  String $camelCaseKey({$params}) {')
          ..writeln("    return _context.tr('$key', args: {$mapEntries});")
          ..writeln('  }');
      }
      buffer.writeln();
    });

    buffer.writeln('}');
  }

  List<String> _extractArgs(String value) {
    final matches = _argRegExp.allMatches(value);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }
}
