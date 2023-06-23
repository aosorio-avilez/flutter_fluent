import 'package:analyzer/dart/element/element.dart';

import 'package:build/build.dart';
import 'package:fluent_environment/src/annotations/fluent_environment.dart';

import 'package:source_gen/source_gen.dart';

class FluentEnvironmentGenerator
    extends GeneratorForAnnotation<FluentEnvironment> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // final visitor = ModelVisitor();
    // element.visitChildren(visitor);

    final classBuffer = StringBuffer()
      ..writeln('extension EnvironmentExtension on Environment {');

    for (final value in annotation.read('valueNames').listValue) {
      final name = value.toStringValue();

      classBuffer.writeln(
        "String get $name => values['$name'] ?? '';",
      );
    }

    classBuffer.writeln('}');

    return classBuffer.toString();
  }
}
