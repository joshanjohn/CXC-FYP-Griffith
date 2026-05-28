import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/core/constants/app_variables.dart';
import 'package:cxc/features/auth/services/auth_token_service.dart';
import 'package:cxc/core/utils/platform_url.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:http/http.dart' as http;

class DocsService {
  final String baseUrl = resolveBackendUrl(beUri, mobileUrl: beUriMobile);

  Future<Map<String, String>> getHeaders() async {
    final token = await AuthTokenService().getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<List<ModelInfo>> getModelsInfo() async {
    if (baseUrl.isEmpty) {
      return const [];
    }

    final uri = Uri.parse('$baseUrl/models-info');

    try {
      final headers = await getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        final models = decodedData['models'] as List<dynamic>;
        return models
            .map((item) => ModelInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Session expired. Please log in again.');
      }

      throw Exception(
        'Failed to fetch model info: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
