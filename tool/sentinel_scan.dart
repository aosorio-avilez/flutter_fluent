import 'dart:io';

/// Sentinel Security Scan
///
/// Scans the codebase for:
/// 1. Unsafe file permissions (0777)
/// 2. Code injection patterns (writeln with interpolation)
/// 3. Supply chain risks (git dependencies)
/// 4. CI secret leaks
void main() {
  print('🛡️ Sentinel Security Scan Initiated...');

  final rootDir = Directory.current;
  int issuesFound = 0;

  // 1. Scan pubspec.yaml for git dependencies
  print('🔍 Scanning for Supply Chain risks...');
  final pubspecs = rootDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('pubspec.yaml'));

  for (final file in pubspecs) {
    if (file.path.contains('.fvm')) continue;
    final lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().startsWith('#')) continue;

      if (line.contains('git:') && !line.contains('sdk: flutter')) {
        print('⚠️ [Supply Chain] Git dependency found in ${file.path}:${i + 1}');
      }
      if ((line.contains('http://') || line.contains('https://')) && line.contains('hosted:')) {
         // Check for non-pub hosted dependencies if needed.
      }
    }
  }

  // 2. Scan .dart files
  print('🔍 Scanning .dart files for code/file safety...');
  final dartFiles = rootDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    if (file.path.contains('.fvm')) continue;
    if (file.path.contains('.dart_tool')) continue;

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check 2.1: File Permissions
      if (line.contains('.create(') && line.contains('mode:') && line.contains('0777')) {
        print('❌ [Unsafe Permissions] World-readable file creation at ${file.path}:${i + 1}');
        print('   Line: ${line.trim()}');
        issuesFound++;
      }

      // Check 2.2: Code Injection
      // Looking for writeln("...$var...") which suggests writing code without escaping.
      // This is a heuristic.
      if ((line.contains('.writeln(') || line.contains('.write(')) &&
          line.contains('\$') &&
          !line.contains('escapeDartString')) {

        // Exclude test files or logger which might just print stuff
        if (!file.path.contains('test/') && !file.path.contains('logger')) {
           // We only care if it looks like generating code.
           // E.g. "final x = $y;"
           if (line.contains('final ') || line.contains('const ') || line.contains('var ')) {
              print('⚠️ [Code Injection Risk] Potential unescaped code generation at ${file.path}:${i + 1}');
              print('   Line: ${line.trim()}');
              issuesFound++;
           }
        }
      }
    }
  }

  // 3. Scan CI workflows
  print('🔍 Scanning CI workflows for secret leaks...');
  final ciDir = Directory('.github/workflows');
  if (ciDir.existsSync()) {
    final ciFiles = ciDir.listSync(recursive: true).whereType<File>();
    for (final file in ciFiles) {
       final lines = file.readAsLinesSync();
       for (int i = 0; i < lines.length; i++) {
         final line = lines[i];
         if (line.contains('echo') && line.contains('secrets.')) {
           print('❌ [CI Secret Leak] Potential secret echo in ${file.path}:${i + 1}');
           issuesFound++;
         }
       }
    }
  }

  if (issuesFound > 0) {
    print('❌ Sentinel Scan failed: $issuesFound issues found.');
    exit(1);
  } else {
    print('✅ Sentinel Scan Passed. Infrastructure is secure.');
    exit(0);
  }
}
