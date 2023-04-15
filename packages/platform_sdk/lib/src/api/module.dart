import 'package:platform_sdk/src/api/registry.dart';

abstract class Module {
  Module({required this.testMode});

  final bool testMode;

  void build(Registry registry);
}
