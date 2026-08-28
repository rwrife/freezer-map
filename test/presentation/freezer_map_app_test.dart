import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/presentation/empty_inventory_screen.dart';
import 'package:freezer_map/presentation/freezer_map_app.dart';

void main() {
  testWidgets('starts on an honest, accessible empty state', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const FreezerMapApp());

    expect(find.text('Freezer Map'), findsOneWidget);
    expect(find.text(EmptyInventoryScreen.heading), findsOneWidget);
    expect(find.text(EmptyInventoryScreen.description), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const Key('empty-state-heading'))).label,
      EmptyInventoryScreen.heading,
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);

    semantics.dispose();
  });

  testWidgets('empty state remains usable at 200% text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const FreezerMapApp(),
      ),
    );

    expect(find.text(EmptyInventoryScreen.heading), findsOneWidget);
    expect(find.text(EmptyInventoryScreen.description), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
