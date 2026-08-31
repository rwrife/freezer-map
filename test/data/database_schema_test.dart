import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/migrations.dart';

void main() {
  late FreezerDatabase database;

  setUp(() => database = FreezerDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'migration contract enumerates every committed schema version',
    () async {
      expect(
        committedSchemaVersions,
        List<int>.generate(database.schemaVersion, (index) => index + 1),
      );

      await database.customSelect('SELECT 1').getSingle();
      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), database.schemaVersion);
    },
  );

  test(
    'schema v1 creates all tables, foreign keys, and useful indexes',
    () async {
      expect(database.schemaVersion, 1);
      final tables = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll(<String>[
          'appliances',
          'zones',
          'freezer_items',
          'inventory_events',
          'reminders',
        ]),
      );

      final foreignKeys = await database
          .customSelect('PRAGMA foreign_key_list(freezer_items)')
          .get();
      expect(foreignKeys.single.read<String>('table'), 'zones');

      final indexes = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      expect(
        indexes.map((row) => row.read<String>('name')),
        containsAll(<String>[
          'zones_appliance_parent_idx',
          'freezer_items_zone_archived_idx',
          'inventory_events_item_time_idx',
          'reminders_item_enabled_idx',
        ]),
      );
    },
  );
}
