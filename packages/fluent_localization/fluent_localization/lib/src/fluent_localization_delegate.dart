import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/material.dart';

/// The FluentLocalization delegate class.
class FluentLocalizationDelegate
    extends LocalizationsDelegate<FluentLocalization> {
  /// Creates a new app localization delegate instance.
  const FluentLocalizationDelegate({
    this.supportedLocales = const [Locale('en')],
    this.path = defaultPath,
    this.locale,
  });

  /// Contains all supported locales.
  final List<Locale> supportedLocales;

  /// The get path function.
  final String path;

  /// Current locale
  final Locale? locale;

  @override
  bool isSupported(Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.toString() == locale.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<FluentLocalization> load(Locale locale) async {
    final localization = FluentLocalization(
      locale: this.locale ?? locale,
      path: path,
    );

    try {
      await localization.load();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }

    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<FluentLocalization> old) => false;
}
