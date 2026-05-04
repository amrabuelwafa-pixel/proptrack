import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      final message = e is AuthException ? e.message : e.toString();
      return Left(AuthFailure(message));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final user = await _remoteDataSource.signInWithApple();
      return Right(user);
    } catch (e) {
      final message = e is AuthException ? e.message : e.toString();
      return Left(AuthFailure(message));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } catch (e) {
      final message = e is AuthException ? e.message : e.toString();
      return Left(AuthFailure(message));
    }
  }

  @override
  Stream<AuthState> get authStateChanges =>
      _remoteDataSource.authStateChanges;

  @override
  User? get currentUser => _remoteDataSource.currentUser;
}
