import 'package:flutter/material.dart';

/// Interface defined to use the fluent localization functionalities
abstract class LocalizationApi {
  /// Get the neccesary localization delegates for supported locales
  /// on the default location, in order to change the default location
  /// use the pathFunction to define it.
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates(
    List<Locale> locales, {
    String Function(Locale locale)? pathFunction,
  });

  /// Translate a specific key through the build context
  /// And pass optional args in order to fill placeholders with values
  String translate(
    BuildContext context,
    String key, {
    Map<String, String>? args,
  });
}
