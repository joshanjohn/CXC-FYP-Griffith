import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as dev;

// firebase token service 
class AuthTokenService {

  // Singleton instance
  static final AuthTokenService instance = AuthTokenService._internal();

  // Factory constructor returns the same instance
  factory AuthTokenService() => instance;

  // Private constructor
  AuthTokenService._internal();

  // Secure storage for persisting tokens
  final storage = const FlutterSecureStorage();

  // Firebase authentication instance
  final auth = FirebaseAuth.instance;

  // In-memory token cache
  String? cachedToken;

  // Initialize token service and listen for token changes
  Future<void> initialize() async {

    // Load saved token from secure storage
    cachedToken = await storage.read(key: 'firebase_token');

    // Listen for login, logout, and token refresh events
    auth.idTokenChanges().listen((User? user) async {

      if (user != null) {
        // Get latest Firebase ID token
        final token = await user.getIdToken();

        // Update cache and secure storage
        cachedToken = token;
        await storage.write(key: 'firebase_token', value: token);

        dev.log('[AuthTokenService] Token updated and saved');
      } else {
        // Clear token when user logs out
        cachedToken = null;
        await storage.delete(key: 'firebase_token');

        dev.log('[AuthTokenService] Token cleared');
      }
    });
  }

  // Retrieve the current Firebase token
  Future<String?> getToken({bool forceRefresh = false}) async {

    final user = auth.currentUser;

    if (user != null) {

      // Get latest token from Firebase
      final token = await user.getIdToken(forceRefresh);

      // Update cache and storage
      cachedToken = token;
      await storage.write(key: 'firebase_token', value: token);

      return token;
    }

    // Fallback to stored token if user object is unavailable
    cachedToken ??= await storage.read(key: 'firebase_token');

    return cachedToken;
  }

  // Remove token from memory and secure storage
  Future<void> clearToken() async {

    cachedToken = null;
    await storage.delete(key: 'firebase_token');

    dev.log('[AuthTokenService] Token manually cleared');
  }
}