import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezer_map/application/inventory_query.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/policies.dart';
import 'package:freezer_map/domain/value_objects.dart';

enum InventoryView { inventory, useFirst, thawQueue }

final class InventoryBrowser extends StatefulWidget {
  const InventoryBrowser({
    required this.appliances,
    required this.zones,
    required this.items,
    required this.locationOverview,
    required this.breadcrumbFor,
    required this.onIncrement,
    required this.onDecrement,
    required this.onConsumeAll,
    required this.onMove,
    required this.onThaw,
    required this.onReturnToFrozen,
    required this.onEdit,
    required this.onArchive,
    super.key,
  });

  final List<Appliance> appliances;
  final List<Zone> zones;
  final List<FreezerItem> items;
  final Widget locationOverview;
  final String Function(ZoneId zoneId) breadcrumbFor;
  final Future<void> Function(FreezerItem item) onIncrement;
  final Future<void> Function(FreezerItem item) onDecrement;
  final Future<void> Function(FreezerItem item) onConsumeAll;
  final Future<void> Function(FreezerItem item) onMove;
  final Future<void> Function(FreezerItem item) onThaw;
  final Future<void> Function(FreezerItem item) onReturnToFrozen;
  final Future<void> Function(FreezerItem item) onEdit;
  final Future<void> Function(FreezerItem item) onArchive;

  @override
  State<InventoryBrowser> createState() => _InventoryBrowserState();
}

final class _InventoryBrowserState extends State<InventoryBrowser> {
  final _search = TextEditingController();
  Timer? _debounce;
  InventoryFilter _filter = const InventoryFilter();
  InventoryView _view = InventoryView.inventory;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _filter = _filter.copyWith(query: value));
    });
  }

  void _clearFilters() {
    _debounce?.cancel();
    _search.clear();
    setState(() => _filter = const InventoryFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<InventoryView>(
            segments: const [
              ButtonSegment(
                value: InventoryView.inventory,
                icon: Icon(Icons.inventory_2_outlined),
                label: Text('Inventory'),
              ),
              ButtonSegment(
                value: InventoryView.useFirst,
                icon: Icon(Icons.event_outlined),
                label: Text('Use First'),
              ),
              ButtonSegment(
                value: InventoryView.thawQueue,
                icon: Icon(Icons.ac_unit_outlined),
                label: Text('Thaw Queue'),
              ),
            ],
            selected: {_view},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => _view = value.single),
          ),
        ),
        Expanded(
          child: switch (_view) {
            InventoryView.inventory => _inventory(),
            InventoryView.useFirst => _useFirst(),
            InventoryView.thawQueue => _thawQueue(),
          },
        ),
      ],
    );
  }

  Widget _inventory() {
    final filtered = filterInventory(widget.items, widget.zones, _filter);
    final categories =
        widget.items
            .map((item) => item.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ListView(
      key: const ValueKey(InventoryView.inventory),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (widget.items.isEmpty) ...[widget.locationOverview, const Divider()],
        TextField(
          key: const Key('inventory-search'),
          controller: _search,
          decoration: const InputDecoration(
            labelText: 'Search inventory',
            hintText: 'Name, category, notes, or unit',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onChanged: _searchChanged,
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Filters'),
          subtitle: Text('${filtered.length} matching item(s)'),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dropdown<ApplianceId?>(
                  label: 'Appliance',
                  value: _filter.applianceId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final appliance in widget.appliances)
                      DropdownMenuItem(
                        value: appliance.id,
                        child: Text(appliance.name),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(
                      applianceId: value,
                      clearAppliance: value == null,
                      clearZone: true,
                    ),
                  ),
                ),
                _dropdown<ZoneId?>(
                  label: 'Zone',
                  value: _filter.zoneId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final zone in widget.zones.where(
                      (zone) =>
                          _filter.applianceId == null ||
                          zone.applianceId == _filter.applianceId,
                    ))
                      DropdownMenuItem(
                        value: zone.id,
                        child: Text(
                          widget.breadcrumbFor(zone.id),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(
                      zoneId: value,
                      clearZone: value == null,
                    ),
                  ),
                ),
                _dropdown<String?>(
                  label: 'Category',
                  value: _filter.category,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final category in categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(
                      category: value,
                      clearCategory: value == null,
                    ),
                  ),
                ),
                _dropdown<ThawState?>(
                  label: 'Thaw state',
                  value: _filter.thawState,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(
                      value: ThawState.frozen,
                      child: Text('Frozen'),
                    ),
                    DropdownMenuItem(
                      value: ThawState.thawing,
                      child: Text('Thawing'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(
                      thawState: value,
                      clearThawState: value == null,
                    ),
                  ),
                ),
                _dropdown<ArchivedFilter>(
                  label: 'Archived state',
                  value: _filter.archived,
                  items: const [
                    DropdownMenuItem(
                      value: ArchivedFilter.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: ArchivedFilter.archived,
                      child: Text('Archived'),
                    ),
                    DropdownMenuItem(
                      value: ArchivedFilter.all,
                      child: Text('All'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(archived: value),
                  ),
                ),
                _dropdown<DatePresenceFilter>(
                  label: 'Frozen-on date',
                  value: _filter.frozenOn,
                  items: _dateItems,
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(frozenOn: value),
                  ),
                ),
                _dropdown<DatePresenceFilter>(
                  label: 'Use-first date',
                  value: _filter.useFirstOn,
                  items: _dateItems,
                  onChanged: (value) => setState(
                    () => _filter = _filter.copyWith(useFirstOn: value),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear filters'),
              ),
            ),
          ],
        ),
        Text('Items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        if (filtered.isEmpty)
          const _EmptyResults(
            title: 'No matching items',
            message: 'Adjust or clear the local search and filters.',
          )
        else
          for (final item in filtered) _card(item),
        if (widget.items.isNotEmpty) ...[
          const Divider(),
          widget.locationOverview,
        ],
      ],
    );
  }

  Widget _useFirst() {
    final items = useFirstInventory(widget.items);
    final dated = items
        .where((item) => UseFirstPolicy.groupOf(item) == UseFirstGroup.dated)
        .toList();
    final unknown = items
        .where(
          (item) =>
              UseFirstPolicy.groupOf(item) == UseFirstGroup.unknownUseFirstDate,
        )
        .toList();
    return ListView(
      key: const ValueKey(InventoryView.useFirst),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Text('Use First', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          'Ordered only by user-entered planning dates. This is not a food-safety or spoilage assessment.',
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const _EmptyResults(
            title: 'No active items',
            message: 'Add inventory to build a use-first plan.',
          )
        else ...[
          Text(
            'Dated planning items',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (dated.isEmpty) const Text('No items have a use-first date.'),
          for (final item in dated) _card(item),
          const SizedBox(height: 12),
          Text(
            'Unknown use-first date — no urgency assigned',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final item in unknown) _card(item),
        ],
      ],
    );
  }

  Widget _thawQueue() {
    final items = thawQueueInventory(widget.items);
    return ListView(
      key: const ValueKey(InventoryView.thawQueue),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Text('Thaw Queue', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          'A list of items you marked thawing. Times are activity history, not safe-thaw guidance.',
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const _EmptyResults(
            title: 'Nothing marked thawing',
            message: 'Use an item action to add it to this queue.',
          )
        else
          for (final item in items) _card(item),
      ],
    );
  }

  Widget _card(FreezerItem item) => _InventoryItemCard(
    item: item,
    breadcrumb: widget.breadcrumbFor(item.zoneId),
    onIncrement: () => widget.onIncrement(item),
    onDecrement: () => widget.onDecrement(item),
    onConsumeAll: () => widget.onConsumeAll(item),
    onMove: () => widget.onMove(item),
    onThaw: () => widget.onThaw(item),
    onReturnToFrozen: () => widget.onReturnToFrozen(item),
    onEdit: () => widget.onEdit(item),
    onArchive: () => widget.onArchive(item),
  );

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => SizedBox(
    width: 220,
    child: DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    ),
  );

  static const _dateItems = [
    DropdownMenuItem(value: DatePresenceFilter.any, child: Text('Any')),
    DropdownMenuItem(value: DatePresenceFilter.known, child: Text('Present')),
    DropdownMenuItem(value: DatePresenceFilter.unknown, child: Text('Unknown')),
  ];
}

final class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.item,
    required this.breadcrumb,
    required this.onIncrement,
    required this.onDecrement,
    required this.onConsumeAll,
    required this.onMove,
    required this.onThaw,
    required this.onReturnToFrozen,
    required this.onEdit,
    required this.onArchive,
  });

  final FreezerItem item;
  final String breadcrumb;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onConsumeAll;
  final VoidCallback onMove;
  final VoidCallback onThaw;
  final VoidCallback onReturnToFrozen;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final state = item.isArchived
        ? 'Archived'
        : item.thawState == ThawState.thawing
        ? 'Thawing'
        : 'Frozen';
    final semantics =
        '${item.name}, ${item.quantity.canonical} '
        '${item.unit.value}, $breadcrumb, $state';
    return Semantics(
      container: true,
      label: semantics,
      child: Card(
        key: Key('item-card-${item.id.value}'),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              Text(breadcrumb),
              const SizedBox(height: 4),
              Text('${item.quantity.canonical} ${item.unit.value}'),
              if (item.category.isNotEmpty) Text('Category: ${item.category}'),
              Text('Frozen on: ${_planningDate(item.frozenOn)}'),
              Text('Use first on: ${_planningDate(item.useFirstOn)}'),
              Text('State: $state'),
              Text('Last updated: ${_dateTime(item.updatedAt)}'),
              if (!item.isArchived) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _action(
                      key: Key('item-edit-${item.id.value}'),
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onPressed: onEdit,
                    ),
                    _action(
                      key: Key('item-decrement-${item.id.value}'),
                      icon: Icons.remove,
                      label: 'Use portion',
                      onPressed: onDecrement,
                    ),
                    _action(
                      key: Key('item-increment-${item.id.value}'),
                      icon: Icons.add,
                      label: 'Add portion',
                      onPressed: onIncrement,
                    ),
                    _action(
                      key: Key('item-consume-${item.id.value}'),
                      icon: Icons.done_all,
                      label: 'Consume all',
                      onPressed: onConsumeAll,
                    ),
                    _action(
                      key: Key('item-move-${item.id.value}'),
                      icon: Icons.drive_file_move_outline,
                      label: 'Move',
                      onPressed: onMove,
                    ),
                    if (item.thawState == ThawState.frozen)
                      _action(
                        key: Key('item-thaw-${item.id.value}'),
                        icon: Icons.ac_unit,
                        label: 'Mark thawing',
                        onPressed: onThaw,
                      )
                    else
                      _action(
                        key: Key('item-freeze-${item.id.value}'),
                        icon: Icons.undo,
                        label: 'Return to frozen',
                        onPressed: onReturnToFrozen,
                      ),
                    _action(
                      key: Key('item-archive-${item.id.value}'),
                      icon: Icons.archive_outlined,
                      label: 'Archive',
                      onPressed: onArchive,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _action({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => OutlinedButton.icon(
    key: key,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(44, 44),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
  );

  static String _planningDate(PlanningDate date) =>
      date.isKnown ? '${_date(date.value!)} (planning date)' : 'Unknown';

  static String _dateTime(DateTime value) =>
      '${_date(value.toLocal())} '
      '${value.toLocal().hour.toString().padLeft(2, '0')}:'
      '${value.toLocal().minute.toString().padLeft(2, '0')}';

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

final class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$title. $message',
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 40),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
