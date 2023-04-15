import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  String tl(String key) {
    return getApi<LocalizationApi>().translate(this, key);
  }
}