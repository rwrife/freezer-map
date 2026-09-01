import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

export 'package:freezer_map/domain/contracts.dart' show Clock, StableIdSource;
export 'package:freezer_map/domain/policies.dart' show ZeroQuantityDisposition;

typedef ItemWriteCheckpoint = Future<void> Function(InventoryAction action);
typedef LocationWriteCheckpoint = Future<void> Function();

final class InventoryCommands {
  const InventoryCommands({
    required this.repository,
    required this.clock,
    required this.ids,
    this.afterItemWrite,
    this.afterLocationWrite,
  });

  final TransactionalInventoryRepository repository;
  final Clock clock;
  final StableIdSource ids;
  final ItemWriteCheckpoint? afterItemWrite;
  final LocationWriteCheckpoint? afterLocationWrite;

  Future<(Appliance, Zone)> createInitialLocation({
    required String applianceName,
    required String zoneName,
  }) => repository.transaction((repositories) async {
    final appliance = Appliance(
      id: ApplianceId(ids.next()),
      name: applianceName,
      sortOrder: 0,
    );
    final zone = Zone(
      id: ZoneId(ids.next()),
      applianceId: appliance.id,
      name: zoneName,
      sortOrder: 0,
    );
    await repositories.saveAppliance(appliance);
    await _locationCheckpoint();
    await repositories.saveZone(zone);
    return (appliance, zone);
  });

  Future<void> reorderAppliances(
    ApplianceId firstId,
    ApplianceId secondId,
  ) => repository.transaction((repositories) async {
    final first = await _appliance(repositories, firstId);
    final second = await _appliance(repositories, secondId);
    _requireActiveAppliance(first);
    _requireActiveAppliance(second);
    await repositories.saveAppliance(
      Appliance(id: first.id, name: first.name, sortOrder: second.sortOrder),
    );
    await _locationCheckpoint();
    await repositories.saveAppliance(
      Appliance(id: second.id, name: second.name, sortOrder: first.sortOrder),
    );
  });

  Future<void> reorderZones(ZoneId firstId, ZoneId secondId) =>
      repository.transaction((repositories) async {
        final first = await _zone(repositories, firstId);
        final second = await _zone(repositories, secondId);
        _requireActiveZone(first);
        _requireActiveZone(second);
        if (first.applianceId != second.applianceId ||
            first.parentId != second.parentId) {
          throw const DomainValidationException(
            'Only sibling zones can be reordered.',
          );
        }
        await repositories.saveZone(
          Zone(
            id: first.id,
            applianceId: first.applianceId,
            parentId: first.parentId,
            name: first.name,
            sortOrder: second.sortOrder,
          ),
        );
        await _locationCheckpoint();
        await repositories.saveZone(
          Zone(
            id: second.id,
            applianceId: second.applianceId,
            parentId: second.parentId,
            name: second.name,
            sortOrder: first.sortOrder,
          ),
        );
      });

  Future<Appliance> createAppliance({
    required String name,
    required int sortOrder,
  }) => repository.transaction((repositories) async {
    final appliance = Appliance(
      id: ApplianceId(ids.next()),
      name: name,
      sortOrder: sortOrder,
    );
    await repositories.saveAppliance(appliance);
    await _locationCheckpoint();
    return appliance;
  });

  Future<Appliance> updateAppliance(
    ApplianceId id, {
    required String name,
    required int sortOrder,
  }) => repository.transaction((repositories) async {
    final current = await _appliance(repositories, id);
    _requireActiveAppliance(current);
    final updated = Appliance(id: id, name: name, sortOrder: sortOrder);
    await repositories.saveAppliance(updated);
    await _locationCheckpoint();
    return updated;
  });

  Future<Appliance> archiveAppliance(ApplianceId id) =>
      repository.transaction((repositories) async {
        final current = await _appliance(repositories, id);
        _requireActiveAppliance(current);
        final activeZones = (await repositories.zones()).where(
          (zone) => zone.applianceId == id,
        );
        if (activeZones.isNotEmpty) {
          throw const DomainValidationException(
            'An appliance with active zones cannot be archived.',
          );
        }
        final archived = Appliance(
          id: id,
          name: current.name,
          sortOrder: current.sortOrder,
          isArchived: true,
        );
        await repositories.saveAppliance(archived);
        return archived;
      });

  Future<Zone> createZone({
    required ApplianceId applianceId,
    required String name,
    required int sortOrder,
    ZoneId? parentId,
  }) => repository.transaction((repositories) async {
    final appliance = await _appliance(repositories, applianceId);
    _requireActiveAppliance(appliance);
    if (parentId != null) {
      final parent = await _zone(repositories, parentId);
      _requireActiveZone(parent);
      if (parent.applianceId != applianceId) {
        throw const DomainValidationException(
          'A zone parent must belong to the same appliance.',
        );
      }
    }
    final zone = Zone(
      id: ZoneId(ids.next()),
      applianceId: applianceId,
      parentId: parentId,
      name: name,
      sortOrder: sortOrder,
    );
    final zones = [...await repositories.zones(), zone];
    ZoneForest.validate(zones);
    await repositories.saveZone(zone);
    await _locationCheckpoint();
    return zone;
  });

  Future<Zone> updateZone(
    ZoneId id, {
    required String name,
    required int sortOrder,
  }) => repository.transaction((repositories) async {
    final current = await _zone(repositories, id);
    _requireActiveZone(current);
    final updated = Zone(
      id: id,
      applianceId: current.applianceId,
      parentId: current.parentId,
      name: name,
      sortOrder: sortOrder,
    );
    await repositories.saveZone(updated);
    await _locationCheckpoint();
    return updated;
  });

  Future<Zone> moveZone(ZoneId id, {ZoneId? newParentId}) =>
      repository.transaction((repositories) async {
        final current = await _zone(repositories, id);
        _requireActiveZone(current);
        if (newParentId != null) {
          final parent = await _zone(repositories, newParentId);
          _requireActiveZone(parent);
          if (parent.applianceId != current.applianceId) {
            throw const DomainValidationException(
              'A zone parent must belong to the same appliance.',
            );
          }
        }
        final zones = await repositories.zones();
        var sortOrder = current.sortOrder;
        if (newParentId != current.parentId) {
          int? maximumDestinationOrder;
          for (final zone in zones) {
            if (zone.id == id ||
                zone.applianceId != current.applianceId ||
                zone.parentId != newParentId) {
              continue;
            }
            if (maximumDestinationOrder == null ||
                zone.sortOrder > maximumDestinationOrder) {
              maximumDestinationOrder = zone.sortOrder;
            }
          }
          sortOrder = maximumDestinationOrder == null
              ? 0
              : maximumDestinationOrder + 1;
        }
        final moved = Zone(
          id: id,
          applianceId: current.applianceId,
          parentId: newParentId,
          name: current.name,
          sortOrder: sortOrder,
        );
        final candidate = [
          for (final zone in zones)
            if (zone.id == id) moved else zone,
        ];
        ZoneForest.validate(candidate);
        await repositories.saveZone(moved);
        return moved;
      });

  Future<Zone> archiveZone(ZoneId id) =>
      repository.transaction((repositories) async {
        final current = await _zone(repositories, id);
        _requireActiveZone(current);
        if ((await repositories.zones()).any((zone) => zone.parentId == id)) {
          throw const DomainValidationException(
            'A zone with active child zones cannot be archived.',
          );
        }
        if ((await repositories.items()).any((item) => item.zoneId == id)) {
          throw const DomainValidationException(
            'A zone containing active items cannot be archived.',
          );
        }
        final archived = Zone(
          id: id,
          applianceId: current.applianceId,
          parentId: current.parentId,
          name: current.name,
          sortOrder: current.sortOrder,
          isArchived: true,
        );
        await repositories.saveZone(archived);
        return archived;
      });

  Future<FreezerItem> createItem({
    required String name,
    required String category,
    required ZoneId zoneId,
    required PortionQuantity quantity,
    required PortionUnit unit,
    required PlanningDate frozenOn,
    required PlanningDate useFirstOn,
    required String notes,
  }) => repository.transaction((repositories) async {
    await _requireActiveLocation(repositories, zoneId);
    final now = clock.nowUtc().toUtc();
    final item = FreezerItem.create(
      id: ItemId(ids.next()),
      name: name,
      category: category,
      zoneId: zoneId,
      quantity: quantity,
      unit: unit,
      frozenOn: frozenOn,
      useFirstOn: useFirstOn,
      notes: notes,
      now: now,
    );
    await repositories.saveItem(item);
    await _checkpoint(InventoryAction.create);
    await _appendEvent(repositories, item, InventoryAction.create, null, now);
    return item;
  });

  Future<FreezerItem> editItem(
    ItemId id, {
    required String name,
    required String category,
    required PortionQuantity quantity,
    required PortionUnit unit,
    required PlanningDate frozenOn,
    required PlanningDate useFirstOn,
    required String notes,
    required ZoneId zoneId,
  }) => _mutate(
    id,
    InventoryAction.edit,
    (item, now) => ItemPolicy.edit(
      ItemPolicy.move(item, zoneId, now: now),
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      frozenOn: frozenOn,
      useFirstOn: useFirstOn,
      notes: notes,
      now: now,
    ),
    destination: zoneId,
  );

  Future<FreezerItem> incrementItem(ItemId id, PortionQuantity amount) =>
      _mutate(
        id,
        InventoryAction.increment,
        (item, now) => ItemPolicy.increment(item, amount, now: now),
      );

  Future<FreezerItem> decrementItem(
    ItemId id,
    PortionQuantity amount, {
    required ZeroQuantityDisposition whenZero,
  }) => _mutate(
    id,
    InventoryAction.decrement,
    (item, now) =>
        ItemPolicy.decrement(item, amount, now: now, whenZero: whenZero),
  );

  Future<FreezerItem> moveItem(ItemId id, ZoneId destination) => _mutate(
    id,
    InventoryAction.move,
    (item, now) => ItemPolicy.move(item, destination, now: now),
    destination: destination,
  );

  Future<FreezerItem> markItemThawing(ItemId id) => _mutate(
    id,
    InventoryAction.markThawing,
    (item, now) => ItemPolicy.markThawing(item, now: now),
  );

  Future<FreezerItem> returnItemToFrozen(ItemId id) => _mutate(
    id,
    InventoryAction.returnToFrozen,
    (item, now) => ItemPolicy.returnToFrozen(item, now: now),
  );

  Future<FreezerItem> archiveItem(ItemId id) => _mutate(
    id,
    InventoryAction.archive,
    (item, now) => ItemPolicy.archive(item, now: now),
  );

  Future<FreezerItem> _mutate(
    ItemId id,
    InventoryAction action,
    FreezerItem Function(FreezerItem item, DateTime now) change, {
    ZoneId? destination,
  }) => repository.transaction((repositories) async {
    final current = await repositories.itemById(id);
    if (current == null) {
      throw DomainValidationException('Unknown item: ${id.value}.');
    }
    if (destination != null) {
      await _requireActiveLocation(repositories, destination);
    }
    final now = clock.nowUtc().toUtc();
    final updated = change(current, now);
    await repositories.saveItem(updated);
    await _checkpoint(action);
    await _appendEvent(repositories, updated, action, current, now);
    return updated;
  });

  Future<void> _appendEvent(
    InventoryRepositories repositories,
    FreezerItem after,
    InventoryAction action,
    FreezerItem? before,
    DateTime now,
  ) => repositories.appendEvent(
    InventoryEvent(
      id: InventoryEventId(ids.next()),
      itemId: after.id,
      action: action,
      beforeSummary: before == null ? '' : _summary(before),
      afterSummary: _summary(after),
      occurredAt: now,
    ),
  );

  Future<void> _checkpoint(InventoryAction action) async {
    final callback = afterItemWrite;
    if (callback != null) {
      await callback(action);
    }
  }

  Future<void> _locationCheckpoint() async {
    final callback = afterLocationWrite;
    if (callback != null) await callback();
  }
}

String _summary(FreezerItem item) =>
    'quantity=${item.quantity.canonical};zone=${item.zoneId.value};'
    'thaw=${item.thawState.name};archived=${item.isArchived}';

Future<Appliance> _appliance(
  InventoryRepositories repositories,
  ApplianceId id,
) async {
  final value = await repositories.applianceById(id);
  if (value == null) {
    throw DomainValidationException('Unknown appliance: ${id.value}.');
  }
  return value;
}

Future<Zone> _zone(InventoryRepositories repositories, ZoneId id) async {
  final value = await repositories.zoneById(id);
  if (value == null) {
    throw DomainValidationException('Unknown zone: ${id.value}.');
  }
  return value;
}

void _requireActiveAppliance(Appliance appliance) {
  if (appliance.isArchived) {
    throw const DomainValidationException('Appliance is archived.');
  }
}

void _requireActiveZone(Zone zone) {
  if (zone.isArchived) {
    throw const DomainValidationException('Zone is archived.');
  }
}

Future<void> _requireActiveLocation(
  InventoryRepositories repositories,
  ZoneId zoneId,
) async {
  final zone = await _zone(repositories, zoneId);
  _requireActiveZone(zone);
  _requireActiveAppliance(await _appliance(repositories, zone.applianceId));
}
