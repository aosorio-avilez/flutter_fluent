import 'package:ez_localization/ez_localization.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationApiImpl extends LocalizationApi {
  @override
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates(
    List<Locale> locales,
  ) {
    return [
      EzLocalizationDelegate(supportedLocales: locales),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  @override
  String translate(BuildContext context, String key) {
    return EzLocalization.of(context)!.get(key);
  }
}
