import 'package:fluent_navigation/src/api/go_router_mock.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() => Fluent.build([NavigationModule()]));

  test('verify navigateTo', () async {
    mockApi<GoRouter>(GoRouterMock());
    final router = getApi<GoRouter>();
    // when(() => router.goNamed(any())).thenReturn(null);

    getApi<NavigationApi>().navigateTo('/');

    verify(() => router.goNamed(any())).called(1);
  });

  test('verify pushTo', () async {
    mockApi<GoRouter>(GoRouterMock());
    final router = getApi<GoRouter>();
    when(() => router.pushNamed<void>(any())).thenAnswer((_) => Future.value());

    await getApi<NavigationApi>().pushTo<void>('/');

    verify(() => router.pushNamed<void>(any())).called(1);
  });

  test('verify getConfig', () async {
    mockApi<GoRouter>(GoRouterMock());

    final config = getApi<NavigationApi>().getConfig();

    expect(config, isA<GoRouter>());
  });
}
