import 'package:flutter/material.dart';

/// Interface defined to use the fluent localization functionalities
abstract class LocalizationApi {
  /// Get the localization delegate for supported locales
  /// on the default location, in order to change the default location
  /// use the path attribute to define it.
  LocalizationsDelegate<dynamic> getDelegate(
    List<Locale> locales, {
    Locale? defaultLocale,
    String? path,
  });

  /// Translate a specific key through the build context
  /// And pass optional args in order to fill placeholders with values
  String translate(
    BuildContext context,
    String key, {
    Map<String, String>? args,
  });
}
