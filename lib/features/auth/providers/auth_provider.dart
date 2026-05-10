import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSourceImpl(supabaseClient);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return dataSource.authStateChanges;
});

final currentUserProvider = Provider<User?>(
  (ref) {
    final dataSource = ref.watch(authRemoteDataSourceProvider);
    return dataSource.currentUser;
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._dataSource) : super(const AsyncValue.data(null));

  final AuthRemoteDataSource _dataSource;

  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dataSource.signInWithEmailPassword(email, password),
    );
  }

  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dataSource.signUpWithEmailPassword(email, password, fullName),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_dataSource.signInWithGoogle);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_dataSource.signOut);
  }

  Future<void> resetPasswordForEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dataSource.resetPasswordForEmail(email),
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) {
    final dataSource = ref.watch(authRemoteDataSourceProvider);
    return AuthNotifier(dataSource);
  },
);
