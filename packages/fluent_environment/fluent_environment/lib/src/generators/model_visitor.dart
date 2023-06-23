import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  final parameters = <String>[];

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();

    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  void visitFieldElement(FieldElement element) {
    print(element);
  }

  // @override
  // void visitParameterElement(ParameterElement element) {
  //   final annotations =
  //       const TypeChecker.fromRuntime(FluentEnvironment).annotationsOf(element);
  //   print(annotations);
  // }
}
