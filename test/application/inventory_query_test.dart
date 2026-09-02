import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/inventory_query.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  final firstAppliance = Appliance(
    id: ApplianceId('appliance-a'),
    name: 'Kitchen',
    sortOrder: 0,
  );
  final secondAppliance = Appliance(
    id: ApplianceId('appliance-b'),
    name: 'Garage',
    sortOrder: 1,
  );
  final kitchen = Zone(
    id: ZoneId('zone-a'),
    applianceId: firstAppliance.id,
    name: 'Drawer',
    sortOrder: 0,
  );
  final garage = Zone(
    id: ZoneId('zone-b'),
    applianceId: secondAppliance.id,
    name: 'Basket',
    sortOrder: 0,
  );

  FreezerItem item({
    required String id,
    required String name,
    required Zone zone,
    String category = '',
    String quantity = '1',
    PlanningDate frozenOn = const PlanningDate.unknown(),
    PlanningDate useFirstOn = const PlanningDate.unknown(),
    ThawState thawState = ThawState.frozen,
    DateTime? thawChanged,
    bool archived = false,
  }) => FreezerItem.rehydrate(
    id: ItemId(id),
    name: name,
    category: category,
    zoneId: zone.id,
    quantity: PortionQuantity.parse(quantity),
    unit: PortionUnit('bags'),
    frozenOn: frozenOn,
    useFirstOn: useFirstOn,
    thawState: thawState,
    notes: name == 'Crème soup' ? 'family lunch' : '',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 2, 1),
    thawStateChangedAt: thawChanged ?? DateTime.utc(2026, 2, 1),
    archivedAt: archived ? DateTime.utc(2026, 2, 2) : null,
  );

  test('combined filters and normalized local search use AND semantics', () {
    final matching = item(
      id: '1',
      name: 'Crème soup',
      zone: kitchen,
      category: 'Meals',
      frozenOn: PlanningDate.known(DateTime.utc(2026, 1, 3)),
      useFirstOn: PlanningDate.known(DateTime.utc(2026, 3, 1)),
      thawState: ThawState.thawing,
    );
    final wrongAppliance = item(
      id: '2',
      name: 'Creme soup',
      zone: garage,
      category: 'Meals',
      frozenOn: PlanningDate.known(DateTime.utc(2026, 1, 3)),
      useFirstOn: PlanningDate.known(DateTime.utc(2026, 3, 1)),
      thawState: ThawState.thawing,
    );
    final wrongDate = item(
      id: '3',
      name: 'Creme soup',
      zone: kitchen,
      category: 'Meals',
      thawState: ThawState.thawing,
    );

    final result = filterInventory(
      [matching, wrongAppliance, wrongDate],
      [kitchen, garage],
      InventoryFilter(
        query: 'creme',
        applianceId: firstAppliance.id,
        zoneId: kitchen.id,
        category: 'Meals',
        thawState: ThawState.thawing,
        frozenOn: DatePresenceFilter.known,
        useFirstOn: DatePresenceFilter.known,
      ),
    );

    expect(result, [matching]);
  });

  test('archived filter is explicit and defaults to active records', () {
    final active = item(id: 'active', name: 'Active', zone: kitchen);
    final archived = item(
      id: 'archived',
      name: 'Archived',
      zone: kitchen,
      quantity: '0',
      archived: true,
    );

    expect(
      filterInventory([active, archived], [kitchen], const InventoryFilter()),
      [active],
    );
    expect(
      filterInventory(
        [active, archived],
        [kitchen],
        const InventoryFilter(archived: ArchivedFilter.archived),
      ),
      [archived],
    );
  });

  test(
    'use-first ordering resolves all ties and leaves unknown dates last',
    () {
      final laterId = item(
        id: 'b',
        name: 'Soup',
        zone: kitchen,
        frozenOn: PlanningDate.known(DateTime.utc(2026, 1, 1)),
        useFirstOn: PlanningDate.known(DateTime.utc(2026, 3, 1)),
      );
      final earlierId = item(
        id: 'a',
        name: 'Soup',
        zone: kitchen,
        frozenOn: PlanningDate.known(DateTime.utc(2026, 1, 1)),
        useFirstOn: PlanningDate.known(DateTime.utc(2026, 3, 1)),
      );
      final unknown = item(id: 'unknown', name: 'Beans', zone: kitchen);

      final result = useFirstInventory([unknown, laterId, earlierId]);

      expect(result.map((value) => value.id.value), ['a', 'b', 'unknown']);
    },
  );

  test('thaw queue is deterministic by transition time, name, then ID', () {
    final later = item(
      id: 'later',
      name: 'Berries',
      zone: kitchen,
      thawState: ThawState.thawing,
      thawChanged: DateTime.utc(2026, 3, 2),
    );
    final b = item(
      id: 'b',
      name: 'Soup',
      zone: kitchen,
      thawState: ThawState.thawing,
      thawChanged: DateTime.utc(2026, 3, 1),
    );
    final a = item(
      id: 'a',
      name: 'Soup',
      zone: kitchen,
      thawState: ThawState.thawing,
      thawChanged: DateTime.utc(2026, 3, 1),
    );
    final frozen = item(id: 'frozen', name: 'Frozen', zone: kitchen);

    expect(
      thawQueueInventory([later, b, frozen, a]).map((value) => value.id.value),
      ['a', 'b', 'later'],
    );
  });
}
