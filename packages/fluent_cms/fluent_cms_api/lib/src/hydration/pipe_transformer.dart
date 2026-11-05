import 'package:flutter/widgets.dart';

/// Contract for a pipe transformation applied in `{{expression | pipe:arg}}`.
abstract class PipeTransformer {
  /// Unique name of the pipe (e.g. `'currency'`, `'uppercase'`, `'translate'`).
  String get name;

  /// Transforms [value] using an optional [argument] and [context].
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  });
}
