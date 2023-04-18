import 'package:fluent_navigation_example/page_one.dart';
import 'package:fluent_navigation_example/page_two.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

class ExampleModule extends Module {
  ExampleModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry
      // Initial route
      ..registerRoute(const Route(
        "one",
        "/",
        // initial: true,
        page: PageOne(),
      ))
      // Second route
      ..registerRoute(const Route(
        "two",
        "/two",
        page: PageTwo(),
      ));
  }
}
