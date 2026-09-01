import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/data/app_database.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:freezer_map/main.dart';

void main() {
  test('offline stable IDs are unique across rapid calls', () {
    final ids = LocalStableIds();

    final generated = List.generate(10000, (_) => ids.next());

    expect(generated.toSet(), hasLength(generated.length));
    expect(generated, everyElement(matches(RegExp(r'^[0-9a-f]{32}$'))));
  });

  testWidgets('bootstrap retains one ID source across rebuilds', (
    tester,
  ) async {
    var sourcesCreated = 0;
    final key = GlobalKey();
    StableIdSource createIds() {
      sourcesCreated++;
      return _Ids();
    }

    await tester.pumpWidget(
      FreezerMapBootstrap(
        key: key,
        databaseOpener: () => Future.error(StateError('unavailable')),
        idSourceFactory: createIds,
      ),
    );
    await tester.pump();
    await tester.pumpWidget(
      FreezerMapBootstrap(
        key: key,
        databaseOpener: () => Future.error(StateError('still unavailable')),
        idSourceFactory: createIds,
      ),
    );
    await tester.pump();

    expect(sourcesCreated, 1);
  });

  testWidgets('shows loading, initialization recovery, and retries', (
    tester,
  ) async {
    final completer = Completer<FreezerDatabase>();
    var attempts = 0;
    await tester.pumpWidget(
      FreezerMapBootstrap(
        databaseOpener: () {
          attempts++;
          if (attempts == 1) {
            return Future.error(StateError('disk unavailable'));
          }
          return completer.future;
        },
      ),
    );
    await tester.pump();

    expect(
      find.text('Could not open on-device freezer storage.'),
      findsOneWidget,
    );
    expect(find.textContaining('available device storage'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final database = FreezerDatabase.forTesting(NativeDatabase.memory());
    completer.complete(database);
    await tester.pumpAndSettle();
    expect(find.text('No freezer locations yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await expectLater(
      DriftInventoryRepository(database).appliances(),
      throwsA(anything),
    );
  });

  test('file-backed inventory survives close, reopen, and bootstrap', () async {
    final directory = await Directory.systemTemp.createTemp(
      'freezer-map-restart-',
    );
    FreezerDatabase? reopenedDatabase;
    addTearDown(() async {
      await reopenedDatabase?.close();
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    final firstDatabase = await openAppPrivateDatabase(
      directoryProvider: () async => directory,
    );
    final repository = DriftInventoryRepository(firstDatabase);
    final appliance = Appliance(
      id: ApplianceId('appliance'),
      name: 'Cellar',
      sortOrder: 0,
    );
    final zone = Zone(
      id: ZoneId('zone'),
      applianceId: appliance.id,
      name: 'Shelf',
      sortOrder: 0,
    );
    await repository.saveAppliance(appliance);
    await repository.saveZone(zone);
    await repository.saveItem(
      FreezerItem.create(
        id: ItemId('item'),
        name: 'Berries',
        category: 'Fruit',
        zoneId: zone.id,
        quantity: PortionQuantity.parse('3'),
        unit: PortionUnit('bags'),
        frozenOn: const PlanningDate.unknown(),
        useFirstOn: const PlanningDate.unknown(),
        notes: '',
        now: DateTime.utc(2026, 9, 1),
      ),
    );
    await firstDatabase.close();

    reopenedDatabase = await openAppPrivateDatabase(
      directoryProvider: () async => directory,
    );
    final bootstrappedRepository = DriftInventoryRepository(reopenedDatabase);

    expect((await bootstrappedRepository.appliances()).single.name, 'Cellar');
    expect((await bootstrappedRepository.zones()).single.name, 'Shelf');
    expect((await bootstrappedRepository.items()).single.name, 'Berries');
  });
}

final class _Ids implements StableIdSource {
  @override
  String next() => 'unused';
}
