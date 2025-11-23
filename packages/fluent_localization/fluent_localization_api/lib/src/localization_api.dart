import 'package:flutter/material.dart';

/// Provides an interface for localization operations.
///
/// This abstract class defines the contract for a localization API,
/// including methods to retrieve localization delegates and translate
/// strings.
abstract class LocalizationApi {
  /// Returns a list of localization delegates for the specified locales.
  ///
  /// The `locales` parameter specifies the list of locales that the application
  /// supports. An optional `defaultLocale` can be provided as a fallback.
  /// The `path` parameter can be used to specify the location of localization
  /// resources.
  List<LocalizationsDelegate<dynamic>> getDelegates(
    List<Locale> locales, {
    Locale? defaultLocale,
    String? path,
  });

  /// Translates a given localization key into the current locale's string.
  ///
  /// The `context` is used to resolve the current locale and access the
  /// localization resources. The `key` identifies the string to be translated.
  /// Optional `args` can be provided to substitute placeholders within the
  /// translated string.
  String translate(
    BuildContext context,
    String key, {
    Map<String, String>? args,
  });
}
