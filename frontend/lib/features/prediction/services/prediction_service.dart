import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/core/constants/app_variables.dart';
import 'package:cxc/core/services/auth_token_service.dart';
import 'package:cxc/features/prediction/models/prediction_response_model.dart';
import 'package:cxc/core/utils/platform_url.dart';

class BatchZipDownload {
  const BatchZipDownload({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class BatchImageInput {
  const BatchImageInput({required this.bytes, required this.filename});

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
    if (modelName == null || modelName.trim().isEmpty) {
      throw Exception('A model name is required for prediction.');
    }

    final uri = Uri.parse(
      '$baseUrl/predict',
    ).replace(queryParameters: {'model_name': modelName});

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
      return ['cxc201'];
    }
    final uri = Uri.parse('$baseUrl/models');

    try {
      final headers = await getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final models = List<String>.from(decodedData['models']);
        final filteredModels = models
            .where((model) => model.toLowerCase() != 'default')
            .toList();

        return filteredModels.isNotEmpty ? filteredModels : ['cxc201'];
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

  Future<List<PredictionResponseModel>> predictBatchImages(
    String sessionId,
    List<BatchImageInput> files, {
    String? modelName,
  }) async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }
    if (files.isEmpty) {
      return const <PredictionResponseModel>[];
    }

    final uri = Uri.parse('$baseUrl/predict/batch').replace(
      queryParameters: modelName != null && modelName.toLowerCase() != 'default'
          ? {'model_name': modelName}
          : null,
    );

    final request = http.MultipartRequest('POST', uri);
    final headers = await getHeaders();
    request.headers.addAll(headers);
    request.fields['session_id'] = sessionId;

    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          file.bytes,
          filename: file.filename,
          contentType: contentTypeForFilename(file.filename),
        ),
      );
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final decoded = json.decode(responseData) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>;
        return results
            .map(
              (item) => PredictionResponseModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to predict batch images: $responseData');
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
