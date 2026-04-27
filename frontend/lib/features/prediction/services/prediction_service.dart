import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:frontend/core/constants/app_variables.dart';
import 'package:frontend/core/utils/platform_url.dart';
import 'package:frontend/features/prediction/models/prediction_response_model.dart';
import 'package:frontend/core/storage/secure_storage_service.dart';

class BatchZipDownload {
  const BatchZipDownload({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class PredictionService {
  final String _baseUrl = resolveBackendUrl(beUri);
  final SecureStorageService _storageService = SecureStorageService();

  MediaType _contentTypeForFilename(String filename) {
    final normalized = filename.toLowerCase();
    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    return MediaType('image', 'jpeg');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    final String endpoint = modelName != null ? '/predictv2' : '/predict';
    final queryParams = modelName != null ? {'model_name': modelName} : null;

    final uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: _contentTypeForFilename(filename),
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseDataString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseDataString);
        return PredictionResponseModel.fromJson(decodedData);
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
    final uri = Uri.parse('$_baseUrl/models');

    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return List<String>.from(decodedData['models']);
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
    final uri = Uri.parse('$_baseUrl/batch/start');
    try {
      final headers = await _getHeaders();
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['session_id'];
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
    final uri = Uri.parse('$_baseUrl/batch/classify').replace(
      queryParameters: modelName != null ? {'model_name': modelName} : null,
    );

    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.fields['session_id'] = sessionId;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: _contentTypeForFilename(filename),
      ),
    );

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return PredictionResponseModel.fromJson(json.decode(responseData));
      } else {
        throw Exception('Failed to classify batch image: $responseData');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<BatchZipDownload> downloadBatchZip(String sessionId) async {
    final uri = Uri.parse('$_baseUrl/batch/download/$sessionId');

    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download batch ZIP: ${response.statusCode} - ${response.body}',
        );
      }

      final filename = _extractFilename(
        response.headers['content-disposition'],
      );
      return BatchZipDownload(bytes: response.bodyBytes, filename: filename);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _extractFilename(String? contentDisposition) {
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
