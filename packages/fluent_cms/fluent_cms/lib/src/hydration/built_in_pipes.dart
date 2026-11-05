import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/widgets.dart';

/// Optional callback used by [TranslatePipe] to resolve a translation key.
typedef CmsTranslationResolver =
    String? Function(
      String key, {
      String? argument,
      BuildContext? context,
    });

/// Formats a numeric value with a currency symbol/ISO prefix (`currency:MXN`,
/// `currency:USD`, `currency:EUR`).
class CurrencyPipe implements PipeTransformer {
  /// Creates a [CurrencyPipe].
  const CurrencyPipe();

  @override
  String get name => 'currency';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    final number = _parseDouble(value);
    if (number == null) return value ?? '';

    final code = argument?.trim().toUpperCase() ?? '';
    final isNegative = number < 0;
    final absValue = number.abs();
    final formattedNumber = _formatDecimal(absValue, decimals: 2);
    final sign = isNegative ? '-' : '';

    return switch (code) {
      'EUR' => '$sign€$formattedNumber',
      'GBP' => '$sign£$formattedNumber',
      'JPY' => '$sign¥${_formatDecimal(absValue, decimals: 0)}',
      '' => '$sign\$$formattedNumber',
      _ => '$code $sign\$$formattedNumber',
    };
  }
}

/// Formats a numeric value with thousand separators and optional decimal places
/// (`number` or `number:2`).
class NumberPipe implements PipeTransformer {
  /// Creates a [NumberPipe].
  const NumberPipe();

  @override
  String get name => 'number';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    final number = _parseDouble(value);
    if (number == null) return value ?? '';

    final decimals = argument != null ? int.tryParse(argument.trim()) : null;
    final isNegative = number < 0;
    final absValue = number.abs();

    if (decimals != null && decimals >= 0) {
      final formatted = _formatDecimal(absValue, decimals: decimals);
      return isNegative ? '-$formatted' : formatted;
    }

    // Default: if integer-valued, format with 0 decimals; otherwise up to 2.
    if (absValue == absValue.truncateToDouble()) {
      final formatted = _formatDecimal(absValue, decimals: 0);
      return isNegative ? '-$formatted' : formatted;
    }
    final formatted = _formatDecimal(absValue, decimals: 2);
    return isNegative ? '-$formatted' : formatted;
  }
}

/// Formats a [DateTime], epoch milliseconds [int], or ISO-8601 [String]
/// (`date`, `date:yyyy-MM-dd`, `date:dd/MM/yyyy`, `date:yyyy-MM-dd HH:mm`).
class DatePipe implements PipeTransformer {
  /// Creates a [DatePipe].
  const DatePipe();

  @override
  String get name => 'date';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    final date = _parseDateTime(value);
    if (date == null) return value ?? '';

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    final pattern = argument?.trim() ?? 'yyyy-MM-dd';
    return switch (pattern) {
      'dd/MM/yyyy' => '$day/$month/$year',
      'MM/dd/yyyy' => '$month/$day/$year',
      'yyyy-MM-dd HH:mm' => '$year-$month-$day $hour:$minute',
      _ => '$year-$month-$day',
    };
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
}

/// Converts a value to an uppercase string (`uppercase`).
class UppercasePipe implements PipeTransformer {
  /// Creates an [UppercasePipe].
  const UppercasePipe();

  @override
  String get name => 'uppercase';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    if (value == null) return '';
    return value.toString().toUpperCase();
  }
}

/// Converts a value to a lowercase string (`lowercase`).
class LowercasePipe implements PipeTransformer {
  /// Creates a [LowercasePipe].
  const LowercasePipe();

  @override
  String get name => 'lowercase';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    if (value == null) return '';
    return value.toString().toLowerCase();
  }
}

/// Returns the fallback argument when the input value is `null` or an empty
/// [String] (`default:Fallback`).
class DefaultPipe implements PipeTransformer {
  /// Creates a [DefaultPipe].
  const DefaultPipe();

  @override
  String get name => 'default';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    if (value == null) return argument ?? '';
    if (value is String && value.isEmpty) return argument ?? '';
    return value;
  }
}

/// Translates a localization key using an optional [translator] callback or
/// static [dictionary] (`translate` or `translate:Default Text`).
class TranslatePipe implements PipeTransformer {
  /// Creates a [TranslatePipe].
  const TranslatePipe({
    this.translator,
    this.dictionary = const <String, String>{},
  });

  /// Optional callback delegating to a localization service.
  final CmsTranslationResolver? translator;

  /// Optional static dictionary of key-to-translation entries.
  final Map<String, String> dictionary;

  @override
  String get name => 'translate';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) {
    if (value == null) return argument ?? '';
    final key = value.toString();
    if (key.isEmpty) return argument ?? '';

    final resolved = translator?.call(
      key,
      argument: argument,
      context: context,
    );
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    final dictHit = dictionary[key];
    if (dictHit != null) {
      return dictHit;
    }

    if (argument != null && argument.isNotEmpty) {
      return argument;
    }
    return key;
  }
}

double? _parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value.trim());
  }
  return null;
}

String _formatDecimal(double absValue, {required int decimals}) {
  final fixed = absValue.toStringAsFixed(decimals);
  final dotIndex = fixed.indexOf('.');
  final intPart = dotIndex == -1 ? fixed : fixed.substring(0, dotIndex);
  final decPart = dotIndex == -1 ? '' : fixed.substring(dotIndex);

  if (intPart.length <= 3) {
    return '$intPart$decPart';
  }

  final buffer = StringBuffer();
  final len = intPart.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(intPart[i]);
  }
  buffer.write(decPart);
  return buffer.toString();
}
