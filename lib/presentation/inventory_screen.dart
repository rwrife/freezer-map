import 'package:flutter/material.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/domain/entities.dart';
import 'package:freezer_map/domain/value_objects.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    required this.repository,
    required this.commands,
    super.key,
  });

  final TransactionalInventoryRepository repository;
  final InventoryCommands commands;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _loading = true;
  Object? _error;
  List<Appliance> _appliances = const [];
  List<Zone> _zones = const [];
  List<FreezerItem> _items = const [];
  ZoneId? _recentZoneId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appliances = await widget.repository.appliances();
      final zones = await widget.repository.zones();
      final items = await widget.repository.items();
      if (!mounted) return;
      setState(() {
        _appliances = appliances;
        _zones = zones;
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _setup() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _SetupDialog(commands: widget.commands),
    );
    if (created == true && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freezer Map'),
        actions: [
          if (!_loading && _error == null && _appliances.isNotEmpty)
            IconButton(
              tooltip: 'Add appliance',
              onPressed: _addAppliance,
              icon: const Icon(Icons.kitchen),
            ),
        ],
      ),
      body: SafeArea(child: _body()),
      floatingActionButton: !_loading && _error == null && _zones.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _editItem(),
              tooltip: 'Add freezer item',
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            )
          : null,
    );
  }

  Widget _body() {
    if (_loading) {
      return Center(
        child: Semantics(
          label: 'Loading freezer inventory',
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load your freezer data.'),
            const Text('Your on-device data is unchanged. Try again.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_appliances.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No freezer locations yet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text('Set up an appliance and its first storage zone.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _setup,
                child: const Text('Set up a freezer'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final appliance in _appliances) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              appliance.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            trailing: PopupMenuButton<String>(
              key: Key('appliance-menu-${appliance.id.value}'),
              tooltip: 'Actions for ${appliance.name}',
              onSelected: (action) => _applianceAction(appliance, action),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'zone', child: Text('Add top-level zone')),
                PopupMenuItem(value: 'rename', child: Text('Rename appliance')),
                PopupMenuItem(value: 'up', child: Text('Move appliance up')),
                PopupMenuItem(
                  value: 'down',
                  child: Text('Move appliance down'),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: Text('Archive appliance'),
                ),
              ],
            ),
          ),
          for (final zone in _zones.where(
            (zone) => zone.applianceId == appliance.id,
          ))
            ListTile(
              title: Text(zone.name),
              subtitle: Text(_breadcrumb(zone)),
              trailing: PopupMenuButton<String>(
                key: Key('zone-menu-${zone.id.value}'),
                tooltip: 'Actions for ${zone.name}',
                onSelected: (action) => _zoneAction(zone, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'child', child: Text('Add subzone')),
                  PopupMenuItem(value: 'rename', child: Text('Rename zone')),
                  PopupMenuItem(value: 'up', child: Text('Move zone up')),
                  PopupMenuItem(value: 'down', child: Text('Move zone down')),
                  PopupMenuItem(value: 'move', child: Text('Move zone')),
                  PopupMenuItem(value: 'archive', child: Text('Archive zone')),
                ],
              ),
            ),
          for (final item in _items.where(
            (item) => _zones.any(
              (zone) =>
                  zone.id == item.zoneId && zone.applianceId == appliance.id,
            ),
          ))
            Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity.canonical} ${item.unit.value} • '
                  '${_breadcrumb(_zone(item.zoneId))}',
                ),
                trailing: IconButton(
                  key: Key('item-edit-${item.id.value}'),
                  tooltip: 'Edit ${item.name}',
                  onPressed: () => _editItem(item),
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Zone _zone(ZoneId id) => _zones.firstWhere((zone) => zone.id == id);

  Future<void> _editItem([FreezerItem? item]) async {
    final savedZone = await showDialog<ZoneId>(
      context: context,
      builder: (context) => _ItemDialog(
        commands: widget.commands,
        zones: _zones,
        breadcrumbs: {for (final zone in _zones) zone.id: _breadcrumb(zone)},
        item: item,
        recentZoneId: _recentZoneId,
      ),
    );
    if (savedZone == null) return;
    if (!mounted) return;
    _recentZoneId = savedZone;
    await _reload();
  }

  Future<bool?> _askName({
    required String title,
    required String label,
    required Future<void> Function(String name) save,
    String initial = '',
  }) => showDialog<bool>(
    context: context,
    builder: (context) =>
        _NameDialog(title: title, label: label, initial: initial, save: save),
  );

  Future<void> _addAppliance() async {
    final saved = await _askName(
      title: 'Add appliance',
      label: 'Appliance name',
      save: (name) => widget.commands.createAppliance(
        name: name,
        sortOrder: _nextSortOrder(_appliances.map((value) => value.sortOrder)),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  Future<void> _applianceAction(Appliance appliance, String action) async {
    if (action == 'zone') {
      await _addZone(appliance);
    } else if (action == 'rename') {
      final saved = await _askName(
        title: 'Rename appliance',
        label: 'Appliance name',
        initial: appliance.name,
        save: (name) => widget.commands.updateAppliance(
          appliance.id,
          name: name,
          sortOrder: appliance.sortOrder,
        ),
      );
      if (saved == true && mounted) await _reload();
    } else if (action == 'up' || action == 'down') {
      await _reorderAppliance(appliance, action == 'up' ? -1 : 1);
    } else if (action == 'archive') {
      await _runWrite(
        () => widget.commands.archiveAppliance(appliance.id),
        destructive: true,
      );
    }
  }

  Future<void> _reorderAppliance(Appliance appliance, int offset) async {
    final index = _appliances.indexWhere((value) => value.id == appliance.id);
    final target = index + offset;
    if (target < 0 || target >= _appliances.length) return;
    final other = _appliances[target];
    await _runWrite(
      () => widget.commands.reorderAppliances(appliance.id, other.id),
    );
  }

  Future<void> _addZone(Appliance appliance, [Zone? parent]) async {
    final siblings = _zones.where(
      (zone) => zone.applianceId == appliance.id && zone.parentId == parent?.id,
    );
    final saved = await _askName(
      title: parent == null ? 'Add top-level zone' : 'Add subzone',
      label: 'Zone name',
      save: (name) => widget.commands.createZone(
        applianceId: appliance.id,
        parentId: parent?.id,
        name: name,
        sortOrder: _nextSortOrder(siblings.map((value) => value.sortOrder)),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  int _nextSortOrder(Iterable<int> existing) => existing.fold(
    0,
    (next, sortOrder) => sortOrder >= next ? sortOrder + 1 : next,
  );

  Future<void> _zoneAction(Zone zone, String action) async {
    final appliance = _appliances.firstWhere(
      (candidate) => candidate.id == zone.applianceId,
    );
    if (action == 'child') {
      await _addZone(appliance, zone);
    } else if (action == 'rename') {
      final saved = await _askName(
        title: 'Rename zone',
        label: 'Zone name',
        initial: zone.name,
        save: (name) => widget.commands.updateZone(
          zone.id,
          name: name,
          sortOrder: zone.sortOrder,
        ),
      );
      if (saved == true && mounted) await _reload();
    } else if (action == 'up' || action == 'down') {
      await _reorderZone(zone, action == 'up' ? -1 : 1);
    } else if (action == 'move') {
      await _moveZone(zone);
    } else if (action == 'archive') {
      await _runWrite(
        () => widget.commands.archiveZone(zone.id),
        destructive: true,
      );
    }
  }

  Future<void> _reorderZone(Zone zone, int offset) async {
    final siblings =
        _zones
            .where(
              (candidate) =>
                  candidate.applianceId == zone.applianceId &&
                  candidate.parentId == zone.parentId,
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final index = siblings.indexWhere((value) => value.id == zone.id);
    final target = index + offset;
    if (target < 0 || target >= siblings.length) return;
    final other = siblings[target];
    await _runWrite(() => widget.commands.reorderZones(zone.id, other.id));
  }

  Future<void> _runWrite(
    Future<void> Function() write, {
    bool destructive = false,
  }) async {
    if (destructive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Archive location?'),
          content: const Text(
            'Archiving hides this location. Move or archive its active '
            'zones and items first; nothing is deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!mounted) return;
    }
    try {
      await write();
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            destructive
                ? '${_message(error)} Nothing was deleted.'
                : _message(error),
          ),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
    }
  }

  String _breadcrumb(Zone zone) {
    final names = <String>[zone.name];
    var parentId = zone.parentId;
    while (parentId != null) {
      final parent = _zones
          .where((candidate) => candidate.id == parentId)
          .first;
      names.insert(0, parent.name);
      parentId = parent.parentId;
    }
    final appliance = _appliances
        .where((candidate) => candidate.id == zone.applianceId)
        .first;
    names.insert(0, appliance.name);
    return names.join(' › ');
  }

  Future<void> _moveZone(Zone zone) async {
    ZoneId? selected;
    String? error;
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Move ${zone.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<ZoneId?>(
                decoration: const InputDecoration(
                  labelText: 'New parent',
                  helperText: 'Choose top level to keep this zone shallow.',
                ),
                initialValue: selected,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Top level')),
                  for (final candidate in _zones.where(
                    (candidate) => candidate.applianceId == zone.applianceId,
                  ))
                    DropdownMenuItem(
                      value: candidate.id,
                      child: Text(_breadcrumb(candidate)),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (value) => setDialogState(() => selected = value),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await widget.commands.moveZone(
                          zone.id,
                          newParentId: selected,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) await _reload();
                      } catch (caught) {
                        if (dialogContext.mounted) {
                          setDialogState(() {
                            saving = false;
                            error = _message(caught);
                          });
                        }
                      }
                    },
              child: Text(saving ? 'Moving…' : 'Move'),
            ),
          ],
        ),
      ),
    );
  }
}

String _message(Object error) {
  if (error is DomainValidationException) return error.message;
  return 'Could not save to on-device storage. Try again; your entries are still here.';
}

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({
    required this.commands,
    required this.zones,
    required this.breadcrumbs,
    required this.item,
    required this.recentZoneId,
  });

  final InventoryCommands commands;
  final List<Zone> zones;
  final Map<ZoneId, String> breadcrumbs;
  final FreezerItem? item;
  final ZoneId? recentZoneId;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.save,
  });

  final String title;
  final String label;
  final String initial;
  final Future<void> Function(String name) save;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            autofocus: true,
            enabled: !_saving,
            decoration: InputDecoration(labelText: widget.label),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a name.' : null,
            onFieldSubmitted: (_) {
              if (!_saving) _submit();
            },
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _saveError!,
                key: const Key('name-save-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _submit,
        child: Text(_saving ? 'Saving…' : 'Save'),
      ),
    ],
  );

  Future<void> _submit() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.save(_controller.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = _message(error);
        });
      }
    }
  }
}

class _ItemDialogState extends State<_ItemDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _category;
  late final TextEditingController _frozenOn;
  late final TextEditingController _useFirstOn;
  late final TextEditingController _notes;
  ZoneId? _zoneId;
  String? _locationError;
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name);
    _quantity = TextEditingController(text: item?.quantity.canonical);
    _unit = TextEditingController(text: item?.unit.value ?? 'portions');
    _category = TextEditingController(text: item?.category);
    _frozenOn = TextEditingController(text: _date(item?.frozenOn.value));
    _useFirstOn = TextEditingController(text: _date(item?.useFirstOn.value));
    _notes = TextEditingController(text: item?.notes);
    _zoneId = item?.zoneId;
  }

  static String _date(DateTime? value) => value == null
      ? ''
      : '${value.year.toString().padLeft(4, '0')}-'
            '${value.month.toString().padLeft(2, '0')}-'
            '${value.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    for (final controller in [
      _name,
      _quantity,
      _unit,
      _category,
      _frozenOn,
      _useFirstOn,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _positive(String? value) {
    try {
      if (value == null || !PortionQuantity.parse(value).isPositive) {
        return 'Enter a quantity greater than zero.';
      }
    } catch (_) {
      return 'Enter a valid positive number.';
    }
    return null;
  }

  String? _planningDate(String? source, {required bool optional}) {
    final value = source?.trim() ?? '';
    if (value.isEmpty && optional) return null;
    if (value.toLowerCase() == 'unknown') return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null || _date(parsed) != value) {
      return 'Use YYYY-MM-DD${optional ? ' or leave blank' : ' or unknown'}.';
    }
    return null;
  }

  PlanningDate _parseDate(String source) {
    final value = source.trim();
    return value.isEmpty || value.toLowerCase() == 'unknown'
        ? const PlanningDate.unknown()
        : PlanningDate.known(DateTime.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    final recent = widget.recentZoneId;
    return AlertDialog(
      title: Text(widget.item == null ? 'Add freezer item' : 'Edit item'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _required,
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  controller: _quantity,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: _positive,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  controller: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: _required,
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  textInputAction: TextInputAction.next,
                ),
                DropdownButtonFormField<ZoneId>(
                  initialValue: _zoneId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Appliance and zone',
                    hintText: 'Choose location',
                    errorText: _locationError,
                  ),
                  items: [
                    for (final zone in widget.zones)
                      DropdownMenuItem(
                        value: zone.id,
                        child: Text(
                          widget.breadcrumbs[zone.id]!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _zoneId = value;
                    _locationError = null;
                  }),
                ),
                if (widget.item == null &&
                    recent != null &&
                    widget.breadcrumbs.containsKey(recent))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(Icons.history),
                      label: Text('Use recent: ${widget.breadcrumbs[recent]}'),
                      onPressed: () => setState(() {
                        _zoneId = recent;
                        _locationError = null;
                      }),
                    ),
                  ),
                TextFormField(
                  controller: _frozenOn,
                  decoration: const InputDecoration(
                    labelText: 'Frozen on',
                    hintText: 'YYYY-MM-DD or unknown',
                    helperText: 'Planning metadata only',
                  ),
                  validator: (value) => _planningDate(value, optional: false),
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  controller: _useFirstOn,
                  decoration: const InputDecoration(
                    labelText: 'Use first on',
                    hintText: 'YYYY-MM-DD (optional)',
                    helperText: 'Planning metadata only',
                  ),
                  validator: (value) => _planningDate(value, optional: true),
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  minLines: 2,
                  maxLines: 4,
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _saveError!,
                    key: const Key('item-save-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(widget.item == null ? 'Add item' : 'Save changes'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _locationError = _zoneId == null ? 'Choose an appliance and zone.' : null;
      _saveError = null;
    });
    if (!_form.currentState!.validate() || _zoneId == null) return;
    setState(() => _saving = true);
    try {
      final item = widget.item;
      if (item == null) {
        await widget.commands.createItem(
          name: _name.text,
          category: _category.text,
          zoneId: _zoneId!,
          quantity: PortionQuantity.parse(_quantity.text),
          unit: PortionUnit(_unit.text),
          frozenOn: _parseDate(_frozenOn.text),
          useFirstOn: _parseDate(_useFirstOn.text),
          notes: _notes.text,
        );
      } else {
        await widget.commands.editItem(
          item.id,
          name: _name.text,
          category: _category.text,
          quantity: PortionQuantity.parse(_quantity.text),
          unit: PortionUnit(_unit.text),
          frozenOn: _parseDate(_frozenOn.text),
          useFirstOn: _parseDate(_useFirstOn.text),
          notes: _notes.text,
          zoneId: _zoneId!,
        );
      }
      if (mounted) Navigator.pop(context, _zoneId);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = _message(error);
        });
      }
    }
  }
}

class _SetupDialog extends StatefulWidget {
  const _SetupDialog({required this.commands});

  final InventoryCommands commands;

  @override
  State<_SetupDialog> createState() => _SetupDialogState();
}

class _SetupDialogState extends State<_SetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appliance = TextEditingController();
  final _zone = TextEditingController();
  bool _saving = false;
  String? _saveError;

  @override
  void dispose() {
    _appliance.dispose();
    _zone.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Enter a name.' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set up a freezer'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _appliance,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Appliance name'),
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _zone,
                decoration: const InputDecoration(labelText: 'First zone name'),
                validator: _required,
                onFieldSubmitted: (_) {
                  if (!_saving) _submit();
                },
              ),
              if (_saveError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _saveError!,
                  key: const Key('setup-save-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Creating…' : 'Create location'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.commands.createInitialLocation(
        applianceName: _appliance.text.trim(),
        zoneName: _zone.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = _message(error);
        });
      }
    }
  }
}
