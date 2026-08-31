import 'package:drift/drift.dart';
import 'package:freezer_map/data/migrations.dart';

part 'database.g.dart';

@DataClassName('ApplianceRow')
class Appliances extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ZoneRow')
@TableIndex(
  name: 'zones_appliance_parent_idx',
  columns: {#applianceId, #parentId, #isArchived},
)
class Zones extends Table {
  TextColumn get id => text()();
  TextColumn get applianceId => text().references(
    Appliances,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get parentId => text().nullable().references(
    Zones,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {id, applianceId},
  ];
}

@DataClassName('FreezerItemRow')
@TableIndex(
  name: 'freezer_items_zone_archived_idx',
  columns: {#zoneId, #archivedAt},
)
@TableIndex(
  name: 'freezer_items_use_first_idx',
  columns: {#archivedAt, #useFirstOn},
)
class FreezerItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get zoneId => text().references(
    Zones,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  DateTimeColumn get frozenOn => dateTime().nullable()();
  DateTimeColumn get useFirstOn => dateTime().nullable()();
  TextColumn get thawState => text()();
  TextColumn get notes => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get thawStateChangedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InventoryEventRow')
@TableIndex(
  name: 'inventory_events_item_time_idx',
  columns: {#itemId, #occurredAt, #id},
)
class InventoryEvents extends Table {
  IntColumn get sequence => integer().autoIncrement()();
  TextColumn get id => text().unique()();
  TextColumn get itemId => text().references(
    FreezerItems,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get action => text()();
  TextColumn get beforeSummary => text()();
  TextColumn get afterSummary => text()();
  DateTimeColumn get occurredAt => dateTime()();
}

@DataClassName('ReminderRow')
@TableIndex(
  name: 'reminders_item_enabled_idx',
  columns: {#itemId, #isEnabled, #scheduledFor},
)
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(
    FreezerItems,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  DateTimeColumn get scheduledFor => dateTime()();
  TextColumn get privacyMode => text()();
  BoolColumn get isEnabled => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Appliances, Zones, FreezerItems, InventoryEvents, Reminders],
)
class FreezerDatabase extends _$FreezerDatabase {
  FreezerDatabase(super.executor);

  FreezerDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => freezerMigration(this);
}
