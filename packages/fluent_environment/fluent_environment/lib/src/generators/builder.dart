// 1
import 'package:build/build.dart';
import 'package:fluent_environment/src/generators/fluent_environment_generator.dart';
// 3

// 2
import 'package:source_gen/source_gen.dart';

// 4
Builder generateExtension(BuilderOptions options) =>
    SharedPartBuilder([FluentEnvironmentGenerator()], 'extension_generator');
