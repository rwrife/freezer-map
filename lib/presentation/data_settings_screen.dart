import 'package:flutter/material.dart';
import 'package:freezer_map/application/data_management.dart';

class DataSettingsScreen extends StatefulWidget {
  const DataSettingsScreen({
    required this.portability,
    required this.documents,
    required this.nowUtc,
    super.key,
  });

  final DataPortability portability;
  final DocumentGateway documents;
  final DateTime Function() nowUtc;

  @override
  State<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends State<DataSettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data & privacy')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your data stays local',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Freezer Map stores inventory in this app’s private on-device '
            'database. It has no account, analytics, telemetry, advertising, '
            'or upload path. Files are opened or created only when you choose '
            'a location in the system document picker.',
          ),
          const SizedBox(height: 20),
          _ActionTile(
            icon: Icons.backup_outlined,
            title: 'Save JSON backup',
            subtitle: 'Complete, versioned restore format including history and reminders.',
            enabled: !_busy,
            onTap: _exportJson,
          ),
          _ActionTile(
            icon: Icons.restore,
            title: 'Restore JSON backup',
            subtitle:
                'Fully validated with a dry-run summary before any write.',
            enabled: !_busy,
            onTap: _restore,
          ),
          _ActionTile(
            icon: Icons.table_view_outlined,
            title: 'Save CSV export',
            subtitle: 'Inspectable item list; history, reminders, and hierarchy metadata are omitted.',
            enabled: !_busy,
            onTap: _exportCsv,
          ),
          const Divider(height: 32),
          _ActionTile(
            icon: Icons.delete_forever,
            title: 'Delete all local data',
            subtitle: 'Permanently removes inventory, history, and reminder records from this device.',
            enabled: !_busy,
            destructive: true,
            onTap: _deleteAll,
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: LinearProgressIndicator(
                semanticsLabel: 'Data operation in progress',
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _exportJson() async {
    if (!await _confirmSharing(
      'Save a complete backup?',
      'The JSON file can contain item names, notes, locations, history, and '
          'reminder settings. Freezer Map does not upload it; anyone you share '
          'it with may be able to read it.',
      'Choose location',
    )) {
      return;
    }
    await _run(() async {
      final now = widget.nowUtc().toUtc();
      final contents = await widget.portability.createJsonBackup(
        exportedAt: now,
      );
      final saved = await widget.documents.saveText(
        suggestedName: 'freezer-map-backup-${_day(now)}.json',
        mimeType: 'application/json',
        contents: contents,
      );
      _notify(
        saved ? 'JSON backup saved.' : 'Backup cancelled; no file was written.',
      );
    });
  }

  Future<void> _exportCsv() async {
    if (!await _confirmSharing(
      'Save a lossy CSV export?',
      'CSV contains an inspectable item view but omits event history, reminders, '
          'stable relationship metadata, and nested structure details. It cannot '
          'be used as a complete restore. Treat it as private when sharing.',
      'Choose location',
    )) {
      return;
    }
    await _run(() async {
      final now = widget.nowUtc().toUtc();
      final saved = await widget.documents.saveText(
        suggestedName: 'freezer-map-items-${_day(now)}.csv',
        mimeType: 'text/csv',
        contents: await widget.portability.createCsvExport(),
      );
      _notify(
        saved ? 'CSV export saved.' : 'Export cancelled; no file was written.',
      );
    });
  }

  Future<void> _restore() async {
    final source = await _runWithResult(widget.documents.openJson);
    if (source == null || !mounted) return;
    final mode = await showDialog<RestoreMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose restore mode'),
        content: const Text(
          'Replace removes current local data only after validation succeeds. '
          'Merge keeps current data but rejects every stable-ID collision.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, RestoreMode.merge),
            child: const Text('Merge'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, RestoreMode.replace),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (mode == null) return;
    await _run(() async {
      final prepared = await widget.portability.prepareRestore(
        source,
        mode: mode,
      );
      if (!mounted) return;
      final approved =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Restore dry run passed'),
              content: Text(
                '${prepared.summary.description} passed schema, domain, and '
                'reference validation. ${mode == RestoreMode.replace ? 'Current data will be replaced.' : 'These records will be added.'}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Apply restore'),
                ),
              ],
            ),
          ) ??
          false;
      if (!approved) return;
      await widget.portability.applyRestore(prepared);
      _notify('Restore completed transactionally.');
    });
  }

  Future<void> _deleteAll() async {
    final confirmed = await _confirmSharing(
      'Delete all local data?',
      'This permanently deletes appliances, zones, items, event history, and '
          'reminder records from this device. Export a backup first if needed.',
      'Delete everything',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() async {
      await widget.portability.deleteAllAndVerify();
      _notify(
        'All local inventory and reminder records were deleted and verified.',
      );
    });
  }

  Future<bool> _confirmSharing(
    String title,
    String message,
    String action, {
    bool destructive = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    )
                  : null,
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _notify('Operation failed; local data is unchanged. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<T?> _runWithResult<T>(Future<T?> Function() action) async {
    T? result;
    await _run(() async => result = await action());
    return result;
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      icon,
      color: destructive ? Theme.of(context).colorScheme.error : null,
    ),
    title: Text(
      title,
      style: destructive
          ? TextStyle(color: Theme.of(context).colorScheme.error)
          : null,
    ),
    subtitle: Text(subtitle),
    enabled: enabled,
    onTap: enabled ? onTap : null,
  );
}

String _day(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
