import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult {
  granted, // Permission granted
  denied, // Permission denied by user
  permanentlyDenied,  // Permission permanently denied by user
}

class ImageDatasourceService {
  // Image picker instance for camera and gallery access
  final ImagePicker picker = ImagePicker();

  // Cached list of available device cameras
  List<CameraDescription>? _cameras;

  Future<void> initializeCameras() async {
    // Camera initialization is only needed on mobile devices
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
        // Retrieve available cameras
        _cameras = await availableCameras();
      } catch (e) {
        debugPrint('Error initializing cameras: $e');
      }
    }
  }

  // Return available cameras
  List<CameraDescription>? get cameras => _cameras;

  Future<PermissionResult> checkAndRequestPermissions({
    required bool forCamera,
  }) async {
    // Web and desktop platforms do not require runtime permissions
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return PermissionResult.granted;
    }

    if (forCamera) {
      // Request camera permission
      final status = await Permission.camera.request();
      return _mapStatusToResult(status);
    } else {
      // Request gallery/storage permission
      if (Platform.isAndroid) {
        var status = await Permission.photos.request();

        if (status.isGranted) {
          return PermissionResult.granted;
        }

        // Fallback to storage permission if needed
        if (status.isDenied || status.isLimited) {
          status = await Permission.storage.request();
        }

        return _mapStatusToResult(status);
      } else {
        // iOS photo library permission
        final status =
            await (Platform.isIOS
                    ? Permission.photos
                    : Permission.storage)
                .request();

        return _mapStatusToResult(status);
      }
    }
  }

  PermissionResult _mapStatusToResult(PermissionStatus status) {
    // Convert permission package status to app-specific result
    if (status.isGranted || status.isLimited) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  // Supported image formats
  static const _allowedExtensions = ['jpg', 'jpeg', 'png'];

  Future<XFile?> pickImageFromGallery() async {
    try {
      // Open gallery and select an image
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Validate file extension
      final ext = image.path.split('.').last.toLowerCase();

      if (!_allowedExtensions.contains(ext)) {
        debugPrint(
          'Unsupported format: $ext. Only JPG and PNG are allowed.',
        );
        return null;
      }

      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<XFile?> captureImageFromCamera() async {
    // Camera capture is only supported on mobile devices
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      debugPrint('Camera capture not supported on this platform');
      return null;
    }

    try {
      // Open camera and capture image
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      debugPrint('Error capturing image from camera: $e');
      return null;
    }
  }

  Future<dynamic> pickImageWithFilePicker() async {
    try {
      // Open file picker for desktop and web platforms
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png'],
            allowMultiple: false,

            // Load bytes directly for web and macOS
            withData: kIsWeb || (!kIsWeb && Platform.isMacOS),
          );

      if (result != null) {
        // Return file bytes if available
        if (result.files.single.bytes != null) {
          return result.files.single.bytes;
        }

        // Otherwise return file path
        return result.files.single.path;
      }

      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  Future<dynamic> selectImage({bool fromCamera = false}) async {
    // Use file picker on web
    if (kIsWeb) {
      return await pickImageWithFilePicker();
    }

    // Use gallery or camera on mobile
    else if (Platform.isIOS || Platform.isAndroid) {
      final result = await checkAndRequestPermissions(
        forCamera: fromCamera,
      );

      // Handle permanently denied permissions
      if (result == PermissionResult.permanentlyDenied) {
        throw Exception('PERMISSION_PERMANENTLY_DENIED');
      }

      // Handle denied permissions
      else if (result == PermissionResult.denied) {
        throw Exception('PERMISSION_DENIED');
      }

      // Capture image using camera
      if (fromCamera) {
        return await captureImageFromCamera();
      }

      // Select image from gallery
      return await pickImageFromGallery();
    }

    // Use file picker on desktop platforms
    else {
      return await pickImageWithFilePicker();
    }
  }

  bool isValidImageFile(String? path) {
    // Ensure path exists
    if (path == null) return false;

    // Supported image extensions
    final validExtensions = ['.jpg', '.jpeg', '.png'];

    // Validate file extension
    return validExtensions.any(
      (ext) => path.toLowerCase().endsWith(ext),
    );
  }
}