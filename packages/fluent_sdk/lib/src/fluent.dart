import 'package:fluent_sdk/src/api/module.dart';
import 'package:fluent_sdk/src/app_registry.dart';
import 'package:get_it/get_it.dart';

class Fluent {
  factory Fluent.build(List<Module> modules) {
    return Fluent._privateConstructor(modules);
  }

  Fluent._privateConstructor(this.modules) {
    final registry = AppRegistry();
    final getIt = GetIt.instance..allowReassignment = true;

    for (final module in modules) {
      getIt.pushNewScope();
      module.build(registry);
    }
  }
  final List<Module> modules;
}
