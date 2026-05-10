import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:proptrack/features/auth/presentation/providers/auth_providers.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error, signupPending }

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
    signInWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
    signUpWithEmailUseCase: ref.watch(signUpWithEmailUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  ),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SignOutUseCase signOutUseCase;
  String? _errorMessage;

  AuthNotifier({
    required this.signInWithGoogleUseCase,
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.resetPasswordUseCase,
    required this.signOutUseCase,
  }) : super(AuthState.idle);

  String? get errorMessage => _errorMessage;

  Future<void> signInWithGoogle() async {
    state = AuthState.loading;
    final result = await signInWithGoogleUseCase.call();
    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        state = AuthState.error;
      },
      (_) {
        _errorMessage = null;
        state = AuthState.authenticated;
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading;
    final result = await signInWithEmailUseCase.call(email, password);
    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        state = AuthState.error;
      },
      (_) {
        _errorMessage = null;
        state = AuthState.authenticated;
      },
    );
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    state = AuthState.loading;
    final result = await signUpWithEmailUseCase.call(email, password, fullName);
    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        state = AuthState.error;
      },
      (_) {
        _errorMessage = null;
        state = AuthState.signupPending;
      },
    );
  }

  Future<void> resetPassword(String email) async {
    state = AuthState.loading;
    final result = await resetPasswordUseCase.call(email);
    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        state = AuthState.error;
      },
      (_) {
        _errorMessage = null;
        state = AuthState.idle;
      },
    );
  }

  Future<void> signOut() async {
    state = AuthState.loading;
    final result = await signOutUseCase.call();
    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        state = AuthState.error;
      },
      (_) {
        _errorMessage = null;
        state = AuthState.unauthenticated;
      },
    );
  }

  void resetState() {
    state = AuthState.idle;
    _errorMessage = null;
  }
}
