import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation_example/page_one.dart';
import 'package:fluent_navigation_example/page_two.dart';

class ExampleModule extends Module {
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
