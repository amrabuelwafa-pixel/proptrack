import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resetPasswordForEmail(email);
}
