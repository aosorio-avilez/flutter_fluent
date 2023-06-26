import 'package:build/build.dart';

/// Copy contents of a `txt` files into `name.txt.copy`.
///
/// A header row is added pointing to the input file name.
class CopyBuilder implements Builder {
  @override
  Future<dynamic> build(BuildStep buildStep) async {
    // Each [buildStep] has a single input.
    final inputId = buildStep.inputId;

    // Create a new target [AssetId] based on the old one.
    final contents = await buildStep.readAsString(inputId);

    final copy = inputId.addExtension('.copy');

    // Write out the new asset.
    await buildStep.writeAsString(copy, '// Copied from $inputId\n$contents');
  }

  @override
  final buildExtensions = const {
    '.txt': ['.txt.copy']
  };
}
