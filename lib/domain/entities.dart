import 'package:freezer_map/domain/value_objects.dart';

enum ThawState { frozen, thawing }

enum InventoryAction {
  create,
  edit,
  increment,
  decrement,
  move,
  markThawing,
  returnToFrozen,
  archive,
  undo,
}

enum ReminderPrivacyMode { itemName, generic }

final class Appliance {
  Appliance({
    required this.id,
    required String name,
    required this.sortOrder,
    this.isArchived = false,
  }) : name = _requiredText(name, 'name') {
    if (sortOrder < 0) {
      throw const DomainValidationException('Sort order cannot be negative.');
    }
  }

  final ApplianceId id;
  final String name;
  final int sortOrder;
  final bool isArchived;
}

final class Zone {
  Zone({
    required this.id,
    required this.applianceId,
    required String name,
    required this.sortOrder,
    this.parentId,
    this.isArchived = false,
  }) : name = _requiredText(name, 'name') {
    if (sortOrder < 0) {
      throw const DomainValidationException('Sort order cannot be negative.');
    }
    if (parentId == id) {
      throw const DomainValidationException('A zone cannot be its own parent.');
    }
  }

  final ZoneId id;
  final ApplianceId applianceId;
  final ZoneId? parentId;
  final String name;
  final int sortOrder;
  final bool isArchived;
}

final class FreezerItem {
  FreezerItem._({
    required this.id,
    required this.name,
    required this.category,
    required this.zoneId,
    required this.quantity,
    required this.unit,
    required this.frozenOn,
    required this.useFirstOn,
    required this.thawState,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.thawStateChangedAt,
    required this.archivedAt,
  });

  factory FreezerItem.create({
    required ItemId id,
    required String name,
    required String category,
    required ZoneId zoneId,
    required PortionQuantity quantity,
    required PortionUnit unit,
    required PlanningDate frozenOn,
    required PlanningDate useFirstOn,
    required String notes,
    required DateTime now,
  }) => FreezerItem._(
    id: id,
    name: _requiredText(name, 'name'),
    category: category.trim(),
    zoneId: zoneId,
    quantity: quantity.requirePositive(),
    unit: unit,
    frozenOn: frozenOn,
    useFirstOn: useFirstOn,
    thawState: ThawState.frozen,
    notes: notes.trim(),
    createdAt: now.toUtc(),
    updatedAt: now.toUtc(),
    thawStateChangedAt: now.toUtc(),
    archivedAt: null,
  );

  factory FreezerItem.rehydrate({
    required ItemId id,
    required String name,
    required String category,
    required ZoneId zoneId,
    required PortionQuantity quantity,
    required PortionUnit unit,
    required PlanningDate frozenOn,
    required PlanningDate useFirstOn,
    required ThawState thawState,
    required String notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime thawStateChangedAt,
    required DateTime? archivedAt,
  }) {
    if (quantity.isZero && archivedAt == null) {
      throw const DomainValidationException(
        'An active inventory item cannot have zero quantity.',
      );
    }
    if (updatedAt.toUtc().isBefore(createdAt.toUtc())) {
      throw const DomainValidationException(
        'Updated time cannot be before created time.',
      );
    }
    return FreezerItem._(
      id: id,
      name: _requiredText(name, 'name'),
      category: category.trim(),
      zoneId: zoneId,
      quantity: quantity,
      unit: unit,
      frozenOn: frozenOn,
      useFirstOn: useFirstOn,
      thawState: thawState,
      notes: notes.trim(),
      createdAt: createdAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
      thawStateChangedAt: thawStateChangedAt.toUtc(),
      archivedAt: archivedAt?.toUtc(),
    );
  }

  final ItemId id;
  final String name;
  final String category;
  final ZoneId zoneId;
  final PortionQuantity quantity;
  final PortionUnit unit;
  final PlanningDate frozenOn;
  final PlanningDate useFirstOn;
  final ThawState thawState;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime thawStateChangedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

final class InventoryEvent {
  InventoryEvent({
    required this.id,
    required this.itemId,
    required this.action,
    required this.beforeSummary,
    required this.afterSummary,
    required DateTime occurredAt,
  }) : occurredAt = occurredAt.toUtc();

  final InventoryEventId id;
  final ItemId itemId;
  final InventoryAction action;
  final String beforeSummary;
  final String afterSummary;
  final DateTime occurredAt;
}

final class Reminder {
  Reminder({
    required this.id,
    required this.itemId,
    required DateTime scheduledFor,
    required this.privacyMode,
    required this.isEnabled,
  }) : scheduledFor = scheduledFor.toUtc();

  final ReminderId id;
  final ItemId itemId;
  final DateTime scheduledFor;
  final ReminderPrivacyMode privacyMode;
  final bool isEnabled;
}

String _requiredText(String value, String field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw DomainValidationException('$field cannot be blank.');
  }
  return normalized;
}
