import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_sdk/src/environment_type.dart';

void main() {
  test('verify dev environment type', () async {
    const devType = EnvironmentType.dev;

    expect(devType.color, Colors.blue);
    expect(devType.description, 'Development');
  });

  test('verify staging environment type', () async {
    const devType = EnvironmentType.stg;

    expect(devType.color, Colors.orange);
    expect(devType.description, 'Staging');
  });

  test('verify production environment type', () async {
    const devType = EnvironmentType.prod;

    expect(devType.color, Colors.red);
    expect(devType.description, 'Production');
  });
}
