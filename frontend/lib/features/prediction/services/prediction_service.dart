import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:frontend/core/constants/app_variables.dart';
import 'package:frontend/core/utils/platform_url.dart';
import 'package:frontend/features/prediction/models/prediction_response_model.dart';
import 'package:frontend/core/storage/secure_storage_service.dart';

class PredictionService {
  final String _baseUrl = resolveBackendUrl(BE_URI);
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {
    final String endpoint = modelName != null ? '/predictv2' : '/predict';
    final queryParams = modelName != null ? {'model_name': modelName} : null;
    
    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );
    
    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
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
}
