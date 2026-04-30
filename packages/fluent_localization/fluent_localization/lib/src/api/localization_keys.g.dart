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

  /// Translation for "test.hello"
  /// Value: "Hello {name}!"
  String testHello({required String name}) {
    return _context.tr('test.hello', args: {'name': name});
  }

  /// Translation for "test.hello_args"
  /// Value: "{greetings} {name}"
  String testHelloArgs({required String greetings, required String name}) {
    return _context.tr('test.hello_args', args: {'greetings': greetings, 'name': name});
  }

  /// Translation for "title"
  /// Value: "Title"
  String get title => _context.tr('title');

}
