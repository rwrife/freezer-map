import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:freezer_map/application/data_management.dart';

final class FilePickerDocumentGateway implements DocumentGateway {
  const FilePickerDocumentGateway();

  @override
  Future<String?> openJson() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Choose a Freezer Map JSON backup',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes());
  }

  @override
  Future<bool> saveText({
    required String suggestedName,
    required String mimeType,
    required String contents,
  }) async {
    final location = await FilePicker.saveFile(
      dialogTitle: 'Choose where to save the Freezer Map file',
      fileName: suggestedName,
      bytes: Uint8List.fromList(utf8.encode(contents)),
      mimeType: mimeType,
      type: FileType.custom,
      allowedExtensions: [suggestedName.split('.').last],
    );
    return location != null;
  }
}
