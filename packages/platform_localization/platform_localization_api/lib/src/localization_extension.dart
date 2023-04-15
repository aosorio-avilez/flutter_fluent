import 'package:flutter/material.dart';
import 'package:platform_localization_api/platform_localization_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

extension LocalizationExtension on BuildContext {
  String tl(String key) {
    return getApi<LocalizationApi>().translate(this, key);
  }
}
