import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/core/constants/app_variables.dart';
import 'package:cxc/features/auth/services/auth_token_service.dart';
import 'package:cxc/core/utils/platform_url.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:http/http.dart' as http;

class DocsService {
  // Backend API base URL
  final String baseUrl = resolveBackendUrl(beUri, mobileUrl: beUriMobile);

  Future<Map<String, String>> getHeaders() async {
    // Retrieve authentication token
    final token = await AuthTokenService().getToken();
    // Add Authorization header when token is available
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<List<ModelInfo>> getModelsInfo() async {
    // Return empty list if backend URL is unavailable
    if (baseUrl.isEmpty) {
      return const [];
    }

    // Build API endpoint URL
    final uri = Uri.parse('$baseUrl/models-info');

    try {
      // Get request headers
      final headers = await getHeaders();
      // Send GET request to fetch model information
      final response = await http.get(uri, headers: headers);

      // Process successful response
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        // Extract model list from response
        final models = decodedData['models'] as List<dynamic>;
        // Convert JSON objects into ModelInfo objects
        return models
            .map((item) => ModelInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Handle expired or invalid authentication
      if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      }

      // Handle other API errors
      throw Exception(
        'Failed to fetch model info: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      // Handle network and unexpected errors
      throw Exception('Network error: $e');
    }
  }
}
