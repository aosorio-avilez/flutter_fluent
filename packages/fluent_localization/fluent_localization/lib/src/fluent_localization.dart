import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// A function type that parses JSON content.
typedef JsonParser = Future<Map<String, String>> Function(String content);

/// The default path where JSON localization files are expected to be found.
///
/// This path is used if no custom path is provided during
/// [FluentLocalization] initialization.
/// The JSON files within this directory should be named after their
/// locale codes (e.g., `en.json`, `es.json`).
const defaultPath = 'assets/languages';

/// A class that provides internationalization and localization
/// capabilities for Flutter applications.
///
/// It loads translation strings from JSON files located in the specified [path]
/// and provides methods to retrieve localized
/// strings based on the current [locale].
class FluentLocalization {
  /// Creates an instance of [FluentLocalization].
  ///
  /// The [locale] specifies the language to load. Defaults to `en`.
  /// The [path] indicates the directory where language JSON files are stored.
  /// Defaults to `assets/languages`.
  /// The [bundle] is used to load asset strings. Defaults to `rootBundle`.
  FluentLocalization({
    this.locale = const Locale('en'),
    this.path = defaultPath,
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  /// Gets the current [JsonParser].
  static JsonParser? get parser => _parserOverride;

  /// Sets a custom [JsonParser] to be used for parsing localization files.
  ///
  /// This is primarily intended for use in unit tests to provide a
  /// synchronous parser and avoid isolate-related issues.
  @visibleForTesting
  static set parser(JsonParser? parser) => _parserOverride = parser;

  static JsonParser? _parserOverride;

  /// The locale for which the localization strings are loaded.
  final Locale locale;

  /// The directory where language JSON files are stored.
  final String path;

  /// The asset bundle used to load the localization files.
  final AssetBundle _bundle;

  /// A map containing the loaded localization strings.
  final Map<String, String> _strings = {};

  /// Retrieves the [FluentLocalization]
  /// instance from the nearest [BuildContext].
  ///
  /// Returns `null` if no [FluentLocalization] is found in the widget tree.
  static FluentLocalization? of(BuildContext context) =>
      Localizations.of<FluentLocalization>(context, FluentLocalization);

  /// Loads the localization strings for the
  /// current [locale] from the asset bundle.
  ///
  /// This method reads the JSON file corresponding to the [locale] from the
  /// specified [path], parses it, and flattens the key-value pairs into
  /// the internal `_strings` map.
  ///
  /// If the file is not found or an error occurs during loading/parsing,
  /// a debug message will be printed.
  Future<void> load() async {
    final filePath = '$path/$locale.json';

    try {
      final content = await _bundle.loadString(filePath);

      if (content.isEmpty) return;

      final Map<String, String> strings;

      if (_parserOverride != null) {
        strings = await _parserOverride!(content);
      } else {
        strings = await Isolate.run(() => parseJson(content));
      }

      _strings.addAll(strings);
    } on Object catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ FluentLocalization: Failed to load $filePath');
        debugPrint('Error: $e');
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  /// Retrieves a localized string for the given [key].
  ///
  /// If [args] are provided, placeholders in the string (e.g., `{name}`)
  /// will be replaced with the corresponding values from the map.
  ///
  /// If the [key] is not found, a debug warning will be printed, and the
  /// [key] itself will be returned.
  @pragma('vm:prefer-inline')
  String get(String key, {Map<String, String>? args}) {
    final value = _strings[key];

    if (value == null) {
      assert(() {
        debugPrint(
          '⚠️ FluentLocalization: Missing key "$key" for locale $locale',
        );
        return true;
      }(), 'Missing key "$key" for locale $locale');
      return key;
    }

    if (args != null && args.isNotEmpty) {
      return _formatValue(value, args);
    }

    return value;
  }

  static final _argRegExp = RegExp(r'\{([^\}]+)\}');

  /// Replaces placeholders in a string with provided arguments.
  ///
  /// Placeholders are identified by curly braces, e.g., `{argName}`.
  String _formatValue(String value, Map<String, String> arguments) {
    return value.replaceAllMapped(_argRegExp, (match) {
      final key = match.group(1);
      return arguments[key] ?? match.group(0)!;
    });
  }
}

/// Parses the JSON content and flattens it into a map.
Map<String, String> parseJson(String content) {
  final dynamic jsonMap = json.decode(content);
  final result = <String, String>{};

  if (jsonMap is Map<String, dynamic>) {
    flattenStringsRecursive(jsonMap, result);
  }
  return result;
}

/// Recursively flattens a nested JSON map into a single-level map.
void flattenStringsRecursive(
  Map<String, dynamic> data,
  Map<String, String> result, [
  String prefix = '',
]) {
  data.forEach((key, value) {
    final newKey = prefix.isEmpty ? key : '$prefix.$key';

    if (value is Map<String, dynamic>) {
      flattenStringsRecursive(value, result, newKey);
    } else if (value != null) {
      result[newKey] = value.toString();
    }
  });
}
