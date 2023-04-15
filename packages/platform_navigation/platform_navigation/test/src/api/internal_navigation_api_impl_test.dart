import 'package:flutter_test/flutter_test.dart';
import 'package:platform_navigation/src/api/internal_navigation_api.dart';
import 'package:platform_navigation/src/navigation_module.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  setUpAll(() => Platform.build([NavigationModule()]));

  test('verify getRegisteredRoutes return registered routes', () async {
    mockApi<List<Route>>([const Route('test', '/path')]);
    final internalApi = getApi<InternalNavigationApi>();

    final registeredRoutes = internalApi.getRegisteredRoutes();

    expect(registeredRoutes.length, 1);
  });

  test('verify getInitialRoute return initial route', () async {
    mockApi<List<Route>>([const Route('test', '/path', initial: true)]);
    final internalApi = getApi<InternalNavigationApi>();

    final initialRoute = internalApi.getInitialRoute();

    expect(initialRoute, isNotNull);
    expect(initialRoute?.initial, isTrue);
  });
}
