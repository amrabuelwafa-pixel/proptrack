import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  Future<Either<Failure, User>> signInWithEmailPassword(String email, String password);
  Future<Either<Failure, User>> signUpWithEmailPassword(String email, String password, String fullName);
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, Unit>> resetPasswordForEmail(String email);
  Future<Either<Failure, Unit>> signOut();
}
