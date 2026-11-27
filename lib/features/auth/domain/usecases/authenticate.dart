import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class Authenticate {
  const Authenticate(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) {
    final failure = _validate(email, password);
    if (failure != null) return Future.value(Failure(failure));
    return _repository.signIn(email: email.trim(), password: password);
  }

  Future<Result<AuthSession>> register({
    required String email,
    required String password,
  }) {
    final failure = _validate(email, password);
    if (failure != null) return Future.value(Failure(failure));
    return _repository.register(email: email.trim(), password: password);
  }

  ValidationFailure? _validate(String email, String password) {
    if (!email.contains('@') || email.trim().length > 320)
      return const ValidationFailure('Enter a valid email address.');
    if (password.length < 6 || password.length > 72)
      return const ValidationFailure('Password must be 6 to 72 characters.');
    return null;
  }
}
