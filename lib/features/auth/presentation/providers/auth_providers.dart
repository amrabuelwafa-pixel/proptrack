import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/providers/supabase_provider.dart';
import 'package:proptrack/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:proptrack/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:proptrack/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSourceImpl(supabaseClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmailUseCase(repository);
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpWithEmailUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
