import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

enum ArchivedFilter { active, archived, all }

enum DatePresenceFilter { any, known, unknown }

final class InventoryFilter {
  const InventoryFilter({
    this.query = '',
    this.applianceId,
    this.zoneId,
    this.category,
    this.thawState,
    this.archived = ArchivedFilter.active,
    this.frozenOn = DatePresenceFilter.any,
    this.useFirstOn = DatePresenceFilter.any,
  });

  final String query;
  final ApplianceId? applianceId;
  final ZoneId? zoneId;
  final String? category;
  final ThawState? thawState;
  final ArchivedFilter archived;
  final DatePresenceFilter frozenOn;
  final DatePresenceFilter useFirstOn;

  InventoryFilter copyWith({
    String? query,
    ApplianceId? applianceId,
    bool clearAppliance = false,
    ZoneId? zoneId,
    bool clearZone = false,
    String? category,
    bool clearCategory = false,
    ThawState? thawState,
    bool clearThawState = false,
    ArchivedFilter? archived,
    DatePresenceFilter? frozenOn,
    DatePresenceFilter? useFirstOn,
  }) => InventoryFilter(
    query: query ?? this.query,
    applianceId: clearAppliance ? null : applianceId ?? this.applianceId,
    zoneId: clearZone ? null : zoneId ?? this.zoneId,
    category: clearCategory ? null : category ?? this.category,
    thawState: clearThawState ? null : thawState ?? this.thawState,
    archived: archived ?? this.archived,
    frozenOn: frozenOn ?? this.frozenOn,
    useFirstOn: useFirstOn ?? this.useFirstOn,
  );

  bool matches(FreezerItem item, Map<ZoneId, Zone> zones) {
    final zone = zones[item.zoneId];
    if (zone == null) return false;
    if (!_matchesArchived(item)) return false;
    if (applianceId != null && zone.applianceId != applianceId) return false;
    if (zoneId != null && item.zoneId != zoneId) return false;
    if (category != null && item.category != category) return false;
    if (thawState != null && item.thawState != thawState) return false;
    if (!_matchesDate(item.frozenOn, frozenOn)) return false;
    if (!_matchesDate(item.useFirstOn, useFirstOn)) return false;

    final normalizedQuery = normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return true;
    return <String>[
      item.name,
      item.category,
      item.notes,
      item.unit.value,
    ].any((value) => matchesNormalizedSearch(value, normalizedQuery));
  }

  bool _matchesArchived(FreezerItem item) => switch (archived) {
    ArchivedFilter.active => !item.isArchived,
    ArchivedFilter.archived => item.isArchived,
    ArchivedFilter.all => true,
  };

  static bool _matchesDate(PlanningDate date, DatePresenceFilter presence) =>
      switch (presence) {
        DatePresenceFilter.any => true,
        DatePresenceFilter.known => date.isKnown,
        DatePresenceFilter.unknown => !date.isKnown,
      };
}

List<FreezerItem> filterInventory(
  Iterable<FreezerItem> items,
  Iterable<Zone> zones,
  InventoryFilter filter,
) {
  final zonesById = {for (final zone in zones) zone.id: zone};
  final result = items
      .where((item) => filter.matches(item, zonesById))
      .toList(growable: false);
  return result;
}

List<FreezerItem> useFirstInventory(Iterable<FreezerItem> items) {
  final result = items.where((item) => !item.isArchived).toList();
  result.sort(UseFirstPolicy.compare);
  return result;
}

List<FreezerItem> thawQueueInventory(Iterable<FreezerItem> items) {
  final result = items
      .where((item) => !item.isArchived && item.thawState == ThawState.thawing)
      .toList();
  result.sort((left, right) {
    var comparison = left.thawStateChangedAt.compareTo(
      right.thawStateChangedAt,
    );
    if (comparison != 0) return comparison;
    comparison = normalizeForSearch(left.name)
        .compareTo(normalizeForSearch(right.name));
    if (comparison != 0) return comparison;
    return left.id.value.compareTo(right.id.value);
  });
  return result;
}
