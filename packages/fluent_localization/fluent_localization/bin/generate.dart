import 'dart:io';
import 'package:fluent_localization/src/generator/localization_generator.dart';

void main(List<String> args) async {
  stdout.writeln('🚀 Fluent Localization: Starting code generation...');

  var inputPath = 'assets/languages';
  if (args.isNotEmpty) {
    inputPath = args[0];
  }

  final generator = LocalizationGenerator(inputPath: inputPath);

  try {
    await generator.generate();
    stdout
      ..writeln('✅ Fluent Localization: Code generation completed!')
      ..writeln('📍 Generated file: lib/src/api/localization_keys.g.dart');
  } on Object catch (e) {
    stderr
      ..writeln('❌ Fluent Localization: Generation failed')
      ..writeln('Error: $e');
  }
}
