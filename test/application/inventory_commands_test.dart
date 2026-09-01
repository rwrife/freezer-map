import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  late FreezerDatabase database;
  late DriftInventoryRepository repository;
  late _Clock clock;
  late _Ids ids;
  late InventoryCommands commands;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
    clock = _Clock(DateTime.utc(2026, 8, 31, 12));
    ids = _Ids();
    commands = InventoryCommands(
      repository: repository,
      clock: clock,
      ids: ids,
    );
  });
  tearDown(() => database.close());

  Future<(Appliance, Zone)> location() async {
    final appliance = await commands.createAppliance(
      name: 'Garage',
      sortOrder: 0,
    );
    final zone = await commands.createZone(
      applianceId: appliance.id,
      name: 'Basket',
      sortOrder: 0,
    );
    return (appliance, zone);
  }

  test(
    'uses injected IDs and UTC clock and appends events for item commands',
    () async {
      final (_, zone) = await location();
      final item = await commands.createItem(
        name: 'Soup',
        category: 'Meals',
        zoneId: zone.id,
        quantity: PortionQuantity.parse('2'),
        unit: PortionUnit('portions'),
        frozenOn: const PlanningDate.unknown(),
        useFirstOn: const PlanningDate.unknown(),
        notes: '',
      );
      clock.value = DateTime.utc(2026, 8, 31, 13);
      await commands.incrementItem(item.id, PortionQuantity.parse('0.25'));
      await commands.markItemThawing(item.id);

      final stored = await repository.itemById(item.id);
      final events = await repository.eventsFor(item.id);
      expect(item.id.value, 'id-3');
      expect(stored!.quantity.canonical, '2.25');
      expect(stored.updatedAt, clock.value);
      expect(events.map((event) => event.action), <InventoryAction>[
        InventoryAction.create,
        InventoryAction.increment,
        InventoryAction.markThawing,
      ]);
      expect(events.last.occurredAt, clock.value);
    },
  );

  test(
    'rejects cycles and archiving locations used by active records',
    () async {
      final (appliance, parent) = await location();
      final child = await commands.createZone(
        applianceId: appliance.id,
        parentId: parent.id,
        name: 'Inner',
        sortOrder: 0,
      );
      await expectLater(
        commands.moveZone(parent.id, newParentId: child.id),
        throwsA(isA<DomainValidationException>()),
      );
      await expectLater(
        commands.archiveZone(parent.id),
        throwsA(isA<DomainValidationException>()),
      );
      await expectLater(
        commands.archiveAppliance(appliance.id),
        throwsA(isA<DomainValidationException>()),
      );
    },
  );

  test(
    'moving a zone appends it to the destination without order collisions',
    () async {
      final (appliance, sourceParent) = await location();
      final destinationParent = await commands.createZone(
        applianceId: appliance.id,
        name: 'Destination',
        sortOrder: 1,
      );
      final movedZone = await commands.createZone(
        applianceId: appliance.id,
        parentId: sourceParent.id,
        name: 'Moved',
        sortOrder: 1,
      );
      await commands.createZone(
        applianceId: appliance.id,
        parentId: destinationParent.id,
        name: 'First',
        sortOrder: 0,
      );
      await commands.createZone(
        applianceId: appliance.id,
        parentId: destinationParent.id,
        name: 'Second',
        sortOrder: 1,
      );

      final moved = await commands.moveZone(
        movedZone.id,
        newParentId: destinationParent.id,
      );
      final unchanged = await commands.moveZone(
        movedZone.id,
        newParentId: destinationParent.id,
      );
      final destinationChildren = (await repository.zones())
          .where((zone) => zone.parentId == destinationParent.id)
          .toList();

      expect(moved.sortOrder, 2);
      expect(unchanged.sortOrder, 2);
      expect(destinationChildren.map((zone) => zone.name), [
        'First',
        'Second',
        'Moved',
      ]);
      expect(
        destinationChildren.map((zone) => zone.sortOrder).toSet().length,
        destinationChildren.length,
      );
    },
  );

  test(
    'rolls item write back when an injected post-write failure occurs',
    () async {
      final (_, zone) = await location();
      final item = await commands.createItem(
        name: 'Soup',
        category: '',
        zoneId: zone.id,
        quantity: PortionQuantity.parse('2'),
        unit: PortionUnit('portions'),
        frozenOn: const PlanningDate.unknown(),
        useFirstOn: const PlanningDate.unknown(),
        notes: '',
      );
      commands = InventoryCommands(
        repository: repository,
        clock: clock,
        ids: ids,
        afterItemWrite: (_) async => throw StateError('injected failure'),
      );

      await expectLater(
        commands.decrementItem(
          item.id,
          PortionQuantity.parse('1'),
          whenZero: ZeroQuantityDisposition.archive,
        ),
        throwsStateError,
      );

      expect((await repository.itemById(item.id))!.quantity.canonical, '2');
      expect((await repository.eventsFor(item.id)).length, 1);
    },
  );

  test('atomic edit including destination rolls back item and audit', () async {
    final (appliance, first) = await location();
    final second = await commands.createZone(
      applianceId: appliance.id,
      name: 'Shelf',
      sortOrder: 1,
    );
    final item = await commands.createItem(
      name: 'Soup',
      category: 'Meal',
      zoneId: first.id,
      quantity: PortionQuantity.parse('2'),
      unit: PortionUnit('tubs'),
      frozenOn: const PlanningDate.unknown(),
      useFirstOn: const PlanningDate.unknown(),
      notes: 'before',
    );
    commands = InventoryCommands(
      repository: repository,
      clock: clock,
      ids: ids,
      afterItemWrite: (_) async => throw StateError('injected failure'),
    );

    await expectLater(
      commands.editItem(
        item.id,
        name: 'Stew',
        category: 'Dinner',
        quantity: PortionQuantity.parse('3'),
        unit: PortionUnit('bags'),
        frozenOn: PlanningDate.known(DateTime.utc(2026, 8, 1)),
        useFirstOn: PlanningDate.known(DateTime.utc(2026, 9, 1)),
        notes: 'after',
        zoneId: second.id,
      ),
      throwsStateError,
    );
    final stored = (await repository.itemById(item.id))!;
    expect(stored.name, item.name);
    expect(stored.category, item.category);
    expect(stored.zoneId, item.zoneId);
    expect(stored.quantity, item.quantity);
    expect(stored.notes, item.notes);
    expect((await repository.eventsFor(item.id)).length, 1);
  });

  test('initial location is atomic when the zone write fails', () async {
    commands = InventoryCommands(
      repository: repository,
      clock: clock,
      ids: ids,
      afterLocationWrite: () async => throw StateError('injected failure'),
    );

    await expectLater(
      commands.createInitialLocation(
        applianceName: 'Garage',
        zoneName: 'Basket',
      ),
      throwsStateError,
    );
    expect(await repository.appliances(), isEmpty);
    expect(await repository.zones(), isEmpty);
  });

  test('appliance and zone reorder swaps are atomic and ordered', () async {
    final firstAppliance = await commands.createAppliance(
      name: 'A',
      sortOrder: 0,
    );
    final secondAppliance = await commands.createAppliance(
      name: 'B',
      sortOrder: 1,
    );
    final firstZone = await commands.createZone(
      applianceId: firstAppliance.id,
      name: 'One',
      sortOrder: 0,
    );
    final secondZone = await commands.createZone(
      applianceId: firstAppliance.id,
      name: 'Two',
      sortOrder: 1,
    );

    await commands.reorderAppliances(firstAppliance.id, secondAppliance.id);
    await commands.reorderZones(firstZone.id, secondZone.id);
    expect((await repository.appliances()).map((value) => value.name), [
      'B',
      'A',
    ]);
    expect((await repository.zones()).map((value) => value.name), [
      'Two',
      'One',
    ]);

    commands = InventoryCommands(
      repository: repository,
      clock: clock,
      ids: ids,
      afterLocationWrite: () async => throw StateError('injected failure'),
    );
    await expectLater(
      commands.reorderAppliances(firstAppliance.id, secondAppliance.id),
      throwsStateError,
    );
    await expectLater(
      commands.reorderZones(firstZone.id, secondZone.id),
      throwsStateError,
    );
    expect((await repository.appliances()).map((value) => value.name), [
      'B',
      'A',
    ]);
    expect((await repository.zones()).map((value) => value.name), [
      'Two',
      'One',
    ]);
  });

  test('supports the complete location and item command lifecycle', () async {
    final (appliance, first) = await location();
    final second = await commands.createZone(
      applianceId: appliance.id,
      name: 'Shelf',
      sortOrder: 1,
    );
    final renamed = await commands.updateAppliance(
      appliance.id,
      name: 'Garage freezer',
      sortOrder: 2,
    );
    final nested = await commands.moveZone(second.id, newParentId: first.id);
    final updatedZone = await commands.updateZone(
      nested.id,
      name: 'Upper shelf',
      sortOrder: 3,
    );
    var item = await commands.createItem(
      name: 'Stew',
      category: '',
      zoneId: first.id,
      quantity: PortionQuantity.parse('1.5'),
      unit: PortionUnit('tubs'),
      frozenOn: const PlanningDate.unknown(),
      useFirstOn: const PlanningDate.unknown(),
      notes: '',
    );
    item = await commands.editItem(
      item.id,
      name: 'Bean stew',
      category: 'Meals',
      quantity: PortionQuantity.parse('2'),
      unit: PortionUnit('tubs'),
      frozenOn: PlanningDate.known(DateTime.utc(2026, 8, 1)),
      useFirstOn: const PlanningDate.unknown(),
      notes: 'user-entered only',
      zoneId: second.id,
    );
    item = await commands.markItemThawing(item.id);
    item = await commands.returnItemToFrozen(item.id);
    item = await commands.decrementItem(
      item.id,
      PortionQuantity.parse('0.5'),
      whenZero: ZeroQuantityDisposition.archive,
    );
    item = await commands.archiveItem(item.id);
    final archivedSecond = await commands.archiveZone(second.id);
    final archivedFirst = await commands.archiveZone(first.id);
    final archivedAppliance = await commands.archiveAppliance(appliance.id);

    expect(renamed.name, 'Garage freezer');
    expect(updatedZone.parentId, first.id);
    expect(item.isArchived, isTrue);
    expect(item.quantity.canonical, '1.5');
    expect(archivedSecond.isArchived, isTrue);
    expect(archivedFirst.isArchived, isTrue);
    expect(archivedAppliance.isArchived, isTrue);
    expect(
      (await repository.eventsFor(item.id)).map((event) => event.action),
      <InventoryAction>[
        InventoryAction.create,
        InventoryAction.edit,
        InventoryAction.markThawing,
        InventoryAction.returnToFrozen,
        InventoryAction.decrement,
        InventoryAction.archive,
      ],
    );
  });
}

final class _Clock implements Clock {
  _Clock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
}

final class _Ids implements StableIdSource {
  var count = 0;
  @override
  String next() => 'id-${++count}';
}
