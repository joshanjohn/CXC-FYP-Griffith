import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as dev;

class AuthTokenService {
  static final AuthTokenService _instance = AuthTokenService._internal();
  factory AuthTokenService() => _instance;
  AuthTokenService._internal();

  final _storage = const FlutterSecureStorage();
  final _auth = FirebaseAuth.instance;
  String? _cachedToken;

  /// Initialize the service and start listening to token changes
  Future<void> initialize() async {
    // Load cached token from storage
    _cachedToken = await _storage.read(key: 'firebase_token');
    
    // Listen to token changes and update storage
    _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        final token = await user.getIdToken();
        _cachedToken = token;
        await _storage.write(key: 'firebase_token', value: token);
        dev.log('[AuthTokenService] Token updated and saved');
      } else {
        _cachedToken = null;
        await _storage.delete(key: 'firebase_token');
        dev.log('[AuthTokenService] Token cleared');
      }
    });
  }

  /// Get the current token, preferring cache but falling back to Firebase
  Future<String?> getToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken(forceRefresh);
      _cachedToken = token;
      await _storage.write(key: 'firebase_token', value: token);
      return token;
    }
    
    // Fallback to storage if user object isn't immediately available
    _cachedToken ??= await _storage.read(key: 'firebase_token');
    return _cachedToken;
  }

  /// Clear the token from storage
  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'firebase_token');
    dev.log('[AuthTokenService] Token manually cleared');
  }
}
