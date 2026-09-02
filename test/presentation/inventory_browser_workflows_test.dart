import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:freezer_map/presentation/freezer_map_app.dart';

void main() {
  late FreezerDatabase database;
  late DriftInventoryRepository repository;
  late InventoryCommands commands;
  late _Ids ids;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    repository = DriftInventoryRepository(database);
    ids = _Ids();
    commands = InventoryCommands(
      repository: repository,
      clock: _Clock(),
      ids: ids,
    );
  });

  tearDown(() => database.close());

  Widget app() => FreezerMapApp.inventory(
    repository: repository,
    clock: _Clock(),
    ids: ids,
  );

  Future<(Zone, Zone)> seedLocations() async {
    final appliance = await commands.createAppliance(
      name: 'Kitchen freezer',
      sortOrder: 0,
    );
    final drawer = await commands.createZone(
      applianceId: appliance.id,
      name: 'Lower drawer',
      sortOrder: 0,
    );
    final shelf = await commands.createZone(
      applianceId: appliance.id,
      name: 'Upper shelf',
      sortOrder: 1,
    );
    return (drawer, shelf);
  }

  Future<FreezerItem> seedItem({
    required Zone zone,
    String name = 'Soup',
    String category = 'Meals',
    String quantity = '2',
    PlanningDate useFirstOn = const PlanningDate.unknown(),
  }) => commands.createItem(
    name: name,
    category: category,
    zoneId: zone.id,
    quantity: PortionQuantity.parse(quantity),
    unit: PortionUnit('tubs'),
    frozenOn: PlanningDate.known(DateTime.utc(2026, 8, 1)),
    useFirstOn: useFirstOn,
    notes: 'Family lunch',
  );

  testWidgets('debounces local search and separates unknown use-first dates', (
    tester,
  ) async {
    final (drawer, _) = await seedLocations();
    await seedItem(
      zone: drawer,
      useFirstOn: PlanningDate.known(DateTime.utc(2026, 9, 5)),
    );
    await seedItem(zone: drawer, name: 'Berries', category: 'Fruit');

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Berries'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('inventory-search')), 'soup');
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.text('Berries'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Berries'), findsNothing);
    expect(find.text('Soup'), findsOneWidget);

    await tester.tap(find.text('Use First'));
    await tester.pumpAndSettle();
    expect(find.textContaining('not a food-safety'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(
      find.text('Unknown use-first date — no urgency assigned'),
      findsOneWidget,
    );
    expect(find.text('Berries'), findsOneWidget);
  });

  testWidgets('quantity, move, thaw, archive, and undo stay transactional', (
    tester,
  ) async {
    final (drawer, shelf) = await seedLocations();
    final item = await seedItem(zone: drawer);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final decrement = find.byKey(Key('item-decrement-${item.id.value}'));
    await tester.ensureVisible(decrement);
    await tester.tap(decrement);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('portion-amount')), '0.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Use'));
    await tester.pumpAndSettle();
    expect((await repository.itemById(item.id))!.quantity.canonical, '1.5');
    expect(find.textContaining('decreased by 0.5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('undo-decrement')));
    await tester.pumpAndSettle();
    expect((await repository.itemById(item.id))!.quantity.canonical, '2');

    final move = find.byKey(Key('item-move-${item.id.value}'));
    await tester.ensureVisible(move);
    await tester.tap(move);
    await tester.pumpAndSettle();
    final moveField = tester.widget<DropdownButtonFormField<ZoneId>>(
      find.byKey(const Key('move-item-destination')),
    );
    moveField.onChanged!(shelf.id);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Move'));
    await tester.pumpAndSettle();
    expect((await repository.itemById(item.id))!.zoneId, shelf.id);

    final thaw = find.byKey(Key('item-thaw-${item.id.value}'));
    await tester.ensureVisible(thaw);
    await tester.tap(thaw);
    await tester.pumpAndSettle();
    expect((await repository.itemById(item.id))!.thawState, ThawState.thawing);
    await tester.tap(find.text('Thaw Queue'));
    await tester.pumpAndSettle();
    expect(find.text('Soup'), findsOneWidget);
    expect(find.textContaining('not safe-thaw guidance'), findsOneWidget);

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    final archive = find.byKey(Key('item-archive-${item.id.value}'));
    await tester.ensureVisible(archive);
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(archive);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();
    expect((await repository.itemById(item.id))!.isArchived, isTrue);
    await tester.tap(find.byKey(const Key('undo-archive')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    final finalItem = (await repository.itemById(item.id))!;
    expect(finalItem.isArchived, isFalse);
  });

  testWidgets(
    'item semantics announce quantity, location, and non-color state',
    (tester) async {
      final (drawer, _) = await seedLocations();
      final item = await seedItem(zone: drawer);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final card = find.byKey(Key('item-card-${item.id.value}'));
      expect(
        tester.getSemantics(card).label,
        allOf(
          contains('Soup'),
          contains('2 tubs'),
          contains('Kitchen freezer › Lower drawer'),
          contains('State: Frozen'),
        ),
      );
      final edit = find.byKey(Key('item-edit-${item.id.value}'));
      final size = tester.getSize(edit);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(
        find.text('Frozen on: 2026-08-01 (planning date)'),
        findsOneWidget,
      );
      expect(find.text('Use first on: Unknown'), findsOneWidget);
      expect(find.textContaining('Last updated:'), findsOneWidget);
      semantics.dispose();
    },
  );
}

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 2, 12, 30);
}

final class _Ids implements StableIdSource {
  var value = 0;

  @override
  String next() => 'browser-${++value}';
}
