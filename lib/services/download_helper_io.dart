import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(String filename, String content) async {
  try {
    // On Android, we use FilePicker to let the user choose where to save.
    // This avoids permission issues with specific directories like /Download.
    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save Export',
      fileName: filename,
      bytes: Uint8List.fromList(content.codeUnits),
    );

    if (outputFile != null) {
      print('File saved successfully to: $outputFile');
    } else {
      print('Save cancelled by user');
    }
  } catch (e) {
    print('Error exporting file on mobile: $e');
    
    // Fallback: save to app directory and notify
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsString(content);
      print('Fallback: File saved to $path');
    } catch (e2) {
       print('Fallback failed: $e2');
    }
  }
}
