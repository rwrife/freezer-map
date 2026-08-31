import 'package:drift/drift.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/domain/entities.dart' as domain;
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

final class DriftInventoryRepository
    implements TransactionalInventoryRepository {
  const DriftInventoryRepository(this.database);

  final FreezerDatabase database;

  @override
  Future<T> transaction<T>(
    Future<T> Function(InventoryRepositories repositories) action,
  ) => database.transaction(() => action(this));

  @override
  Future<domain.Appliance?> applianceById(ApplianceId id) async {
    final row = await (database.select(
      database.appliances,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _appliance(row);
  }

  @override
  Future<List<domain.Appliance>> appliances({
    bool includeArchived = false,
  }) async {
    final query = database.select(database.appliances);
    if (!includeArchived) {
      query.where((table) => table.isArchived.equals(false));
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.sortOrder),
      (table) => OrderingTerm.asc(table.id),
    ]);
    return (await query.get()).map(_appliance).toList(growable: false);
  }

  @override
  Future<void> saveAppliance(domain.Appliance appliance) => database
      .into(database.appliances)
      .insertOnConflictUpdate(
        ApplianceRow(
          id: appliance.id.value,
          name: appliance.name,
          sortOrder: appliance.sortOrder,
          isArchived: appliance.isArchived,
        ),
      );

  @override
  Future<domain.Zone?> zoneById(ZoneId id) async {
    final row = await (database.select(
      database.zones,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _zone(row);
  }

  @override
  Future<List<domain.Zone>> zones({bool includeArchived = false}) async {
    final query = database.select(database.zones);
    if (!includeArchived) {
      query.where((table) => table.isArchived.equals(false));
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.applianceId),
      (table) => OrderingTerm.asc(table.sortOrder),
      (table) => OrderingTerm.asc(table.id),
    ]);
    return (await query.get()).map(_zone).toList(growable: false);
  }

  @override
  Future<void> saveZone(domain.Zone zone) async {
    final appliance = await applianceById(zone.applianceId);
    if (appliance == null || (!zone.isArchived && appliance.isArchived)) {
      throw const DomainValidationException(
        'An active zone requires an active appliance.',
      );
    }
    final parentId = zone.parentId;
    if (parentId != null) {
      final parent = await zoneById(parentId);
      if (parent == null || parent.applianceId != zone.applianceId) {
        throw const DomainValidationException(
          'A zone parent must belong to the same appliance.',
        );
      }
      if (!zone.isArchived && parent.isArchived) {
        throw const DomainValidationException(
          'An active zone cannot have an archived parent.',
        );
      }
    }

    final existing = await zones(includeArchived: true);
    if (zone.isArchived &&
        existing.any(
          (candidate) => !candidate.isArchived && candidate.parentId == zone.id,
        )) {
      throw const DomainValidationException(
        'A zone with active child zones cannot be archived.',
      );
    }
    ZoneForest.validate([
      for (final candidate in existing)
        if (candidate.id == zone.id) zone else candidate,
      if (!existing.any((candidate) => candidate.id == zone.id)) zone,
    ]);

    await database
        .into(database.zones)
        .insertOnConflictUpdate(
          ZoneRow(
            id: zone.id.value,
            applianceId: zone.applianceId.value,
            parentId: zone.parentId?.value,
            name: zone.name,
            sortOrder: zone.sortOrder,
            isArchived: zone.isArchived,
          ),
        );
  }

  @override
  Future<domain.FreezerItem?> itemById(ItemId id) async {
    final row = await (database.select(
      database.freezerItems,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _item(row);
  }

  @override
  Future<List<domain.FreezerItem>> items({bool includeArchived = false}) async {
    final query = database.select(database.freezerItems);
    if (!includeArchived) {
      query.where((table) => table.archivedAt.isNull());
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.name),
      (table) => OrderingTerm.asc(table.id),
    ]);
    return (await query.get()).map(_item).toList(growable: false);
  }

  @override
  Future<void> saveItem(domain.FreezerItem item) async {
    if (!item.isArchived) {
      final zone = await zoneById(item.zoneId);
      final appliance = zone == null
          ? null
          : await applianceById(zone.applianceId);
      if (zone == null ||
          zone.isArchived ||
          appliance == null ||
          appliance.isArchived) {
        throw const DomainValidationException(
          'An active item requires an active zone and appliance.',
        );
      }
    }

    await database
        .into(database.freezerItems)
        .insertOnConflictUpdate(
          FreezerItemRow(
            id: item.id.value,
            name: item.name,
            category: item.category,
            zoneId: item.zoneId.value,
            quantity: item.quantity.canonical,
            unit: item.unit.value,
            frozenOn: item.frozenOn.value,
            useFirstOn: item.useFirstOn.value,
            thawState: item.thawState.name,
            notes: item.notes,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            thawStateChangedAt: item.thawStateChangedAt,
            archivedAt: item.archivedAt,
          ),
        );
  }

  @override
  Future<List<domain.InventoryEvent>> eventsFor(ItemId itemId) async {
    final query = database.select(database.inventoryEvents)
      ..where((table) => table.itemId.equals(itemId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.occurredAt),
        (table) => OrderingTerm.asc(table.sequence),
      ]);
    return (await query.get()).map(_event).toList(growable: false);
  }

  @override
  Future<void> appendEvent(domain.InventoryEvent event) => database
      .into(database.inventoryEvents)
      .insert(
        InventoryEventsCompanion.insert(
          id: event.id.value,
          itemId: event.itemId.value,
          action: event.action.name,
          beforeSummary: event.beforeSummary,
          afterSummary: event.afterSummary,
          occurredAt: event.occurredAt,
        ),
      );

  @override
  Future<domain.Reminder?> reminderById(ReminderId id) async {
    final row = await (database.select(
      database.reminders,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _reminder(row);
  }

  @override
  Future<List<domain.Reminder>> remindersFor(ItemId itemId) async {
    final query = database.select(database.reminders)
      ..where((table) => table.itemId.equals(itemId.value))
      ..orderBy([
        (table) => OrderingTerm.asc(table.scheduledFor),
        (table) => OrderingTerm.asc(table.id),
      ]);
    return (await query.get()).map(_reminder).toList(growable: false);
  }

  @override
  Future<void> saveReminder(domain.Reminder reminder) => database
      .into(database.reminders)
      .insertOnConflictUpdate(
        ReminderRow(
          id: reminder.id.value,
          itemId: reminder.itemId.value,
          scheduledFor: reminder.scheduledFor,
          privacyMode: reminder.privacyMode.name,
          isEnabled: reminder.isEnabled,
        ),
      );
}

domain.Appliance _appliance(ApplianceRow row) => domain.Appliance(
  id: ApplianceId(row.id),
  name: row.name,
  sortOrder: row.sortOrder,
  isArchived: row.isArchived,
);

domain.Zone _zone(ZoneRow row) => domain.Zone(
  id: ZoneId(row.id),
  applianceId: ApplianceId(row.applianceId),
  parentId: row.parentId == null ? null : ZoneId(row.parentId!),
  name: row.name,
  sortOrder: row.sortOrder,
  isArchived: row.isArchived,
);

domain.FreezerItem _item(FreezerItemRow row) => domain.FreezerItem.rehydrate(
  id: ItemId(row.id),
  name: row.name,
  category: row.category,
  zoneId: ZoneId(row.zoneId),
  quantity: PortionQuantity.parse(row.quantity),
  unit: PortionUnit(row.unit),
  frozenOn: row.frozenOn == null
      ? const PlanningDate.unknown()
      : PlanningDate.known(row.frozenOn!),
  useFirstOn: row.useFirstOn == null
      ? const PlanningDate.unknown()
      : PlanningDate.known(row.useFirstOn!),
  thawState: domain.ThawState.values.byName(row.thawState),
  notes: row.notes,
  createdAt: row.createdAt.toUtc(),
  updatedAt: row.updatedAt.toUtc(),
  thawStateChangedAt: row.thawStateChangedAt.toUtc(),
  archivedAt: row.archivedAt?.toUtc(),
);

domain.InventoryEvent _event(InventoryEventRow row) => domain.InventoryEvent(
  id: InventoryEventId(row.id),
  itemId: ItemId(row.itemId),
  action: domain.InventoryAction.values.byName(row.action),
  beforeSummary: row.beforeSummary,
  afterSummary: row.afterSummary,
  occurredAt: row.occurredAt.toUtc(),
);

domain.Reminder _reminder(ReminderRow row) => domain.Reminder(
  id: ReminderId(row.id),
  itemId: ItemId(row.itemId),
  scheduledFor: row.scheduledFor.toUtc(),
  privacyMode: domain.ReminderPrivacyMode.values.byName(row.privacyMode),
  isEnabled: row.isEnabled,
);
