import 'package:flutter/material.dart';

enum EnvironmentType {
  dev,
  stg,
  prod;

  Color get color {
    if (this == EnvironmentType.stg) {
      return Colors.orange;
    } else if (this == EnvironmentType.prod) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  String get description {
    if (this == EnvironmentType.stg) {
      return 'Staging';
    } else if (this == EnvironmentType.prod) {
      return 'Production';
    } else {
      return 'Development';
    }
  }
}
