import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/environment_api_mock.dart';

class EnvironmentMock extends Mock implements Environment {}

void main() {
  setUpAll(
    () async {
      await Fluent.build([
        EnvironmentModule(
          environment: EnvironmentMock(),
        ),
      ]);
      addTearDown(Fluent.reset);
    },
  );

  testWidgets('verify environment banner', (tester) async {
    Fluent.mock<EnvironmentApi>(EnvironmentApiMock());
    Fluent.mock<Environment>(EnvironmentMock());
    final environment = Fluent.get<Environment>();
    final api = Fluent.get<EnvironmentApi>();

    when(() => environment.name).thenReturn('Development');
    when(() => environment.type).thenReturn(EnvironemntType.dev);
    when(() => environment.color).thenReturn(Colors.blue);
    when(() => api.environment).thenReturn(environment);

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

  testWidgets('verify production environment banner', (tester) async {
    Fluent.mock<EnvironmentApi>(EnvironmentApiMock());
    Fluent.mock<Environment>(EnvironmentMock());
    final environment = Fluent.get<Environment>();
    final api = Fluent.get<EnvironmentApi>();

    when(() => environment.name).thenReturn('Prooduction');
    when(() => environment.type).thenReturn(EnvironemntType.prod);
    when(() => environment.color).thenReturn(Colors.blue);
    when(() => api.environment).thenReturn(environment);

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        builder: (context, child) {
          return EnvironmentBanner(child: child!);
        },
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
