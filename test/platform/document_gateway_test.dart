import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/platform/document_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FilePickerPlatform original;
  late _FakeFilePicker picker;

  setUp(() {
    original = FilePickerPlatform.instance;
    picker = _FakeFilePicker();
    FilePickerPlatform.instance = picker;
  });

  tearDown(() => FilePickerPlatform.instance = original);

  test('openJson uses the scoped JSON picker and reads its result', () async {
    picker.openResult = _MemoryPlatformFile(
      name: 'backup.json',
      bytes: Uint8List.fromList('{"format":"freezer-map-backup"}'.codeUnits),
    );

    final result = await const FilePickerDocumentGateway().openJson();

    expect(result, '{"format":"freezer-map-backup"}');
    expect(picker.openType, FileType.custom);
    expect(picker.openExtensions, ['json']);
  });

  test(
    'saveText passes bytes only to the user-initiated save picker',
    () async {
      picker.saveResult = Uri.parse('content://documents/chosen.json');

      final saved = await const FilePickerDocumentGateway().saveText(
        suggestedName: 'suggested.json',
        mimeType: 'application/json',
        contents: '{"version":1}',
      );

      expect(saved, isTrue);
      expect(picker.savedName, 'suggested.json');
      expect(picker.savedMimeType, 'application/json');
      expect(String.fromCharCodes(picker.savedBytes!), '{"version":1}');
    },
  );

  test('picker cancellation reports that no file was written', () async {
    expect(
      await const FilePickerDocumentGateway().saveText(
        suggestedName: 'backup.json',
        mimeType: 'application/json',
        contents: 'private',
      ),
      isFalse,
    );
  });
}

final class _FakeFilePicker extends FilePickerPlatform {
  PlatformFile? openResult;
  Uri? saveResult;
  FileType? openType;
  List<String>? openExtensions;
  String? savedName;
  String? savedMimeType;
  Uint8List? savedBytes;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    openType = type;
    openExtensions = allowedExtensions;
    return openResult;
  }

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    void Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    savedName = fileName;
    savedMimeType = mimeType;
    savedBytes = bytes;
    return saveResult;
  }
}

base class _MemoryPlatformFile extends PlatformFile {
  _MemoryPlatformFile({required this.name, required Uint8List bytes})
    : _bytes = bytes,
      uri = Uri.dataFromBytes(bytes);

  final Uint8List _bytes;

  @override
  final String name;

  @override
  final Uri uri;

  @override
  Never get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => _bytes.length;

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}
