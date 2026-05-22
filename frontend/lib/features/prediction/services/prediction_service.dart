import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/core/constants/app_variables.dart';
import 'package:frontend/core/services/auth_token_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:frontend/core/utils/platform_url.dart';
import 'package:frontend/features/prediction/models/prediction_response_model.dart';

class BatchZipDownload {
  const BatchZipDownload({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class PredictionService {
  final String baseUrl = resolveBackendUrl(beUri, mobileUrl: beUriMobile);

  MediaType contentTypeForFilename(String filename) {
    final normalized = filename.toLowerCase();
    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    return MediaType('image', 'jpeg');
  }

  Future<Map<String, String>> getHeaders() async {
    // firebase token
    final token = await AuthTokenService().getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configurederror');
    }

    final bool isDefault =
        modelName == null || modelName.toLowerCase() == 'default';
    final String endpoint = isDefault ? '/predict' : '/predictv2';
    final queryParams = isDefault ? null : {'model_name': modelName};

    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    final request = http.MultipartRequest('POST', uri);
    final headers = await getHeaders();
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: contentTypeForFilename(filename),
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseDataString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseDataString);
        return PredictionResponseModel.fromJson(decodedData);
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - $responseDataString',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<String>> getAvailableModels() async {
    if (baseUrl.isEmpty) {
      return ['default', 'cxc105']; // Fallback
    }
    final uri = Uri.parse('$baseUrl/models');

    try {
      final headers = await getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return List<String>.from(decodedData['models']);
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to fetch models: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> startBatchSession() async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }
    final uri = Uri.parse('$baseUrl/batch/start');
    try {
      final headers = await getHeaders();
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['session_id'];
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to start batch session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<PredictionResponseModel> classifyBatchImage(
    String sessionId,
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }
    final uri = Uri.parse('$baseUrl/batch/classify').replace(
      queryParameters: modelName != null && modelName.toLowerCase() != 'default'
          ? {'model_name': modelName}
          : null,
    );

    final request = http.MultipartRequest('POST', uri);
    final headers = await getHeaders();
    request.headers.addAll(headers);
    request.fields['session_id'] = sessionId;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: contentTypeForFilename(filename),
      ),
    );

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return PredictionResponseModel.fromJson(json.decode(responseData));
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to classify batch image: $responseData');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<BatchZipDownload> downloadBatchZip(String sessionId) async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }
    final uri = Uri.parse('$baseUrl/batch/download/$sessionId');

    try {
      final headers = await getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download batch ZIP: ${response.statusCode} - ${response.body}',
        );
      }

      final filename = extractFilename(response.headers['content-disposition']);
      return BatchZipDownload(bytes: response.bodyBytes, filename: filename);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String extractFilename(String? contentDisposition) {
    if (contentDisposition == null || contentDisposition.isEmpty) {
      return 'classified_images.zip';
    }

    final filenameStarMatch = RegExp(
      r'''filename\*=UTF-8''([^;]+)''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    if (filenameStarMatch != null) {
      return Uri.decodeComponent(filenameStarMatch.group(1)!);
    }

    final filenameMatch = RegExp(
      r'''filename="?([^"]+)"?''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    return filenameMatch?.group(1) ?? 'classified_images.zip';
  }
}
