import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  /// Translate an element through the BuildContext
  /// with optional args
  String tl(String key, {Map<String, String>? args}) {
    return Fluent.get<LocalizationApi>().translate(this, key, args: args);
  }
}
