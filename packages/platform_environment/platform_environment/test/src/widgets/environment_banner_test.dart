import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:platform_environment/src/api/environment_api_mock.dart';
import 'package:platform_environment/src/environment_module.dart';
import 'package:platform_environment/src/widgets/environment_banner.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class EnvironmentMock extends Mock implements Environment {}

void main() {
  setUpAll(
    () => Platform.build([
      EnvironmentModule(
        EnvironmentMock(),
      )
    ]),
  );

  testWidgets('verify environment banner', (tester) async {
    mockApi<EnvironmentApi>(EnvironmentApiMock());
    mockApi<Environment>(EnvironmentMock());
    final environment = getApi<Environment>();
    final api = getApi<EnvironmentApi>();

    when(() => environment.type).thenReturn(EnvironmentType.dev);
    when(api.getEnvironment).thenReturn(environment);

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        builder: (context, child) {
          return EnvironmentBanner(child: child!);
        },
      ),
    );

    expect(find.byType(EnvironmentBanner), findsOneWidget);
  });
}
