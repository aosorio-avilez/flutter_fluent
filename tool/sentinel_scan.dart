import 'dart:io';

Future<void> main() async {
  final root = Directory.current;
  int violations = 0;

  print('🛡️ Sentinel Scan starting...');

  await for (final entity in root.list(recursive: true)) {
    if (entity is! File) continue;

    // Normalize path for consistent checking
    final path = entity.path.replaceAll('\\', '/');

    // Ignore known directories and files
    if (path.contains('/.git/') ||
        path.contains('/.fvm/') ||
        path.contains('/.dart_tool/') ||
        path.contains('/build/') ||
        path.contains('/.pub-cache/') ||
        path.contains('tool/sentinel_scan.dart')) {
      continue;
    }

    // Ignore binary files and others
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.gif') ||
        path.endsWith('.ico') ||
        path.endsWith('.lock') ||
        path.endsWith('.pack') ||
        path.endsWith('.idx')) {
      continue;
    }

    String content;
    try {
      content = await entity.readAsString();
    } catch (e) {
      // Skip files we can't read as string (binary, etc.)
      continue;
    }

    if (content.isEmpty) continue;

    // Check 1: Unsafe File Permissions (0777)
    // Split the string to avoid self-detection
    final unsafePerm = '0' + '777';
    if (content.contains(unsafePerm)) {
      print('❌ VIOLATION: Unsafe file permissions ($unsafePerm) found in $path');
      violations++;
    }

    final chmodUnsafe = 'chmod ' + '777';
    if (content.contains(chmodUnsafe)) {
      print('❌ VIOLATION: Unsafe chmod permissions ($chmodUnsafe) found in $path');
      violations++;
    }

    // Check 2: Supply Chain (git dependencies in pubspec.yaml)
    if (path.endsWith('pubspec.yaml')) {
      if (content.contains('git:')) {
         print('❌ VIOLATION: Git dependency found in $path');
         violations++;
      }
    }

    // Check 3: Insecure Downloads (http://, curl, wget)
    // Split strings
    final httpProto = 'http:' + '//';
    if (content.contains(httpProto)) {
      // Create a temporary content string with whitelisted URLs removed
      String checkContent = content;
      final whitelist = [
        httpProto + 'localhost',
        httpProto + '127.0.0.1',
        httpProto + 'schemas.android.com',
        httpProto + 'www.apple.com/DTDs/PropertyList-1.0.dtd',
        httpProto + 'path.com',
      ];

      for (final url in whitelist) {
        checkContent = checkContent.replaceAll(url, '');
      }

      if (checkContent.contains(httpProto)) {
         print('❌ VIOLATION: Insecure URL ($httpProto) found in $path');
         violations++;
      }
    }

    if (content.contains('curl ') || content.contains('wget ')) {
       print('⚠️ WARNING: curl/wget usage found in $path. Verify integrity!');
    }
  }

  if (violations > 0) {
    print('💀 Sentinel Scan failed with $violations violations.');
    exit(1);
  } else {
    print('✅ Sentinel Scan passed.');
    exit(0);
  }
}
