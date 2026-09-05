import 'package:flutter/material.dart';
import 'package:freezer_map/domain/entities.dart';

final class ReminderDraft {
  const ReminderDraft({
    required this.isEnabled,
    required this.scheduledForLocal,
    required this.privacyMode,
  });

  final bool isEnabled;
  final DateTime scheduledForLocal;
  final ReminderPrivacyMode privacyMode;
}

final class ReminderDialog extends StatefulWidget {
  const ReminderDialog({
    required this.item,
    required this.nowLocal,
    required this.initial,
    super.key,
  });

  final FreezerItem item;
  final DateTime nowLocal;
  final Reminder? initial;

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

final class _ReminderDialogState extends State<ReminderDialog> {
  late bool _enabled;
  late DateTime _scheduledLocal;
  late ReminderPrivacyMode _privacyMode;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _enabled = initial?.isEnabled ?? false;
    _scheduledLocal =
        initial?.scheduledFor.toLocal() ??
        widget.nowLocal.add(const Duration(days: 1));
    _scheduledLocal = DateTime(
      _scheduledLocal.year,
      _scheduledLocal.month,
      _scheduledLocal.day,
      _scheduledLocal.hour,
      _scheduledLocal.minute,
    );
    _privacyMode = initial?.privacyMode ?? ReminderPrivacyMode.generic;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Reminder for ${widget.item.name}'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reminders are planning metadata only.'),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            key: const Key('reminder-enabled-switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable reminder'),
            subtitle: const Text(
              'Requests notification permission only when enabled.',
            ),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          if (_enabled) ...[
            const SizedBox(height: 8),
            Text(
              'Date and time',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pickerButton(
                  key: const Key('reminder-date-button'),
                  icon: Icons.event_outlined,
                  title: 'Date',
                  value: _date(_scheduledLocal),
                  onPressed: _pickDate,
                ),
                const SizedBox(height: 8),
                _pickerButton(
                  key: const Key('reminder-time-button'),
                  icon: Icons.schedule,
                  title: 'Time',
                  value: _time(_scheduledLocal),
                  onPressed: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderPrivacyMode>(
              key: const Key('reminder-privacy-mode'),
              isExpanded: true,
              initialValue: _privacyMode,
              decoration: const InputDecoration(
                labelText: 'Notification text',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ReminderPrivacyMode.generic,
                  child: Text('Generic text'),
                ),
                DropdownMenuItem(
                  value: ReminderPrivacyMode.itemName,
                  child: Text('Include item name'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _privacyMode = value);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                key: const Key('reminder-dialog-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ],
      ),
    ),
    actions: _actions(),
  );

  List<Widget> _actions() => [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    FilledButton(
      key: const Key('reminder-save-button'),
      onPressed: _save,
      child: Text(_enabled ? 'Save' : 'Disable'),
    ),
  ];

  Widget _pickerButton({
    required Key key,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      key: key,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [Icon(icon), Text('$title $value')],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _scheduledLocal,
      firstDate: DateTime(widget.nowLocal.year - 1),
      lastDate: DateTime(widget.nowLocal.year + 10),
    );
    if (value == null || !mounted) return;
    setState(
      () => _scheduledLocal = DateTime(
        value.year,
        value.month,
        value.day,
        _scheduledLocal.hour,
        _scheduledLocal.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledLocal),
    );
    if (value == null || !mounted) return;
    setState(
      () => _scheduledLocal = DateTime(
        _scheduledLocal.year,
        _scheduledLocal.month,
        _scheduledLocal.day,
        value.hour,
        value.minute,
      ),
    );
  }

  void _save() {
    if (_enabled && !_scheduledLocal.isAfter(widget.nowLocal)) {
      setState(() => _error = 'Choose a future local date and time.');
      return;
    }
    Navigator.pop(
      context,
      ReminderDraft(
        isEnabled: _enabled,
        scheduledForLocal: _scheduledLocal,
        privacyMode: _privacyMode,
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
