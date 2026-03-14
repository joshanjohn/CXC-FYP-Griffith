import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {

  static FlutterSecureStorage _buildStorage() {
    // web configure 
    if (kIsWeb) {
      return const FlutterSecureStorage(
        webOptions: WebOptions(
          dbName: 'cxc_secure_storage',
          publicKey: 'cxc_storage_key',
        ),
      );
    }
    // TODO: need to configure other platforms 
    // all other platforms 
    return const FlutterSecureStorage();
  }

  final _storage = _buildStorage(); 

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  Future<void> saveUserCredentials({
    required String userId,
    required String userName,
  }) async {
    // writing id and username
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserName, value: userName);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<Map<String, String?>> getUserData() async {
    final userId = await _storage.read(key: _keyUserId);
    final userName = await _storage.read(key: _keyUserName);
    return {
      'userId': userId,
      'userName': userName,
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
