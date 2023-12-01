import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// The default path.
const String defaultPath = 'assets/languages';

// The FluentLocalization class.
class FluentLocalization {
  /// Creates a new localization instance.
  FluentLocalization({
    this.locale = const Locale('en'),
    this.path = defaultPath,
  });

  /// The current locale.
  final Locale locale;

  /// The path resolver function.
  final String path;

  /// The localized strings.
  final Map<String, String> _strings = HashMap();

  /// Return the localization instance
  static FluentLocalization? of(BuildContext context) =>
      Localizations.of<FluentLocalization>(context, FluentLocalization);

  /// Loads the localized strings.
  Future<Map<String, String>> load() async {
    final filePath = '$path/$locale.json';
    final fileExists = File(filePath).existsSync();

    if (fileExists) {
      final data = await rootBundle.loadString(filePath);
      (json.decode(data) as Map<String, dynamic>).forEach(_addStrings);
    }

    return _strings;
  }

  /// Get the string associated with the specified key.
  String get(String key, {Map<String, String>? args}) {
    final value = _strings[key];

    if (value == null) {
      return key;
    }

    if (args != null) {
      return _getFormatedValue(value, args);
    } else {
      return value;
    }
  }

  /// Adds the strings to the current strings map.
  void _addStrings(String key, dynamic data) {
    if (data is Map) {
      data.forEach((subKey, subData) => _addStrings('$key.$subKey', subData));
      return;
    }

    if (data != null) {
      _strings[key] = data.toString();
    }
  }

  /// Formats the current value based on the specified arguments.
  String _getFormatedValue(String value, Map<String, String>? arguments) {
    if (arguments != null) {
      var temp = value;
      arguments.forEach((formatKey, formatValue) {
        temp = temp.replaceAll('{$formatKey}', formatValue);
      });
      return temp;
    } else {
      return value;
    }
  }
}
