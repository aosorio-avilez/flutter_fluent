import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:platform_localization_api/platform_localization_api.dart';

class LocalizationApiImpl extends LocalizationApi {
  @override
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates() {
    return [
      EzLocalizationDelegate(supportedLocales: getSupportedLocales()),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  @override
  List<Locale> getSupportedLocales() {
    return [
      const Locale('es'),
      const Locale('en'),
    ];
  }

  @override
  String translate(BuildContext context, String key) {
    return EzLocalization.of(context)!.get(key);
  }
}
