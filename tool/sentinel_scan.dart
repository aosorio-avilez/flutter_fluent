import 'dart:io';

Future<void> main() async {
  print('🛡️ Sentinel Security Scan Initiated...');

  final rootDir = Directory.current;
  int vulnerabilityCount = 0;

  final entities = rootDir.list(recursive: true, followLinks: false);
  await for (final entity in entities) {
    if (entity is! File) continue;

    final path = entity.path;
    // Normalized path for checks
    final normalizedPath = path.replaceAll('\\', '/');

    // Skip hidden files/dirs (except .github) and build artifacts
    if (normalizedPath.contains('/.git/') ||
        normalizedPath.contains('/.fvm/') ||
        normalizedPath.contains('/build/') ||
        normalizedPath.contains('/.dart_tool/')) {
      continue;
    }

    final relativePath = path.startsWith(rootDir.path)
        ? path.substring(rootDir.path.length + 1)
        : path;

    final filename = Uri.file(path).pathSegments.last;

    try {
      final content = await entity.readAsString();

      // 1. Check for unsafe permissions (0777) in Dart code
      if (filename.endsWith('.dart')) {
        // Split strings to avoid self-detection
        if (content.contains('chmod ' + '777') ||
            content.contains('mode: ' + '0777') ||
            content.contains('mode: ' + '511')) {

           // Self-detection check: ensure we don't flag the scanner itself
           if (!relativePath.endsWith('sentinel_scan.dart')) {
              print('❌ [CRITICAL] Unsafe file permissions detected in $relativePath');
              vulnerabilityCount++;
           }
        }
      }

      // 2. Check for git dependencies in pubspec.yaml
      if (filename == 'pubspec.yaml') {
        if (content.contains('git:')) {
           print('❌ [CRITICAL] Git dependency detected in $relativePath');
           vulnerabilityCount++;
        }
      }

      // 3. Check for CI secret leaks
      if (normalizedPath.contains('.github/') || filename.endsWith('.sh')) {
         final lines = content.split('\n');
         for (var i = 0; i < lines.length; i++) {
           final line = lines[i];
           if (line.trim().startsWith('echo') && (line.contains('\$'))) {
               // naive check for secret keywords
               final upperLine = line.toUpperCase();
               if (upperLine.contains('SECRET') ||
                   upperLine.contains('TOKEN') ||
                   upperLine.contains('KEY') ||
                   upperLine.contains('PASSWORD')) {
                  print('❌ [CRITICAL] Potential secret leak in $relativePath:${i+1}');
                  vulnerabilityCount++;
               }
           }
         }
      }

      // 4. Check for insecure downloads (http:)
      if (content.contains('http:' + '//')) {
          if (content.contains('curl ') || content.contains('wget ') || content.contains("Uri.parse('http:' + '//")) {
             print('⚠️ [HIGH] Insecure HTTP download detected in $relativePath');
             vulnerabilityCount++;
          }
      }

    } catch (e) {
      // Ignore read errors (e.g. binary files)
    }
  }

  if (vulnerabilityCount > 0) {
    print('\n🛑 Scan failed! Found $vulnerabilityCount vulnerabilities.');
    exit(1);
  } else {
    print('\n✅ Scan passed. No vulnerabilities found.');
  }
}
