import 'package:ez_localization/ez_localization.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationApiImpl extends LocalizationApi {
  @override
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates(
    List<Locale> locales, {
    String Function(Locale locale)? pathFunction,
  }) {
    return [
      EzLocalizationDelegate(
        supportedLocales: locales,
        getPathFunction: pathFunction ?? EzLocalization.defaultGetPathFunction,
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
    return context.getString(key, args);
  }
}
