import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation_example/page_one.dart';
import 'package:fluent_navigation_example/page_two.dart';

class ExampleModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      // Initial route
      ..registerRoute(const FluentRoute(
        "one",
        "/",
        // initial: true,
        page: PageOne(),
      ))
      // Second route
      ..registerRoute(const FluentRoute(
        "two",
        "/two",
        page: PageTwo(),
      ));
  }
}
