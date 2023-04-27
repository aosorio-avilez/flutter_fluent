import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/fluent_route.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Fluent.build([NavigationModule()]);
    addTearDown(Fluent.reset);
  });

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
