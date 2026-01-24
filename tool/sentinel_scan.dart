import 'dart:io';

void main() async {
  print('🛡️ Sentinel Scan Started...');
  bool hasErrors = false;

  // 1. Scan for secrets in .github
  print('\n🔍 Scanning for secrets in .github...');
  final githubDir = Directory('.github');
  if (githubDir.existsSync()) {
    await for (final entity in githubDir.list(recursive: true)) {
      if (entity is File) {
        try {
          final content = await entity.readAsString();
          // Heuristic: echoing a variable that looks like a secret
          if (content.contains('echo "\$') || content.contains('echo \$')) {
             if (content.contains('SECRET') || content.contains('TOKEN') || content.contains('KEY') || content.contains('PASSWORD')) {
                print('❌ CRITICAL: Potential secret leak in ${entity.path}');
                hasErrors = true;
             }
          }
        } catch (e) {
          // Ignore read errors
        }
      }
    }
  }

  // 2. Scan for git dependencies
  print('\n🔍 Scanning for git dependencies in pubspec.yaml...');
  final root = Directory('.');
  // Using `find` logic recursively is hard with standard dart:io without walking.
  // We'll walk the directory.

  await for (final entity in root.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('pubspec.yaml')) {
      try {
        final content = await entity.readAsString();
        if (content.contains('git:')) {
           // Exclude self if checking against "git:" as a string literal in this script, but this script is .dart
           print('❌ CRITICAL: Git dependency found in ${entity.path}');
           hasErrors = true;
        }
      } catch (e) {
          print('⚠️ Error reading ${entity.path}: $e');
      }
    }
  }

  // 3. Scan for chmod 777
  print('\n🔍 Scanning for unsafe permissions (chmod 777)...');
   await for (final entity in root.list(recursive: true)) {
    if (entity is File) {
       if (entity.path.contains('.git/') || entity.path.contains('.fvm/') || entity.path.contains('build/')) continue;

       if (entity.path.endsWith('.png') || entity.path.endsWith('.jpg') || entity.path.endsWith('.gif') || entity.path.endsWith('.ico') || entity.path.endsWith('.webp')) continue;

       try {
         final content = await entity.readAsString();
         if (entity.path.endsWith('sentinel_scan.dart')) continue;

         // Break the string to avoid self-detection
         const chmod777 = 'chmod ' + '777';
         if (content.contains(chmod777) || content.contains('chmod -R 777')) {
            print('❌ CRITICAL: Unsafe permission change ($chmod777) found in ${entity.path}');
            hasErrors = true;
         }
       } catch (e) {
         // Ignore read errors (binary files etc)
       }
    }
  }

  if (hasErrors) {
    print('\n❌ Sentinel Scan Failed! Vulnerabilities found.');
    exit(1);
  } else {
    print('\n✅ Sentinel Scan Passed. No critical vulnerabilities found.');
  }
}
