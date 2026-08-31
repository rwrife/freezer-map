import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:unorm_dart/unorm_dart.dart' as unicode;

enum ZeroQuantityDisposition { archive, keepActive }

enum UseFirstGroup { dated, unknownUseFirstDate }

abstract final class ZoneForest {
  static void validate(Iterable<Zone> zones) {
    final byId = <ZoneId, Zone>{};
    for (final zone in zones) {
      if (byId.containsKey(zone.id)) {
        throw DomainValidationException('Duplicate zone ID: ${zone.id.value}.');
      }
      byId[zone.id] = zone;
    }

    for (final zone in byId.values) {
      final parentId = zone.parentId;
      if (parentId == null) {
        continue;
      }
      final parent = byId[parentId];
      if (parent == null) {
        throw DomainValidationException(
          'Zone ${zone.id.value} has a missing parent ${parentId.value}.',
        );
      }
      if (parent.applianceId != zone.applianceId) {
        throw DomainValidationException(
          'A zone parent must belong to the same appliance.',
        );
      }
    }

    final visiting = <ZoneId>{};
    final visited = <ZoneId>{};

    void visit(Zone zone) {
      if (visited.contains(zone.id)) {
        return;
      }
      if (!visiting.add(zone.id)) {
        throw DomainValidationException(
          'Zone parent cycle includes ${zone.id.value}.',
        );
      }
      final parentId = zone.parentId;
      if (parentId != null) {
        visit(byId[parentId]!);
      }
      visiting.remove(zone.id);
      visited.add(zone.id);
    }

    for (final zone in byId.values) {
      visit(zone);
    }
  }
}

abstract final class ItemPolicy {
  static FreezerItem edit(
    FreezerItem item, {
    required String name,
    required String category,
    required PortionQuantity quantity,
    required PortionUnit unit,
    required PlanningDate frozenOn,
    required PlanningDate useFirstOn,
    required String notes,
    required DateTime now,
  }) {
    _requireActive(item);
    quantity.requirePositive();
    return _copy(
      item,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      frozenOn: frozenOn,
      useFirstOn: useFirstOn,
      notes: notes,
      updatedAt: now,
    );
  }

  static FreezerItem increment(
    FreezerItem item,
    PortionQuantity amount, {
    required DateTime now,
  }) {
    amount.requirePositive();
    _requireActive(item);
    return _copy(item, quantity: item.quantity.plus(amount), updatedAt: now);
  }

  static FreezerItem decrement(
    FreezerItem item,
    PortionQuantity amount, {
    required DateTime now,
    required ZeroQuantityDisposition whenZero,
  }) {
    amount.requirePositive();
    _requireActive(item);
    final quantity = item.quantity.minus(amount);
    if (quantity.isZero && whenZero == ZeroQuantityDisposition.keepActive) {
      throw const DomainValidationException(
        'Zero quantity must be explicitly archived.',
      );
    }
    return _copy(
      item,
      quantity: quantity,
      updatedAt: now,
      archivedAt: quantity.isZero ? now : item.archivedAt,
    );
  }

  static FreezerItem move(
    FreezerItem item,
    ZoneId destination, {
    required DateTime now,
  }) {
    _requireActive(item);
    return _copy(item, zoneId: destination, updatedAt: now);
  }

  static FreezerItem markThawing(FreezerItem item, {required DateTime now}) {
    _requireActive(item);
    if (item.thawState == ThawState.thawing) {
      throw const DomainValidationException('Item is already marked thawing.');
    }
    return _copy(
      item,
      thawState: ThawState.thawing,
      thawStateChangedAt: now,
      updatedAt: now,
    );
  }

  static FreezerItem returnToFrozen(FreezerItem item, {required DateTime now}) {
    _requireActive(item);
    if (item.thawState == ThawState.frozen) {
      throw const DomainValidationException('Item is already marked frozen.');
    }
    return _copy(
      item,
      thawState: ThawState.frozen,
      thawStateChangedAt: now,
      updatedAt: now,
    );
  }

  static FreezerItem archive(FreezerItem item, {required DateTime now}) {
    _requireActive(item);
    return _copy(item, updatedAt: now, archivedAt: now);
  }

  static FreezerItem _copy(
    FreezerItem item, {
    String? name,
    String? category,
    ZoneId? zoneId,
    PortionQuantity? quantity,
    PortionUnit? unit,
    PlanningDate? frozenOn,
    PlanningDate? useFirstOn,
    ThawState? thawState,
    String? notes,
    DateTime? updatedAt,
    DateTime? thawStateChangedAt,
    DateTime? archivedAt,
  }) => FreezerItem.rehydrate(
    id: item.id,
    name: name ?? item.name,
    category: category ?? item.category,
    zoneId: zoneId ?? item.zoneId,
    quantity: quantity ?? item.quantity,
    unit: unit ?? item.unit,
    frozenOn: frozenOn ?? item.frozenOn,
    useFirstOn: useFirstOn ?? item.useFirstOn,
    thawState: thawState ?? item.thawState,
    notes: notes ?? item.notes,
    createdAt: item.createdAt,
    updatedAt: updatedAt ?? item.updatedAt,
    thawStateChangedAt: thawStateChangedAt ?? item.thawStateChangedAt,
    archivedAt: archivedAt ?? item.archivedAt,
  );

  static void _requireActive(FreezerItem item) {
    if (item.isArchived) {
      throw const DomainValidationException(
        'Archived items cannot be changed.',
      );
    }
  }
}

abstract final class UseFirstPolicy {
  static int compare(FreezerItem left, FreezerItem right) {
    var result = _comparePlanningDate(left.useFirstOn, right.useFirstOn);
    if (result != 0) {
      return result;
    }
    result = _comparePlanningDate(left.frozenOn, right.frozenOn);
    if (result != 0) {
      return result;
    }
    result = normalizeForSearch(left.name)
        .compareTo(normalizeForSearch(right.name));
    if (result != 0) {
      return result;
    }
    return left.id.value.compareTo(right.id.value);
  }

  static UseFirstGroup groupOf(FreezerItem item) => item.useFirstOn.isKnown
      ? UseFirstGroup.dated
      : UseFirstGroup.unknownUseFirstDate;

  static int _comparePlanningDate(PlanningDate left, PlanningDate right) {
    if (left.isKnown != right.isKnown) {
      return left.isKnown ? -1 : 1;
    }
    if (!left.isKnown) {
      return 0;
    }
    return left.value!.compareTo(right.value!);
  }
}

String normalizeForSearch(String source) {
  final decomposed = unicode.nfkd(source.toLowerCase());
  final withoutMarks = decomposed.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  return withoutMarks
      .replaceAll('ß', 'ss')
      .replaceAll('æ', 'ae')
      .replaceAll('œ', 'oe')
      .replaceAll('ø', 'o')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool matchesNormalizedSearch(String candidate, String query) =>
    normalizeForSearch(candidate).contains(normalizeForSearch(query));
