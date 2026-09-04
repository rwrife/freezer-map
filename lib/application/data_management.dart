abstract interface class DocumentGateway {
  Future<String?> openJson();

  Future<bool> saveText({
    required String suggestedName,
    required String mimeType,
    required String contents,
  });
}

enum RestoreMode { replace, merge }

final class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class RestoreSummary {
  const RestoreSummary({
    required this.mode,
    required this.appliances,
    required this.zones,
    required this.items,
    required this.events,
    required this.reminders,
  });

  final RestoreMode mode;
  final int appliances;
  final int zones;
  final int items;
  final int events;
  final int reminders;

  int get total => appliances + zones + items + events + reminders;

  String get description =>
      '$appliances appliances, $zones zones, $items items, '
      '$events events, and $reminders reminders';
}

abstract interface class PreparedRestore {
  RestoreSummary get summary;
}

abstract interface class DataPortability {
  Future<String> createJsonBackup({required DateTime exportedAt});
  Future<String> createCsvExport();
  Future<PreparedRestore> prepareRestore(
    String source, {
    required RestoreMode mode,
  });
  Future<void> applyRestore(PreparedRestore restore);
  Future<void> deleteAllAndVerify();
}
