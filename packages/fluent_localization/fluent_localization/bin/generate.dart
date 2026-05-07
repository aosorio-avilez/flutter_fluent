import 'dart:io';
import 'package:fluent_localization/src/generator/localization_generator.dart';

void main(List<String> args) async {
  stdout.writeln('🚀 Fluent Localization: Starting code generation...');

  var inputPath = 'assets/languages';
  var outputPath = 'lib/localization_keys.g.dart';
  var baseLocale = 'en';

  if (args.isNotEmpty) {
    inputPath = args[0];
  }

  if (args.length > 1) {
    outputPath = args[1];
  }

  if (args.length > 2) {
    baseLocale = args[2];
  }

  final generator = LocalizationGenerator(
    inputPath: inputPath,
    outputPath: outputPath,
    baseLocale: baseLocale,
  );

  try {
    await generator.generate();
    stdout
      ..writeln('✅ Fluent Localization: Code generation completed!')
      ..writeln('📍 Generated file: $outputPath');
  } on Object catch (e) {
    stderr
      ..writeln('❌ Fluent Localization: Generation failed')
      ..writeln('Error: $e');
  }
}
