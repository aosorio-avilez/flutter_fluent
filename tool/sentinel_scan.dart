import 'dart:io';

Future<void> main() async {
  final rootDir = Directory.current;
  final issues = <String>[];

  // Whitelist for HTTP
  final httpWhitelist = [
    'http://schemas.android.com',
    'http://www.apple.com',
    'http://localhost',
    'http://www.w3.org',
    'http://maven.apache.org',
    'http://www.apple.com/DTDs/PropertyList-1.0.dtd',
  ];

  // Whitelist for file permissions (if any)

  // Sensitive strings split to avoid self-detection
  final chmod777 = 'chmod ' + '777';
  final mode0777 = 'mode: ' + '0777';
  final plain0777 = '0' + '777';
  final httpProto = 'http:' + '//';
  final gitDep = 'git' + ':';

  print('🔍 Sentinel scanning ${rootDir.path}...');

  await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      final path = entity.path.replaceAll('\\', '/');

      // Exclusions
      if (path.contains('/.git/') ||
          path.contains('/.dart_tool/') ||
          path.contains('/build/') ||
          path.endsWith('tool/sentinel_scan.dart')) {
        continue;
      }

      // Check 1: Supply Chain (pubspec.yaml)
      if (path.endsWith('pubspec.yaml')) {
        try {
          final content = await entity.readAsString();
          if (content.contains(gitDep)) {
             // Check if it is commented out? Simple check for now.
             // A better check would be line by line.
             final lines = content.split('\n');
             for (final line in lines) {
               final trimmed = line.trim();
               if (trimmed.startsWith('#')) continue;
               if (trimmed == gitDep || trimmed.startsWith('$gitDep ')) {
                 issues.add('Unverified git dependency found in $path');
                 break;
               }
             }
          }
        } catch (e) {
          // ignore
        }
      }

      // Check 2: Unsafe File Permissions & Insecure Downloads
      // Skip binary files by extension
      if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.ico') || path.endsWith('.webp')) continue;

      try {
        final content = await entity.readAsString();

        // 0777 check
        if (content.contains(chmod777) || content.contains(mode0777)) {
           issues.add('Unsafe permissions ($plain0777) found in $path');
        }

        // HTTP check
        if (content.contains(httpProto)) {
           var tempContent = content;
           for (final allowed in httpWhitelist) {
             tempContent = tempContent.replaceAll(allowed, '');
           }
           if (tempContent.contains(httpProto)) {
             issues.add('Insecure download/link ($httpProto) found in $path');
           }
        }

        // Check 3: CI Secret Leaks (basic heuristic)
        if (path.contains('.github/workflows')) {
           if (content.contains('echo \$') || content.contains('echo "\$')) {
              // This is very broad. Let's look for suspicious variable names.
              final suspicious = ['SECRET', 'TOKEN', 'KEY', 'PASSWORD', 'AUTH'];
              for (final word in suspicious) {
                  if (content.contains(word) && (content.contains('echo') || content.contains('print'))) {
                       // Refine: echo "$SECRET"
                       if (content.contains('\$$word')) {
                           issues.add('Potential secret leak (printing \$$word) in $path');
                       }
                  }
              }
           }
        }

      } catch (e) {
        // Likely binary or decoding error
      }
    }
  }

  if (issues.isNotEmpty) {
    print('❌ Sentinel found vulnerabilities:');
    for (final issue in issues) {
      print(' - $issue');
    }
    exit(1);
  } else {
    print('✅ Sentinel Scan Passed: No vulnerabilities found.');
  }
}
