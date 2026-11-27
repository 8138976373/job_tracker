sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure(super.message);
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message);
}
