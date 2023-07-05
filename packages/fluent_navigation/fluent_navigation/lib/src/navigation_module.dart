import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:fluent_navigation/src/api/navigation_api_impl.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Register and build all the fluent navigation dependencies
class NavigationModule extends FluentModule {
  NavigationModule({
    this.redirect,
    this.initialLocation,
  });

  /// Callback that allow the app to redirect to a new location.
  final String? Function(String? location)? redirect;
  final String? initialLocation;

  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerLazySingleton<GoRouter>(
        (it) {
          return GoRouter(
            initialLocation: initialLocation,
            navigatorKey: rootNavigatorKey,
            routes: Fluent.get<InternalNavigationApi>().getRegisteredRoutes(),
            redirect: (context, state) => redirect?.call(state.location),
          );
        },
      )
      ..registerSingleton<InternalNavigationApi>(
        (it) => InternalNavigationApiImpl(),
      )
      ..registerSingleton<NavigationApi>((it) => NavigationApiImpl());
  }
}
