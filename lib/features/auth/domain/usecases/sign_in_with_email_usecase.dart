import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call(String email, String password) =>
      _repository.signInWithEmailPassword(email, password);
}
