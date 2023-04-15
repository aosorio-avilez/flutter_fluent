import 'package:get_it/get_it.dart';
import 'package:platform_sdk/src/api/module.dart';
import 'package:platform_sdk/src/app_registry.dart';

class Platform {
  factory Platform.build(List<Module> modules) {
    return Platform._privateConstructor(modules);
  }

  Platform._privateConstructor(this.modules) {
    final registry = AppRegistry();
    final getIt = GetIt.instance..allowReassignment = true;

    for (final module in modules) {
      getIt.pushNewScope();
      module.build(registry);
    }
  }
  final List<Module> modules;
}
