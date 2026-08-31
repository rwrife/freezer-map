import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  final now = DateTime.utc(2026, 8, 31, 12);

  FreezerItem item({
    String id = 'item-1',
    String name = 'Soup',
    String quantity = '2.5',
    PlanningDate frozenOn = const PlanningDate.unknown(),
    PlanningDate useFirstOn = const PlanningDate.unknown(),
  }) => FreezerItem.create(
    id: ItemId(id),
    name: name,
    category: 'Meals',
    zoneId: ZoneId('zone-1'),
    quantity: PortionQuantity.parse(quantity),
    unit: PortionUnit('portions'),
    frozenOn: frozenOn,
    useFirstOn: useFirstOn,
    notes: '',
    now: now,
  );

  group('ZoneForest', () {
    test('accepts an acyclic same-appliance tree', () {
      final applianceId = ApplianceId('freezer');
      final zones = [
        Zone(
          id: ZoneId('root'),
          applianceId: applianceId,
          name: 'Left side',
          sortOrder: 0,
        ),
        Zone(
          id: ZoneId('basket'),
          applianceId: applianceId,
          parentId: ZoneId('root'),
          name: 'Basket',
          sortOrder: 0,
        ),
      ];

      expect(() => ZoneForest.validate(zones), returnsNormally);
    });

    test('rejects cycles, missing parents, and cross-appliance parents', () {
      final first = ApplianceId('first');
      final second = ApplianceId('second');

      expect(
        () => ZoneForest.validate([
          Zone(
            id: ZoneId('a'),
            applianceId: first,
            parentId: ZoneId('b'),
            name: 'A',
            sortOrder: 0,
          ),
          Zone(
            id: ZoneId('b'),
            applianceId: first,
            parentId: ZoneId('a'),
            name: 'B',
            sortOrder: 1,
          ),
        ]),
        throwsA(isA<DomainValidationException>()),
      );
      expect(
        () => ZoneForest.validate([
          Zone(
            id: ZoneId('orphan'),
            applianceId: first,
            parentId: ZoneId('absent'),
            name: 'Orphan',
            sortOrder: 0,
          ),
        ]),
        throwsA(isA<DomainValidationException>()),
      );
      expect(
        () => ZoneForest.validate([
          Zone(
            id: ZoneId('parent'),
            applianceId: first,
            name: 'Parent',
            sortOrder: 0,
          ),
          Zone(
            id: ZoneId('child'),
            applianceId: second,
            parentId: ZoneId('parent'),
            name: 'Child',
            sortOrder: 0,
          ),
        ]),
        throwsA(isA<DomainValidationException>()),
      );
    });
  });

  group('ItemPolicy', () {
    test(
      'increments, decrements, explicitly archives zero, and rejects underflow',
      () {
        final original = item();
        final incremented = ItemPolicy.increment(
          original,
          PortionQuantity.parse('0.5'),
          now: now.add(const Duration(minutes: 1)),
        );
        final archived = ItemPolicy.decrement(
          incremented,
          PortionQuantity.parse('3'),
          now: now.add(const Duration(minutes: 2)),
          whenZero: ZeroQuantityDisposition.archive,
        );

        expect(incremented.quantity.canonical, '3');
        expect(archived.quantity.isZero, isTrue);
        expect(archived.isArchived, isTrue);
        expect(
          () => ItemPolicy.decrement(
            original,
            PortionQuantity.parse('3'),
            now: now,
            whenZero: ZeroQuantityDisposition.archive,
          ),
          throwsA(isA<DomainValidationException>()),
        );
      },
    );

    test(
      'moves and performs explicit thaw transitions without safety inference',
      () {
        final original = item();
        final moved = ItemPolicy.move(
          original,
          ZoneId('zone-2'),
          now: now.add(const Duration(minutes: 1)),
        );
        final thawing = ItemPolicy.markThawing(
          moved,
          now: now.add(const Duration(minutes: 2)),
        );
        final frozen = ItemPolicy.returnToFrozen(
          thawing,
          now: now.add(const Duration(minutes: 3)),
        );

        expect(moved.zoneId, ZoneId('zone-2'));
        expect(thawing.thawState, ThawState.thawing);
        expect(thawing.thawStateChangedAt, now.add(const Duration(minutes: 2)));
        expect(frozen.thawState, ThawState.frozen);
        expect(frozen.thawStateChangedAt, now.add(const Duration(minutes: 3)));
      },
    );

    test('edit can replace quantity but cannot mutate an archived item', () {
      final original = item();
      final edited = ItemPolicy.edit(
        original,
        name: 'Tomato soup',
        category: 'Meals',
        quantity: PortionQuantity.parse('4.25'),
        unit: PortionUnit('tubs'),
        frozenOn: const PlanningDate.unknown(),
        useFirstOn: const PlanningDate.unknown(),
        notes: '',
        now: now,
      );
      final archived = ItemPolicy.archive(edited, now: now);

      expect(edited.quantity.canonical, '4.25');
      expect(
        () => ItemPolicy.edit(
          archived,
          name: 'No change',
          category: '',
          quantity: PortionQuantity.parse('1'),
          unit: PortionUnit('portion'),
          frozenOn: const PlanningDate.unknown(),
          useFirstOn: const PlanningDate.unknown(),
          notes: '',
          now: now,
        ),
        throwsA(isA<DomainValidationException>()),
      );
    });

    test('random action sequences never make quantity negative', () {
      final random = Random(271828);
      var current = item(quantity: '10');

      for (var index = 0; index < 500; index++) {
        final amount = PortionQuantity.parse('${random.nextInt(5) + 1}');
        if (random.nextBool()) {
          current = ItemPolicy.increment(current, amount, now: now);
        } else {
          try {
            current = ItemPolicy.decrement(
              current,
              amount,
              now: now,
              whenZero: ZeroQuantityDisposition.keepActive,
            );
          } on DomainValidationException {
            // Rejected action leaves the last valid state unchanged.
          }
        }
        expect(current.quantity.compareTo(PortionQuantity.zero), isNonNegative);
      }
    });
  });

  group('UseFirstPolicy', () {
    test('orders date ties by frozen date, normalized name, and stable ID', () {
      final useFirst = PlanningDate.known(DateTime.utc(2026, 9, 1));
      final frozen = PlanningDate.known(DateTime.utc(2026, 8, 1));
      final values = [
        item(id: 'b', name: 'Éclair', frozenOn: frozen, useFirstOn: useFirst),
        item(
          id: 'a',
          name: 'e\u0301clair',
          frozenOn: frozen,
          useFirstOn: useFirst,
        ),
        item(
          id: 'early',
          name: 'Soup',
          frozenOn: PlanningDate.known(DateTime.utc(2026, 7, 1)),
          useFirstOn: useFirst,
        ),
      ]..sort(UseFirstPolicy.compare);

      expect(values.map((value) => value.id.value), ['early', 'a', 'b']);
    });

    test('keeps unknown use-first dates in a separate trailing group', () {
      final values = [
        item(id: 'unknown', frozenOn: PlanningDate.known(DateTime.utc(2020))),
        item(id: 'known', useFirstOn: PlanningDate.known(DateTime.utc(2030))),
      ]..sort(UseFirstPolicy.compare);

      expect(values.first.id, ItemId('known'));
      expect(
        UseFirstPolicy.groupOf(values.last),
        UseFirstGroup.unknownUseFirstDate,
      );
    });
  });

  group('SearchPolicy', () {
    test('normalizes Unicode composition, accents, case, and whitespace', () {
      expect(normalizeForSearch('  CAFÉ\tCrème '), 'cafe creme');
      expect(normalizeForSearch('Cafe\u0301 Cre\u0300me'), 'cafe creme');
      expect(normalizeForSearch('Straße'), 'strasse');
      expect(matchesNormalizedSearch('Crème brûlée', 'CREME  BRULEE'), isTrue);
    });
  });
}
