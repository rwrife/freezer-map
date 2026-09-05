import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/data_management.dart';
import 'package:freezer_map/data/data_portability.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FreezerDatabase database;
  late DriftInventoryRepository repository;
  late DataPortabilityService portability;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
    portability = DataPortabilityService(database);
  });

  tearDown(() => database.close());

  test('version 1 JSON round trips every record and stable ID', () async {
    await _seed(repository);
    final backup = await portability.createJsonBackup(
      exportedAt: DateTime.utc(2026, 9, 4, 12),
    );
    final root = jsonDecode(backup) as Map<String, Object?>;

    expect(root['format'], 'freezer-map-backup');
    expect(root['version'], 1);
    expect(root['schema'], {'application': 'freezer-map', 'database': 1});

    final restoredDatabase = FreezerDatabase.forTesting(
      NativeDatabase.memory(),
    );
    addTearDown(restoredDatabase.close);
    final restored = DataPortabilityService(restoredDatabase);
    final dryRun = await restored.prepareRestore(
      backup,
      mode: RestoreMode.replace,
    );
    expect(
      dryRun.summary.description,
      '1 appliances, 2 zones, 1 items, 1 events, and 1 reminders',
    );

    await restored.applyRestore(dryRun);
    final secondBackup = await restored.createJsonBackup(
      exportedAt: DateTime.utc(2026, 9, 5),
    );
    final firstData = root['data'];
    final secondData =
        (jsonDecode(secondBackup) as Map<String, Object?>)['data'];
    expect(secondData, firstData);
  });

  test('representative version 1 fixture remains readable', () async {
    final source = await File('test/fixtures/backup_v1.json').readAsString();
    final prepared = await portability.prepareRestore(
      source,
      mode: RestoreMode.replace,
    );

    expect(
      prepared.summary.description,
      '1 appliances, 1 zones, 1 items, 0 events, and 0 reminders',
    );
  });

  test('merge adds new records and rejects stable-ID collisions', () async {
    await _seed(repository);
    final backup = await portability.createJsonBackup(
      exportedAt: DateTime.utc(2026, 9, 4),
    );
    final target = FreezerDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    final service = DataPortabilityService(target);

    final prepared = await service.prepareRestore(
      backup,
      mode: RestoreMode.merge,
    );
    await service.applyRestore(prepared);
    await expectLater(
      service.prepareRestore(backup, mode: RestoreMode.merge),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.message,
          'message',
          contains('appliance:appliance-1'),
        ),
      ),
    );
  });

  test(
    'rejects malformed input and unsupported versions before writes',
    () async {
      await expectLater(
        portability.prepareRestore('{bad json', mode: RestoreMode.replace),
        throwsA(isA<BackupValidationException>()),
      );
      final unsupported = _emptyBackup()..['version'] = 99;
      await expectLater(
        portability.prepareRestore(
          jsonEncode(unsupported),
          mode: RestoreMode.replace,
        ),
        throwsA(
          isA<BackupValidationException>().having(
            (error) => error.message,
            'message',
            'Unsupported backup version 99; this app supports version 1.',
          ),
        ),
      );
      expect(await database.appliances.count().getSingle(), 0);
    },
  );

  test(
    'rejects dangling references, zone cycles, and invalid quantities',
    () async {
      final dangling = _emptyBackup();
      final danglingData = dangling['data']! as Map<String, Object?>;
      danglingData['zones'] = [_zone(id: 'z', applianceId: 'missing')];
      await expectLater(
        portability.prepareRestore(
          jsonEncode(dangling),
          mode: RestoreMode.replace,
        ),
        throwsA(_validationContaining('dangling applianceId missing')),
      );

      final cyclic = _emptyBackup();
      final cyclicData = cyclic['data']! as Map<String, Object?>;
      cyclicData['appliances'] = [_appliance()];
      cyclicData['zones'] = [
        _zone(id: 'z1', applianceId: 'a', parentId: 'z2'),
        _zone(id: 'z2', applianceId: 'a', parentId: 'z1'),
      ];
      await expectLater(
        portability.prepareRestore(
          jsonEncode(cyclic),
          mode: RestoreMode.replace,
        ),
        throwsA(isA<BackupValidationException>()),
      );

      final invalidQuantity = _validMinimalBackup();
      final invalidData = invalidQuantity['data']! as Map<String, Object?>;
      final item =
          (invalidData['items']! as List<Object?>).single
              as Map<String, Object?>;
      item['quantity'] = '0';
      await expectLater(
        portability.prepareRestore(
          jsonEncode(invalidQuantity),
          mode: RestoreMode.replace,
        ),
        throwsA(
          _validationContaining('active inventory item cannot have zero'),
        ),
      );
    },
  );

  test(
    'replace restore rolls back deletion and inserts on a later failure',
    () async {
      await repository.saveAppliance(
        Appliance(id: ApplianceId('existing'), name: 'Existing', sortOrder: 0),
      );
      final source = FreezerDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      final sourceRepository = DriftInventoryRepository(source);
      await _seed(sourceRepository);
      final backup = await DataPortabilityService(source)
          .createJsonBackup(exportedAt: DateTime.utc(2026, 9, 4));
      final prepared = await portability.prepareRestore(
        backup,
        mode: RestoreMode.replace,
      );
      await database.customStatement('''
      CREATE TRIGGER force_restore_failure
      BEFORE INSERT ON reminders
      BEGIN
        SELECT RAISE(ABORT, 'forced reminder failure');
      END
    ''');

      await expectLater(portability.applyRestore(prepared), throwsA(anything));
      final appliances = await repository.appliances(includeArchived: true);
      expect(appliances.map((value) => value.id.value), ['existing']);
      expect(await database.zones.count().getSingle(), 0);
      expect(await database.freezerItems.count().getSingle(), 0);
    },
  );

  test(
    'delete all removes and verifies inventory, history, and reminders',
    () async {
      await _seed(repository);
      await portability.deleteAllAndVerify();

      expect(await database.appliances.count().getSingle(), 0);
      expect(await database.zones.count().getSingle(), 0);
      expect(await database.freezerItems.count().getSingle(), 0);
      expect(await database.inventoryEvents.count().getSingle(), 0);
      expect(await database.reminders.count().getSingle(), 0);
    },
  );

  test('CSV is escaped, inspectable, and deliberately item-only', () async {
    await _seed(repository, itemName: 'Soup, "large"');
    final csv = await portability.createCsvExport();

    expect(csv, contains('"Soup, ""large"""'));
    expect(csv, contains('"Garage","Top / Basket"'));
    expect(csv, isNot(contains('event-1')));
    expect(csv, isNot(contains('reminder-1')));
  });
}

Future<void> _seed(
  DriftInventoryRepository repository, {
  String itemName = 'Soup',
}) async {
  final appliance = Appliance(
    id: ApplianceId('appliance-1'),
    name: 'Garage',
    sortOrder: 0,
  );
  final top = Zone(
    id: ZoneId('zone-top'),
    applianceId: appliance.id,
    name: 'Top',
    sortOrder: 0,
  );
  final basket = Zone(
    id: ZoneId('zone-basket'),
    applianceId: appliance.id,
    parentId: top.id,
    name: 'Basket',
    sortOrder: 0,
  );
  final item = FreezerItem.create(
    id: ItemId('item-1'),
    name: itemName,
    category: 'Meals',
    zoneId: basket.id,
    quantity: PortionQuantity.parse('2.5'),
    unit: PortionUnit('portions'),
    frozenOn: PlanningDate.known(DateTime.utc(2026, 8, 1)),
    useFirstOn: const PlanningDate.unknown(),
    notes: 'Test fixture only',
    now: DateTime.utc(2026, 8, 2),
  );
  await repository.saveAppliance(appliance);
  await repository.saveZone(top);
  await repository.saveZone(basket);
  await repository.saveItem(item);
  await repository.appendEvent(
    InventoryEvent(
      id: InventoryEventId('event-1'),
      itemId: item.id,
      action: InventoryAction.create,
      beforeSummary: '',
      afterSummary: 'created',
      occurredAt: DateTime.utc(2026, 8, 2),
    ),
  );
  await repository.saveReminder(
    Reminder(
      id: ReminderId('reminder-1'),
      itemId: item.id,
      scheduledFor: DateTime.utc(2026, 9, 1),
      privacyMode: ReminderPrivacyMode.generic,
      isEnabled: true,
    ),
  );
}

Matcher _validationContaining(String text) =>
    isA<BackupValidationException>().having(
      (error) => error.message.toLowerCase(),
      'message',
      contains(text.toLowerCase()),
    );

Map<String, Object?> _emptyBackup() => {
  'format': 'freezer-map-backup',
  'version': 1,
  'exportedAt': '2026-09-04T00:00:00.000Z',
  'schema': {'application': 'freezer-map', 'database': 1},
  'data': {
    'appliances': <Object?>[],
    'zones': <Object?>[],
    'items': <Object?>[],
    'events': <Object?>[],
    'reminders': <Object?>[],
  },
};

Map<String, Object?> _validMinimalBackup() {
  final backup = _emptyBackup();
  final data = backup['data']! as Map<String, Object?>;
  data['appliances'] = [_appliance()];
  data['zones'] = [_zone(id: 'z', applianceId: 'a')];
  data['items'] = [
    {
      'id': 'i',
      'name': 'Soup',
      'category': '',
      'zoneId': 'z',
      'quantity': '1',
      'unit': 'portion',
      'frozenOn': null,
      'useFirstOn': null,
      'thawState': 'frozen',
      'notes': '',
      'createdAt': '2026-09-04T00:00:00.000Z',
      'updatedAt': '2026-09-04T00:00:00.000Z',
      'thawStateChangedAt': '2026-09-04T00:00:00.000Z',
      'archivedAt': null,
    },
  ];
  return backup;
}

Map<String, Object?> _appliance() => {
  'id': 'a',
  'name': 'Freezer',
  'sortOrder': 0,
  'isArchived': false,
};

Map<String, Object?> _zone({
  required String id,
  required String applianceId,
  String? parentId,
}) => {
  'id': id,
  'applianceId': applianceId,
  'parentId': parentId,
  'name': id,
  'sortOrder': 0,
  'isArchived': false,
};
