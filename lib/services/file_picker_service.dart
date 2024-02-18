import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileData {
  final String fileType;
  final Uint8List bytes;
  const FileData({
    required this.fileType,
    required this.bytes,
  });
}

class FilePickerService {
  Future<List<FileData>?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    dynamic Function(FilePickerStatus)? onFileLoading,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      onFileLoading: onFileLoading,
    );
    debugPrint('result: $result');
    if (result != null) {
      final files = result.files;

      files.removeWhere((element) => element.path == null);

      debugPrint('returning: ${files.length}');
      return files.map(
        (e) {
          final bytes = File(e.path!).readAsBytesSync();
          return FileData(
            fileType: 'image/${e.extension!}',
            bytes: bytes,
          );
        },
      ).toList();
    } else {
      return null;
    }
  }
}
