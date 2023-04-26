import 'package:fluent_environment/src/api/environment_api_mock.dart';
import 'package:fluent_environment/src/environment_module.dart';
import 'package:fluent_environment/src/widgets/environment_banner.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class EnvironmentMock extends Mock implements Environment {}

void main() {
  setUpAll(
    () => Fluent.build([
      EnvironmentModule(
        environment: EnvironmentMock(),
      )
    ]),
  );

  testWidgets('verify environment banner', (tester) async {
    Fluent.mock<EnvironmentApi>(EnvironmentApiMock());
    Fluent.mock<Environment>(EnvironmentMock());
    final environment = Fluent.get<Environment>();
    final api = Fluent.get<EnvironmentApi>();

    when(() => environment.name).thenReturn('Development');
    when(() => environment.color).thenReturn(Colors.blue);
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
