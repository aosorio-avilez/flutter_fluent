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
  const NavigationModule({
    this.redirect,
    this.initialLocation = '/',
    this.optionURLReflectsImperativeAPIs = true,
    this.refreshListenable,
  });

  /// Callback that allow the app to redirect to a new location.
  final String? Function(String? location)? redirect;

  /// The initial location of the app
  final String initialLocation;

  /// Whether or not the url should reflect the imperative APIs.
  final bool optionURLReflectsImperativeAPIs;

  /// A listenable that triggers a refresh of the route information.
  final Listenable? refreshListenable;

  @override
  Future<void> onCreate(Registry registry) async {
    GoRouter.optionURLReflectsImperativeAPIs = optionURLReflectsImperativeAPIs;

    registry
      ..registerLazySingleton<GoRouter>(
        (it) {
          return GoRouter(
            initialLocation: initialLocation,
            navigatorKey: rootNavigatorKey,
            routes: Fluent.get<InternalNavigationApi>().getRegisteredRoutes(),
            redirect: (context, state) => redirect?.call(state.uri.toString()),
            refreshListenable: refreshListenable,
          );
        },
      )
      ..registerSingleton<InternalNavigationApi>(
        (it) => InternalNavigationApiImpl(),
      )
      ..registerSingleton<NavigationApi>((it) => NavigationApiImpl());
  }
}
