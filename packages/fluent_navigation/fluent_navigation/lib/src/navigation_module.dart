import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:fluent_navigation/src/api/navigation_api_impl.dart';
import 'package:fluent_navigation/src/registry_extension.dart';
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
  void onCreate(Registry registry) {
    GoRouter.optionURLReflectsImperativeAPIs = optionURLReflectsImperativeAPIs;

    registry
      ..registerLazySingleton<GoRouter>(
        (it) {
          return GoRouter(
            initialLocation: initialLocation,
            navigatorKey: rootNavigatorKey,
            routes: it.get<InternalNavigationApi>().getRegisteredRoutes(),
            redirect: (context, state) => redirect?.call(state.uri.toString()),
            refreshListenable: refreshListenable,
          );
        },
      )
      ..registerLazySingleton<InternalNavigationApi>(
        (it) {
          if (!it.isRegistered<FluentRoutes>()) {
            it.registerSingleton<FluentRoutes>((_) => <RouteBase>[]);
          }
          return InternalNavigationApiImpl(it.get<FluentRoutes>());
        },
      )
      // Use lazy singleton to defer initialization
      // until the API is actually used.
      ..registerLazySingleton<NavigationApi>(
        (it) => NavigationApiImpl(it.get<GoRouter>(), rootNavigatorKey),
      );
  }
}
