import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/authenticate.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { restoring, signedOut, loading, signedIn, failure }

final class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authenticate, this._repository);
  final Authenticate _authenticate;
  final AuthRepository _repository;
  AuthStatus _status = AuthStatus.restoring;
  AuthSession? _session;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    try {
      _session = await _repository.restoreSession();
    } on Exception {
      await _repository.signOut();
      _session = null;
    }
    _status = _session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) =>
      _submit(() => _authenticate.signIn(email: email, password: password));
  Future<bool> register({required String email, required String password}) =>
      _submit(() => _authenticate.register(email: email, password: password));

  Future<bool> _submit(Future<Result<AuthSession>> Function() action) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    final result = await action();
    result.fold<void>(
      onSuccess: (AuthSession session) {
        _session = session;
        _status = AuthStatus.signedIn;
      },
      onFailure: (AppFailure failure) {
        _errorMessage = failure.message;
        _status = AuthStatus.failure;
      },
    );
    notifyListeners();
    return _status == AuthStatus.signedIn;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _session = null;
    _errorMessage = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}
