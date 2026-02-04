import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling image selection and camera capture
class ImageService {
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
  Future<bool> checkAndRequestPermissions({required bool forCamera}) async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return true; // Permissions handled differently or not required on these platforms
    }

    if (forCamera) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        return false;
      }
    } else {
      // For Gallery/Photo Library
      final status = Platform.isIOS
          ? await Permission.photos.request()
          : await Permission.storage.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }

  /// Pick image from gallery (works on all platforms)
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
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
  Future<String?> pickImageWithFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        return result.files.single.path;
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
      // Web: use file picker
      return await pickImageWithFilePicker();
    } else if (Platform.isIOS || Platform.isAndroid) {
      // Mobile: check permissions first
      final hasPermission = await checkAndRequestPermissions(
        forCamera: fromCamera,
      );
      if (!hasPermission) {
        throw Exception('Permission denied');
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

    final validExtensions = ['.jpg', '.jpeg', '.png', '.bmp', '.gif', '.webp'];
    return validExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}
