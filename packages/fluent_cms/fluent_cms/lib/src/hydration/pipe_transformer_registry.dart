import 'package:fluent_cms/src/hydration/built_in_pipes.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/widgets.dart';

/// Registry for built-in and custom [PipeTransformer] instances (`O(1)`
/// lookup).
class PipeTransformerRegistry {
  /// Creates a [PipeTransformerRegistry] pre-populated with built-in pipes.
  PipeTransformerRegistry({
    LoggerApi? logger,
    CmsTranslationResolver? translationResolver,
    Map<String, String> translationDictionary = const <String, String>{},
    Iterable<PipeTransformer> initialPipes = const <PipeTransformer>[],
  }) : _logger = logger {
    register(const CurrencyPipe());
    register(const NumberPipe());
    register(const DatePipe());
    register(const UppercasePipe());
    register(const LowercasePipe());
    register(const DefaultPipe());
    register(
      TranslatePipe(
        translator: translationResolver,
        dictionary: translationDictionary,
      ),
    );

    for (final pipe in initialPipes) {
      _pipes[pipe.name.trim()] = pipe;
    }
  }

  final LoggerApi? _logger;
  final Map<String, PipeTransformer> _pipes = <String, PipeTransformer>{};

  /// Registers or overrides a [PipeTransformer] by its `name`.
  void register(PipeTransformer pipe) {
    _pipes[pipe.name.trim()] = pipe;
  }

  /// Returns the [PipeTransformer] registered for [name], or `null` if absent.
  PipeTransformer? getPipe(String name) => _pipes[name.trim()];

  /// Returns an unmodifiable snapshot of all registered pipes.
  List<PipeTransformer> get registeredPipes =>
      List<PipeTransformer>.unmodifiable(_pipes.values);

  /// Applies a single pipe segment (e.g. `"currency:MXN"` or `"uppercase"`) to
  /// [value] without closure allocations.
  Object? applyPipeSegment(
    String rawSegment,
    Object? value, {
    BuildContext? context,
  }) {
    final trimmed = rawSegment.trim();
    if (trimmed.isEmpty) return value;

    final colonIndex = trimmed.indexOf(':');
    final String pipeName;
    final String? argument;

    if (colonIndex == -1) {
      pipeName = trimmed;
      argument = null;
    } else {
      pipeName = trimmed.substring(0, colonIndex).trim();
      final rawArg = trimmed.substring(colonIndex + 1).trim();
      argument = _stripQuotes(rawArg);
    }

    final pipe = _pipes[pipeName];
    if (pipe == null) {
      _logger?.logWarning(
        '[fluent_cms] Unknown pipe transformer "$pipeName" in "$rawSegment".',
      );
      return value;
    }

    return pipe.transform(
      value,
      argument: argument,
      context: context,
    );
  }

  String _stripQuotes(String input) {
    if (input.length >= 2) {
      final first = input[0];
      final last = input[input.length - 1];
      if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
        return input.substring(1, input.length - 1);
      }
    }
    return input;
  }
}
