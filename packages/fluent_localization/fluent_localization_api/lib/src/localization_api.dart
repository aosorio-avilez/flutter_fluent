import 'package:flutter/material.dart';

/// Interface defined to use the fluent localization functionalities
abstract class LocalizationApi {
  /// Get the neccesary localization delegates for supported locales
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates(
    List<Locale> locales,
  );

  /// Translate a specific key through the build context
  String translate(BuildContext context, String key);
}
