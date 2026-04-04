import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission check
enum PermissionResult { granted, denied, permanentlyDenied }

/// Service for handling image selection and camera capture
class ImageDatasourceService {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription>? _cameras;

  /// Initialize cameras (call this on app startup for mobile platforms)
  Future<void> initializeCameras() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        debugPrint('Error initializing cameras: $e');
      }
    }
  }

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  /// Check and request permissions (mobile only)
  Future<PermissionResult> checkAndRequestPermissions({
    required bool forCamera,
  }) async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return PermissionResult.granted;
    }

    if (forCamera) {
      final status = await Permission.camera.request();
      return _mapStatusToResult(status);
    } else {
      if (Platform.isAndroid) {

        // Try requesting photos first
        var status = await Permission.photos.request();

        if (status.isGranted) {
          return PermissionResult.granted;
        }

        // if denied or not supported (old Android), try storage
        if (status.isDenied || status.isLimited) {
          status = await Permission.storage.request();
        }

        return _mapStatusToResult(status);
      } else {
        // iOS or other mobile
        final status =
            await (Platform.isIOS ? Permission.photos : Permission.storage)
                .request();
        return _mapStatusToResult(status);
      }
    }
  }

  PermissionResult _mapStatusToResult(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  /// Pick image from gallery (works on all platforms)
  /// Allowed extensions for all platforms
  static const _allowedExtensions = ['jpg', 'jpeg', 'png'];

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return null;
      final ext = image.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        debugPrint('Unsupported format: $ext. Only JPG and PNG are allowed.');
        return null;
      }
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Capture image from camera (mobile only)
  Future<XFile?> captureImageFromCamera() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      debugPrint('Camera capture not supported on this platform');
      return null;
    }

    try {
      final XFile? image = await _picker.pickImage(
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

  /// Pick image using file picker (alternative for desktop/web)
  Future<dynamic> pickImageWithFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: kIsWeb, // Crucial for Web to get bytes
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes == null) {
            debugPrint('Error: No bytes available for picked file on Web');
            return null;
          }
          return bytes; // Returns Uint8List
        }
        return result.files.single.path; // Returns String (path)
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Platform-aware image selection
  /// Uses appropriate method based on platform
  Future<dynamic> selectImage({bool fromCamera = false}) async {
    if (kIsWeb) {
      // Web: use file picker and return bytes
      return await pickImageWithFilePicker();
    } else if (Platform.isIOS || Platform.isAndroid) {
      // Mobile: check permissions first
      final result = await checkAndRequestPermissions(forCamera: fromCamera);

      if (result == PermissionResult.permanentlyDenied) {
        throw Exception('PERMISSION_PERMANENTLY_DENIED');
      } else if (result == PermissionResult.denied) {
        throw Exception('PERMISSION_DENIED');
      }

      // Mobile: use image picker with camera option
      if (fromCamera) {
        return await captureImageFromCamera();
      } else {
        return await pickImageFromGallery();
      }
    } else {
      // Desktop: use file picker
      return await pickImageWithFilePicker();
    }
  }

  /// Validate if the file is an image
  bool isValidImageFile(String? path) {
    if (path == null) return false;

    final validExtensions = ['.jpg', '.jpeg', '.png'];
    return validExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}
