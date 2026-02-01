import 'dart:io';

void main() {
  final root = Directory.current;
  final issues = <String>[];
  // Split strings to avoid self-detection
  final httpPrefix = 'http:' + '//';
  final chmod777 = 'chmod ' + '777';
  final chmod0777 = 'chmod ' + '0777';

  print('🛡️  Sentinel is scanning...');

  try {
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File) {
        final path = entity.path.replaceAll('\\', '/');
        if (_shouldIgnore(path)) continue;

        try {
            _scanFile(entity, path, issues, httpPrefix, chmod777, chmod0777);
        } catch (e) {
            // Ignore read errors (e.g. binary files)
        }
      }
    }
  } catch (e) {
    print('Error during scan: $e');
    exit(1);
  }

  if (issues.isNotEmpty) {
    print('🚨 Found ${issues.length} issues:');
    for (final issue in issues) {
      print(issue);
    }
    exit(1);
  } else {
    print('✅ Scan complete. No threats found.');
  }
}

bool _shouldIgnore(String path) {
  return path.contains('/.git/') ||
      path.contains('/.fvm/') ||
      path.contains('/build/') ||
      path.contains('/.dart_tool/') ||
      path.endsWith('sentinel_scan.dart');
}

void _scanFile(File file, String path, List<String> issues, String httpPrefix, String chmod777, String chmod0777) {
  // Read as bytes first to avoid decoding errors on binary files, or just try-catch string read
  String content;
  try {
    content = file.readAsStringSync();
  } catch (e) {
    return; // Skip binary files
  }

  final lowerContent = content.toLowerCase();

  // 1. Insecure Downloads (HTTP)
  if (!path.contains('/test/') && content.contains(httpPrefix)) {
    final lines = content.split('\n');
    for (var line in lines) {
      if (line.contains(httpPrefix)) {
        bool isSafe = line.contains(httpPrefix + 'localhost') ||
            line.contains(httpPrefix + '127.0.0.1') ||
            line.contains(httpPrefix + 'schemas.android.com') ||
            line.contains(httpPrefix + 'www.apple.com');
        if (!isSafe) {
          issues.add('Insecure Download (HTTP) in $path: ${line.trim()}');
        }
      }
    }
  }

  // 2. Unverified Git Dependencies
  if (path.endsWith('pubspec.yaml')) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('git:') || trimmed.startsWith('git: ')) {
         issues.add('Unverified Git Dependency in $path');
      }
    }
  }

  // 3. Secret Leaks
  if (path.endsWith('.sh') || path.endsWith('.yml') || path.endsWith('.yaml')) {
    // Check for echo of secrets
    if (lowerContent.contains('echo')) {
        final lines = content.split('\n');
        for (var line in lines) {
            final lowerLine = line.toLowerCase();
            if (lowerLine.contains('echo') &&
               (line.contains('secrets.') || line.contains('\${{ secrets') || line.contains('\$SECRET'))) {
                if (!line.contains('::add-mask::')) {
                    issues.add('Potential Secret Leak (echo secrets) in $path');
                }
            }
        }
    }
  }

  // 4. Code Injection
  if (path.endsWith('.dart') && !path.contains('/test/')) {
     final lines = content.split('\n');
     for (var i = 0; i < lines.length; i++) {
       final line = lines[i];
       if ((line.contains('.write(') || line.contains('.writeln(')) && line.contains('\$')) {
           if (!line.contains('escapeDartString')) {
               issues.add('Potential Code Injection in $path:${i + 1}');
           }
       }
     }
  }

  // 5. Unsafe Permissions (chmod 777)
  if (content.contains(chmod777) || content.contains(chmod0777)) {
      issues.add('Unsafe Permissions (chmod 777) in $path');
  }
}
