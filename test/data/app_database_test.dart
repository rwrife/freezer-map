import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/data/app_database.dart';

void main() {
  test('opens SQLite only inside the injected app-private directory', () async {
    final root = await Directory.systemTemp.createTemp('freezer-map-private-');
    addTearDown(() => root.delete(recursive: true));

    final database = await openAppPrivateDatabase(
      directoryProvider: () async => root,
    );
    await database.customSelect('SELECT 1').getSingle();
    await database.close();

    expect(File('${root.path}/freezer-map.sqlite').existsSync(), isTrue);
  });
}
