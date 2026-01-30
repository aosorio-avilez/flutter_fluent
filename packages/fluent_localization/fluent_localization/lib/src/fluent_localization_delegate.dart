import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/material.dart';

/// A [LocalizationsDelegate] for [FluentLocalization].
///
/// This delegate is responsible for loading [FluentLocalization] instances
/// based on the current locale. It allows specifying supported locales,
/// the path to the localization files, an optional specific locale to load,
/// and an optional asset bundle.
class FluentLocalizationDelegate
    extends LocalizationsDelegate<FluentLocalization> {
  /// Creates a [FluentLocalizationDelegate].
  ///
  /// [supportedLocales] is the list of locales that this delegate can provide
  /// localizations for. Defaults to `[Locale('en')]`.
  /// [path] is the path to the localization JSON files.
  /// Defaults to `defaultPath`.
  /// [locale] is an optional specific locale to load,
  /// overriding the system locale.
  /// [assetBundle] is an optional asset bundle to load localization files from.
  const FluentLocalizationDelegate({
    this.supportedLocales = const [Locale('en')],
    this.path = defaultPath,
    this.locale,
    this.assetBundle,
  });

  /// The list of locales that this delegate can provide localizations for.
  final List<Locale> supportedLocales;

  /// The path to the localization JSON files.
  final String path;

  /// An optional specific locale to load, overriding the system locale.
  final Locale? locale;

  /// An optional asset bundle to load localization files from.
  final AssetBundle? assetBundle;

  @override
  bool isSupported(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          (supported.countryCode == null ||
              supported.countryCode == locale.countryCode)) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<FluentLocalization> load(Locale locale) async {
    final effectiveLocale = this.locale ?? locale;

    final localization = FluentLocalization(
      locale: effectiveLocale,
      path: path,
      bundle: assetBundle,
    );

    await localization.load();

    return localization;
  }

  @override
  bool shouldReload(FluentLocalizationDelegate old) {
    return old.path != path || old.supportedLocales != supportedLocales;
  }
}
