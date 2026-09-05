import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/reminders.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  late FreezerDatabase database;
  late DriftInventoryRepository repository;
  late ReminderManager manager;
  late _Clock clock;
  late _Ids ids;
  late _Gateway gateway;

  setUp(() async {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
    clock = _Clock(DateTime.utc(2026, 9, 5, 10));
    ids = _Ids();
    gateway = _Gateway();
    manager = ReminderManager(
      repository: repository,
      clock: clock,
      ids: ids,
      gateway: gateway,
    );

    await _seedInventory(repository, clock.nowUtc());
  });

  tearDown(() => database.close());

  test('requests permission only when user enables a reminder', () async {
    gateway.permissionStatusValue = ReminderPermissionStatus.denied;
    gateway.permissionRequestValue = ReminderPermissionStatus.denied;

    final blocked = await manager.saveReminder(
      itemId: ItemId('item-1'),
      scheduledForLocal: DateTime(2026, 9, 6, 9),
      privacyMode: ReminderPrivacyMode.generic,
      isEnabled: true,
    );

    expect(blocked.outcome, ReminderSaveOutcome.permissionDenied);
    expect(gateway.permissionRequestCount, 1);

    await repository.saveReminder(
      Reminder(
        id: ReminderId('r-keep'),
        itemId: ItemId('item-1'),
        scheduledFor: DateTime.utc(2026, 9, 6, 9),
        privacyMode: ReminderPrivacyMode.itemName,
        isEnabled: true,
      ),
    );

    await manager.saveReminder(
      itemId: ItemId('item-1'),
      scheduledForLocal: DateTime(2026, 9, 6, 9),
      privacyMode: ReminderPrivacyMode.generic,
      isEnabled: false,
    );

    expect(gateway.permissionRequestCount, 1);
  });

  test('generic privacy mode keeps notification text item-neutral', () async {
    gateway.permissionStatusValue = ReminderPermissionStatus.granted;

    final result = await manager.saveReminder(
      itemId: ItemId('item-1'),
      scheduledForLocal: DateTime(2026, 9, 6, 8, 30),
      privacyMode: ReminderPrivacyMode.generic,
      isEnabled: true,
    );

    expect(result.outcome, ReminderSaveOutcome.scheduled);
    expect(gateway.scheduled.single.title, 'Freezer reminder');
    expect(gateway.scheduled.single.body, isNot(contains('Soup')));
    expect(gateway.scheduled.single.title, isNot(contains('Soup')));
  });

  test('reconcile disables reminders for archived items', () async {
    gateway.permissionStatusValue = ReminderPermissionStatus.granted;

    await repository.saveReminder(
      Reminder(
        id: ReminderId('r-1'),
        itemId: ItemId('item-1'),
        scheduledFor: DateTime.utc(2026, 9, 6, 8),
        privacyMode: ReminderPrivacyMode.itemName,
        isEnabled: true,
      ),
    );

    final existing = (await repository.itemById(ItemId('item-1')))!;
    await repository.saveItem(_archive(existing, clock.nowUtc()));

    final report = await manager.reconcileAll();
    final reminder = (await repository.remindersFor(ItemId('item-1'))).single;

    expect(report.disabledCount, 1);
    expect(reminder.isEnabled, isFalse);
    expect(gateway.cancelled, contains(ReminderId('r-1')));
  });

  test('reconcile cancels delivery when permission is revoked', () async {
    gateway.permissionStatusValue = ReminderPermissionStatus.denied;

    await repository.saveReminder(
      Reminder(
        id: ReminderId('r-1'),
        itemId: ItemId('item-1'),
        scheduledFor: DateTime.utc(2026, 9, 6, 8),
        privacyMode: ReminderPrivacyMode.itemName,
        isEnabled: true,
      ),
    );

    final report = await manager.reconcileAll();

    expect(report.scheduledCount, 0);
    expect(report.cancelledCount, 1);
    expect(report.warnings.single, contains('permission is not granted'));
    expect(
      (await repository.remindersFor(ItemId('item-1'))).single.isEnabled,
      isTrue,
    );
  });

  test(
    'reconcile keeps one stable reminder id when duplicates exist',
    () async {
      gateway.permissionStatusValue = ReminderPermissionStatus.granted;

      await repository.saveReminder(
        Reminder(
          id: ReminderId('r-1'),
          itemId: ItemId('item-1'),
          scheduledFor: DateTime.utc(2026, 9, 6, 8),
          privacyMode: ReminderPrivacyMode.itemName,
          isEnabled: true,
        ),
      );
      await repository.saveReminder(
        Reminder(
          id: ReminderId('r-2'),
          itemId: ItemId('item-1'),
          scheduledFor: DateTime.utc(2026, 9, 7, 8),
          privacyMode: ReminderPrivacyMode.generic,
          isEnabled: true,
        ),
      );

      final report = await manager.reconcileAll();
      final reminders = await repository.remindersFor(ItemId('item-1'));

      expect(report.disabledCount, 1);
      expect(gateway.cancelled, contains(ReminderId('r-2')));
      expect(
        reminders.where((value) => value.isEnabled).single.id,
        ReminderId('r-1'),
      );
      expect(gateway.scheduled.single.reminderId, ReminderId('r-1'));
    },
  );
}

Future<void> _seedInventory(
  DriftInventoryRepository repository,
  DateTime now,
) async {
  await repository.saveAppliance(
    Appliance(id: ApplianceId('app-1'), name: 'Garage', sortOrder: 0),
  );
  await repository.saveZone(
    Zone(
      id: ZoneId('zone-1'),
      applianceId: ApplianceId('app-1'),
      name: 'Top Drawer',
      sortOrder: 0,
    ),
  );
  await repository.saveItem(
    FreezerItem.create(
      id: ItemId('item-1'),
      name: 'Soup',
      category: 'Meals',
      zoneId: ZoneId('zone-1'),
      quantity: PortionQuantity.parse('2'),
      unit: PortionUnit('portion'),
      frozenOn: const PlanningDate.unknown(),
      useFirstOn: const PlanningDate.unknown(),
      notes: '',
      now: now,
    ),
  );
}

FreezerItem _archive(FreezerItem value, DateTime nowUtc) =>
    FreezerItem.rehydrate(
      id: value.id,
      name: value.name,
      category: value.category,
      zoneId: value.zoneId,
      quantity: value.quantity,
      unit: value.unit,
      frozenOn: value.frozenOn,
      useFirstOn: value.useFirstOn,
      thawState: value.thawState,
      notes: value.notes,
      createdAt: value.createdAt,
      updatedAt: nowUtc,
      thawStateChangedAt: value.thawStateChangedAt,
      archivedAt: nowUtc,
    );

final class _Clock implements Clock {
  _Clock(this.value);

  DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _Ids implements StableIdSource {
  var _count = 0;

  @override
  String next() => 'id-${++_count}';
}

final class _Gateway implements ReminderNotificationGateway {
  final StreamController<ReminderTapEvent> _tapEvents =
      StreamController<ReminderTapEvent>.broadcast();
  ReminderPermissionStatus permissionStatusValue =
      ReminderPermissionStatus.unknown;
  ReminderPermissionStatus permissionRequestValue =
      ReminderPermissionStatus.granted;
  int permissionRequestCount = 0;
  final List<ReminderNotificationRequest> scheduled =
      <ReminderNotificationRequest>[];
  final List<ReminderId> cancelled = <ReminderId>[];

  @override
  Future<void> cancelReminder(ReminderId reminderId) async {
    cancelled.add(reminderId);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<ReminderPermissionStatus> permissionStatus() async =>
      permissionStatusValue;

  @override
  Future<ReminderPermissionStatus> requestPermission() async {
    permissionRequestCount += 1;
    return permissionRequestValue;
  }

  @override
  Future<void> scheduleReminder(ReminderNotificationRequest request) async {
    scheduled.add(request);
  }

  @override
  Stream<ReminderTapEvent> tapEvents() => _tapEvents.stream;
}
