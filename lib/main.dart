import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/data/app_database.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/data/drift_inventory_repository.dart';
import 'package:freezer_map/presentation/freezer_map_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FreezerMapBootstrap());
}

typedef DatabaseOpener = Future<FreezerDatabase> Function();
typedef StableIdSourceFactory = StableIdSource Function();

StableIdSource createLocalStableIds() => LocalStableIds();

class FreezerMapBootstrap extends StatefulWidget {
  const FreezerMapBootstrap({
    this.databaseOpener = openAppPrivateDatabase,
    this.idSourceFactory = createLocalStableIds,
    super.key,
  });

  final DatabaseOpener databaseOpener;
  final StableIdSourceFactory idSourceFactory;

  @override
  State<FreezerMapBootstrap> createState() => _FreezerMapBootstrapState();
}

class _FreezerMapBootstrapState extends State<FreezerMapBootstrap> {
  late final StableIdSource _ids;
  FreezerDatabase? _database;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _ids = widget.idSourceFactory();
    _open();
  }

  Future<void> _open() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });
    try {
      final database = await widget.databaseOpener();
      if (!mounted) {
        await database.close();
        return;
      }
      setState(() {
        _database = database;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = _database;
    if (database != null) {
      return FreezerMapApp.inventory(
        repository: DriftInventoryRepository(database),
        clock: const _SystemClock(),
        ids: _ids,
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FreezerMapApp.appTitle,
      home: Scaffold(
        appBar: AppBar(title: const Text(FreezerMapApp.appTitle)),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator(
                  semanticsLabel: 'Opening on-device freezer storage',
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not open on-device freezer storage.'),
                      const SizedBox(height: 8),
                      const Text(
                        'Your data has not been changed. Check available '
                        'device storage, then try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _open,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

final class _SystemClock implements Clock {
  const _SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

final class LocalStableIds implements StableIdSource {
  LocalStableIds() : _random = Random.secure();

  final Random _random;

  @override
  String next() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    growable: false,
  ).join();
}
