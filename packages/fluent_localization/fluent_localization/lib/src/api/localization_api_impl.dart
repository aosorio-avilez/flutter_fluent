import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationApiImpl extends LocalizationApi {
  @override
  List<LocalizationsDelegate<dynamic>> getDelegates(
    List<Locale> locales, {
    Locale? defaultLocale,
    String? path,
  }) {
    return [
      FluentLocalizationDelegate(
        supportedLocales: locales,
        locale: defaultLocale,
        path: path ?? defaultPath,
      ),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  @override
  String translate(
    BuildContext context,
    String key, {
    Map<String, String>? args,
  }) {
    final localization = FluentLocalization.of(context);

    if (localization == null) {
      try {
        Fluent.get<LoggerApi>().logWarning(
          '⚠️ LocalizationApi: FluentLocalization not found in context.',
        );
      } on Object {
        // Silently ignore if LoggerApi is not registered
      }
      return key;
    }

    return localization.get(key, args: args);
  }
}
