/// Domain Failure abstractions for Clean Architecture error handling
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}
