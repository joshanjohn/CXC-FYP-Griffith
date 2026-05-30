import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cxc/core/constants/app_variables.dart';
import 'package:cxc/features/auth/services/auth_token_service.dart';
import 'package:cxc/core/utils/platform_url.dart';
import 'package:cxc/features/prediction/models/model_response_model.dart';

class ModelService {
  final String baseUrl = resolveBackendUrl(beUri, mobileUrl: beUriMobile);

  Future<Map<String, String>> getHeaders() async {
    final token = await AuthTokenService().getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<ModelResponseModel> getAvailableModels() async {
    if (baseUrl.isEmpty) {
      return ModelResponseModel(models: const ['cxc201']);
    }
    final uri = Uri.parse('$baseUrl/models');

    try {
      final headers = await getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        return ModelResponseModel.fromJson(decodedData);
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
}
