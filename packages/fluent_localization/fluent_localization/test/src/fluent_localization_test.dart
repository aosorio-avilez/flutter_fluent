import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(WidgetsFlutterBinding.ensureInitialized);

  test('verify fluent localization load', () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    final result = await localization.load();

    expect(result, isNotEmpty);
  });

  test(
      '''verify fluent localization load return empty map of strings when file does not exists''',
      () async {
    final localization = FluentLocalization(
      path: 'path/does/not/exists',
    );

    final result = await localization.load();

    expect(result, isEmpty);
  });

  test('verify fluent localization load return map of strings', () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    final result = await localization.load();

    expect(result, isA<Map<String, String>>());
    expect(result, isNotEmpty);
  });

  test('verify fluent localization get string with map return localized string',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(
      localization.get(
        'test.hello_args',
        args: {
          'greetings': 'Hi',
          'name': 'Dev',
        },
      ),
      'Hi Dev',
    );
  });

  test('verify fluent localization get string return localized string',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(localization.get('title'), 'Title');
  });

  test('verify fluent localization get missing string should return key',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(localization.get('missing_string'), 'missing_string');
  });
}
