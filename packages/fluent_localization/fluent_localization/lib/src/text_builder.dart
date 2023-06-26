import 'dart:convert';

import 'package:build/build.dart';

/// A builder that generates Dart constants for strings defined in a json file.
///
/// Unlike most other builders, which emit files next to their primary inputs,
/// this builder generates files in a different directory! Inputs are expected
/// in `assets` and generated files go to `lib/generated/`.
class TextBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        // To implement directory moves, this builder uses capture groups
        // ({{}}). Capture groups can match anything in the input's path,
        // including subdirectories. The `^assets` at the beginning ensures that
        // only jsons under the top-level `assets/` folder will be considered.
        '^assets/languages/{{}}.json': ['lib/generated/{{}}.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final outputId = AssetId(
      inputId.package,
      inputId.path
          .replaceFirst('assets/languages', 'lib/generated/')
          .replaceFirst('.json', '.dart'),
    );

    final messages = (json.decode(await buildStep.readAsString(inputId)) as Map)
        .cast<String, String>();

    final outputBuffer = StringBuffer('// Generated, do not edit\n');
    messages.forEach((key, value) {
      outputBuffer.writeln("const String $key = '$value';");
    });

    await buildStep.writeAsString(outputId, outputBuffer.toString());
  }
}
