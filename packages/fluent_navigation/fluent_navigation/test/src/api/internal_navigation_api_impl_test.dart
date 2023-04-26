import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => Fluent.build([NavigationModule()]));

  test('verify getRegisteredRoutes return registered routes', () async {
    Fluent.mock<List<FluentRoute>>([const FluentRoute('test', '/path')]);
    final internalApi = Fluent.get<InternalNavigationApi>();

    final registeredRoutes = internalApi.getRegisteredRoutes();

    expect(registeredRoutes.length, 1);
  });

  test('verify getInitialRoute return initial route', () async {
    Fluent.mock<List<FluentRoute>>(
      [
        const FluentRoute('test', '/path', initial: true),
      ],
    );
    final internalApi = Fluent.get<InternalNavigationApi>();

    final initialRoute = internalApi.getInitialRoute();

    expect(initialRoute, isNotNull);
    expect(initialRoute?.initial, isTrue);
  });
}
