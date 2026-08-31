import 'package:decimal/decimal.dart';

final class DomainValidationException implements Exception {
  const DomainValidationException(this.message);

  final String message;

  @override
  String toString() => 'DomainValidationException: $message';
}

sealed class StableId {
  StableId(String value) : value = value.trim() {
    if (this.value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'A stable ID cannot be blank.');
    }
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is StableId &&
      other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => value;
}

final class ApplianceId extends StableId {
  ApplianceId(super.value);
}

final class ZoneId extends StableId {
  ZoneId(super.value);
}

final class ItemId extends StableId {
  ItemId(super.value);
}

final class InventoryEventId extends StableId {
  InventoryEventId(super.value);
}

final class ReminderId extends StableId {
  ReminderId(super.value);
}

final class PortionUnit {
  PortionUnit(String value) : value = value.trim() {
    if (this.value.isEmpty) {
      throw ArgumentError.value(
        value,
        'value',
        'A portion unit cannot be blank.',
      );
    }
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PortionUnit && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class PortionQuantity implements Comparable<PortionQuantity> {
  PortionQuantity._(this._value) {
    if (_value < Decimal.zero) {
      throw const DomainValidationException('Quantity cannot be negative.');
    }
  }

  factory PortionQuantity.parse(String source) {
    try {
      return PortionQuantity._(Decimal.parse(source.trim()));
    } on FormatException {
      throw DomainValidationException('Invalid decimal quantity: $source');
    }
  }

  static final PortionQuantity zero = PortionQuantity._(Decimal.zero);

  final Decimal _value;

  String get canonical => _value.toString();
  bool get isZero => _value == Decimal.zero;
  bool get isPositive => _value > Decimal.zero;

  PortionQuantity plus(PortionQuantity other) =>
      PortionQuantity._(_value + other._value);

  PortionQuantity minus(PortionQuantity other) {
    final result = _value - other._value;
    if (result < Decimal.zero) {
      throw const DomainValidationException('Quantity cannot become negative.');
    }
    return PortionQuantity._(result);
  }

  PortionQuantity requirePositive() {
    if (!isPositive) {
      throw const DomainValidationException(
        'A new inventory item requires a positive quantity.',
      );
    }
    return this;
  }

  @override
  int compareTo(PortionQuantity other) => _value.compareTo(other._value);

  @override
  bool operator ==(Object other) =>
      other is PortionQuantity && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => canonical;
}

sealed class PlanningDate {
  const PlanningDate();

  const factory PlanningDate.unknown() = UnknownPlanningDate;

  factory PlanningDate.known(DateTime value) = KnownPlanningDate;

  bool get isKnown;
  DateTime? get value;
}

final class UnknownPlanningDate extends PlanningDate {
  const UnknownPlanningDate();

  @override
  bool get isKnown => false;

  @override
  DateTime? get value => null;

  @override
  bool operator ==(Object other) => other is UnknownPlanningDate;

  @override
  int get hashCode => 0;
}

final class KnownPlanningDate extends PlanningDate {
  KnownPlanningDate(DateTime value)
    : _value = DateTime.utc(value.year, value.month, value.day);

  final DateTime _value;

  @override
  bool get isKnown => true;

  @override
  DateTime get value => _value;

  @override
  bool operator ==(Object other) =>
      other is KnownPlanningDate && other._value == _value;

  @override
  int get hashCode => _value.hashCode;
}
