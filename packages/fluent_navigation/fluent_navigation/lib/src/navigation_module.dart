import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:fluent_navigation/src/api/navigation_api_impl.dart';
import 'package:fluent_navigation/src/registry_extension.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The root navigator key to use
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Module that allows you to register the navigation api
class NavigationModule extends FluentModule {
  const NavigationModule({
    this.initialLocation = '/',
    this.redirect,
    this.refreshListenable,
    this.optionURLReflectsImperativeAPIs = true,
  });

  /// The initial location to use
  final String initialLocation;

  /// The redirect function to use
  final String? Function(String? location)? redirect;

  /// The refresh listenable to use
  final Listenable? refreshListenable;

  /// Whether or not the url should reflect the imperative APIs.
  final bool optionURLReflectsImperativeAPIs;

  @override
  Future<void> onCreate(Registry registry) async {
    registry
      ..registerLazySingleton<GoRouter>(
        (it) {
          return GoRouter(
            initialLocation: initialLocation,
            navigatorKey: rootNavigatorKey,
            routes: it<InternalNavigationApi>().getRegisteredRoutes(),
            redirect: (context, state) => redirect?.call(state.uri.toString()),
            refreshListenable: refreshListenable,
          );
        },
      )
      ..registerLazySingleton<InternalNavigationApi>(
        (it) {
          if (!it.isRegistered<FluentRoutes>()) {
            it.registerSingleton<FluentRoutes>((it) => <RouteBase>[]);
          }
          return InternalNavigationApiImpl(it<FluentRoutes>());
        },
      )
      // Use lazy singleton to defer initialization
      // until the API is actually used.
      ..registerLazySingleton<NavigationApi>(
        (it) => NavigationApiImpl(it<GoRouter>(), rootNavigatorKey),
      );
  }
}
