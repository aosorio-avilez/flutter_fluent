// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars, public_member_api_docs, unused_element, prefer_const_constructors, library_private_types_in_public_api, directives_ordering

import 'package:fluent_localization/fluent_localization.dart';
import 'package:flutter/widgets.dart';

extension LocalizationKeysExtension on BuildContext {
  /// Helper to access localization keys in a type-safe way.
  _LocalizationKeys get loc => _LocalizationKeys(this);
}

class _LocalizationKeys {
  const _LocalizationKeys(this._context);

  final BuildContext _context;

  /// Translation for "hello"
  /// Value: "Hello {name}!"
  String hello({required String name}) {
    return _context.tr('hello', args: {'name': name});
  }

  /// Translation for "welcome"
  /// Value: "Welcome to the Example App"
  String get welcome => _context.tr('welcome');

  /// Translation for "home.title"
  /// Value: "Home Page"
  String get homeTitle => _context.tr('home.title');

  /// Translation for "home.description"
  /// Value: "This is a type-safe localization example"
  String get homeDescription => _context.tr('home.description');
}
