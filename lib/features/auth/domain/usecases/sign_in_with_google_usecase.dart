import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<Either<Failure, User>> call() => _authRepository.signInWithGoogle();
}
