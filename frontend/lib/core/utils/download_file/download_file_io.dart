import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

// Saves a downloaded file to the device and returns the file path
Future<String?> saveDownloadedFile(Uint8List bytes, String filename) async {
  // Try to save in Downloads, fallback to temp if not available
  final directory =
      await getDownloadsDirectory() ?? await getTemporaryDirectory();

  // Build a unique file path so we don’t overwrite existing files
  final filePath = _buildUniquePath(directory.path, filename);
  final file = File(filePath);

  // Write the file to disk
  await file.writeAsBytes(bytes, flush: true);

  return file.path;
}

// Creates a unique file path by adding a counter if file already exists
String _buildUniquePath(String directoryPath, String filename) {
  final separator = Platform.pathSeparator;

  // Use a default name if filename is empty
  final safeFilename = filename.trim().isEmpty
      ? 'classified_images.zip'
      : filename;

  // Split filename into name and extension
  final dotIndex = safeFilename.lastIndexOf('.');
  final hasExtension = dotIndex > 0 && dotIndex < safeFilename.length - 1;
  final name = hasExtension
      ? safeFilename.substring(0, dotIndex)
      : safeFilename;
  final extension = hasExtension ? safeFilename.substring(dotIndex) : '';

  // Start with original filename
  var candidate = '$directoryPath$separator$safeFilename';
  var counter = 1;

  while (File(candidate).existsSync()) {
    candidate = '$directoryPath$separator${name}_$counter$extension';
    counter++;
  }

  return candidate;
}