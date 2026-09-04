import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/application/data_management.dart';
import 'package:freezer_map/data/data_portability.dart';
import 'package:freezer_map/data/database.dart';
import 'package:freezer_map/presentation/data_settings_screen.dart';

void main() {
  late FreezerDatabase database;
  late _FakeDocuments documents;

  setUp(() {
    database = FreezerDatabase.forTesting(NativeDatabase.memory());
    documents = _FakeDocuments();
  });

  tearDown(() => database.close());

  testWidgets('privacy controls remain reachable at 200% text scale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(database, documents, textScale: 2));

    expect(find.text('Your data stays local'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save JSON backup'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Save JSON backup'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Restore JSON backup'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Restore JSON backup'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save CSV export'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Save CSV export'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete all local data'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Delete all local data'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('backup warning precedes the scoped save adapter', (
    tester,
  ) async {
    await tester.pumpWidget(_app(database, documents));

    await tester.tap(find.text('Save JSON backup'));
    await tester.pumpAndSettle();
    expect(find.text('Save a complete backup?'), findsOneWidget);
    expect(documents.savedContents, isNull);

    await tester.tap(find.text('Choose location'));
    await tester.pumpAndSettle();
    expect(documents.savedName, 'freezer-map-backup-2026-09-04.json');
    expect(documents.savedContents, contains('"format": "freezer-map-backup"'));
    expect(find.text('JSON backup saved.'), findsOneWidget);
  });

  testWidgets('restore displays validated dry-run counts before writing', (
    tester,
  ) async {
    documents.openContents = 'synthetic backup selected by user';
    final portability = _TrackingPortability();
    await tester.pumpWidget(
      _app(database, documents, portability: portability),
    );

    await tester.tap(find.text('Restore JSON backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Restore dry run passed'), findsOneWidget);
    expect(
      find.textContaining(
        '1 appliances, 1 zones, 1 items, 0 events, and 0 reminders',
      ),
      findsOneWidget,
    );
    expect(portability.applied, isFalse);

    await tester.tap(find.text('Apply restore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(portability.applied, isTrue);
  });

  testWidgets(
    'delete all requires confirmation and reports verified completion',
    (tester) async {
      final portability = _TrackingPortability();
      await tester.pumpWidget(
        _app(database, documents, portability: portability),
      );
      await tester.scrollUntilVisible(
        find.text('Delete all local data'),
        100,
        scrollable: find.byType(Scrollable),
      );

      await tester.tap(find.text('Delete all local data'));
      await tester.pumpAndSettle();
      expect(find.text('Delete all local data?'), findsOneWidget);
      expect(portability.deleted, isFalse);

      await tester.tap(find.text('Delete everything'));
      await tester.pumpAndSettle();
      expect(portability.deleted, isTrue);
      expect(
        find.text(
          'All local inventory and reminder records were deleted and verified.',
        ),
        findsOneWidget,
      );
    },
  );
}

Widget _app(
  FreezerDatabase database,
  _FakeDocuments documents, {
  double textScale = 1,
  DataPortability? portability,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: DataSettingsScreen(
    portability: portability ?? DataPortabilityService(database),
    documents: documents,
    nowUtc: () => DateTime.utc(2026, 9, 4, 12),
  ),
);

final class _FakeDocuments implements DocumentGateway {
  String? openContents;
  String? savedName;
  String? savedContents;

  @override
  Future<String?> openJson() async => openContents;

  @override
  Future<bool> saveText({
    required String suggestedName,
    required String mimeType,
    required String contents,
  }) async {
    savedName = suggestedName;
    savedContents = contents;
    return true;
  }
}

final class _TrackingPortability implements DataPortability {
  bool applied = false;
  bool deleted = false;

  @override
  Future<void> applyRestore(PreparedRestore restore) async => applied = true;

  @override
  Future<String> createCsvExport() async => '';

  @override
  Future<String> createJsonBackup({required DateTime exportedAt}) async => '{}';

  @override
  Future<void> deleteAllAndVerify() async => deleted = true;

  @override
  Future<PreparedRestore> prepareRestore(
    String source, {
    required RestoreMode mode,
  }) async => _PreparedFixture(mode);
}

final class _PreparedFixture implements PreparedRestore {
  _PreparedFixture(RestoreMode mode)
    : summary = RestoreSummary(
        mode: mode,
        appliances: 1,
        zones: 1,
        items: 1,
        events: 0,
        reminders: 0,
      );

  @override
  final RestoreSummary summary;
}
