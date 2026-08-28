import 'dart:io';

const _allowedImports = <String, Set<String>>{
  'domain': {'domain'},
  'application': {'application', 'domain'},
  'data': {'application', 'data', 'domain'},
  'presentation': {'application', 'domain', 'presentation'},
  'platform': {'application', 'domain', 'platform'},
};

final _packageImport = RegExp(
  r'''^\s*import\s+['"]package:freezer_map/([^/'"]+)''',
);

List<String> checkArchitecture(Directory repositoryRoot) {
  final libDirectory = Directory('${repositoryRoot.path}/lib');
  final violations = <String>[];

  if (!libDirectory.existsSync()) {
    return ['Missing lib directory at ${libDirectory.path}'];
  }

  final dartFiles =
      libDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final file in dartFiles) {
    final relativePath = file.path.substring(libDirectory.path.length + 1);
    final sourceLayer = relativePath.split(Platform.pathSeparator).first;
    final allowed = _allowedImports[sourceLayer];

    if (allowed == null) {
      continue;
    }

    for (final line in file.readAsLinesSync()) {
      final match = _packageImport.firstMatch(line);
      if (match == null) {
        continue;
      }

      final importedLayer = match.group(1)!;
      if (!allowed.contains(importedLayer)) {
        violations.add(
          '$relativePath ($sourceLayer) must not import $importedLayer: '
          '${line.trim()}',
        );
      }
    }
  }

  return violations;
}

void main() {
  final violations = checkArchitecture(Directory.current);
  if (violations.isNotEmpty) {
    stderr.writeln('Architecture boundary violations:');
    for (final violation in violations) {
      stderr.writeln('  - $violation');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Architecture boundaries: OK');
}
