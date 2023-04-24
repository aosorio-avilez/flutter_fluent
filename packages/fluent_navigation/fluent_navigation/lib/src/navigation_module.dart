import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:fluent_navigation/src/api/navigation_api_impl.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:go_router/go_router.dart';

class NavigationModule extends Module {
  NavigationModule({
    this.redirect,
    super.testMode = false,
  });

  final String? Function(String? location)? redirect;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<GoRouter>((it) => _buildGoRouter(), lazy: true)
      ..registerApi<InternalNavigationApi>((it) => InternalNavigationApiImpl())
      ..registerApi<NavigationApi>((it) => NavigationApiImpl());
  }

  GoRouter _buildGoRouter() {
    return GoRouter(
      initialLocation: getApi<InternalNavigationApi>().getInitialRoute()?.path,
      routes:
          getApi<InternalNavigationApi>().getRegisteredRoutes().map((route) {
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
