import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_store.dart';
import '../../domain/entities/auth_session.dart';

final class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  }) : _apiClient = apiClient,
       _tokenStore = tokenStore;
  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) => _authenticate('login', email, password);
  Future<AuthSession> register({
    required String email,
    required String password,
  }) => _authenticate('register', email, password);

  Future<AuthSession> _authenticate(
    String action,
    String email,
    String password,
  ) async {
    final response = await _apiClient.post(
      'auth/$action',
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;
    final session = AuthSession(
      userId: response['id'] as String,
      email: response['email'] as String,
      accessToken: response['accessToken'] as String,
      expiresAt: DateTime.parse(response['expiresAt'] as String).toUtc(),
    );
    await _tokenStore.writeSession(
      token: session.accessToken,
      userId: session.userId,
      email: session.email,
      expiresAt: session.expiresAt.toIso8601String(),
    );
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final values = await Future.wait([
      _tokenStore.readToken(),
      _tokenStore.readUserId(),
      _tokenStore.readEmail(),
      _tokenStore.readExpiry(),
    ]);
    if (values.any((value) => value == null)) return null;
    final expiry = DateTime.tryParse(values[3]!);
    if (expiry == null ||
        !expiry.isAfter(
          DateTime.now().toUtc().add(const Duration(seconds: 30)),
        )) {
      await _tokenStore.clear();
      return null;
    }
    return AuthSession(
      userId: values[1]!,
      email: values[2]!,
      accessToken: values[0]!,
      expiresAt: expiry,
    );
  }

  Future<void> signOut() => _tokenStore.clear();
}
