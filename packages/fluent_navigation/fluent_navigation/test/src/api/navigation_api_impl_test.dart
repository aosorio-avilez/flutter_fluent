import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/go_router_mock.dart';

void main() {
  setUpAll(() async {
    await Fluent.build([NavigationModule()]);
    addTearDown(Fluent.reset);
  });

  test('verify navigateTo', () async {
    Fluent.mock<GoRouter>(GoRouterMock());
    final router = Fluent.get<GoRouter>();

    Fluent.get<NavigationApi>().navigateTo('/');

    verify(() => router.goNamed(any())).called(1);
  });

  test('verify pushTo', () async {
    Fluent.mock<GoRouter>(GoRouterMock());
    final router = Fluent.get<GoRouter>();
    when(() => router.pushNamed<void>(any())).thenAnswer((_) => Future.value());

    await Fluent.get<NavigationApi>().pushTo<void>('/');

    verify(() => router.pushNamed<void>(any())).called(1);
  });

  test('verify getConfig', () async {
    Fluent.mock<GoRouter>(GoRouterMock());

    final config = Fluent.get<NavigationApi>().getConfig();

    expect(config, isA<GoRouter>());
  });
}
