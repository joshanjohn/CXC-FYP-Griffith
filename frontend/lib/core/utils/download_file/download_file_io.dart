import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveDownloadedFile(Uint8List bytes, String filename) async {
  final safeFilename = filename.trim().isEmpty
      ? 'classified_images.zip'
      : sanitizeFilename(filename);

  if (Platform.isAndroid || Platform.isIOS) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save classified images ZIP',
      fileName: safeFilename,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: bytes,
    );
  }

  final candidateDirectories = await resolveDownloadDirectories();

  Object? lastError;
  for (final directory in candidateDirectories) {
    try {
      await directory.create(recursive: true);
      final filePath = buildUniquePath(directory.path, safeFilename);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (error) {
      lastError = error;
    }
  }

  if (lastError != null) {
    throw Exception('Unable to save downloaded file: $lastError');
  }

  throw Exception('Unable to save downloaded file.');
}

Future<List<Directory>> resolveDownloadDirectories() async {
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

    directories.add(await getApplicationDocumentsDirectory());
    directories.add(await getTemporaryDirectory());
    return uniqueDirectories(directories);
  }

  if (Platform.isIOS) {
    return uniqueDirectories([
      await getApplicationDocumentsDirectory(),
      await getApplicationSupportDirectory(),
      await getTemporaryDirectory(),
    ]);
  }

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

  return [await getTemporaryDirectory()];
}

String buildUniquePath(String directoryPath, String filename) {
  final separator = Platform.pathSeparator;
  final safeFilename = filename.trim().isEmpty
      ? 'classified_images.zip'
      : sanitizeFilename(filename);
  final dotIndex = safeFilename.lastIndexOf('.');
  final hasExtension = dotIndex > 0 && dotIndex < safeFilename.length - 1;
  final name = hasExtension
      ? safeFilename.substring(0, dotIndex)
      : safeFilename;
  final extension = hasExtension ? safeFilename.substring(dotIndex) : '';
  var candidate = '$directoryPath$separator$safeFilename';
  var counter = 1;

  while (File(candidate).existsSync()) {
    candidate = '$directoryPath$separator${name}_$counter$extension';
    counter++;
  }

  return candidate;
}

String sanitizeFilename(String filename) {
  final trimmedFilename = filename.trim();
  if (trimmedFilename.isEmpty) {
    return 'classified_images.zip';
  }

  final invalidCharacters = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
  final sanitizedFilename = trimmedFilename.replaceAll(invalidCharacters, '_');
  return sanitizedFilename.isEmpty
      ? 'classified_images.zip'
      : sanitizedFilename;
}

List<Directory> uniqueDirectories(List<Directory> directories) {
  final seenPaths = <String>{};
  final uniqueList = <Directory>[];

  for (final directory in directories) {
    if (seenPaths.add(directory.path)) {
      uniqueList.add(directory);
    }
  }

  return uniqueList;
}
