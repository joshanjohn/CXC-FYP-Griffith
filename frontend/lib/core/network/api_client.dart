import 'dart:convert';
import 'dart:typed_data';
import 'package:frontend/core/constants/app_variables.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  static late String baseUrl = BE_URI;

  static Future<Map<String, dynamic>> predictXRay(
    Uint8List imageBytes,
    String filename,
  ) async {
    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'), // good enough for most x-rays
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
