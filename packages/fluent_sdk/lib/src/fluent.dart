import 'package:fluent_sdk/src/api/fluent_module.dart';
import 'package:fluent_sdk/src/api/registry.dart';
import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:get_it/get_it.dart';

class Fluent {
  static final Registry _registry = FluentRegistry();

  static Future<void> build(List<FluentModule> modules) async {
    final getIt = GetIt.instance;

    await getIt.reset();

    for (final module in modules) {
      getIt.pushNewScope();
      module.build(_registry);
    }
  }

  static T get<T extends Object>() {
    return GetIt.instance<T>();
  }

  static void mock<T extends Object>(T mock) {
    _registry
      ..allowReassignment(allow: true)
      ..registerSingleton<T>((it) => mock)
      ..allowReassignment(allow: false);
  }
}
