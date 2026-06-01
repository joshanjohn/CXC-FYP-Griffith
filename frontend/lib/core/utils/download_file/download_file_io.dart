import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// Save downloaded ZIP file to the device
Future<String?> saveDownloadedFile(Uint8List bytes, String filename) async {

  // Use a default filename if none is provided
  final safeFilename = filename.trim().isEmpty
      ? 'classified_images.zip'
      : sanitizeFilename(filename);

  // Show save dialog on Android and iOS
  if (Platform.isAndroid || Platform.isIOS) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save classified images ZIP',
      fileName: safeFilename,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: bytes,
    );
  }

  // Get possible download locations
  final candidateDirectories = await resolveDownloadDirectories();

  Object? lastError;

  // Try saving the file in each directory
  for (final directory in candidateDirectories) {
    try {
      await directory.create(recursive: true);

      // Create a unique file path
      final filePath = buildUniquePath(directory.path, safeFilename);

      // Write file to disk
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      return file.path;
    } catch (error) {
      lastError = error;
    }
  }

  // Throw error if saving fails
  if (lastError != null) {
    throw Exception('Unable to save downloaded file: $lastError');
  }

  throw Exception('Unable to save downloaded file.');
}


// Determine suitable download directories for each platform
Future<List<Directory>> resolveDownloadDirectories() async {

  // Android download locations
  if (Platform.isAndroid) {
    final directories = <Directory>[
      Directory('/storage/emulated/0/Download'),
      Directory('/sdcard/Download'),
    ];

    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      directories.add(downloadsDirectory);
    }

    final externalDirectory = await getExternalStorageDirectory();
    if (externalDirectory != null) {
      directories.add(
        Directory(
          '${externalDirectory.path}${Platform.pathSeparator}Downloads',
        ),
      );
      directories.add(externalDirectory);
    }

    // Add app-specific directories as fallback
    directories.add(await getApplicationDocumentsDirectory());
    directories.add(await getTemporaryDirectory());

    return uniqueDirectories(directories);
  }

  // iOS storage locations
  if (Platform.isIOS) {
    return uniqueDirectories([
      await getApplicationDocumentsDirectory(),
      await getApplicationSupportDirectory(),
      await getTemporaryDirectory(),
    ]);
  }

  // Desktop download locations
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    final directories = <Directory>[];

    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      directories.add(downloadsDirectory);
    }

    directories.add(await getApplicationDocumentsDirectory());
    directories.add(await getTemporaryDirectory());

    return uniqueDirectories(directories);
  }

  // Fallback location
  return [await getTemporaryDirectory()];
}


// Generate a unique file path to avoid overwriting existing files
String buildUniquePath(String directoryPath, String filename) {

  final separator = Platform.pathSeparator;

  // Ensure filename is valid
  final safeFilename = filename.trim().isEmpty
      ? 'classified_images.zip'
      : sanitizeFilename(filename);

  // Split filename and extension
  final dotIndex = safeFilename.lastIndexOf('.');
  final hasExtension = dotIndex > 0 && dotIndex < safeFilename.length - 1;

  final name = hasExtension
      ? safeFilename.substring(0, dotIndex)
      : safeFilename;

  final extension = hasExtension ? safeFilename.substring(dotIndex) : '';

  // Initial file path
  var candidate = '$directoryPath$separator$safeFilename';
  var counter = 1;

  // Add numeric suffix if file already exists
  while (File(candidate).existsSync()) {
    candidate = '$directoryPath$separator${name}_$counter$extension';
    counter++;
  }

  return candidate;
}


// Remove invalid characters from filenames
String sanitizeFilename(String filename) {

  final trimmedFilename = filename.trim();

  // Use default filename if empty
  if (trimmedFilename.isEmpty) {
    return 'classified_images.zip';
  }

  // Replace invalid characters with underscores
  final invalidCharacters = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
  final sanitizedFilename = trimmedFilename.replaceAll(
    invalidCharacters,
    '_',
  );

  return sanitizedFilename.isEmpty
      ? 'classified_images.zip'
      : sanitizedFilename;
}


// Remove duplicate directory entries
List<Directory> uniqueDirectories(List<Directory> directories) {

  final seenPaths = <String>{};
  final uniqueList = <Directory>[];

  for (final directory in directories) {

    // Keep only unique paths
    if (seenPaths.add(directory.path)) {
      uniqueList.add(directory);
    }
  }

  return uniqueList;
}