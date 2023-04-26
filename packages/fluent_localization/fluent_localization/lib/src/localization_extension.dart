import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  String tl(String key) {
    return Fluent.get<LocalizationApi>().translate(this, key);
  }
}
