import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<String?> saveDownloadedFile(Uint8List bytes, String filename) async {
  // Convert Uint8List to JSUint8Array
  final jsBytes = bytes.toJS;
  
  // Create a Blob from the bytes
  final blob = web.Blob([jsBytes].toJS);
  
  // Create a URL for the Blob
  final url = web.URL.createObjectURL(blob);
  
  // Create an anchor element and trigger download
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  
  // Cleanup
  web.URL.revokeObjectURL(url);
  
  return filename;
}
