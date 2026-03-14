import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthController {
  late String _backendUri;
  final SecureStorageService _storageService = SecureStorageService();

  AuthController() {
    _backendUri = dotenv.get('BE_URI', fallback: "http://localhost:8080");
  }

  Future<AuthResponseModel> login(String username, String password) async {
    final uri = Uri.parse('$_backendUri/auth/login');

    dev.log('[AuthController] POST $uri | username=$username');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      dev.log('[AuthController] Response status: ${response.statusCode}');
      dev.log('[AuthController] Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(responseData);

        dev.log('[AuthController] JWT received!');
        dev.log('[AuthController] Access token: ${authResponse.accessToken}');
        dev.log('[AuthController] Refresh token: ${authResponse.refreshToken}\n');
        dev.log('[AuthController] User id: ${authResponse.user.id}');

        await _storageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        await _storageService.saveUserCredentials(
          userId: authResponse.user.id,
          userName: authResponse.user.username,
        );

        dev.log('[AuthController] Tokens and credentials saved to secure storage.');
        return authResponse;
      } else {
        dev.log('[AuthController] Login failed: ${responseData["detail"]}');
        throw Exception(responseData['detail'] ?? 'Failed to login');
      }
    } catch (e) {
      dev.log('[AuthController] Exception: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<UserModel> signup(String email, String password, String username) async {
    final uri = Uri.parse('$_backendUri/auth/signup');
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(responseData);
      } else {
        throw Exception(responseData['detail'] ?? 'Failed to signup');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
