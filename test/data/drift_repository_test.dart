import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  late FreezerDatabase database;
  late DriftInventoryRepository repository;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
  });
  tearDown(() => database.close());

  test(
    'round trips appliances, zones, exact items, events, and reminders',
    () async {
      final now = DateTime.utc(2026, 8, 31, 12);
      final appliance = Appliance(
        id: ApplianceId('a'),
        name: 'Garage',
        sortOrder: 0,
      );
      final zone = Zone(
        id: ZoneId('z'),
        applianceId: appliance.id,
        name: 'Basket',
        sortOrder: 0,
      );
      final item = FreezerItem.create(
        id: ItemId('i'),
        name: 'Soup',
        category: 'Meals',
        zoneId: zone.id,
        quantity: PortionQuantity.parse('0.1234567890123456789'),
        unit: PortionUnit('portions'),
        frozenOn: const PlanningDate.unknown(),
        useFirstOn: PlanningDate.known(DateTime.utc(2026, 9, 1)),
        notes: 'No inference',
        now: now,
      );
      final event = InventoryEvent(
        id: InventoryEventId('e'),
        itemId: item.id,
        action: InventoryAction.create,
        beforeSummary: '',
        afterSummary: 'created',
        occurredAt: now,
      );
      final reminder = Reminder(
        id: ReminderId('r'),
        itemId: item.id,
        scheduledFor: now.add(const Duration(days: 1)),
        privacyMode: ReminderPrivacyMode.generic,
        isEnabled: true,
      );

      await repository.saveAppliance(appliance);
      await repository.saveZone(zone);
      await repository.saveItem(item);
      await repository.appendEvent(event);
      await repository.saveReminder(reminder);

      expect((await repository.applianceById(appliance.id))!.name, 'Garage');
      expect((await repository.zoneById(zone.id))!.applianceId, appliance.id);
      expect(
        (await repository.itemById(item.id))!.quantity.canonical,
        '0.1234567890123456789',
      );
      expect((await repository.itemById(item.id))!.frozenOn.isKnown, isFalse);
      expect(
        (await repository.eventsFor(item.id)).single.action,
        InventoryAction.create,
      );
      expect(
        (await repository.remindersFor(item.id)).single.privacyMode,
        ReminderPrivacyMode.generic,
      );
    },
  );

  test('foreign keys reject dangling locations', () async {
    final item = FreezerItem.create(
      id: ItemId('i'),
      name: 'Soup',
      category: '',
      zoneId: ZoneId('missing'),
      quantity: PortionQuantity.parse('1'),
      unit: PortionUnit('portion'),
      frozenOn: const PlanningDate.unknown(),
      useFirstOn: const PlanningDate.unknown(),
      notes: '',
      now: DateTime.utc(2026),
    );

    await expectLater(repository.saveItem(item), throwsA(anything));
  });

  test(
    'repository rejects cross-appliance parents and active archived locations',
    () async {
      final first = Appliance(
        id: ApplianceId('a1'),
        name: 'First',
        sortOrder: 0,
      );
      final second = Appliance(
        id: ApplianceId('a2'),
        name: 'Second',
        sortOrder: 1,
      );
      final parent = Zone(
        id: ZoneId('parent'),
        applianceId: first.id,
        name: 'Parent',
        sortOrder: 0,
      );
      await repository.saveAppliance(first);
      await repository.saveAppliance(second);
      await repository.saveZone(parent);

      await expectLater(
        repository.saveZone(
          Zone(
            id: ZoneId('child'),
            applianceId: second.id,
            parentId: parent.id,
            name: 'Invalid child',
            sortOrder: 0,
          ),
        ),
        throwsA(isA<DomainValidationException>()),
      );

      await repository.saveZone(
        Zone(
          id: parent.id,
          applianceId: first.id,
          name: parent.name,
          sortOrder: parent.sortOrder,
          isArchived: true,
        ),
      );
      await expectLater(
        repository.saveItem(
          FreezerItem.create(
            id: ItemId('active-item'),
            name: 'Soup',
            category: '',
            zoneId: parent.id,
            quantity: PortionQuantity.parse('1'),
            unit: PortionUnit('portion'),
            frozenOn: const PlanningDate.unknown(),
            useFirstOn: const PlanningDate.unknown(),
            notes: '',
            now: DateTime.utc(2026),
          ),
        ),
        throwsA(isA<DomainValidationException>()),
      );
    },
  );
}
