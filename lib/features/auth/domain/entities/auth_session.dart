final class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.expiresAt,
  });
  final String userId;
  final String email;
  final String accessToken;
  final DateTime expiresAt;
}
