import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:fluent_navigation/src/api/navigation_api_impl.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:go_router/go_router.dart';

/// Register and build all the fluent navigation dependencies
class NavigationModule extends FluentModule {
  NavigationModule({
    this.redirect,
  });

  /// Callback that allow the app to redirect to a new location.
  final String? Function(String? location)? redirect;

  @override
  void build(Registry registry) {
    registry
      ..registerLazySingleton<GoRouter>((it) => _buildGoRouter())
      ..registerSingleton<InternalNavigationApi>(
        (it) => InternalNavigationApiImpl(),
      )
      ..registerSingleton<NavigationApi>((it) => NavigationApiImpl());
  }

  GoRouter _buildGoRouter() {
    return GoRouter(
      initialLocation:
          Fluent.get<InternalNavigationApi>().getInitialRoute()?.path,
      routes: Fluent.get<InternalNavigationApi>()
          .getRegisteredRoutes()
          .map((route) {
        return GoRoute(
          name: route.name,
          path: route.path,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: route.builder != null
                  ? route.builder!.call(state.params, state.queryParams)
                  : route.page!,
              key: state.pageKey,
            );
          },
        );
      }).toList(),
      redirect: (context, state) => redirect?.call(state.location),
    );
  }
}
