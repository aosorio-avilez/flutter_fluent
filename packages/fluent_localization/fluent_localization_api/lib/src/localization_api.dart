import 'package:flutter/material.dart';

abstract class LocalizationApi {
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates();

  List<Locale> getSupportedLocales();

  String translate(BuildContext context, String key);
}
