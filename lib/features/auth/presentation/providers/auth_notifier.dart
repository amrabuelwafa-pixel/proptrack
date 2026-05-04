import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:proptrack/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:proptrack/features/auth/presentation/providers/auth_providers.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  ),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  String? _errorMessage;

  AuthNotifier({
    required this.signInWithGoogleUseCase,
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
