import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) => _run(() => _dataSource.signIn(email: email, password: password));
  @override
  Future<Result<AuthSession>> register({
    required String email,
    required String password,
  }) => _run(() => _dataSource.register(email: email, password: password));

  Future<Result<AuthSession>> _run(
    Future<AuthSession> Function() action,
  ) async {
    try {
      return Success(await action());
    } on ApiException catch (error) {
      return Failure(UnexpectedFailure(error.message));
    } on TypeError {
      return const Failure(
        UnexpectedFailure('The server returned data in an unexpected format.'),
      );
    } on Exception {
      return const Failure(
        UnexpectedFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<AuthSession?> restoreSession() => _dataSource.restoreSession();
  @override
  Future<void> signOut() => _dataSource.signOut();
}
