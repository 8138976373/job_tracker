import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

final class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';
  static const _expiryKey = 'token_expires_at';

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  @override
  Future<String?> readUserId() => _storage.read(key: _userIdKey);
  @override
  Future<String?> readEmail() => _storage.read(key: _emailKey);
  @override
  Future<String?> readExpiry() => _storage.read(key: _expiryKey);

  @override
  Future<void> writeSession({
    required String token,
    required String userId,
    required String email,
    required String expiresAt,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _expiryKey, value: expiresAt);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _expiryKey),
    ]);
  }
}
