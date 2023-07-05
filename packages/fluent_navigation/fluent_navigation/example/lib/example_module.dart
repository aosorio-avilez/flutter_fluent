import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation_example/app_scaffold.dart';
import 'package:fluent_navigation_example/page_a.dart';
import 'package:fluent_navigation_example/page_b.dart';
import 'package:fluent_navigation_example/page_d.dart';
import 'package:fluent_navigation_example/page_c.dart';
import 'package:flutter/widgets.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

class ExampleModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerRoute(ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            name: "a",
            path: "/a",
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: PageOne());
            },
          ),
          GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              name: "b",
              path: "/b",
              pageBuilder: (context, state) {
                return const NoTransitionPage(child: PageTwo());
              },
              routes: [
                GoRoute(
                  name: "d",
                  path: "d",
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: PageD());
                  },
                )
              ]),
        ],
      ))
      ..registerRoute(GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: "c",
        path: "/c",
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: PageC());
        },
      ));
  }
}
