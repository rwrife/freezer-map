import 'dart:io';

const _allowedAndroidPermissions = <String>{
  'android.permission.POST_NOTIFICATIONS',
};

const _forbiddenIosUsageKeys = <String>{
  'NSCameraUsageDescription',
  'NSMicrophoneUsageDescription',
  'NSLocationWhenInUseUsageDescription',
  'NSLocationAlwaysAndWhenInUseUsageDescription',
  'NSLocationAlwaysUsageDescription',
  'NSBluetoothAlwaysUsageDescription',
  'NSBluetoothPeripheralUsageDescription',
  'NSContactsUsageDescription',
  'NSHealthShareUsageDescription',
  'NSHealthUpdateUsageDescription',
  'NSPhotoLibraryUsageDescription',
  'NSPhotoLibraryAddUsageDescription',
};

const _forbiddenPackages = <String>{
  'http',
  'dio',
  'firebase_core',
  'firebase_analytics',
  'cloud_firestore',
  'google_mobile_ads',
  'sentry_flutter',
  'amplitude_flutter',
  'mixpanel_flutter',
};

const _forbiddenImportPatterns = <Pattern>[
  'package:http/',
  'package:dio/',
  'HttpClient(',
  'Socket.connect(',
  'RawSocket.connect(',
  'InternetAddress.lookup(',
  'WebSocket.connect(',
];

void main() {
  final failures = <String>[];
  final root = Directory.current;

  _checkAndroidManifest(root, failures);
  _checkIosInfoPlist(root, failures);
  _checkPubspecLock(root, failures);
  _checkLibForNetworkPatterns(root, failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Release readiness checks failed:');
    for (final failure in failures) {
      stderr.writeln('  - $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Release readiness checks passed.');
  stdout.writeln(
    'Verified: restricted Android permissions, no sensitive iOS usage keys, '
    'no forbidden network/telemetry packages, and no network client imports in lib/.',
  );
}

void _checkAndroidManifest(Directory root, List<String> failures) {
  final file = File('${root.path}/android/app/src/main/AndroidManifest.xml');
  if (!file.existsSync()) {
    failures.add('Missing Android manifest: ${file.path}');
    return;
  }

  final content = file.readAsStringSync();
  final matches = RegExp(r'uses-permission\s+android:name="([^"]+)"')
      .allMatches(content)
      .map((match) => match.group(1)!)
      .toSet();

  final unexpected = matches.difference(_allowedAndroidPermissions);
  if (unexpected.isNotEmpty) {
    failures.add('Unexpected Android permissions: ${unexpected.join(', ')}');
  }

  if (!matches.contains('android.permission.POST_NOTIFICATIONS')) {
    failures.add(
      'Expected POST_NOTIFICATIONS permission for optional reminders.',
    );
  }
}

void _checkIosInfoPlist(Directory root, List<String> failures) {
  final file = File('${root.path}/ios/Runner/Info.plist');
  if (!file.existsSync()) {
    failures.add('Missing iOS Info.plist: ${file.path}');
    return;
  }

  final content = file.readAsStringSync();
  for (final key in _forbiddenIosUsageKeys) {
    if (content.contains('<key>$key</key>')) {
      failures.add('Unexpected iOS sensitive permission usage key: $key');
    }
  }
}

void _checkPubspecLock(Directory root, List<String> failures) {
  final file = File('${root.path}/pubspec.lock');
  if (!file.existsSync()) {
    failures.add('Missing pubspec.lock; cannot verify dependency set.');
    return;
  }

  final packageNames = <String>{};
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^  ([a-zA-Z0-9_]+):$').firstMatch(line);
    if (match != null) {
      packageNames.add(match.group(1)!);
    }
  }

  final forbidden = packageNames.intersection(_forbiddenPackages);
  if (forbidden.isNotEmpty) {
    failures.add(
      'Forbidden packages present in lockfile: ${forbidden.join(', ')}',
    );
  }
}

void _checkLibForNetworkPatterns(Directory root, List<String> failures) {
  final lib = Directory('${root.path}/lib');
  if (!lib.existsSync()) {
    failures.add('Missing lib directory: ${lib.path}');
    return;
  }

  final dartFiles = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((entry) => entry.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final source = file.readAsStringSync();
    for (final pattern in _forbiddenImportPatterns) {
      if (source.contains(pattern)) {
        failures.add('Forbidden network pattern "$pattern" in ${file.path}');
      }
    }
  }
}
