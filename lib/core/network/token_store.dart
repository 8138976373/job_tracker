abstract interface class TokenStore {
  Future<String?> readToken();
  Future<String?> readUserId();
  Future<String?> readEmail();
  Future<String?> readExpiry();
  Future<void> writeSession({
    required String token,
    required String userId,
    required String email,
    required String expiresAt,
  });
  Future<void> clear();
}
