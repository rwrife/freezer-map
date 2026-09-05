import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:freezer_map/application/data_management.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

final class _PreparedRestore implements PreparedRestore {
  const _PreparedRestore(this._document, this.summary);

  final _BackupDocument _document;
  @override
  final RestoreSummary summary;
}

/// Owns all database mutations for backup, restore, and deletion.
///
/// Parsing and domain/reference validation finish before [applyRestore] is
/// available. Writes and deletion run in Drift transactions, so an exception
/// leaves the previous local data intact.
final class DataPortabilityService implements DataPortability {
  const DataPortabilityService(this.database);

  static const format = 'freezer-map-backup';
  static const version = 1;

  final FreezerDatabase database;

  @override
  Future<String> createJsonBackup({required DateTime exportedAt}) =>
      database.transaction(() async {
        final appliances = await database.select(database.appliances).get();
        final zones = await database.select(database.zones).get();
        final items = await database.select(database.freezerItems).get();
        final events = await database.select(database.inventoryEvents).get();
        final reminders = await database.select(database.reminders).get();
        appliances.sort((left, right) => left.id.compareTo(right.id));
        zones.sort((left, right) => left.id.compareTo(right.id));
        items.sort((left, right) => left.id.compareTo(right.id));
        events.sort((left, right) => left.sequence.compareTo(right.sequence));
        reminders.sort((left, right) => left.id.compareTo(right.id));
        final envelope = <String, Object?>{
          'format': format,
          'version': version,
          'exportedAt': exportedAt.toUtc().toIso8601String(),
          'schema': <String, Object>{
            'application': 'freezer-map',
            'database': 1,
          },
          'data': <String, Object>{
            'appliances': [
              for (final row in appliances)
                {
                  'id': row.id,
                  'name': row.name,
                  'sortOrder': row.sortOrder,
                  'isArchived': row.isArchived,
                },
            ],
            'zones': [
              for (final row in zones)
                {
                  'id': row.id,
                  'applianceId': row.applianceId,
                  'parentId': row.parentId,
                  'name': row.name,
                  'sortOrder': row.sortOrder,
                  'isArchived': row.isArchived,
                },
            ],
            'items': [
              for (final row in items)
                {
                  'id': row.id,
                  'name': row.name,
                  'category': row.category,
                  'zoneId': row.zoneId,
                  'quantity': row.quantity,
                  'unit': row.unit,
                  'frozenOn': row.frozenOn?.toUtc().toIso8601String(),
                  'useFirstOn': row.useFirstOn?.toUtc().toIso8601String(),
                  'thawState': row.thawState,
                  'notes': row.notes,
                  'createdAt': row.createdAt.toUtc().toIso8601String(),
                  'updatedAt': row.updatedAt.toUtc().toIso8601String(),
                  'thawStateChangedAt': row.thawStateChangedAt
                      .toUtc()
                      .toIso8601String(),
                  'archivedAt': row.archivedAt?.toUtc().toIso8601String(),
                },
            ],
            'events': [
              for (final row in events)
                {
                  'id': row.id,
                  'itemId': row.itemId,
                  'action': row.action,
                  'beforeSummary': row.beforeSummary,
                  'afterSummary': row.afterSummary,
                  'occurredAt': row.occurredAt.toUtc().toIso8601String(),
                },
            ],
            'reminders': [
              for (final row in reminders)
                {
                  'id': row.id,
                  'itemId': row.itemId,
                  'scheduledFor': row.scheduledFor.toUtc().toIso8601String(),
                  'privacyMode': row.privacyMode,
                  'isEnabled': row.isEnabled,
                },
            ],
          },
        };
        return const JsonEncoder.withIndent('  ').convert(envelope);
      });

  @override
  Future<String> createCsvExport() => database.transaction(() async {
    final appliances = {
      for (final row in await database.select(database.appliances).get())
        row.id: row.name,
    };
    final zones = await database.select(database.zones).get();
    final zoneById = {for (final row in zones) row.id: row};
    final items = await database.select(database.freezerItems).get();
    items.sort((left, right) => left.id.compareTo(right.id));
    const columns = [
      'id',
      'name',
      'category',
      'quantity',
      'unit',
      'appliance',
      'zone_path',
      'frozen_on',
      'use_first_on',
      'thaw_state',
      'notes',
      'archived_at',
    ];
    final output = StringBuffer('${columns.join(',')}\r\n');
    for (final item in items) {
      final zone = zoneById[item.zoneId];
      final path = <String>[];
      var cursor = zone;
      final visited = <String>{};
      while (cursor != null && visited.add(cursor.id)) {
        path.insert(0, cursor.name);
        cursor = cursor.parentId == null ? null : zoneById[cursor.parentId];
      }
      final values = <Object?>[
        item.id,
        item.name,
        item.category,
        item.quantity,
        item.unit,
        zone == null ? '' : appliances[zone.applianceId] ?? '',
        path.join(' / '),
        _dateOnly(item.frozenOn),
        _dateOnly(item.useFirstOn),
        item.thawState,
        item.notes,
        item.archivedAt?.toUtc().toIso8601String(),
      ];
      output.write('${values.map(_csvCell).join(',')}\r\n');
    }
    return output.toString();
  });

  @override
  Future<PreparedRestore> prepareRestore(
    String source, {
    required RestoreMode mode,
  }) async {
    final document = _BackupDocument.parse(source);
    if (mode == RestoreMode.merge) {
      final collisions = await _collisions(document);
      if (collisions.isNotEmpty) {
        throw BackupValidationException(
          'Merge rejected stable-ID collisions: ${collisions.join(', ')}. '
          'Choose replace to restore a backup of this same inventory.',
        );
      }
    }
    return _PreparedRestore(
      document,
      RestoreSummary(
        mode: mode,
        appliances: document.appliances.length,
        zones: document.zones.length,
        items: document.items.length,
        events: document.events.length,
        reminders: document.reminders.length,
      ),
    );
  }

  @override
  Future<void> applyRestore(PreparedRestore restore) {
    if (restore is! _PreparedRestore) {
      throw ArgumentError.value(
        restore,
        'restore',
        'was not prepared by this adapter',
      );
    }
    return database.transaction(() async {
      await database.customStatement('PRAGMA defer_foreign_keys = ON');
      final document = restore._document;
      if (restore.summary.mode == RestoreMode.merge) {
        final collisions = await _collisions(document);
        if (collisions.isNotEmpty) {
          throw BackupValidationException(
            'Inventory changed after the dry run; colliding IDs: '
            '${collisions.join(', ')}.',
          );
        }
      } else {
        await _deleteAllRows();
      }
      for (final row in document.appliances) {
        await database.into(database.appliances).insert(row);
      }
      for (final row in document.zones) {
        await database.into(database.zones).insert(row);
      }
      for (final row in document.items) {
        await database.into(database.freezerItems).insert(row);
      }
      for (final row in document.events) {
        await database.into(database.inventoryEvents).insert(row);
      }
      for (final row in document.reminders) {
        await database.into(database.reminders).insert(row);
      }
    });
  }

  @override
  Future<void> deleteAllAndVerify() => database.transaction(() async {
    await _deleteAllRows();
    final remaining = await Future.wait<int>([
      database.appliances.count().getSingle(),
      database.zones.count().getSingle(),
      database.freezerItems.count().getSingle(),
      database.inventoryEvents.count().getSingle(),
      database.reminders.count().getSingle(),
    ]);
    if (remaining.any((count) => count != 0)) {
      throw StateError(
        'Delete all could not verify that local data was removed.',
      );
    }
  });

  Future<void> _deleteAllRows() async {
    // Zones self-reference with RESTRICT. Deferral permits one atomic wipe while
    // preserving foreign-key enforcement at the transaction boundary.
    await database.customStatement('PRAGMA defer_foreign_keys = ON');
    await database.delete(database.reminders).go();
    await database.delete(database.inventoryEvents).go();
    await database.delete(database.freezerItems).go();
    await database.delete(database.zones).go();
    await database.delete(database.appliances).go();
  }

  Future<List<String>> _collisions(_BackupDocument document) async {
    final collisions = <String>[];
    Future<void> collect(
      String kind,
      List<String> incoming,
      List<String> current,
    ) async {
      final existing = current.toSet();
      collisions.addAll(
        incoming.where(existing.contains).map((id) => '$kind:$id'),
      );
    }

    await collect(
      'appliance',
      document.appliances.map((row) => row.id).toList(),
      (await database.select(database.appliances).get())
          .map((row) => row.id)
          .toList(),
    );
    await collect(
      'zone',
      document.zones.map((row) => row.id).toList(),
      (await database.select(database.zones).get())
          .map((row) => row.id)
          .toList(),
    );
    await collect(
      'item',
      document.items.map((row) => row.id).toList(),
      (await database.select(database.freezerItems).get())
          .map((row) => row.id)
          .toList(),
    );
    await collect(
      'event',
      document.events.map((row) => row.id.value).toList(),
      (await database.select(database.inventoryEvents).get())
          .map((row) => row.id)
          .toList(),
    );
    await collect(
      'reminder',
      document.reminders.map((row) => row.id).toList(),
      (await database.select(database.reminders).get())
          .map((row) => row.id)
          .toList(),
    );
    return collisions;
  }
}

final class _BackupDocument {
  const _BackupDocument({
    required this.appliances,
    required this.zones,
    required this.items,
    required this.events,
    required this.reminders,
  });

  final List<ApplianceRow> appliances;
  final List<ZoneRow> zones;
  final List<FreezerItemRow> items;
  final List<InventoryEventsCompanion> events;
  final List<ReminderRow> reminders;

  static _BackupDocument parse(String source) {
    try {
      final decoded = jsonDecode(source);
      final root = _map(decoded, 'backup');
      if (_string(root, 'format') != DataPortabilityService.format) {
        throw const BackupValidationException('Not a Freezer Map backup.');
      }
      final version = _integer(root, 'version');
      if (version != DataPortabilityService.version) {
        throw BackupValidationException(
          'Unsupported backup version $version; this app supports version 1.',
        );
      }
      _timestamp(root['exportedAt'], 'exportedAt');
      final schema = _map(root['schema'], 'schema');
      if (_string(schema, 'application') != 'freezer-map' ||
          _integer(schema, 'database') != 1) {
        throw const BackupValidationException(
          'Unsupported backup schema metadata.',
        );
      }
      final data = _map(root['data'], 'data');
      final appliances = <ApplianceRow>[];
      final applianceIds = <String>{};
      final applianceById = <String, Appliance>{};
      for (final entry in _list(data, 'appliances')) {
        final row = _map(entry, 'appliance');
        final appliance = Appliance(
          id: ApplianceId(_string(row, 'id')),
          name: _string(row, 'name'),
          sortOrder: _integer(row, 'sortOrder'),
          isArchived: _boolean(row, 'isArchived'),
        );
        _unique(applianceIds, appliance.id.value, 'appliance');
        applianceById[appliance.id.value] = appliance;
        appliances.add(
          ApplianceRow(
            id: appliance.id.value,
            name: appliance.name,
            sortOrder: appliance.sortOrder,
            isArchived: appliance.isArchived,
          ),
        );
      }

      final zones = <ZoneRow>[];
      final domainZones = <Zone>[];
      final zoneIds = <String>{};
      for (final entry in _list(data, 'zones')) {
        final row = _map(entry, 'zone');
        final applianceId = _string(row, 'applianceId');
        if (!applianceIds.contains(applianceId)) {
          throw BackupValidationException(
            'Zone ${row['id']} has dangling applianceId $applianceId.',
          );
        }
        final parent = _nullableString(row, 'parentId');
        final zone = Zone(
          id: ZoneId(_string(row, 'id')),
          applianceId: ApplianceId(applianceId),
          parentId: parent == null ? null : ZoneId(parent),
          name: _string(row, 'name'),
          sortOrder: _integer(row, 'sortOrder'),
          isArchived: _boolean(row, 'isArchived'),
        );
        _unique(zoneIds, zone.id.value, 'zone');
        domainZones.add(zone);
        zones.add(
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
      for (final zone in domainZones) {
        final parentId = zone.parentId;
        if (parentId != null && !zoneIds.contains(parentId.value)) {
          throw BackupValidationException(
            'Zone ${zone.id.value} has dangling parentId ${parentId.value}.',
          );
        }
        if (parentId != null &&
            domainZones
                    .firstWhere((candidate) => candidate.id == parentId)
                    .applianceId !=
                zone.applianceId) {
          throw BackupValidationException(
            'Zone ${zone.id.value} has a parent in another appliance.',
          );
        }
      }
      ZoneForest.validate(domainZones);
      final domainZoneById = {
        for (final zone in domainZones) zone.id.value: zone,
      };
      for (final zone in domainZones) {
        final appliance = applianceById[zone.applianceId.value]!;
        final parent = zone.parentId == null
            ? null
            : domainZoneById[zone.parentId!.value];
        if (!zone.isArchived &&
            (appliance.isArchived || parent?.isArchived == true)) {
          throw BackupValidationException(
            'Active zone ${zone.id.value} requires active parent locations.',
          );
        }
      }

      final items = <FreezerItemRow>[];
      final itemIds = <String>{};
      for (final entry in _list(data, 'items')) {
        final row = _map(entry, 'item');
        final zoneId = _string(row, 'zoneId');
        if (!zoneIds.contains(zoneId)) {
          throw BackupValidationException(
            'Item ${row['id']} has dangling zoneId $zoneId.',
          );
        }
        final frozenOn = _nullableTimestamp(row['frozenOn'], 'frozenOn');
        final useFirstOn = _nullableTimestamp(row['useFirstOn'], 'useFirstOn');
        final item = FreezerItem.rehydrate(
          id: ItemId(_string(row, 'id')),
          name: _string(row, 'name'),
          category: _string(row, 'category'),
          zoneId: ZoneId(zoneId),
          quantity: PortionQuantity.parse(_string(row, 'quantity')),
          unit: PortionUnit(_string(row, 'unit')),
          frozenOn: frozenOn == null
              ? const PlanningDate.unknown()
              : PlanningDate.known(frozenOn),
          useFirstOn: useFirstOn == null
              ? const PlanningDate.unknown()
              : PlanningDate.known(useFirstOn),
          thawState: ThawState.values.byName(_string(row, 'thawState')),
          notes: _string(row, 'notes'),
          createdAt: _timestamp(row['createdAt'], 'createdAt'),
          updatedAt: _timestamp(row['updatedAt'], 'updatedAt'),
          thawStateChangedAt: _timestamp(
            row['thawStateChangedAt'],
            'thawStateChangedAt',
          ),
          archivedAt: _nullableTimestamp(row['archivedAt'], 'archivedAt'),
        );
        _unique(itemIds, item.id.value, 'item');
        final itemZone = domainZoneById[item.zoneId.value]!;
        if (!item.isArchived &&
            (itemZone.isArchived ||
                applianceById[itemZone.applianceId.value]!.isArchived)) {
          throw BackupValidationException(
            'Active item ${item.id.value} requires an active zone and appliance.',
          );
        }
        items.add(
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

      final events = <InventoryEventsCompanion>[];
      final eventIds = <String>{};
      for (final entry in _list(data, 'events')) {
        final row = _map(entry, 'event');
        final itemId = _string(row, 'itemId');
        if (!itemIds.contains(itemId)) {
          throw BackupValidationException(
            'Event ${row['id']} has dangling itemId $itemId.',
          );
        }
        final event = InventoryEvent(
          id: InventoryEventId(_string(row, 'id')),
          itemId: ItemId(itemId),
          action: InventoryAction.values.byName(_string(row, 'action')),
          beforeSummary: _string(row, 'beforeSummary'),
          afterSummary: _string(row, 'afterSummary'),
          occurredAt: _timestamp(row['occurredAt'], 'occurredAt'),
        );
        _unique(eventIds, event.id.value, 'event');
        events.add(
          InventoryEventsCompanion.insert(
            id: event.id.value,
            itemId: event.itemId.value,
            action: event.action.name,
            beforeSummary: event.beforeSummary,
            afterSummary: event.afterSummary,
            occurredAt: event.occurredAt,
          ),
        );
      }

      final reminders = <ReminderRow>[];
      final reminderIds = <String>{};
      for (final entry in _list(data, 'reminders')) {
        final row = _map(entry, 'reminder');
        final itemId = _string(row, 'itemId');
        if (!itemIds.contains(itemId)) {
          throw BackupValidationException(
            'Reminder ${row['id']} has dangling itemId $itemId.',
          );
        }
        final reminder = Reminder(
          id: ReminderId(_string(row, 'id')),
          itemId: ItemId(itemId),
          scheduledFor: _timestamp(row['scheduledFor'], 'scheduledFor'),
          privacyMode: ReminderPrivacyMode.values.byName(
            _string(row, 'privacyMode'),
          ),
          isEnabled: _boolean(row, 'isEnabled'),
        );
        _unique(reminderIds, reminder.id.value, 'reminder');
        reminders.add(
          ReminderRow(
            id: reminder.id.value,
            itemId: reminder.itemId.value,
            scheduledFor: reminder.scheduledFor,
            privacyMode: reminder.privacyMode.name,
            isEnabled: reminder.isEnabled,
          ),
        );
      }
      return _BackupDocument(
        appliances: appliances,
        zones: zones,
        items: items,
        events: events,
        reminders: reminders,
      );
    } on BackupValidationException {
      rethrow;
    } on FormatException catch (error) {
      throw BackupValidationException('Malformed backup: ${error.message}');
    } on ArgumentError catch (error) {
      throw BackupValidationException('Invalid backup value: ${error.message}');
    } catch (error) {
      throw BackupValidationException('Invalid backup: $error');
    }
  }
}

Map<String, Object?> _map(Object? value, String field) {
  if (value is! Map<String, Object?>) {
    throw BackupValidationException('$field must be a JSON object.');
  }
  return value;
}

List<Object?> _list(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! List<Object?>) {
    throw BackupValidationException('$key must be a JSON array.');
  }
  return value;
}

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String) {
    throw BackupValidationException('$key must be a string.');
  }
  return value;
}

String? _nullableString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is! String) {
    throw BackupValidationException('$key must be a string or null.');
  }
  return value;
}

int _integer(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! int) {
    throw BackupValidationException('$key must be an integer.');
  }
  return value;
}

bool _boolean(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! bool) {
    throw BackupValidationException('$key must be a boolean.');
  }
  return value;
}

DateTime _timestamp(Object? value, String field) {
  if (value is! String) {
    throw BackupValidationException('$field must be an ISO-8601 timestamp.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !value.endsWith('Z')) {
    throw BackupValidationException('$field must be a UTC ISO-8601 timestamp.');
  }
  return parsed.toUtc();
}

DateTime? _nullableTimestamp(Object? value, String field) =>
    value == null ? null : _timestamp(value, field);

void _unique(Set<String> ids, String id, String kind) {
  if (!ids.add(id)) {
    throw BackupValidationException('Duplicate $kind ID $id.');
  }
}

String _csvCell(Object? value) {
  final text = value?.toString() ?? '';
  return '"${text.replaceAll('"', '""')}"';
}

String _dateOnly(DateTime? value) => value?.toUtc().toIso8601String() ?? '';
