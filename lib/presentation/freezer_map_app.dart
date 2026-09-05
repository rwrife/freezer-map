import 'package:flutter/material.dart';
import 'package:freezer_map/application/data_management.dart';
import 'package:freezer_map/application/inventory_commands.dart';
import 'package:freezer_map/domain/contracts.dart';
import 'package:freezer_map/presentation/empty_inventory_screen.dart';
import 'package:freezer_map/presentation/inventory_screen.dart';

class FreezerMapApp extends StatelessWidget {
  const FreezerMapApp({super.key})
    : repository = null,
      clock = null,
      ids = null,
      portability = null,
      documents = null;

  const FreezerMapApp.inventory({
    required TransactionalInventoryRepository this.repository,
    required Clock this.clock,
    required StableIdSource this.ids,
    this.portability,
    this.documents,
    super.key,
  });

  final TransactionalInventoryRepository? repository;
  final Clock? clock;
  final StableIdSource? ids;
  final DataPortability? portability;
  final DocumentGateway? documents;

  static const appTitle = 'Freezer Map';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF286983)),
        useMaterial3: true,
      ),
      home: repository == null
          ? const EmptyInventoryScreen()
          : InventoryScreen(
              repository: repository!,
              commands: InventoryCommands(
                repository: repository!,
                clock: clock!,
                ids: ids!,
              ),
              portability: portability,
              documents: documents,
              nowUtc: clock!.nowUtc,
            ),
    );
  }
}
