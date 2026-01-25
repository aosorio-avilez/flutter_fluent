import 'dart:io';

Future<void> main() async {
  print('🛡️ Sentinel: Starting infrastructure scan...');
  bool hasIssues = false;
  final rootDir = Directory.current;

  // Define patterns to avoid self-detection (Quine safety)
  // We split the string literals so that this source code itself doesn't trigger the scanner.
  final unsafePermission = '0' + '777';
  final unsafeMode = 'mode: ' + '777';

  await for (final entity in rootDir.list(recursive: true)) {
    if (entity is! File) continue;
    if (_shouldIgnore(entity.path)) continue;

    // 1. Supply Chain: Check pubspec.yaml for git dependencies
    if (entity.path.endsWith('pubspec.yaml')) {
      if (await _checkPubspec(entity)) hasIssues = true;
    }

    // 2. CI Secrets: Check workflows for secret leaks
    if (entity.path.contains('.github/workflows')) {
      if (await _checkCI(entity)) hasIssues = true;
    }

    // 3. Unsafe Permissions: Check .dart files
    if (entity.path.endsWith('.dart')) {
      if (await _checkDartSource(entity, unsafePermission, unsafeMode)) hasIssues = true;
    }
  }

  if (hasIssues) {
    print('❌ Sentinel: Vulnerabilities found!');
    exit(1);
  } else {
    print('✅ Sentinel: No vulnerabilities found.');
  }
}

bool _shouldIgnore(String path) {
  // Normalize path separators to forward slashes for consistency across platforms
  final normalizedPath = path.replaceAll('\\', '/');
  return normalizedPath.contains('/.git/') ||
      normalizedPath.contains('/.fvm/') ||
      normalizedPath.contains('/build/') ||
      normalizedPath.contains('tool/sentinel_scan.dart'); // Ignore self
}

Future<bool> _checkPubspec(File file) async {
  try {
    final content = await file.readAsString();
    if (content.contains('git:')) {
      print('❌ Supply Chain: Git dependency found in ${file.path}');
      return true;
    }
  } catch (e) {
    print('⚠️ Error reading ${file.path}: $e');
  }
  return false;
}

Future<bool> _checkCI(File file) async {
  try {
    final lines = await file.readAsLines();
    bool issue = false;
    for (final line in lines) {
      // Heuristic: echoing a variable that looks like a secret
      if (line.contains('echo') &&
          line.contains('\$') &&
          (line.toUpperCase().contains('SECRET') ||
              line.toUpperCase().contains('TOKEN') ||
              line.toUpperCase().contains('KEY'))) {
        print('❌ CI: Potential secret leak in ${file.path}: ${line.trim()}');
        issue = true;
      }
    }
    return issue;
  } catch (e) {
    print('⚠️ Error reading ${file.path}: $e');
    return false;
  }
}

Future<bool> _checkDartSource(File file, String unsafePermission, String unsafeMode) async {
  try {
    final content = await file.readAsString();
    if (content.contains(unsafePermission) || content.contains(unsafeMode)) {
      print('❌ Permissions: Unsafe file permissions (0777) in ${file.path}');
      return true;
    }
  } catch (e) {
    print('⚠️ Error reading ${file.path}: $e');
  }
  return false;
}
