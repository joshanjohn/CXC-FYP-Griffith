import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as dev;

class AuthTokenService {
  static final AuthTokenService instance = AuthTokenService._internal();
  factory AuthTokenService() => instance;
  AuthTokenService._internal();

  final storage = const FlutterSecureStorage();
  final auth = FirebaseAuth.instance;
  String? cachedToken;

  /// Initialize the service and start listening to token changes
  Future<void> initialize() async {
    // Load cached token from storage
    cachedToken = await storage.read(key: 'firebase_token');
    
    // Listen to token changes and update storage
    auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        final token = await user.getIdToken();
        cachedToken = token;
        await storage.write(key: 'firebase_token', value: token);
        dev.log('[AuthTokenService] Token updated and saved');
      } else {
        cachedToken = null;
        await storage.delete(key: 'firebase_token');
        dev.log('[AuthTokenService] Token cleared');
      }
    });
  }

  /// Get the current token, preferring cache but falling back to Firebase
  Future<String?> getToken({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken(forceRefresh);
      cachedToken = token;
      await storage.write(key: 'firebase_token', value: token);
      return token;
    }
    
    // Fallback to storage if user object isn't immediately available
    cachedToken ??= await storage.read(key: 'firebase_token');
    return cachedToken;
  }

  /// Clear the token from storage
  Future<void> clearToken() async {
    cachedToken = null;
    await storage.delete(key: 'firebase_token');
    dev.log('[AuthTokenService] Token manually cleared');
  }
}
