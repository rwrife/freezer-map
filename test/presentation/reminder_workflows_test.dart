import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:freezer_map/presentation/reminder_dialog.dart';

void main() {
  testWidgets('dialog shows validation for past reminder schedules', (
    tester,
  ) async {
    final nowLocal = DateTime(2026, 9, 5, 12);
    final item = _item(nowLocal.toUtc());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => ReminderDialog(
                      item: item,
                      nowLocal: nowLocal,
                      initial: Reminder(
                        id: ReminderId('r-1'),
                        itemId: item.id,
                        scheduledFor: nowLocal.subtract(
                          const Duration(hours: 1),
                        ),
                        privacyMode: ReminderPrivacyMode.generic,
                        isEnabled: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open reminder dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open reminder dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reminder-save-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reminder-dialog-error')), findsOneWidget);
    expect(find.textContaining('future local date and time'), findsOneWidget);
  });

  testWidgets(
    'dialog controls remain visible at 200% text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final nowLocal = DateTime(2026, 9, 5, 12);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => ReminderDialog(
                          item: _item(nowLocal.toUtc()),
                          nowLocal: nowLocal,
                          initial: Reminder(
                            id: ReminderId('r-ui'),
                            itemId: ItemId('item-1'),
                            scheduledFor: nowLocal.add(const Duration(days: 1)),
                            privacyMode: ReminderPrivacyMode.generic,
                            isEnabled: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open reminder dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open reminder dialog'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('reminder-date-button')));
      await tester.ensureVisible(find.byKey(const Key('reminder-time-button')));
      await tester.ensureVisible(
        find.byKey(const Key('reminder-privacy-mode')),
      );
      await tester.ensureVisible(find.byKey(const Key('reminder-save-button')));
      await tester.ensureVisible(find.widgetWithText(TextButton, 'Cancel'));

      expect(find.byKey(const Key('reminder-date-button')), findsOneWidget);
      expect(find.byKey(const Key('reminder-time-button')), findsOneWidget);
      expect(find.byKey(const Key('reminder-privacy-mode')), findsOneWidget);
      expect(find.byKey(const Key('reminder-save-button')), findsOneWidget);
      expect(
        tester
            .getSemantics(find.byKey(const Key('reminder-enabled-switch')))
            .label,
        contains('Enable reminder'),
      );
      expect(
        tester.getSize(find.byKey(const Key('reminder-date-button'))).height,
        greaterThanOrEqualTo(44),
      );
      expect(
        tester.getSize(find.byKey(const Key('reminder-time-button'))).height,
        greaterThanOrEqualTo(44),
      );
      expect(
        tester.getSize(find.byKey(const Key('reminder-save-button'))).height,
        greaterThanOrEqualTo(44),
      );
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );
}

FreezerItem _item(DateTime now) => FreezerItem.create(
  id: ItemId('item-1'),
  name: 'Soup',
  category: 'Meals',
  zoneId: ZoneId('zone-1'),
  quantity: PortionQuantity.parse('1'),
  unit: PortionUnit('portion'),
  frozenOn: const PlanningDate.unknown(),
  useFirstOn: const PlanningDate.unknown(),
  notes: '',
  now: now,
);
