import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation_example/page_one.dart';
import 'package:fluent_navigation_example/page_two.dart';

class ExampleModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      // Initial route
      ..registerRoute(GoRoute(
        name: "one",
        path: "/",
        // initial: true,
        builder: (context, state) => const PageOne(),
      ))
      // Second route
      ..registerRoute(GoRoute(
        name: "two",
        path: "/two",
        builder: (context, state) => const PageTwo(),
      ));
  }
}
