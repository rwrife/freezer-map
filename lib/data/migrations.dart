import 'package:drift/drift.dart';
import 'package:freezer_map/data/database.dart';

const int currentSchemaVersion = 1;
const List<int> committedSchemaVersions = [1];

MigrationStrategy freezerMigration(FreezerDatabase database) =>
    MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 1) {
          await migrator.createAll();
        }
      },
      beforeOpen: (details) async {
        await database.customStatement('PRAGMA foreign_keys = ON');
      },
    );
