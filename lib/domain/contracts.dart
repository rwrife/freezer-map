import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

abstract interface class Clock {
  DateTime nowUtc();
}

abstract interface class StableIdSource {
  String next();
}

abstract interface class ApplianceRepository {
  Future<Appliance?> applianceById(ApplianceId id);
  Future<List<Appliance>> appliances({bool includeArchived = false});
  Future<void> saveAppliance(Appliance appliance);
}

abstract interface class ZoneRepository {
  Future<Zone?> zoneById(ZoneId id);
  Future<List<Zone>> zones({bool includeArchived = false});
  Future<void> saveZone(Zone zone);
}

abstract interface class ItemRepository {
  Future<FreezerItem?> itemById(ItemId id);
  Future<List<FreezerItem>> items({bool includeArchived = false});
  Future<void> saveItem(FreezerItem item);
}

abstract interface class InventoryEventRepository {
  Future<List<InventoryEvent>> eventsFor(ItemId itemId);
  Future<void> appendEvent(InventoryEvent event);
}

abstract interface class ReminderRepository {
  Future<Reminder?> reminderById(ReminderId id);
  Future<List<Reminder>> remindersFor(ItemId itemId);
  Future<void> saveReminder(Reminder reminder);
}

abstract interface class InventoryRepositories
    implements
        ApplianceRepository,
        ZoneRepository,
        ItemRepository,
        InventoryEventRepository,
        ReminderRepository {}

abstract interface class TransactionalInventoryRepository
    implements InventoryRepositories {
  Future<T> transaction<T>(
    Future<T> Function(InventoryRepositories repositories) action,
  );
}
