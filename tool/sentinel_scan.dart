import 'dart:io';

void main() {
  final root = Directory.current;
  int exitCode = 0;

  print('🛡️ Sentinel: Starting infrastructure scan...');

  // Config - Split strings to avoid self-detection (Quine safety)
  final unsafePermissions = '0' '777';
  final insecureHttp = 'http:' '//';
  final gitDependency = 'git:';

  // Whitelist
  final ignoredPaths = [
    '.git/',
    '.dart_tool/',
    'build/',
    '.fvm/',
  ];

  final httpWhitelist = [
    'schemas.android.com',
    'www.apple.com/DTDs',
    'localhost',
    '127.0.0.1',
    'maven.google.com',
  ];

  // Counters
  int issuesFound = 0;

  // Helper to check ignores
  bool isIgnored(String path) {
    // Normalize path separators
    final normalized = path.replaceAll('\\', '/');
    for (final ignored in ignoredPaths) {
      if (normalized.contains(ignored)) return true;
    }
    return false;
  }

  // Scan
  try {
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File) continue;

      final path = entity.path;
      if (isIgnored(path)) continue;

      final filename = path.split(Platform.pathSeparator).last;

      // Skip binary files and known non-source files
      if (filename.endsWith('.png') ||
          filename.endsWith('.jpg') ||
          filename.endsWith('.lock') ||
          filename.endsWith('.webp') ||
          filename.endsWith('.ico')) {
        continue;
      }

      String content;
      try {
        content = entity.readAsStringSync();
      } catch (e) {
        // Likely binary or encoding issue, skip
        continue;
      }

      final lines = content.split('\n');

      // 1. Supply Chain: pubspec.yaml git dependencies
      if (filename == 'pubspec.yaml') {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith(gitDependency) || line.startsWith('$gitDependency ')) {
             print('🚨 [CRITICAL] Git dependency found in $path:${i+1}');
             print('   Line: ${lines[i].trim()}');
             issuesFound++;
             exitCode = 1;
          }
        }
      }

      // 2. Unsafe Permissions (0-777)
      if (filename.endsWith('.dart')) {
         if (content.contains(unsafePermissions)) {
           print('🚨 [CRITICAL] Unsafe file permissions found in $path');
           issuesFound++;
           exitCode = 1;
         }
      }

      // 3. Insecure Downloads (http)
      // Skip tests as they often use dummy URLs
      if (content.contains(insecureHttp) && !path.contains('/test/')) {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains(insecureHttp)) {
            // Check whitelist
            bool safe = false;
            for (final safeUrl in httpWhitelist) {
              if (line.contains('$insecureHttp$safeUrl')) {
                safe = true;
                break;
              }
            }
            if (!safe) {
               print('⚠️ [HIGH] Insecure HTTP link found in $path:${i+1}');
               print('   Line: ${line.trim()}');
               issuesFound++;
               exitCode = 1;
            }
          }
        }
      }

      // 4. Secret Leaks in CI
      if (path.contains('.github/') || filename.endsWith('.sh')) {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Check for echoing secrets
          if (line.contains('echo') &&
             (line.contains('secrets.') || line.contains(r'${{ secrets') || line.contains(r'$SECRET'))) {
             print('🚨 [CRITICAL] Potential secret leak in CI found in $path:${i+1}');
             print('   Line: ${line.trim()}');
             issuesFound++;
             exitCode = 1;
          }
        }
      }

      // 5. Code Injection (Builders)
      // Heuristic: Look for string interpolation in buffer writes without escaping
      // Skip tests
      if (filename.endsWith('.dart') &&
          !path.contains('/test/') &&
          (content.contains('.writeln(') || content.contains('.write('))) {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if ((line.contains('.writeln(') || line.contains('.write(')) &&
              line.contains(r'$') &&
              !line.contains('escapeDartString')) {
              // Exclude comments
              if (line.trim().startsWith('//')) continue;

              print('⚠️ [WARNING] Potential unescaped code generation found in $path:${i+1}');
              print('   Line: ${line.trim()}');
              print('   Tip: Use escapeDartString() for user input.');
              issuesFound++;
          }
        }
      }
    }
  } catch (e, s) {
    print('❌ Error during scan: $e');
    print(s);
    exit(1);
  }

  if (issuesFound == 0) {
    print('✅ Scan complete. No vulnerabilities found.');
  } else {
    print('❌ Scan complete. $issuesFound issues found.');
    exit(exitCode);
  }
}
