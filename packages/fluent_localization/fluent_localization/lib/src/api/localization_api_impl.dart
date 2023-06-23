import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization_delegate.dart';
import 'package:flutter/material.dart';

class LocalizationApiImpl extends LocalizationApi {
  @override
  LocalizationsDelegate<dynamic> getDelegate(
    List<Locale> locales, {
    Locale? defaultLocale,
    String? path,
  }) {
    return FluentLocalizationDelegate(
      supportedLocales: locales,
      locale: defaultLocale,
      path: path ?? defaultPath,
    );
  }

  @override
  String translate(
    BuildContext context,
    String key, {
    Map<String, String>? args,
  }) {
    return FluentLocalization.of(context)!.get(key, args: args);
  }
}
