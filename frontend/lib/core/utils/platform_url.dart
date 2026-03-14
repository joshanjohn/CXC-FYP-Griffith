import 'dart:io';
import 'package:flutter/foundation.dart';

/// Rewrites localhost/127.0.0.1 URLs to the correct host for the current platform.
///
/// - Android emulator → 10.0.2.2  (routes to host machine)
/// - iOS simulator / macOS / Web → keep as-is
String resolveBackendUrl(String url) {
  if (!kIsWeb && Platform.isAndroid) {
    return url
        .replaceFirst('localhost', '10.0.2.2')
        .replaceFirst('127.0.0.1', '10.0.2.2');
  }
  return url;
}
