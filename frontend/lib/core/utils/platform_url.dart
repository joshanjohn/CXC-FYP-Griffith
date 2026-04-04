import 'dart:io';
import 'package:flutter/foundation.dart';

String resolveBackendUrl(String url) {
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    if (!kIsWeb && Platform.isAndroid) {
      return url
          .replaceFirst('localhost', '10.0.2.2')
          .replaceFirst('127.0.0.1', '10.0.2.2');
    }
  }
  return url;
}
