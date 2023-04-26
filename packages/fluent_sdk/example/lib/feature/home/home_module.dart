import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:fluient_sdk_example/feature/home/home_api.dart';
import 'package:fluient_sdk_example/feature/home/home_api_impl.dart';

class HomeModule extends FluentModule {
  @override
  void build(Registry registry) {
    // Registry home api
    registry.registerSingleton<HomeApi>((it) => HomeApiImpl());
  }
}
