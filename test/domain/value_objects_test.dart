import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/domain/value_objects.dart';

void main() {
  group('Stable identifiers', () {
    test('reject empty values and retain type-safe stable values', () {
      expect(() => ApplianceId('  '), throwsArgumentError);
      expect(ApplianceId('appliance-1').value, 'appliance-1');
      expect(ZoneId('zone-1'), ZoneId('zone-1'));
      expect(ZoneId('same') == ItemId('same'), isFalse);
    });
  });

  group('PortionQuantity', () {
    test('parses exact decimals without binary floating point drift', () {
      final quantity = PortionQuantity.parse('0.10');

      expect(quantity.canonical, '0.1');
      expect(quantity.plus(PortionQuantity.parse('0.2')).canonical, '0.3');
      expect(
        () => quantity.minus(PortionQuantity.parse('0.2')),
        throwsA(isA<DomainValidationException>()),
      );
    });

    test('requires a positive quantity for a new inventory item', () {
      expect(
        () => PortionQuantity.parse('0').requirePositive(),
        throwsA(isA<DomainValidationException>()),
      );
      expect(PortionQuantity.parse('1.25').requirePositive().canonical, '1.25');
    });
  });

  group('PlanningDate', () {
    test('keeps unknown separate from a known calendar date', () {
      const unknown = PlanningDate.unknown();
      final known = PlanningDate.known(DateTime.utc(2026, 8, 31, 23, 45));

      expect(unknown.isKnown, isFalse);
      expect(known.isKnown, isTrue);
      expect(known.value, DateTime.utc(2026, 8, 31));
      expect(unknown, isNot(known));
    });
  });

  test('PortionUnit trims labels and rejects blank units', () {
    expect(PortionUnit(' portions ').value, 'portions');
    expect(() => PortionUnit(' '), throwsArgumentError);
  });
}
