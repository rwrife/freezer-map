import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:freezer_map/presentation/freezer_map_app.dart';
import 'package:freezer_map/presentation/inventory_screen.dart';

void main() {
  late FreezerDatabase database;
  late DriftInventoryRepository repository;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
  });

  tearDown(() => database.close());

  Widget app() => FreezerMapApp.inventory(
    repository: repository,
    clock: _Clock(),
    ids: _Ids(),
  );

  testWidgets('first run creates an appliance and its first shallow zone', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('No freezer locations yet'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Set up a freezer'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Appliance name'),
      'Garage freezer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'First zone name'),
      'Left basket',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create location'));
    await tester.pumpAndSettle();

    expect(find.text('Garage freezer'), findsOneWidget);
    expect(find.text('Left basket'), findsOneWidget);
    expect((await repository.appliances()).single.name, 'Garage freezer');
    expect((await repository.zones()).single.name, 'Left basket');
  });

  testWidgets('setup storage failure stays inline and preserves entries', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(),
      afterLocationWrite: () async => throw StateError('storage failed'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(repository: repository, commands: commands),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Set up a freezer'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Appliance name'),
      'Garage',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'First zone name'),
      'Basket',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create location'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('setup-save-error')), findsOneWidget);
    expect(find.textContaining('on-device storage'), findsOneWidget);
    expect(find.text('Nothing was deleted.'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Appliance name'),
          )
          .controller!
          .text,
      'Garage',
    );
    expect(await repository.appliances(), isEmpty);
  });

  testWidgets('nested zones show breadcrumbs and reject a cycle inline', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(),
    );
    final appliance = await commands.createAppliance(
      name: 'Kitchen',
      sortOrder: 0,
    );
    final basket = await commands.createZone(
      applianceId: appliance.id,
      name: 'Basket',
      sortOrder: 0,
    );
    await commands.createZone(
      applianceId: appliance.id,
      parentId: basket.id,
      name: 'Veg',
      sortOrder: 0,
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Kitchen › Basket › Veg'), findsOneWidget);
    await tester.tap(find.byKey(Key('zone-menu-${basket.id.value}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move zone'));
    await tester.pumpAndSettle();
    final field = tester.widget<DropdownButtonFormField<ZoneId?>>(
      find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<ZoneId?>,
      ),
    );
    field.onChanged!(ZoneId('workflow-3'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Move'));
    await tester.pumpAndSettle();

    expect(find.textContaining('cycle'), findsOneWidget);
    expect((await repository.zoneById(basket.id))!.parentId, isNull);
  });

  testWidgets('new appliance follows max active order after an archive gap', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(100),
    );
    final first = await commands.createAppliance(name: 'First', sortOrder: 0);
    final middle = await commands.createAppliance(name: 'Middle', sortOrder: 1);
    await commands.createAppliance(name: 'Last', sortOrder: 2);
    await commands.archiveAppliance(middle.id);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add appliance'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Appliance name'),
      'New',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    var active = await repository.appliances();
    expect(active.map((value) => value.sortOrder), [0, 2, 3]);
    final created = active.last;
    await tester.tap(find.byKey(Key('appliance-menu-${created.id.value}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move appliance up'));
    await tester.pumpAndSettle();

    active = await repository.appliances();
    expect(active.map((value) => value.name), ['First', 'New', 'Last']);
    expect(active.map((value) => value.sortOrder), [0, 2, 3]);
    expect(first.sortOrder, 0);
  });

  testWidgets(
    'async name dialog keeps an appliance name after storage failure and retries',
    (tester) async {
      final seedCommands = InventoryCommands(
        repository: repository,
        clock: _Clock(),
        ids: _Ids(),
      );
      await seedCommands.createAppliance(name: 'Kitchen', sortOrder: 0);
      var failNextWrite = true;
      final commands = InventoryCommands(
        repository: repository,
        clock: _Clock(),
        ids: _Ids(100),
        afterLocationWrite: () async {
          if (failNextWrite) {
            failNextWrite = false;
            throw StateError('storage failed');
          }
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: InventoryScreen(repository: repository, commands: commands),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add appliance'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Appliance name'),
        'Garage freezer',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Add appliance'), findsOneWidget);
      expect(find.byKey(const Key('name-save-error')), findsOneWidget);
      expect(find.textContaining('on-device storage'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.widgetWithText(TextFormField, 'Appliance name'),
            )
            .controller!
            .text,
        'Garage freezer',
      );
      expect((await repository.appliances()).map((value) => value.name), [
        'Kitchen',
      ]);

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Add appliance'), findsNothing);
      expect((await repository.appliances()).map((value) => value.name), [
        'Kitchen',
        'Garage freezer',
      ]);
    },
  );

  testWidgets('new sibling zone follows max active order after archive gap', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(100),
    );
    final appliance = await commands.createAppliance(
      name: 'Kitchen',
      sortOrder: 0,
    );
    final first = await commands.createZone(
      applianceId: appliance.id,
      name: 'First',
      sortOrder: 0,
    );
    await commands.createZone(
      applianceId: appliance.id,
      name: 'Middle',
      sortOrder: 1,
    );
    await commands.createZone(
      applianceId: appliance.id,
      name: 'Last',
      sortOrder: 2,
    );
    await commands.archiveZone(first.id);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('appliance-menu-${appliance.id.value}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add top-level zone'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Zone name'),
      'New',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    var active = await repository.zones();
    expect(active.map((value) => value.sortOrder), [1, 2, 3]);
    final created = active.last;
    await tester.tap(find.byKey(Key('zone-menu-${created.id.value}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move zone up'));
    await tester.pumpAndSettle();

    active = await repository.zones();
    expect(active.map((value) => value.name), ['Middle', 'New', 'Last']);
    expect(active.map((value) => value.sortOrder), [1, 2, 3]);
  });

  testWidgets('quick add validates inline and edit persists every item field', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(),
    );
    final appliance = await commands.createAppliance(
      name: 'Kitchen',
      sortOrder: 0,
    );
    final drawer = await commands.createZone(
      applianceId: appliance.id,
      name: 'Drawer',
      sortOrder: 0,
    );
    final shelf = await commands.createZone(
      applianceId: appliance.id,
      name: 'Shelf',
      sortOrder: 1,
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add freezer item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Soup');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pump();
    expect(find.text('Enter a quantity greater than zero.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantity'),
      '2.5',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'tubs');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Category'),
      'Meals',
    );
    final locationField = tester.widget<DropdownButtonFormField<ZoneId>>(
      find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<ZoneId>,
      ),
    );
    locationField.onChanged!(drawer.id);
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frozen on'),
      '2026-08-30',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Use first on'),
      '2026-09-15',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes'),
      'Lunch',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.text('Soup'), findsOneWidget);
    final item = (await repository.items()).single;
    expect(item.quantity.canonical, '2.5');
    expect(item.unit.value, 'tubs');
    expect(item.frozenOn.value, DateTime.utc(2026, 8, 30));
    expect(item.useFirstOn.value, DateTime.utc(2026, 9, 15));
    expect(item.notes, 'Lunch');

    await tester.tap(find.byKey(Key('item-edit-${item.id.value}')));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Stew');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '4');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unit'), 'bags');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Category'),
      'Dinner',
    );
    tester
        .widget<DropdownButtonFormField<ZoneId>>(
          find.byWidgetPredicate(
            (widget) => widget is DropdownButtonFormField<ZoneId>,
          ),
        )
        .onChanged!(shelf.id);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frozen on'),
      '2026-08-31',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Use first on'),
      '2026-10-01',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes'),
      'Dinner',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final edited = (await repository.items()).single;
    expect(edited.name, 'Stew');
    expect(edited.quantity.canonical, '4');
    expect(edited.unit.value, 'bags');
    expect(edited.category, 'Dinner');
    expect(edited.zoneId, shelf.id);
    expect(edited.frozenOn.value, DateTime.utc(2026, 8, 31));
    expect(edited.useFirstOn.value, DateTime.utc(2026, 10, 1));
    expect(edited.notes, 'Dinner');
    expect((await repository.eventsFor(item.id)).map((event) => event.action), [
      InventoryAction.create,
      InventoryAction.edit,
    ]);
  });

  testWidgets('inventory is reloaded from the repository after app restart', (
    tester,
  ) async {
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(),
    );
    final appliance = await commands.createAppliance(
      name: 'Cellar',
      sortOrder: 0,
    );
    final zone = await commands.createZone(
      applianceId: appliance.id,
      name: 'Shelf',
      sortOrder: 0,
    );
    await commands.createItem(
      name: 'Berries',
      category: 'Fruit',
      zoneId: zone.id,
      quantity: PortionQuantity.parse('3'),
      unit: PortionUnit('bags'),
      frozenOn: const PlanningDate.unknown(),
      useFirstOn: const PlanningDate.unknown(),
      notes: '',
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Berries'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Cellar › Shelf'), findsWidgets);
    expect(find.text('Berries'), findsOneWidget);
  });

  testWidgets('inventory and item form remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: _Ids(),
    );
    final appliance = await commands.createAppliance(
      name: 'Kitchen',
      sortOrder: 0,
    );
    await commands.createZone(
      applianceId: appliance.id,
      name: 'Very long lower pull-out drawer',
      sortOrder: 0,
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add freezer item'));
    await tester.pumpAndSettle();

    expect(find.text('Add freezer item'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pump();
    expect(find.text('This field is required.'), findsWidgets);
    expect(find.text('Choose an appliance and zone.'), findsOneWidget);
    final location = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<ZoneId>,
    );
    tester.widget<DropdownButtonFormField<ZoneId>>(location).onChanged!(
      (await repository.zones()).single.id,
    );
    await tester.pump();
    expect(find.text('Choose an appliance and zone.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 1, 12);
}

final class _Ids implements StableIdSource {
  _Ids([this.value = 0]);

  int value;

  @override
  String next() => 'workflow-${++value}';
}
