import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/core/constants/app_variables.dart';
import 'package:cxc/features/auth/services/auth_token_service.dart';
import 'package:cxc/features/prediction/models/prediction_response_model.dart';
import 'package:cxc/core/utils/platform_url.dart';

// Stores downloaded ZIP file data and filename
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

  // Backend API URL
  final String baseUrl = resolveBackendUrl(beUri, mobileUrl: beUriMobile);

  // Determine image MIME type from filename
  MediaType contentTypeForFilename(String filename) {
    final normalized = filename.toLowerCase();

    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    return MediaType('image', 'jpeg');
  }

  // Get authorization headers with Firebase token
  Future<Map<String, String>> getHeaders() async {
    final token = await AuthTokenService().getToken();

    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Send a single X-ray image for prediction
  Future<PredictionResponseModel> predictXRay(
    Uint8List imageBytes,
    String filename, {
    String? modelName,
  }) async {

    // Validate configuration
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured');
    }

    // Ensure a model is selected
    if (modelName == null || modelName.trim().isEmpty) {
      throw Exception('A model name is required for prediction.');
    }

    // Build prediction endpoint URL
    final uri = Uri.parse(
      '$baseUrl/predict',
    ).replace(queryParameters: {'model_name': modelName});

    final request = http.MultipartRequest('POST', uri);

    // Attach authentication headers
    final headers = await getHeaders();
    request.headers.addAll(headers);

    // Create image file payload
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: contentTypeForFilename(filename),
    );

    request.files.add(multipartFile);

    try {

      // Send prediction request
      final response = await request.send();
      final responseDataString = await response.stream.bytesToString();

      // Parse successful response
      if (response.statusCode == 200) {
        final decodedData = json.decode(responseDataString);
        return PredictionResponseModel.fromJson(decodedData);

      // Handle expired authentication
      } else if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');

      // Handle API errors
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - $responseDataString',
        );
      }
    } catch (e) {

      // Handle network failures
      throw Exception('Network error: $e');
    }
  }

  // Create a new batch prediction session
  Future<String> startBatchSession() async {

    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    final uri = Uri.parse('$baseUrl/batch/start');

    try {
      final headers = await getHeaders();

      // Request new session ID
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

  // Upload multiple images for batch prediction
  Future<List<PredictionResponseModel>> predictBatchImages(
    String sessionId,
    List<BatchImageInput> files, {
    String? modelName,
  }) async {

    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    // Return empty result if no files selected
    if (files.isEmpty) {
      return const <PredictionResponseModel>[];
    }

    // Build batch prediction URL
    final uri = Uri.parse('$baseUrl/predict/batch').replace(
      queryParameters: modelName != null && modelName.toLowerCase() != 'default'
          ? {'model_name': modelName}
          : null,
    );

    final request = http.MultipartRequest('POST', uri);

    // Add authentication headers
    final headers = await getHeaders();
    request.headers.addAll(headers);

    // Attach session ID
    request.fields['session_id'] = sessionId;

    // Add all image files
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

      // Send batch prediction request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {

        // Convert prediction results into model objects
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

  // Download classified images as a ZIP file
  Future<BatchZipDownload> downloadBatchZip(String sessionId) async {

    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    final uri = Uri.parse('$baseUrl/batch/download/$sessionId');

    try {
      final headers = await getHeaders();

      // Request ZIP file from server
      final response = await http.get(uri, headers: headers);

      // Handle expired authentication
      if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      }

      // Handle download failures
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download batch ZIP: ${response.statusCode} - ${response.body}',
        );
      }

      // Extract filename from response headers
      final filename = extractFilename(
        response.headers['content-disposition'],
      );

      return BatchZipDownload(
        bytes: response.bodyBytes,
        filename: filename,
      );

    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Extract filename from Content-Disposition header
  String extractFilename(String? contentDisposition) {

    if (contentDisposition == null || contentDisposition.isEmpty) {
      return 'classified_images.zip';
    }

    // Handle UTF-8 encoded filenames
    final filenameStarMatch = RegExp(
      r'''filename\*=UTF-8''([^;]+)''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    if (filenameStarMatch != null) {
      return Uri.decodeComponent(filenameStarMatch.group(1)!);
    }

    // Handle standard filenames
    final filenameMatch = RegExp(
      r'''filename="?([^"]+)"?''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    return filenameMatch?.group(1) ?? 'classified_images.zip';
  }
}