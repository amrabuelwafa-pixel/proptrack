import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  Future<User> signInWithEmailPassword(String email, String password);
  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  );
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPasswordForEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _supabaseClient.auth.currentUser!;
  }

  @override
  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      emailRedirectTo: 'io.supabase.proptrack://login-callback/',
    );
    return response.user!;
  }

  @override
  Future<User> signInWithGoogle() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'http://localhost:3000',
    );
    return _supabaseClient.auth.currentUser!;
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.proptrack://reset-password/',
    );
  }
}
