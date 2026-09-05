import 'dart:async';

import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

enum ReminderPermissionStatus { granted, denied, restricted, unknown }

enum ReminderSaveOutcome {
  scheduled,
  disabled,
  permissionDenied,
  archivedItem,
  invalidSchedule,
  missingItem,
}

final class ReminderSaveResult {
  const ReminderSaveResult({
    required this.outcome,
    required this.message,
    this.reminder,
  });

  final ReminderSaveOutcome outcome;
  final String message;
  final Reminder? reminder;

  bool get isSuccess =>
      outcome == ReminderSaveOutcome.scheduled ||
      outcome == ReminderSaveOutcome.disabled;
}

final class ReminderNotificationRequest {
  const ReminderNotificationRequest({
    required this.reminderId,
    required this.itemId,
    required this.title,
    required this.body,
    required this.scheduledForUtc,
  });

  final ReminderId reminderId;
  final ItemId itemId;
  final String title;
  final String body;
  final DateTime scheduledForUtc;
}

final class ReminderTapEvent {
  const ReminderTapEvent({required this.reminderId, required this.itemId});

  final ReminderId reminderId;
  final ItemId itemId;
}

abstract interface class ReminderNotificationGateway {
  Future<void> initialize();
  Future<ReminderPermissionStatus> permissionStatus();
  Future<ReminderPermissionStatus> requestPermission();
  Future<void> scheduleReminder(ReminderNotificationRequest request);
  Future<void> cancelReminder(ReminderId reminderId);
  Stream<ReminderTapEvent> tapEvents();
}

final class ReminderReconcileResult {
  const ReminderReconcileResult({
    required this.scheduledCount,
    required this.cancelledCount,
    required this.disabledCount,
    required this.warnings,
  });

  final int scheduledCount;
  final int cancelledCount;
  final int disabledCount;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}

final class ReminderManager {
  ReminderManager({
    required this.repository,
    required this.clock,
    required this.ids,
    required this.gateway,
  });

  final TransactionalInventoryRepository repository;
  final Clock clock;
  final StableIdSource ids;
  final ReminderNotificationGateway gateway;

  Future<void> initialize() => gateway.initialize();

  Stream<ReminderTapEvent> tapEvents() => gateway.tapEvents();

  Future<Reminder?> reminderForItem(ItemId itemId) async {
    final reminders = await repository.remindersFor(itemId);
    for (final reminder in reminders) {
      if (reminder.isEnabled) return reminder;
    }
    return reminders.isEmpty ? null : reminders.first;
  }

  Future<ReminderSaveResult> saveReminder({
    required ItemId itemId,
    required DateTime scheduledForLocal,
    required ReminderPrivacyMode privacyMode,
    required bool isEnabled,
  }) async {
    final item = await repository.itemById(itemId);
    if (item == null) {
      return const ReminderSaveResult(
        outcome: ReminderSaveOutcome.missingItem,
        message: 'Item no longer exists. Reminder was not changed.',
      );
    }

    final reminders = await repository.remindersFor(itemId);

    if (!isEnabled) {
      await _disableAll(reminders);
      return const ReminderSaveResult(
        outcome: ReminderSaveOutcome.disabled,
        message: 'Reminder disabled.',
      );
    }

    if (item.isArchived) {
      return const ReminderSaveResult(
        outcome: ReminderSaveOutcome.archivedItem,
        message: 'Archived items cannot have active reminders.',
      );
    }

    final nowLocal = clock.nowUtc().toLocal();
    if (!scheduledForLocal.isAfter(nowLocal)) {
      return const ReminderSaveResult(
        outcome: ReminderSaveOutcome.invalidSchedule,
        message: 'Choose a future date and time for this reminder.',
      );
    }

    final permission = await _ensurePermission();
    if (permission != ReminderPermissionStatus.granted) {
      return const ReminderSaveResult(
        outcome: ReminderSaveOutcome.permissionDenied,
        message:
            'Notification permission is disabled. Reminder was not enabled.',
      );
    }

    final keep = _primary(reminders);
    final reminder = Reminder(
      id: keep?.id ?? ReminderId(ids.next()),
      itemId: item.id,
      scheduledFor: scheduledForLocal.toUtc(),
      privacyMode: privacyMode,
      isEnabled: true,
    );

    await repository.saveReminder(reminder);
    await _disableDuplicates(reminders, keepId: reminder.id);
    await _schedule(item, reminder);

    return ReminderSaveResult(
      outcome: ReminderSaveOutcome.scheduled,
      message: 'Reminder scheduled.',
      reminder: reminder,
    );
  }

  Future<ReminderReconcileResult> reconcileAll() async {
    final items = await repository.items(includeArchived: true);
    final permission = await gateway.permissionStatus();
    var scheduledCount = 0;
    var cancelledCount = 0;
    var disabledCount = 0;
    final warnings = <String>[];

    for (final item in items) {
      final reminders = await repository.remindersFor(item.id);
      if (reminders.isEmpty) continue;

      final enabled = reminders.where((value) => value.isEnabled).toList();
      if (enabled.isEmpty) continue;

      final keep = enabled.first;
      for (final duplicate in enabled.skip(1)) {
        await repository.saveReminder(
          _withEnabled(duplicate, isEnabled: false),
        );
        await gateway.cancelReminder(duplicate.id);
        cancelledCount += 1;
        disabledCount += 1;
        warnings.add(
          'Duplicate reminder for ${item.name} was disabled to keep a '
          'single stable reminder ID.',
        );
      }

      if (item.isArchived) {
        await repository.saveReminder(_withEnabled(keep, isEnabled: false));
        await gateway.cancelReminder(keep.id);
        cancelledCount += 1;
        disabledCount += 1;
        warnings.add('Reminder for archived item ${item.name} was disabled.');
        continue;
      }

      if (permission != ReminderPermissionStatus.granted) {
        await gateway.cancelReminder(keep.id);
        cancelledCount += 1;
        continue;
      }

      await _schedule(item, keep);
      scheduledCount += 1;
    }

    if (permission != ReminderPermissionStatus.granted) {
      warnings.add(
        'Notification permission is not granted. Reminders remain in your '
        'local data and will resume when permission is re-enabled.',
      );
    }

    return ReminderReconcileResult(
      scheduledCount: scheduledCount,
      cancelledCount: cancelledCount,
      disabledCount: disabledCount,
      warnings: warnings,
    );
  }

  Future<void> _schedule(FreezerItem item, Reminder reminder) {
    final itemNameMode = reminder.privacyMode == ReminderPrivacyMode.itemName;
    final title = itemNameMode ? 'Reminder: ${item.name}' : 'Freezer reminder';
    final body = itemNameMode
        ? 'Check your planning date for ${item.name}.'
        : 'Check your freezer planning list.';
    return gateway.scheduleReminder(
      ReminderNotificationRequest(
        reminderId: reminder.id,
        itemId: item.id,
        title: title,
        body: body,
        scheduledForUtc: reminder.scheduledFor,
      ),
    );
  }

  Future<void> _disableAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      if (!reminder.isEnabled) continue;
      await repository.saveReminder(_withEnabled(reminder, isEnabled: false));
      await gateway.cancelReminder(reminder.id);
    }
  }

  Future<void> _disableDuplicates(
    List<Reminder> reminders, {
    required ReminderId keepId,
  }) async {
    for (final reminder in reminders) {
      if (reminder.id == keepId) continue;
      if (!reminder.isEnabled) continue;
      await repository.saveReminder(_withEnabled(reminder, isEnabled: false));
      await gateway.cancelReminder(reminder.id);
    }
  }

  Reminder? _primary(List<Reminder> reminders) {
    for (final reminder in reminders) {
      if (reminder.isEnabled) return reminder;
    }
    return reminders.isEmpty ? null : reminders.first;
  }

  Future<ReminderPermissionStatus> _ensurePermission() async {
    final current = await gateway.permissionStatus();
    if (current == ReminderPermissionStatus.granted) return current;
    return gateway.requestPermission();
  }
}

Reminder _withEnabled(Reminder reminder, {required bool isEnabled}) => Reminder(
  id: reminder.id,
  itemId: reminder.itemId,
  scheduledFor: reminder.scheduledFor,
  privacyMode: reminder.privacyMode,
  isEnabled: isEnabled,
);

final class UnsupportedReminderNotificationGateway
    implements ReminderNotificationGateway {
  const UnsupportedReminderNotificationGateway();

  @override
  Future<void> cancelReminder(ReminderId reminderId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<ReminderPermissionStatus> permissionStatus() async =>
      ReminderPermissionStatus.denied;

  @override
  Future<ReminderPermissionStatus> requestPermission() async =>
      ReminderPermissionStatus.denied;

  @override
  Future<void> scheduleReminder(ReminderNotificationRequest request) async {}

  @override
  Stream<ReminderTapEvent> tapEvents() =>
      const Stream<ReminderTapEvent>.empty();
}
