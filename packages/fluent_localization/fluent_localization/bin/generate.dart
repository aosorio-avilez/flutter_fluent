import 'package:fluent_localization/src/generator/localization_generator.dart';

void main(List<String> args) async {
  print('🚀 Fluent Localization: Starting code generation...');
  
  String inputPath = 'assets/languages';
  if (args.isNotEmpty) {
    inputPath = args[0];
  }

  final generator = LocalizationGenerator(inputPath: inputPath);
  
  try {
    await generator.generate();
    print('✅ Fluent Localization: Code generation completed successfully!');
    print('📍 Generated file: lib/src/api/localization_keys.g.dart');
  } catch (e) {
    print('❌ Fluent Localization: Generation failed');
    print('Error: $e');
  }
}
