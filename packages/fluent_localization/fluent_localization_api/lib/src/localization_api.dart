import 'package:flutter/material.dart';

abstract class LocalizationApi {
  List<LocalizationsDelegate<dynamic>> getLocalizationDelegates(
    List<Locale> locales,
  );

  String translate(BuildContext context, String key);
}
