import 'package:go_router/go_router.dart';
import 'package:platform_navigation/src/api/internal_navigation_api.dart';
import 'package:platform_navigation/src/api/internal_navigation_api_impl.dart';
import 'package:platform_navigation/src/api/navigation_api_impl.dart';
import 'package:platform_navigation_api/platform_navigation_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class NavigationModule extends Module {
  NavigationModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry
      ..registerApi<GoRouter>((it) => _buildGoRouter(), lazy: true)
      ..registerApi<InternalNavigationApi>((it) => InternalNavigationApiImpl())
      ..registerApi<NavigationApi>((it) => NavigationApiImpl());
  }

  GoRouter _buildGoRouter() {
    return GoRouter(
      initialLocation: getApi<InternalNavigationApi>().getInitialRoute()?.name,
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
    );
  }
}
