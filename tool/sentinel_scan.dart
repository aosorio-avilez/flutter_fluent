import 'dart:io';

void main() async {
  print('🛡️ Sentinel: Starting Infrastructure Scan...');

  final rootDir = Directory.current;
  final issues = <String>[];

  await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      final path = entity.path.replaceAll('\\', '/');

      // Skip hidden files/dirs and build artifacts
      if (path.contains('/.') || path.contains('/build/') || path.contains('/.fvm/')) {
        continue;
      }

      // 1. Secret Leaks in CI
      if (path.contains('.github/workflows')) {
        await _checkSecrets(entity, issues);
      }

      // 2. Code Generation Injection & Unsafe Permissions
      // Skip the sentinel script itself to avoid self-flagging
      if (path.endsWith('.dart') && !path.endsWith('tool/sentinel_scan.dart')) {
        await _checkDartSafety(entity, issues);
      }

      // 3. Supply Chain
      if (path.endsWith('pubspec.yaml')) {
        await _checkPubspec(entity, issues);
      }
    }
  }

  if (issues.isEmpty) {
    print('✅ Sentinel: No vulnerabilities found. Systems secure.');
    exit(0);
  } else {
    print('🚨 Sentinel: Found ${issues.length} potential vulnerabilities!');
    for (final issue in issues) {
      print('  - $issue');
    }
    exit(1);
  }
}

Future<void> _checkSecrets(File file, List<String> issues) async {
  final content = await file.readAsString();
  final lines = content.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // Flag echoing of potential secrets
    if (line.contains('echo') && (line.contains('\$') && (line.toUpperCase().contains('TOKEN') || line.toUpperCase().contains('SECRET') || line.toUpperCase().contains('KEY') || line.toUpperCase().contains('PASSWORD')))) {
       issues.add('Possible secret leak in ${file.path}:${i + 1}: "$line"');
    }
  }
}

Future<void> _checkDartSafety(File file, List<String> issues) async {
  final content = await file.readAsString();
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Check for 0777
    if (line.contains('0777')) {
      issues.add('Unsafe file permission (0777) in ${file.path}:${i + 1}');
    }

    // Check for unsafe code generation patterns
    // Heuristic: writeln with interpolation but no obvious escaping
    if (line.contains('.writeln(') && line.contains('\$')) {
       // Only flag if it looks like we are generating code (e.g., writing "final " or "class ")
       if (line.contains('final ') || line.contains('class ') || line.contains('void ')) {
          if (!line.contains('escapeDartString')) {
             issues.add('Potential Unsafe Code Gen in ${file.path}:${i + 1}. Ensure user input is escaped: "$line"');
          }
       }
    }
  }
}

Future<void> _checkPubspec(File file, List<String> issues) async {
  final content = await file.readAsString();
  if (content.contains('git:')) {
    issues.add('Git dependency found in ${file.path}. Prefer hosted packages for supply chain security.');
  }
}
