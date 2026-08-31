import 'dart:io';

import 'package:drift/native.dart';
import 'package:freezer_map/data/database.dart';
import 'package:path/path.dart' as paths;
import 'package:path_provider/path_provider.dart';

typedef AppPrivateDirectoryProvider = Future<Directory> Function();

Future<FreezerDatabase> openAppPrivateDatabase({
  AppPrivateDirectoryProvider? directoryProvider,
}) async {
  final provider = directoryProvider ?? getApplicationSupportDirectory;
  final directory = await provider();
  await directory.create(recursive: true);
  final databaseFile = File(paths.join(directory.path, 'freezer-map.sqlite'));
  return FreezerDatabase(NativeDatabase.createInBackground(databaseFile));
}
