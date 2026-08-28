import 'package:flutter/material.dart';
import 'package:freezer_map/presentation/empty_inventory_screen.dart';

class FreezerMapApp extends StatelessWidget {
  const FreezerMapApp({super.key});

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
      home: const EmptyInventoryScreen(),
    );
  }
}
