import 'package:flutter/material.dart';

class EmptyInventoryScreen extends StatelessWidget {
  const EmptyInventoryScreen({super.key});

  static const heading = 'No freezer locations yet';
  static const description =
      'Freezer Map will keep your inventory on this device. '
      'Appliance and zone setup arrives in the next milestone.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Freezer Map')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(child: Icon(Icons.ac_unit, size: 64)),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: const Text(
                      heading,
                      key: Key('empty-state-heading'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(description, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
