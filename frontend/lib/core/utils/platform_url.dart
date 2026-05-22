import 'dart:io';
import 'package:flutter/foundation.dart';

String resolveBackendUrl(String url, {String mobileUrl = ''}) {
  if (kIsWeb) {
    return url;
  }

  final isMobilePlatform = Platform.isAndroid || Platform.isIOS;
  final hasMobileUrl = mobileUrl.isNotEmpty;

  if (isMobilePlatform && hasMobileUrl) {
    return mobileUrl;
  }

  if (Platform.isAndroid &&
      (url.contains('localhost') || url.contains('127.0.0.1'))) {
    return url
        .replaceFirst('localhost', '10.0.2.2')
        .replaceFirst('127.0.0.1', '10.0.2.2');
  }

  return url.replaceFirst('0.0.0.0', 'localhost');
}
